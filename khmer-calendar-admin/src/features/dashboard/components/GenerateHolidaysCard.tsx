import { useState, type FormEvent } from 'react'
import { Link } from 'react-router'
import { errorMessage } from '@/core/api/errors'
import { Button, Select } from '@/shared/ui'
import { useGenerateHolidays } from '../hooks'

function yearOptions() {
  const current = new Date().getFullYear()
  return Array.from({ length: 6 }, (_, i) => current - 1 + i).map((y) => ({ value: String(y), label: String(y) }))
}

export function GenerateHolidaysCard() {
  const [year, setYear] = useState(() => new Date().getFullYear() + 1)
  const generate = useGenerateHolidays()

  function handleSubmit(e: FormEvent) {
    e.preventDefault()
    generate.mutate(year)
  }

  const result = generate.data
  return (
    <section className="card dash-card" aria-labelledby="generate-title">
      <h2 id="generate-title">Generate holidays</h2>
      <p className="muted">Create draft events for a year from the built-in lunar and fixed-date holiday rules. Existing ones are skipped.</p>
      <form className="dash-generate" onSubmit={handleSubmit}>
        <Select
          label="Year"
          name="generateYear"
          options={yearOptions()}
          value={String(year)}
          onChange={(e) => {
            setYear(Number(e.target.value))
            generate.reset()
          }}
        />
        <Button type="submit" variant="primary" loading={generate.isPending}>
          Generate for {year}
        </Button>
      </form>

      {generate.isError && (
        <p className="form-error" role="alert">
          {errorMessage(generate.error)}
        </p>
      )}

      {result && (
        <div className="dash-result" role="status">
          <p>
            <strong>{result.created.length}</strong> created, <strong>{result.skipped.length}</strong> skipped (already existed).
          </p>
          {result.created.length > 0 && (
            <>
              <ul className="dash-result__list">
                {result.created.map((e) => (
                  <li key={e.id}>
                    <Link to={`/events/${e.id}/edit`}>
                      <span className="km" lang="km">
                        {e.titleKm}
                      </span>{' '}
                      <span className="muted">— {e.titleEn}</span>
                    </Link>
                  </li>
                ))}
              </ul>
              <p className="notice notice--warning">
                New events are <strong>drafts</strong>. Review and publish them before they appear in the app.{' '}
                <Link to={`/events?status=DRAFT&year=${year}`}>Review drafts for {year}</Link>
              </p>
            </>
          )}
        </div>
      )}
    </section>
  )
}
