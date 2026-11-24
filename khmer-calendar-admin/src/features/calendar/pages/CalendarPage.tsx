import { useMemo, useState } from 'react'
import { useNavigate, useSearchParams } from 'react-router'
import { todayIso } from '@/shared/lib/dates'
import { ErrorState, PageSpinner } from '@/shared/ui'
import { CalendarHeader } from '../components/CalendarHeader'
import { MonthGrid } from '../components/MonthGrid'
import { useCalendarMonth } from '../hooks'
import { summarizeLunar } from '../summary'
import './calendar.css'

const MIN_YEAR = 1900
const MAX_YEAR = 2100

function readMonth(params: URLSearchParams, now: Date): { year: number; month: number } {
  const year = Number(params.get('year'))
  const month = Number(params.get('month'))
  const validYear = Number.isInteger(year) && year >= MIN_YEAR && year <= MAX_YEAR
  const validMonth = Number.isInteger(month) && month >= 1 && month <= 12
  return validYear && validMonth ? { year, month } : { year: now.getFullYear(), month: now.getMonth() + 1 }
}

export function CalendarPage() {
  const [params, setParams] = useSearchParams()
  const navigate = useNavigate()
  const [now] = useState(() => new Date())
  const { year, month } = readMonth(params, now)
  const query = useCalendarMonth(year, month)
  const lunar = useMemo(() => (query.data ? summarizeLunar(query.data.days) : null), [query.data])

  function go(delta: number) {
    const index = year * 12 + (month - 1) + delta
    const nextYear = Math.floor(index / 12)
    if (nextYear < MIN_YEAR || nextYear > MAX_YEAR) return
    setParams({ year: String(nextYear), month: String((index % 12) + 1) })
  }

  return (
    <div className="page">
      <CalendarHeader
        year={year}
        month={month}
        lunar={query.data && query.data.year === year && query.data.month === month ? lunar : null}
        onPrev={() => go(-1)}
        onNext={() => go(1)}
        onToday={() => setParams({})}
        loading={query.isFetching && query.isPlaceholderData}
      />
      <p className="cal-legend subtle">
        <span>
          <span className="cal-legend__swatch cal-legend__swatch--dayoff" aria-hidden="true" /> Day off
        </span>
        <span>
          <span className="cal-cell__holy" aria-hidden="true">
            ☸
          </span>{' '}
          Holy day (<span className="km" lang="km">ថ្ងៃសីល</span>)
        </span>
        <span>Only published events are shown. Click an event to edit it.</span>
      </p>
      {query.isPending ? (
        <PageSpinner label="Loading calendar…" />
      ) : query.isError ? (
        <ErrorState error={query.error} title="Could not load the calendar" onRetry={() => void query.refetch()} />
      ) : (
        <div className={query.isPlaceholderData ? 'cal-loading' : undefined} aria-busy={query.isPlaceholderData || undefined}>
          <MonthGrid days={query.data.days} today={todayIso(now)} onEventClick={(e) => navigate(`/events/${e.id}/edit`)} />
        </div>
      )}
    </div>
  )
}
