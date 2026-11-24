import { Button } from './Button'

export interface PaginationProps {
  page: number
  totalPages: number
  total: number
  limit: number
  onPageChange: (page: number) => void
}

export function Pagination({ page, totalPages, total, limit, onPageChange }: PaginationProps) {
  if (total === 0) return null
  const first = (page - 1) * limit + 1
  const last = Math.min(page * limit, total)
  return (
    <nav className="pagination" aria-label="Pagination">
      <p className="pagination__summary">
        {first}–{last} of {total}
      </p>
      <div className="pagination__controls">
        <Button size="sm" variant="secondary" onClick={() => onPageChange(page - 1)} disabled={page <= 1} aria-label="Previous page">
          ‹ Prev
        </Button>
        <span className="pagination__page" aria-current="page">
          Page {page} of {Math.max(totalPages, 1)}
        </span>
        <Button size="sm" variant="secondary" onClick={() => onPageChange(page + 1)} disabled={page >= totalPages} aria-label="Next page">
          Next ›
        </Button>
      </div>
    </nav>
  )
}
