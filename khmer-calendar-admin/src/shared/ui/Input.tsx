import type { InputHTMLAttributes, ReactNode } from 'react'
import { cx } from '@/shared/lib/cx'
import { Field } from './Field'

export interface InputProps extends Omit<InputHTMLAttributes<HTMLInputElement>, 'id'> {
  label: ReactNode
  error?: string | string[] | null
  hint?: ReactNode
  fieldClassName?: string
}

export function Input({ label, error, hint, required, className, fieldClassName, ...rest }: InputProps) {
  return (
    <Field label={label} error={error} hint={hint} required={required} className={fieldClassName}>
      {(a11y) => <input className={cx('control', className)} required={required} {...a11y} {...rest} />}
    </Field>
  )
}

export interface CheckboxProps extends Omit<InputHTMLAttributes<HTMLInputElement>, 'type'> {
  label: ReactNode
  hint?: ReactNode
}

export function Checkbox({ label, hint, className, ...rest }: CheckboxProps) {
  return (
    <label className={cx('checkbox', className)}>
      <input type="checkbox" {...rest} />
      <span>
        <span className="checkbox__label">{label}</span>
        {hint && <span className="checkbox__hint">{hint}</span>}
      </span>
    </label>
  )
}
