import type { ReactNode, SelectHTMLAttributes } from 'react'
import { cx } from '@/shared/lib/cx'
import { Field } from './Field'

export interface SelectOption {
  value: string
  label: string
}

export interface SelectProps extends Omit<SelectHTMLAttributes<HTMLSelectElement>, 'id'> {
  label: ReactNode
  options: readonly SelectOption[]
  placeholder?: string
  error?: string | string[] | null
  hint?: ReactNode
  fieldClassName?: string
}

export function Select({ label, options, placeholder, error, hint, required, className, fieldClassName, ...rest }: SelectProps) {
  return (
    <Field label={label} error={error} hint={hint} required={required} className={fieldClassName}>
      {(a11y) => (
        <select className={cx('control', 'control--select', className)} required={required} {...a11y} {...rest}>
          {placeholder !== undefined && <option value="">{placeholder}</option>}
          {options.map((o) => (
            <option key={o.value} value={o.value}>
              {o.label}
            </option>
          ))}
        </select>
      )}
    </Field>
  )
}
