import { cx } from '@/shared/lib/cx'
import { formatDate } from '@/shared/lib/dates'
import { formatLunarDay } from '@/shared/lib/khmer'
import type { EventSummary } from '@/features/events/types'
import type { CalendarDay } from '../types'

const WEEKDAYS = [
  { en: 'Sun', km: 'អាទិត្យ' },
  { en: 'Mon', km: 'ចន្ទ' },
  { en: 'Tue', km: 'អង្គារ' },
  { en: 'Wed', km: 'ពុធ' },
  { en: 'Thu', km: 'ព្រហស្បតិ៍' },
  { en: 'Fri', km: 'សុក្រ' },
  { en: 'Sat', km: 'សៅរ៍' },
] as const

export interface MonthGridProps {
  days: readonly CalendarDay[]
  today: string
  onEventClick: (event: EventSummary) => void
}

export function MonthGrid({ days, today, onEventClick }: MonthGridProps) {
  const leading = days[0]?.dayOfWeek ?? 0
  const trailing = (7 - ((leading + days.length) % 7)) % 7

  return (
    <div className="cal-grid">
      <div className="cal-grid__weekdays" aria-hidden="true">
        {WEEKDAYS.map((w) => (
          <div key={w.en} className="cal-grid__weekday">
            <span>{w.en}</span>
            <span className="km cal-grid__weekday-km" lang="km">
              {w.km}
            </span>
          </div>
        ))}
      </div>
      <ol className="cal-grid__cells" aria-label="Days of the month">
        {Array.from({ length: leading }, (_, i) => (
          <li key={`lead-${i}`} className="cal-cell cal-cell--blank" aria-hidden="true" />
        ))}
        {days.map((day) => {
          const isToday = day.date === today
          const isWeekend = day.dayOfWeek === 0 || day.dayOfWeek === 6
          const hasDayOff = day.events.some((e) => e.isDayOff)
          const gregorian = Number(day.date.slice(8, 10))
          return (
            <li
              key={day.date}
              aria-current={isToday ? 'date' : undefined}
              className={cx('cal-cell', isWeekend && 'cal-cell--weekend', isToday && 'cal-cell--today', hasDayOff && 'cal-cell--dayoff')}
            >
              <div className="cal-cell__top">
                <span className="cal-cell__day">
                  <span aria-hidden="true">{gregorian}</span>
                  <span className="visually-hidden">{formatDate(day.date)}</span>
                </span>
                <span className="cal-cell__lunar km" lang="km" title={day.lunar.formattedKm}>
                  {day.lunar.isHolyDay && (
                    <span className="cal-cell__holy" title="Holy day (ថ្ងៃសីល)">
                      <span aria-hidden="true">☸</span>
                      <span className="visually-hidden">Holy day</span>
                    </span>
                  )}
                  {formatLunarDay(day.lunar.day, day.lunar.moonPhase)}
                </span>
              </div>
              {day.events.length > 0 && (
                <ul className="cal-cell__events">
                  {day.events.map((event) => (
                    <li key={event.id}>
                      <button
                        type="button"
                        className={cx('cal-chip', event.isDayOff && 'cal-chip--dayoff')}
                        onClick={() => onEventClick(event)}
                        title={`${event.titleKm} — ${event.titleEn}${event.isDayOff ? ' (day off)' : ''}`}
                      >
                        <span className="km" lang="km">
                          {event.titleKm}
                        </span>
                        <span className="visually-hidden">
                          {' '}
                          ({event.titleEn}){event.isDayOff ? ', day off' : ''}. Edit event.
                        </span>
                      </button>
                    </li>
                  ))}
                </ul>
              )}
            </li>
          )
        })}
        {Array.from({ length: trailing }, (_, i) => (
          <li key={`trail-${i}`} className="cal-cell cal-cell--blank" aria-hidden="true" />
        ))}
      </ol>
    </div>
  )
}
