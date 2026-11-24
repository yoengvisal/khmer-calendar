import { cx } from '@/shared/lib/cx'

export function Spinner({ label = 'Loading…', size = 'md', className }: { label?: string; size?: 'sm' | 'md' | 'lg'; className?: string }) {
  return (
    <span className={cx('spinner', `spinner--${size}`, className)} role="status">
      <span className="spinner__ring" aria-hidden="true" />
      <span className="visually-hidden">{label}</span>
    </span>
  )
}

export function PageSpinner({ label = 'Loading…' }: { label?: string }) {
  return (
    <div className="page-spinner">
      <Spinner size="lg" label={label} />
    </div>
  )
}
