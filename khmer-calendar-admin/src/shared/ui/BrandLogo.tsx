import iconUrl from '@/assets/brand/khmer-calendar-icon.svg'

/** Khmer Calendar app icon ("Kbach Kor"). Source of truth: branding/build_logo.py */
export function BrandLogo({ size = 36, className }: { size?: number; className?: string }) {
  return <img src={iconUrl} width={size} height={size} alt="" aria-hidden="true" className={className} />
}
