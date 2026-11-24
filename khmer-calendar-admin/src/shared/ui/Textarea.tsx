import type { ReactNode, TextareaHTMLAttributes } from 'react'
import { cx } from '@/shared/lib/cx'
import { Field } from './Field'

export interface TextareaProps extends Omit<TextareaHTMLAttributes<HTMLTextAreaElement>, 'id'> {
  label: ReactNode
  error?: string | string[] | null
  hint?: ReactNode
  fieldClassName?: string
}

export function Textarea({ label, error, hint, required, className, fieldClassName, rows = 3, ...rest }: TextareaProps) {
  return (
    <Field label={label} error={error} hint={hint} required={required} className={fieldClassName}>
      {(a11y) => <textarea className={cx('control', 'control--textarea', className)} rows={rows} required={required} {...a11y} {...rest} />}
    </Field>
  )
}
