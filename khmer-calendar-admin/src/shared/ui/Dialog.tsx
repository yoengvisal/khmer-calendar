import { useEffect, useId, useRef, type ReactNode } from 'react'
import { cx } from '@/shared/lib/cx'

export interface DialogProps {
  open: boolean
  onClose: () => void
  title: ReactNode
  description?: ReactNode
  children?: ReactNode
  footer?: ReactNode
  size?: 'sm' | 'md' | 'lg'
  /** Prevent closing via Escape / backdrop (e.g. while a mutation is pending). */
  dismissible?: boolean
}

/**
 * Modal dialog built on the native <dialog> element: `showModal()` gives us the top layer,
 * inert background, focus containment, Escape handling and focus restoration for free.
 * Content is only mounted while open so forms reset between openings.
 */
export function Dialog({ open, onClose, title, description, children, footer, size = 'md', dismissible = true }: DialogProps) {
  const ref = useRef<HTMLDialogElement>(null)
  const titleId = useId()
  const descriptionId = useId()

  useEffect(() => {
    const el = ref.current
    if (!el) return
    if (open && !el.open) {
      if (typeof el.showModal === 'function') el.showModal()
      else el.setAttribute('open', '') // jsdom / very old browsers
    } else if (!open && el.open) {
      if (typeof el.close === 'function') el.close()
      else el.removeAttribute('open')
    }
  }, [open])

  return (
    <dialog
      ref={ref}
      className={cx('dialog', `dialog--${size}`)}
      aria-labelledby={titleId}
      aria-describedby={description ? descriptionId : undefined}
      aria-modal="true"
      onCancel={(e) => {
        e.preventDefault()
        if (dismissible) onClose()
      }}
      onMouseDown={(e) => {
        if (dismissible && e.target === ref.current) onClose()
      }}
    >
      {open && (
        <div className="dialog__panel">
          <header className="dialog__header">
            <h2 id={titleId} className="dialog__title">
              {title}
            </h2>
            <button type="button" className="icon-btn" onClick={onClose} aria-label="Close dialog" disabled={!dismissible}>
              ×
            </button>
          </header>
          {description && (
            <p id={descriptionId} className="dialog__description">
              {description}
            </p>
          )}
          {children && <div className="dialog__body">{children}</div>}
          {footer && <footer className="dialog__footer">{footer}</footer>}
        </div>
      )}
    </dialog>
  )
}
