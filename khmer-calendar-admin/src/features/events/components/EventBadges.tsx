import { Badge } from '@/shared/ui'
import { CATEGORY_LABELS, CATEGORY_TONES, STATUS_LABELS, STATUS_TONES } from '../constants'
import type { EventCategory, EventStatus } from '../types'

export function CategoryBadge({ category }: { category: EventCategory }) {
  return <Badge tone={CATEGORY_TONES[category]}>{CATEGORY_LABELS[category]}</Badge>
}

export function StatusBadge({ status }: { status: EventStatus }) {
  return <Badge tone={STATUS_TONES[status]}>{STATUS_LABELS[status]}</Badge>
}

export function DayOffBadge({ isDayOff }: { isDayOff: boolean }) {
  return isDayOff ? (
    <Badge tone="danger" title="Public day off">
      Day off
    </Badge>
  ) : (
    <span className="subtle">
      <span aria-hidden="true">—</span>
      <span className="visually-hidden">Not a day off</span>
    </span>
  )
}
