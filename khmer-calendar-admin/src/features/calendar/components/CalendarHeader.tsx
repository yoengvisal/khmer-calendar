import { formatMonth } from '@/shared/lib/dates'
import { toKhmerNumerals } from '@/shared/lib/khmer'
import { Button } from '@/shared/ui'
import type { LunarSummary } from '../summary'

export interface CalendarHeaderProps {
  year: number
  month: number
  lunar: LunarSummary | null
  onPrev: () => void
  onNext: () => void
  onToday: () => void
  loading?: boolean
}

export function CalendarHeader({ year, month, lunar, onPrev, onNext, onToday, loading }: CalendarHeaderProps) {
  return (
    <div className="cal-header">
      <div className="cal-header__titles">
        <h1 aria-live="polite">{formatMonth(year, month)}</h1>
        {lunar && (
          <dl className="cal-header__lunar">
            <div>
              <dt>Lunar months</dt>
              <dd>
                <span className="km" lang="km">
                  {lunar.monthsKm.join(' – ')}
                </span>{' '}
                <span className="muted">({lunar.monthsEn.join(' – ')})</span>
              </dd>
            </div>
            <div>
              <dt>Animal year</dt>
              <dd>
                <span className="km" lang="km">
                  ឆ្នាំ{lunar.animalYearsKm.join(' / ')}
                </span>{' '}
                <span className="muted">({lunar.animalYearsEn.join(' / ')})</span>
              </dd>
            </div>
            <div>
              <dt>Sak</dt>
              <dd className="km" lang="km">
                {lunar.saks.join(' / ')}
              </dd>
            </div>
            <div>
              <dt>Buddhist Era</dt>
              <dd>
                <span className="km" lang="km">
                  ព.ស. {lunar.beYears.map((y) => toKhmerNumerals(y)).join(' / ')}
                </span>{' '}
                <span className="muted">(BE {lunar.beYears.join(' / ')})</span>
              </dd>
            </div>
          </dl>
        )}
      </div>
      <div className="cal-header__nav" role="group" aria-label="Change month">
        <Button onClick={onPrev} aria-label="Previous month" disabled={loading}>
          ‹
        </Button>
        <Button onClick={onToday}>Today</Button>
        <Button onClick={onNext} aria-label="Next month" disabled={loading}>
          ›
        </Button>
      </div>
    </div>
  )
}
