#!/usr/bin/env ruby
# frozen_string_literal: true

# Configures iOS flavors (dev / staging / production) in ios/Runner.xcodeproj.
#
#   ruby tool/configure_ios_flavors.rb      # run from khmer_calendar_app/
#
# Idempotent: safe to re-run (e.g. after `flutter create .` regenerates files).
# Requires the `xcodeproj` gem (ships with CocoaPods).
#
# What it does:
#   1. Creates (if missing) the xcconfig files:
#        ios/Flutter/AppIdentity.xcconfig      <- base bundle id (ONE place)
#        ios/Flutter/Flavors/<flavor>.xcconfig <- suffix, display name, ATS flag
#   2. Creates build configurations Debug-<flavor>, Release-<flavor>,
#      Profile-<flavor> for the project and every target, cloned from the
#      template's Debug/Release/Profile, then removes the flavorless ones.
#      Project-level configs use Flavors/<flavor>.xcconfig as their base
#      configuration (inherited by all targets); the Runner target keeps
#      Flutter's Debug/Release.xcconfig (which include Generated.xcconfig).
#   3. Sets PRODUCT_BUNDLE_IDENTIFIER to $(APP_BUNDLE_ID_BASE)$(APP_BUNDLE_ID_SUFFIX)
#      and Info.plist CFBundleDisplayName to $(APP_DISPLAY_NAME).
#   4. Adds a "Dev ATS exception" build phase that allows plain HTTP to
#      localhost ONLY when APP_ALLOW_LOCAL_HTTP = YES (dev flavor).
#   5. Writes shared schemes `dev`, `staging`, `production` and removes the
#      flavorless `Runner` scheme.

require 'fileutils'
require 'xcodeproj'

FLAVORS = {
  'dev' => { suffix: '.dev', display_name: 'Khmer Calendar Dev', allow_local_http: 'YES' },
  'staging' => { suffix: '.staging', display_name: 'Khmer Calendar Stg', allow_local_http: 'NO' },
  'production' => { suffix: '', display_name: 'Khmer Calendar', allow_local_http: 'NO' },
}.freeze

BASE_BUNDLE_ID = 'com.example.khmercalendar'
BUILD_TYPES = %w[Debug Release Profile].freeze
ATS_PHASE_NAME = 'Dev ATS exception'

APP_ROOT = File.expand_path('..', __dir__)
IOS_DIR = File.join(APP_ROOT, 'ios')
PROJECT_PATH = File.join(IOS_DIR, 'Runner.xcodeproj')
FLUTTER_DIR = File.join(IOS_DIR, 'Flutter')
FLAVOR_XCCONFIG_DIR = File.join(FLUTTER_DIR, 'Flavors')
SCHEMES_DIR = File.join(PROJECT_PATH, 'xcshareddata', 'xcschemes')
INFO_PLIST = File.join(IOS_DIR, 'Runner', 'Info.plist')

def write_unless_exists(path, content)
  if File.exist?(path)
    puts "  keep   #{path.delete_prefix("#{APP_ROOT}/")}"
  else
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
    puts "  create #{path.delete_prefix("#{APP_ROOT}/")}"
  end
end

# --- 1. xcconfig files --------------------------------------------------------
puts 'xcconfig files'
write_unless_exists(File.join(FLUTTER_DIR, 'AppIdentity.xcconfig'), <<~XCCONFIG)
  // App identity — the ONE place to change the iOS bundle identifier before a
  // store release. Flavors append APP_BUNDLE_ID_SUFFIX (see Flavors/*.xcconfig).
  APP_BUNDLE_ID_BASE = #{BASE_BUNDLE_ID}
XCCONFIG

FLAVORS.each do |flavor, cfg|
  write_unless_exists(File.join(FLAVOR_XCCONFIG_DIR, "#{flavor}.xcconfig"), <<~XCCONFIG)
    // #{flavor} flavor. Used as the PROJECT-level base configuration of
    // Debug-#{flavor} / Release-#{flavor} / Profile-#{flavor}.
    #include "../AppIdentity.xcconfig"

    APP_FLAVOR = #{flavor}
    APP_BUNDLE_ID_SUFFIX = #{cfg[:suffix]}
    APP_DISPLAY_NAME = #{cfg[:display_name]}
    // YES only for dev: lets the app call http://localhost (ATS exception).
    APP_ALLOW_LOCAL_HTTP = #{cfg[:allow_local_http]}
  XCCONFIG
end

# --- 2. build configurations -------------------------------------------------
project = Xcodeproj::Project.open(PROJECT_PATH)
flutter_group = project.main_group.children.find { |g| g.display_name == 'Flutter' } ||
                project.main_group.new_group('Flutter')

flavor_refs = FLAVORS.keys.to_h do |flavor|
  abs = File.join(FLAVOR_XCCONFIG_DIR, "#{flavor}.xcconfig")
  ref = flutter_group.files.find { |f| f.real_path.to_s == abs } || flutter_group.new_reference(abs)
  [flavor, ref]
end
identity_abs = File.join(FLUTTER_DIR, 'AppIdentity.xcconfig')
flutter_group.files.find { |f| f.real_path.to_s == identity_abs } || flutter_group.new_reference(identity_abs)

def deep_copy(settings)
  Marshal.load(Marshal.dump(settings))
end

# Clones Debug/Release/Profile into <type>-<flavor>; returns the config list.
def ensure_flavor_configs(project, config_list, owner_name)
  BUILD_TYPES.each do |type|
    template = config_list.build_configurations.find { |c| c.name == type } ||
               config_list.build_configurations.find { |c| c.name == "#{type}-dev" }
    raise "No #{type} template configuration in #{owner_name}" unless template

    FLAVORS.each_key do |flavor|
      name = "#{type}-#{flavor}"
      next if config_list.build_configurations.any? { |c| c.name == name }

      config = project.new(Xcodeproj::Project::Object::XCBuildConfiguration)
      config.name = name
      config.build_settings = deep_copy(template.build_settings)
      config.base_configuration_reference = template.base_configuration_reference
      config_list.build_configurations << config
      puts "  create #{owner_name}: #{name}"
    end
  end
  # Remove the flavorless configurations so every build must pick a flavor.
  config_list.build_configurations.select { |c| BUILD_TYPES.include?(c.name) }.each do |c|
    puts "  remove #{owner_name}: #{c.name}"
    c.remove_from_project
  end
  config_list.default_configuration_name = 'Release-production'
end

puts 'build configurations'
ensure_flavor_configs(project, project.build_configuration_list, 'project')
project.build_configuration_list.build_configurations.each do |config|
  flavor = config.name.split('-', 2).last
  config.base_configuration_reference = flavor_refs.fetch(flavor)
end

runner = project.targets.find { |t| t.name == 'Runner' } or raise 'Runner target not found'
project.targets.each do |target|
  ensure_flavor_configs(project, target.build_configuration_list, target.name)
  target.build_configurations.each do |config|
    bundle_id = '$(APP_BUNDLE_ID_BASE)$(APP_BUNDLE_ID_SUFFIX)'
    bundle_id += ".#{target.name}" unless target == runner
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = bundle_id
    # Per-flavor launcher icon (Assets.xcassets/AppIcon-<flavor>.appiconset, generated by
    # flutter_launcher_icons from flutter_launcher_icons-<flavor>.yaml).
    config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon-$(APP_FLAVOR)' if target == runner
  end
end

# --- 3. Info.plist display name ------------------------------------------------
plist = Xcodeproj::Plist.read_from_path(INFO_PLIST)
if plist['CFBundleDisplayName'] != '$(APP_DISPLAY_NAME)'
  plist['CFBundleDisplayName'] = '$(APP_DISPLAY_NAME)'
  Xcodeproj::Plist.write_to_path(plist, INFO_PLIST)
  puts 'Info.plist: CFBundleDisplayName = $(APP_DISPLAY_NAME)'
end

# --- 4. dev-only ATS exception --------------------------------------------------
ats_script = <<~'SH'
  # Allow plain HTTP to localhost ONLY for the dev flavor (APP_ALLOW_LOCAL_HTTP=YES,
  # set in ios/Flutter/Flavors/dev.xcconfig). staging/production keep full ATS.
  if [ "${APP_ALLOW_LOCAL_HTTP}" != "YES" ]; then
    exit 0
  fi
  PLIST="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
  /usr/libexec/PlistBuddy -c "Delete :NSAppTransportSecurity" "$PLIST" >/dev/null 2>&1 || true
  /usr/libexec/PlistBuddy \
    -c "Add :NSAppTransportSecurity dict" \
    -c "Add :NSAppTransportSecurity:NSAllowsLocalNetworking bool true" \
    -c "Add :NSAppTransportSecurity:NSExceptionDomains dict" \
    -c "Add :NSAppTransportSecurity:NSExceptionDomains:localhost dict" \
    -c "Add :NSAppTransportSecurity:NSExceptionDomains:localhost:NSExceptionAllowsInsecureHTTPLoads bool true" \
    "$PLIST"
SH
phase = runner.shell_script_build_phases.find { |p| p.name == ATS_PHASE_NAME }
unless phase
  phase = runner.new_shell_script_build_phase(ATS_PHASE_NAME)
  puts "build phase: #{ATS_PHASE_NAME}"
end
phase.shell_path = '/bin/sh'
phase.shell_script = ats_script
phase.input_paths = ['${TARGET_BUILD_DIR}/${INFOPLIST_PATH}']
phase.always_out_of_date = '1'
# Run last (after Flutter's "Thin Binary", which also edits Info.plist).
runner.build_phases.delete(phase)
runner.build_phases << phase

project.save

# --- 5. schemes ------------------------------------------------------------------
puts 'schemes'
template_path = [File.join(SCHEMES_DIR, 'Runner.xcscheme'), File.join(SCHEMES_DIR, 'dev.xcscheme')]
                .find { |p| File.exist?(p) } or raise 'No scheme template found'
FLAVORS.each_key do |flavor|
  scheme = Xcodeproj::XCScheme.new(template_path)
  scheme.launch_action.build_configuration = "Debug-#{flavor}"
  scheme.test_action.build_configuration = "Debug-#{flavor}"
  scheme.analyze_action.build_configuration = "Debug-#{flavor}"
  scheme.profile_action.build_configuration = "Profile-#{flavor}"
  scheme.archive_action.build_configuration = "Release-#{flavor}"
  scheme.save_as(PROJECT_PATH, flavor, true)
  puts "  write  #{flavor}.xcscheme"
end
runner_scheme = File.join(SCHEMES_DIR, 'Runner.xcscheme')
if File.exist?(runner_scheme)
  File.delete(runner_scheme)
  puts '  remove Runner.xcscheme'
end

puts 'Done.'
