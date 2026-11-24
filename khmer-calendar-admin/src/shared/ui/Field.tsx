import { useId, type ReactNode } from 'react'
import { cx } from '@/shared/lib/cx'

export interface FieldRenderProps {
  id: string
  'aria-invalid': boolean | undefined
  'aria-describedby': string | undefined
  'aria-required': boolean | undefined
}

export interface FieldProps {
  label: ReactNode
  error?: string | string[] | null
  hint?: ReactNode
  required?: boolean
  className?: string
  children: (props: FieldRenderProps) => ReactNode
}

/** Label + control + hint + error, wired with ids for assistive tech. */
export function Field({ label, error, hint, required, className, children }: FieldProps) {
  const id = useId()
  const hintId = hint ? `${id}-hint` : undefined
  const errors = error ? (Array.isArray(error) ? error : [error]) : []
  const errorId = errors.length > 0 ? `${id}-error` : undefined
  const describedBy = [hintId, errorId].filter(Boolean).join(' ') || undefined
  return (
    <div className={cx('field', errors.length > 0 && 'field--invalid', className)}>
      <label className="field__label" htmlFor={id}>
        {label}
        {required && (
          <span className="field__required" aria-hidden="true">
            {' '}*
          </span>
        )}
      </label>
      {children({
        id,
        'aria-invalid': errors.length > 0 || undefined,
        'aria-describedby': describedBy,
        'aria-required': required || undefined,
      })}
      {hint && (
        <p className="field__hint" id={hintId}>
          {hint}
        </p>
      )}
      {errorId && (
        <p className="field__error" id={errorId}>
          {errors.join(' ')}
        </p>
      )}
    </div>
  )
}
