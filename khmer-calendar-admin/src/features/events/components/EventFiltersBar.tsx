import { useEffect, useRef, useState } from 'react'
import { MONTH_NAMES } from '@/shared/lib/dates'
import { Button, Input, Select } from '@/shared/ui'
import { CATEGORY_LABELS, STATUS_LABELS } from '../constants'
import type { EventFilters } from '../filters'
import { EVENT_CATEGORIES, EVENT_STATUSES, type EventCategory, type EventStatus } from '../types'
import './events.css'

const monthOptions = MONTH_NAMES.map((name, i) => ({ value: String(i + 1), label: name }))
const statusOptions = EVENT_STATUSES.map((s) => ({ value: s, label: STATUS_LABELS[s] }))
const categoryOptions = EVENT_CATEGORIES.map((c) => ({ value: c, label: CATEGORY_LABELS[c] }))

function yearOptions(selected: number) {
  const current = new Date().getFullYear()
  const years = new Set<number>([selected])
  for (let y = current - 5; y <= current + 5; y++) years.add(y)
  return [...years].sort((a, b) => a - b).map((y) => ({ value: String(y), label: String(y) }))
}

export interface EventFiltersBarProps {
  filters: EventFilters
  onChange: (patch: Partial<Omit<EventFilters, 'page'>>) => void
  onReset: () => void
}

export function EventFiltersBar({ filters, onChange, onReset }: EventFiltersBarProps) {
  const [search, setSearch] = useState(filters.q)
  const timer = useRef<number | undefined>(undefined)

  useEffect(() => () => window.clearTimeout(timer.current), [])

  // Debounce: push the search term to the URL 350ms after the user stops typing.
  function handleSearch(value: string) {
    setSearch(value)
    window.clearTimeout(timer.current)
    timer.current = window.setTimeout(() => onChange({ q: value.trim() }), 350)
  }

  return (
    <form className="filters" role="search" aria-label="Filter events" onSubmit={(e) => e.preventDefault()}>
      <Input
        label="Search titles"
        type="search"
        name="q"
        placeholder="Khmer, English or Chinese…"
        value={search}
        onChange={(e) => handleSearch(e.target.value)}
        fieldClassName="filters__search"
      />
      <Select
        label="Year"
        name="year"
        options={yearOptions(filters.year)}
        value={String(filters.year)}
        onChange={(e) => onChange({ year: Number(e.target.value) })}
      />
      <Select
        label="Month"
        name="month"
        options={monthOptions}
        placeholder="All months"
        value={filters.month ? String(filters.month) : ''}
        onChange={(e) => onChange({ month: e.target.value ? Number(e.target.value) : null })}
      />
      <Select
        label="Status"
        name="status"
        options={statusOptions}
        placeholder="Any status"
        value={filters.status ?? ''}
        onChange={(e) => onChange({ status: (e.target.value || null) as EventStatus | null })}
      />
      <Select
        label="Category"
        name="category"
        options={categoryOptions}
        placeholder="Any category"
        value={filters.category ?? ''}
        onChange={(e) => onChange({ category: (e.target.value || null) as EventCategory | null })}
      />
      <div className="filters__reset">
        <Button
          variant="ghost"
          onClick={() => {
            window.clearTimeout(timer.current)
            setSearch('')
            onReset()
          }}
        >
          Reset
        </Button>
      </div>
    </form>
  )
}
