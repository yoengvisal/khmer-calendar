import type { ReactNode } from 'react'
import { cx } from '@/shared/lib/cx'

export interface Column<T> {
  key: string
  header: ReactNode
  render: (row: T) => ReactNode
  className?: string
  /** Hide on narrow screens. */
  hideOnMobile?: boolean
}

export interface TableProps<T> {
  caption: string
  columns: readonly Column<T>[]
  rows: readonly T[]
  rowKey: (row: T) => string
  /** Dim rows while a background refetch runs. */
  busy?: boolean
}

/** Responsive table: scrolls horizontally on small screens; caption is visually hidden but announced. */
export function Table<T>({ caption, columns, rows, rowKey, busy }: TableProps<T>) {
  return (
    <div className={cx('table-wrap', busy && 'table-wrap--busy')} aria-busy={busy || undefined}>
      <table className="table">
        <caption className="visually-hidden">{caption}</caption>
        <thead>
          <tr>
            {columns.map((c) => (
              <th key={c.key} scope="col" className={cx(c.className, c.hideOnMobile && 'hide-mobile')}>
                {c.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <tr key={rowKey(row)}>
              {columns.map((c, index) => (
                <td
                  key={c.key}
                  className={cx(c.className, c.hideOnMobile && 'hide-mobile')}
                  // Used as the inline label in the stacked (phone) layout; the first column is the row's title.
                  data-label={index > 0 && typeof c.header === 'string' ? c.header : undefined}
                >
                  {c.render(row)}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
