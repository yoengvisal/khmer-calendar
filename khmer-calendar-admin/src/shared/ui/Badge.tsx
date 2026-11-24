import type { ReactNode } from 'react'
import { cx } from '@/shared/lib/cx'

export type BadgeTone = 'neutral' | 'info' | 'success' | 'warning' | 'danger' | 'accent'

export function Badge({ tone = 'neutral', children, className, title }: { tone?: BadgeTone; children: ReactNode; className?: string; title?: string }) {
  return (
    <span className={cx('badge', `badge--${tone}`, className)} title={title}>
      {children}
    </span>
  )
}
