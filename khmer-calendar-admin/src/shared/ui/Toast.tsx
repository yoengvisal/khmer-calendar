import { useCallback, useMemo, useRef, useState, type ReactNode } from 'react'
import { cx } from '@/shared/lib/cx'
import { ToastContext, type ToastApi, type ToastInput } from './toastContext'

interface ToastItem extends Required<Omit<ToastInput, 'description'>> {
  id: number
  description?: string
}

export function ToastProvider({ children }: { children: ReactNode }) {
  const [toasts, setToasts] = useState<ToastItem[]>([])
  const nextId = useRef(1)

  const dismiss = useCallback((id: number) => setToasts((list) => list.filter((t) => t.id !== id)), [])

  const show = useCallback(
    (input: ToastInput) => {
      const id = nextId.current++
      const item: ToastItem = { tone: 'info', duration: 5000, ...input, id }
      setToasts((list) => [...list.slice(-3), item])
      if (item.duration > 0) window.setTimeout(() => dismiss(id), item.duration)
    },
    [dismiss],
  )

  const api = useMemo<ToastApi>(
    () => ({
      show,
      success: (title, description) => show({ title, description, tone: 'success' }),
      error: (title, description) => show({ title, description, tone: 'error', duration: 8000 }),
    }),
    [show],
  )

  return (
    <ToastContext.Provider value={api}>
      {children}
      <div className="toasts" aria-live="polite" aria-relevant="additions">
        {toasts.map((t) => (
          <div key={t.id} className={cx('toast', `toast--${t.tone}`)} role={t.tone === 'error' ? 'alert' : 'status'}>
            <div className="toast__body">
              <p className="toast__title">{t.title}</p>
              {t.description && <p className="toast__description">{t.description}</p>}
            </div>
            <button type="button" className="icon-btn" onClick={() => dismiss(t.id)} aria-label="Dismiss notification">
              ×
            </button>
          </div>
        ))}
      </div>
    </ToastContext.Provider>
  )
}
