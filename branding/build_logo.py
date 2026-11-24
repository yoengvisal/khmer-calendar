#!/usr/bin/env python3
"""
Khmer Calendar logo ("Kbach Kor") — single source of truth for every logo file.

    python3 branding/build_logo.py          # write SVGs + render PNGs (needs Google Chrome)
    python3 branding/build_logo.py --svg    # SVGs only

Text is pre-outlined from Kantumruy Pro Bold (SIL OFL) into source/outlines.json by
source/outline_text.py (HarfBuzz shaping), so no file here depends on an installed font.
"""
import json, os, shutil, subprocess, sys

ROOT = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(ROOT, 'logo')
PNG = os.path.join(OUT, 'png')
T = json.load(open(os.path.join(ROOT, 'source', 'outlines.json')))

# Palette
NAVY, NAVY_DEEP, NAVY_TOP = '#0E2A6B', '#071640', '#123383'
RED = '#C8102E'
GOLD_LIGHT, GOLD = '#F7DA86', '#D59A2E'
GOLD_DEEP_LIGHT, GOLD_DEEP = '#C99A3A', '#9C6A12'  # kbach on light backgrounds
CREAM = '#FBF6EA'
FLAVOR = {'dev': ('#E8730C', T['dev']), 'staging': ('#7B4BC4', T['stg'])}

# Kbach "flame leaf" — base at (0,0), pointing up. Repeated 16x around the moon.
KBACH = 'M-13 0C-17-14-10-27 0-44C-1-33 7-28 9-19C13-23 15-12 13 0Z'
KBACH_COUNT, KBACH_RADIUS, KBACH_SCALE = 16, 188, 0.95


def grad(gid, top, bottom, diagonal=False):
    x2, y2 = ('1', '1') if diagonal else ('0', '1')
    return (f'<linearGradient id="{gid}" x1="0" y1="0" x2="{x2}" y2="{y2}">'
            f'<stop offset="0" stop-color="{top}"/><stop offset="1" stop-color="{bottom}"/></linearGradient>')


def kbach_ring(fill):
    return ''.join(
        f'<path d="{KBACH}" fill="{fill}" transform="rotate({i * 360 / KBACH_COUNT:g} 256 256) '
        f'translate(256 {256 - KBACH_RADIUS}) scale({KBACH_SCALE})"/>' for i in range(KBACH_COUNT))


def mark(p, kbach_fill=None, disc=True):
    """The mark in a 512 box centred on (256,256). `p` prefixes ids so several marks can share a page."""
    kor = T['kor']
    return (
        f'<clipPath id="{p}L"><rect width="256" height="512"/></clipPath>'
        f'<clipPath id="{p}R"><rect x="256" width="256" height="512"/></clipPath>'
        + kbach_ring(kbach_fill or f'url(#{p}gold)')
        + (f'<circle cx="256" cy="256" r="150" fill="{NAVY_DEEP}"/>' if disc else '')
        + f'<circle cx="256" cy="256" r="124" fill="none" stroke="{GOLD}" stroke-width="8"/>'
        + f'<path d="M256 128a128 128 0 0 0 0 256z" fill="url(#{p}gold)"/>'
        + f'<path d="{kor}" fill="{NAVY}" clip-path="url(#{p}L)"/>'
        + f'<path d="{kor}" fill="{GOLD_LIGHT}" clip-path="url(#{p}R)"/>'
    )


def doc(body, defs='', view='0 0 512 512', title='Khmer Calendar'):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{view}" role="img" aria-label="{title}">'
            f'<title>{title}</title><defs>{defs}</defs>{body}</svg>\n')


def gold_defs(p):
    return grad(f'{p}gold', GOLD_LIGHT, GOLD) + grad(f'{p}bg', NAVY_TOP, NAVY_DEEP, diagonal=True)


def icon(p, rounded=True, flavor=None):
    shape = '<rect width="512" height="512" rx="112"/>' if rounded else '<rect width="512" height="512"/>'
    body = f'<clipPath id="{p}tile">{shape}</clipPath><g clip-path="url(#{p}tile)"><rect width="512" height="512" fill="url(#{p}bg)"/>'
    if flavor:
        colour, label = FLAVOR[flavor]
        body += (f'<g transform="translate(256 224) scale(.84) translate(-256 -256)">{mark(p)}</g>'
                 f'<rect y="420" width="512" height="92" fill="{colour}"/>'
                 f'<path d="{label}" fill="#fff" transform="translate(0 488)"/>')
    else:
        body += mark(p)
    return doc(body + '</g>', gold_defs(p),
               title='Khmer Calendar' + (f' ({flavor})' if flavor else ''))


def mono():
    kor = T['kor']
    return doc(
        '<g color="#0E2A6B" fill="currentColor">' + kbach_ring('currentColor')
        + '<circle cx="256" cy="256" r="124" fill="none" stroke="currentColor" stroke-width="8"/>'
        + '<path d="M256 128a128 128 0 0 0 0 256z" mask="url(#monoCut)"/>'
        + f'<path d="{kor}" clip-path="url(#monoR)"/></g>',
        f'<mask id="monoCut"><rect width="512" height="512" fill="#fff"/><path d="{kor}" fill="#000"/></mask>'
        '<clipPath id="monoR"><rect x="256" width="256" height="512"/></clipPath>',
        title='Khmer Calendar (one colour)')


def adaptive_foreground(flavor=None):
    # Android adaptive icon: 108dp canvas, only the central 66dp circle is guaranteed visible.
    p = 'af'
    scale = 0.58 if flavor else 0.66
    body = f'<g transform="translate(256 {238 if flavor else 256}) scale({scale}) translate(-256 -256)">{mark(p)}</g>'
    if flavor:
        colour, label = FLAVOR[flavor]
        body += (f'<rect x="186" y="352" width="140" height="44" rx="22" fill="{colour}"/>'
                 f'<path d="{label}" fill="#fff" transform="translate(256 386) scale(.62) translate(-256 0)"/>')
    return doc(body, gold_defs(p), title='Adaptive icon foreground')


def adaptive_monochrome():
    # Android 13+ themed icon: single colour, system tints it.
    inner = mono().split('<title>Khmer Calendar (one colour)</title>')[1].replace('</svg>\n', '')
    inner = inner.replace('color="#0E2A6B"', 'color="#FFFFFF"')
    return ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><title>Themed icon</title>'
            f'<g transform="translate(256 256) scale(.66) translate(-256 -256)">{inner}</g></svg>\n')


def lockup(dark=False, stacked=False):
    p = 'lk'
    km, en = T['km_wordmark'], T['en_wordmark']
    km_fill, en_fill = (CREAM, GOLD_LIGHT) if dark else (NAVY, RED)
    kbach = None if dark else f'url(#{p}deep)'
    defs = gold_defs(p) + grad(f'{p}deep', GOLD_DEEP_LIGHT, GOLD_DEEP)
    if stacked:
        km_x, en_x = 260 - T['km_width'] / 2, 260 - T['en_width'] / 2
        body = (f'<g transform="translate(110 16) scale(.586)">{mark(p, kbach)}</g>'
                f'<path d="{km}" fill="{km_fill}" transform="translate({km_x:.1f} 420)"/>'
                f'<path d="{en}" fill="{en_fill}" transform="translate({en_x:.1f} 484)"/>')
        return doc(body, defs, '0 0 520 512', 'ប្រតិទិនខ្មែរ — Khmer Calendar')
    width = 290 + max(T['km_width'], T['en_width']) + 24
    body = (f'<g transform="translate(10 10) scale(.469)">{mark(p, kbach)}</g>'
            f'<path d="{km}" fill="{km_fill}" transform="translate(290 128)"/>'
            f'<path d="{en}" fill="{en_fill}" transform="translate(294 196)"/>')
    return doc(body, defs, f'0 0 {width:.0f} 260', 'ប្រតិទិនខ្មែរ — Khmer Calendar')


def anatomy():
    """Annotated diagram for the brand guide (labels use system fonts; documentation only)."""
    p = 'an'
    labels = [  # (target x, y, label x, y, anchor, text)
        (256, 50, 590, 70, 'start', '1  Kbach flame leaves (ក្បាច់) · 16'),
        (330, 120, 590, 150, 'start', '2  Navy disc: night sky'),
        (370, 220, 590, 230, 'start', '3  Gold ring: full moon'),
        (300, 300, 590, 310, 'start', '4  ក: first letter of កើត'),
        (180, 300, -80, 300, 'end', 'Waxing half · កើត  5'),
        (330, 370, 590, 390, 'start', '6  Waning half · រោច'),
    ]
    body = f'<rect x="-420" y="-20" width="1460" height="552" fill="{CREAM}"/>'
    body += mark(p, f'url(#{p}deep)')
    for tx, ty, lx, ly, anchor, text in labels:
        ex = lx - 10 if anchor == 'start' else lx + 10
        body += (f'<path d="M{tx} {ty}L{ex} {ly - 7}" stroke="{RED}" stroke-width="2" fill="none"/>'
                 f'<circle cx="{tx}" cy="{ty}" r="6" fill="{RED}"/>'
                 f'<text x="{lx}" y="{ly}" text-anchor="{anchor}" font-family="Kantumruy Pro, Khmer Sangam MN, Helvetica, sans-serif" '
                 f'font-size="26" fill="{NAVY}">{text}</text>')
    return doc(body, gold_defs(p) + grad(f'{p}deep', GOLD_DEEP_LIGHT, GOLD_DEEP), '-420 -20 1460 552', 'Logo anatomy')


FILES = {
    'khmer-calendar-anatomy.svg': anatomy,
    'khmer-calendar-icon.svg': lambda: icon('ic'),
    'khmer-calendar-icon-fullbleed.svg': lambda: icon('fb', rounded=False),
    'khmer-calendar-icon-dev.svg': lambda: icon('dv', rounded=False, flavor='dev'),
    'khmer-calendar-icon-staging.svg': lambda: icon('st', rounded=False, flavor='staging'),
    'khmer-calendar-mark.svg': lambda: doc(mark('mk'), gold_defs('mk'), title='Khmer Calendar mark'),
    'khmer-calendar-mark-on-light.svg': lambda: doc(mark('ml', 'url(#mldeep)'), gold_defs('ml') + grad('mldeep', GOLD_DEEP_LIGHT, GOLD_DEEP), title='Khmer Calendar mark'),
    'khmer-calendar-mark-mono.svg': mono,
    'khmer-calendar-lockup.svg': lambda: lockup(),
    'khmer-calendar-lockup-on-dark.svg': lambda: lockup(dark=True),
    'khmer-calendar-lockup-stacked.svg': lambda: lockup(stacked=True),
    'khmer-calendar-lockup-stacked-on-dark.svg': lambda: lockup(dark=True, stacked=True),
    'android/adaptive-foreground.svg': adaptive_foreground,
    'android/adaptive-foreground-dev.svg': lambda: adaptive_foreground('dev'),
    'android/adaptive-foreground-staging.svg': lambda: adaptive_foreground('staging'),
    'android/adaptive-background.svg': lambda: doc('<rect width="512" height="512" fill="url(#abbg)"/>', gold_defs('ab'), title='Adaptive icon background'),
    'android/adaptive-monochrome.svg': adaptive_monochrome,
}

# (source svg, png name, width, height, transparent)
RENDERS = [
    ('khmer-calendar-anatomy.svg', 'anatomy-1460.png', 1460, 552, False),
    ('khmer-calendar-icon-fullbleed.svg', 'app-icon-1024.png', 1024, 1024, False),
    ('khmer-calendar-icon-dev.svg', 'app-icon-dev-1024.png', 1024, 1024, False),
    ('khmer-calendar-icon-staging.svg', 'app-icon-staging-1024.png', 1024, 1024, False),
    ('khmer-calendar-icon.svg', 'icon-rounded-1024.png', 1024, 1024, True),
    ('khmer-calendar-icon.svg', 'icon-512.png', 512, 512, True),
    ('khmer-calendar-icon.svg', 'icon-192.png', 192, 192, True),
    ('khmer-calendar-icon.svg', 'favicon-32.png', 32, 32, True),
    ('khmer-calendar-icon-fullbleed.svg', 'apple-touch-icon-180.png', 180, 180, False),
    ('khmer-calendar-mark.svg', 'mark-1024.png', 1024, 1024, True),
    ('android/adaptive-foreground.svg', 'adaptive-foreground-1024.png', 1024, 1024, True),
    ('android/adaptive-foreground-dev.svg', 'adaptive-foreground-dev-1024.png', 1024, 1024, True),
    ('android/adaptive-foreground-staging.svg', 'adaptive-foreground-staging-1024.png', 1024, 1024, True),
    ('android/adaptive-background.svg', 'adaptive-background-1024.png', 1024, 1024, False),
    ('android/adaptive-monochrome.svg', 'adaptive-monochrome-1024.png', 1024, 1024, True),
    ('khmer-calendar-lockup.svg', 'lockup-1600.png', None, 520, True),
    ('khmer-calendar-lockup-stacked.svg', 'lockup-stacked-1040.png', 1056, 1040, True),
]

CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'


def render(svg_rel, png, w, h, transparent):
    import re
    src = os.path.join(OUT, svg_rel)
    if w is None:  # keep aspect ratio of the viewBox
        vb = re.search(r'viewBox="0 0 ([\d.]+) ([\d.]+)"', open(src).read())
        w = round(h * float(vb.group(1)) / float(vb.group(2)))
    page = os.path.join(PNG, '.render.html')
    bg = 'transparent' if transparent else '#fff'
    with open(page, 'w') as f:
        f.write(f'<html><body style="margin:0;background:{bg}"><img src="file://{src}" style="display:block;width:{w}px;height:{h}px"></body></html>')
    args = [CHROME, '--headless', '--disable-gpu', '--hide-scrollbars', '--allow-file-access-from-files',
            f'--window-size={w},{h}', f'--screenshot={os.path.join(PNG, png)}']
    if transparent:
        args.append('--default-background-color=00000000')
    subprocess.run(args + [f'file://{page}'], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    os.remove(page)


def main():
    if os.path.isdir(OUT):
        shutil.rmtree(OUT)
    os.makedirs(os.path.join(OUT, 'android'))
    for name, build in FILES.items():
        with open(os.path.join(OUT, name), 'w') as f:
            f.write(build())
    print(f'wrote {len(FILES)} SVGs')
    if '--svg' in sys.argv:
        return
    os.makedirs(PNG)
    for r in RENDERS:
        render(*r)
    print(f'rendered {len(RENDERS)} PNGs')


if __name__ == '__main__':
    main()
