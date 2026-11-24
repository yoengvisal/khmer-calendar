import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'
import { ApiError } from '@/core/api/errors'
import { ToastProvider } from '@/shared/ui'
import { emptyEventForm } from '../validation'
import { EventForm } from './EventForm'

function renderForm(onSubmit = vi.fn().mockResolvedValue(undefined)) {
  render(
    <ToastProvider>
      <EventForm initialValues={emptyEventForm()} submitLabel="Create event" onSubmit={onSubmit} />
    </ToastProvider>,
  )
  return { onSubmit, user: userEvent.setup() }
}

async function fillRequired(user: ReturnType<typeof userEvent.setup>) {
  await user.type(screen.getByLabelText(/title \(khmer\)/i), 'ទិវាពលកម្មអន្តរជាតិ')
  await user.type(screen.getByLabelText(/title \(english\)/i), 'International Labour Day')
  await user.selectOptions(screen.getByLabelText(/category/i), 'PUBLIC_HOLIDAY')
}

describe('EventForm', () => {
  it('defaults the end date to the start date', async () => {
    const { user } = renderForm()
    const start = screen.getByLabelText(/start date/i)
    await user.type(start, '2026-05-01')
    expect(screen.getByLabelText(/end date/i)).toHaveValue('2026-05-01')
  })

  it('rejects an end date before the start date and does not submit', async () => {
    const { user, onSubmit } = renderForm()
    await fillRequired(user)
    await user.type(screen.getByLabelText(/start date/i), '2026-05-02')
    const end = screen.getByLabelText(/end date/i)
    await user.clear(end)
    await user.type(end, '2026-05-01')
    await user.click(screen.getByRole('button', { name: /create event/i }))

    expect(onSubmit).not.toHaveBeenCalled()
    expect(end).toHaveAttribute('aria-invalid', 'true')
    expect(end).toHaveAccessibleDescription(/cannot be before the start date/i)
  })

  it('submits a trimmed body when valid', async () => {
    const { user, onSubmit } = renderForm()
    await fillRequired(user)
    await user.type(screen.getByLabelText(/start date/i), '2026-05-01')
    await user.click(screen.getByLabelText(/public day off/i))
    await user.click(screen.getByRole('button', { name: /create event/i }))

    expect(onSubmit).toHaveBeenCalledWith({
      titleKm: 'ទិវាពលកម្មអន្តរជាតិ',
      titleEn: 'International Labour Day',
      titleZh: null,
      descriptionKm: null,
      descriptionEn: null,
      descriptionZh: null,
      category: 'PUBLIC_HOLIDAY',
      startDate: '2026-05-01',
      endDate: '2026-05-01',
      isDayOff: true,
      status: 'DRAFT',
    })
  })

  it('shows server VALIDATION_ERROR details next to the matching fields', async () => {
    const onSubmit = vi.fn().mockRejectedValue(
      new ApiError({
        status: 400,
        code: 'VALIDATION_ERROR',
        message: 'The request is invalid',
        details: [
          { field: 'titleEn', messages: ['titleEn already used for this date'] },
          { field: 'sourceKey', messages: ['is read-only'] },
        ],
      }),
    )
    const { user } = renderForm(onSubmit)
    await fillRequired(user)
    await user.type(screen.getByLabelText(/start date/i), '2026-05-01')
    await user.click(screen.getByRole('button', { name: /create event/i }))

    expect(await screen.findByLabelText(/title \(english\)/i)).toHaveAccessibleDescription('titleEn already used for this date')
    expect(screen.getByRole('alert')).toHaveTextContent(/fix the highlighted fields.*sourceKey: is read-only/i)
  })
})
