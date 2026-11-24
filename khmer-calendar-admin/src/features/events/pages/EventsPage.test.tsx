import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import { makeEvent, makeUser } from '@/test/fixtures'
import { renderWithProviders } from '@/test/render'
import * as api from '../api'
import { EventsPage } from './EventsPage'

vi.mock('../api', () => ({
  listEvents: vi.fn(),
  getEvent: vi.fn(),
  createEvent: vi.fn(),
  updateEvent: vi.fn(),
  deleteEvent: vi.fn(),
}))

const mocked = vi.mocked(api)

const events = [
  makeEvent({ id: 'e-1', titleKm: 'ពិធីបុណ្យវិសាខបូជា', titleEn: 'Visak Bochea Day', status: 'DRAFT', isDayOff: true, startDate: '2026-05-01', endDate: '2026-05-01' }),
  makeEvent({
    id: 'e-2',
    titleKm: 'ពិធីបុណ្យចូលឆ្នាំថ្មី',
    titleEn: 'Khmer New Year',
    titleZh: '柬埔寨新年',
    category: 'PUBLIC_HOLIDAY',
    status: 'PUBLISHED',
    isDayOff: true,
    startDate: '2026-04-14',
    endDate: '2026-04-16',
  }),
  makeEvent({ id: 'e-3', titleKm: 'ថ្ងៃសីល', titleEn: 'Sila day', category: 'OBSERVANCE', status: 'PUBLISHED', isDayOff: false }),
]

beforeEach(() => {
  mocked.listEvents.mockResolvedValue({ items: events, meta: { page: 1, limit: 20, total: 3, totalPages: 1 } })
})

describe('EventsPage', () => {
  it('renders rows from the API with Khmer + English titles, badges and date ranges', async () => {
    renderWithProviders(<EventsPage />, { path: '/events', route: '/events?year=2026&month=4&status=PUBLISHED', user: makeUser() })

    const table = await screen.findByRole('table', { name: 'Events' })
    const rows = within(table).getAllByRole('row').slice(1)
    expect(rows).toHaveLength(3)

    const newYear = rows[1]!
    expect(within(newYear).getByText('ពិធីបុណ្យចូលឆ្នាំថ្មី')).toHaveAttribute('lang', 'km')
    expect(within(newYear).getByText('Khmer New Year')).toBeInTheDocument()
    expect(within(newYear).getByText('柬埔寨新年')).toHaveAttribute('lang', 'zh-Hans')
    expect(within(newYear).getByText('14 Apr 2026 – 16 Apr 2026')).toBeInTheDocument()
    expect(within(newYear).getByText('Public holiday')).toBeInTheDocument()
    expect(within(newYear).getByText('Published')).toBeInTheDocument()
    expect(within(newYear).getByText('Day off')).toBeInTheDocument()
    expect(within(newYear).getByRole('button', { name: 'Unpublish Khmer New Year' })).toBeInTheDocument()
    expect(within(rows[0]!).getByRole('button', { name: 'Publish Visak Bochea Day' })).toBeInTheDocument()

    // Filters from the URL are translated into the API query (month -> from/to).
    expect(mocked.listEvents).toHaveBeenCalledWith({
      from: '2026-04-01',
      to: '2026-04-30',
      status: 'PUBLISHED',
      category: undefined,
      q: undefined,
      page: 1,
      limit: 20,
    })
    expect(screen.getByText('1–3 of 3')).toBeInTheDocument()
  })

  it('shows Delete only to admins', async () => {
    renderWithProviders(<EventsPage />, { path: '/events', user: makeUser({ role: 'EDITOR' }) })
    await screen.findByRole('table', { name: 'Events' })
    expect(screen.queryByRole('button', { name: /^delete/i })).not.toBeInTheDocument()
    expect(screen.getAllByRole('link', { name: /^edit/i })).toHaveLength(3)
  })

  it('publishes a draft via PATCH status', async () => {
    mocked.updateEvent.mockResolvedValue({ ...events[0]!, status: 'PUBLISHED' })
    renderWithProviders(<EventsPage />, { path: '/events', user: makeUser() })
    const user = userEvent.setup()

    await user.click(await screen.findByRole('button', { name: 'Publish Visak Bochea Day' }))

    await waitFor(() => expect(mocked.updateEvent).toHaveBeenCalledWith('e-1', { status: 'PUBLISHED' }))
    expect(await screen.findByText('Event published')).toBeInTheDocument()
  })

  it('confirms before deleting', async () => {
    mocked.deleteEvent.mockResolvedValue(undefined)
    renderWithProviders(<EventsPage />, { path: '/events', user: makeUser() })
    const user = userEvent.setup()

    await user.click(await screen.findByRole('button', { name: 'Delete Sila day' }))
    const dialog = screen.getByRole('dialog', { name: 'Delete event?' })
    expect(mocked.deleteEvent).not.toHaveBeenCalled()
    await user.click(within(dialog).getByRole('button', { name: 'Delete' }))

    await waitFor(() => expect(mocked.deleteEvent).toHaveBeenCalledWith('e-3'))
  })

  it('shows an error state with the request id when loading fails', async () => {
    const { ApiError } = await import('@/core/api/errors')
    mocked.listEvents.mockRejectedValue(new ApiError({ status: 500, code: 'INTERNAL_ERROR', message: 'Server exploded', requestId: 'req-abc-123' }))
    renderWithProviders(<EventsPage />, { path: '/events', user: makeUser() })
    expect(await screen.findByText('Server exploded')).toBeInTheDocument()
    expect(screen.getByText('req-abc-123')).toBeInTheDocument()
  })
})
