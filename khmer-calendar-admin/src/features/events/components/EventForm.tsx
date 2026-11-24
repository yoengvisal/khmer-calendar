import { useRef, useState, type FormEvent } from 'react'
import { ApiError, errorMessage, getFieldErrors } from '@/core/api/errors'
import { Button, Checkbox, Input, Select, Textarea } from '@/shared/ui'
import { CATEGORY_LABELS, STATUS_LABELS } from '../constants'
import { EVENT_CATEGORIES, EVENT_STATUSES, type EventCategory, type EventStatus, type EventWriteBody } from '../types'
import {
  DESCRIPTION_MAX,
  TITLE_MAX,
  hasErrors,
  toEventWriteBody,
  validateEventForm,
  type EventFormErrors,
  type EventFormField,
  type EventFormValues,
} from '../validation'
import './event-form.css'

const FORM_FIELDS: readonly EventFormField[] = [
  'titleKm',
  'titleEn',
  'titleZh',
  'descriptionKm',
  'descriptionEn',
  'descriptionZh',
  'category',
  'startDate',
  'endDate',
  'isDayOff',
  'status',
]

const categoryOptions = EVENT_CATEGORIES.map((c) => ({ value: c, label: CATEGORY_LABELS[c] }))
const statusOptions = EVENT_STATUSES.map((s) => ({ value: s, label: STATUS_LABELS[s] }))

export interface EventFormProps {
  initialValues: EventFormValues
  submitLabel: string
  /** Should reject with the ApiError on failure so server validation can be mapped to fields. */
  onSubmit: (body: EventWriteBody) => Promise<unknown>
  onCancel?: () => void
  /** Hide the status selector (e.g. when status is managed elsewhere). */
  hideStatus?: boolean
}

export function EventForm({ initialValues, submitLabel, onSubmit, onCancel, hideStatus = false }: EventFormProps) {
  const formRef = useRef<HTMLFormElement>(null)
  const [values, setValues] = useState<EventFormValues>(initialValues)
  const [attempted, setAttempted] = useState(false)
  const [clientErrors, setClientErrors] = useState<EventFormErrors>({})
  const [serverErrors, setServerErrors] = useState<Partial<Record<EventFormField, string[]>>>({})
  const [formError, setFormError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  function update<K extends EventFormField>(field: K, value: EventFormValues[K]) {
    const prev = values
    const next = { ...prev, [field]: value }
    // Keep endDate in step with startDate until the user picks a different end date.
    if (field === 'startDate') {
      const start = value as string
      if (!prev.endDate || prev.endDate === prev.startDate || (start && prev.endDate < start)) next.endDate = start
    }
    setValues(next)
    if (attempted) setClientErrors(validateEventForm(next))
    setServerErrors((prev) => {
      if (!(field in prev)) return prev
      const copy = { ...prev }
      delete copy[field]
      return copy
    })
  }

  function focusFirstInvalid() {
    requestAnimationFrame(() => {
      formRef.current?.querySelector<HTMLElement>('[aria-invalid="true"]')?.focus()
    })
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    setAttempted(true)
    setFormError(null)
    const errors = validateEventForm(values)
    setClientErrors(errors)
    if (hasErrors(errors)) {
      focusFirstInvalid()
      return
    }
    setSubmitting(true)
    try {
      await onSubmit(toEventWriteBody(values))
    } catch (err) {
      const fieldErrors = getFieldErrors(err)
      const mapped: Partial<Record<EventFormField, string[]>> = {}
      const unmapped: string[] = []
      for (const [field, messages] of Object.entries(fieldErrors)) {
        if ((FORM_FIELDS as readonly string[]).includes(field)) mapped[field as EventFormField] = messages
        else unmapped.push(`${field}: ${messages.join(' ')}`)
      }
      setServerErrors(mapped)
      const base = err instanceof ApiError && err.code === 'VALIDATION_ERROR' ? 'Please fix the highlighted fields.' : errorMessage(err)
      setFormError(unmapped.length > 0 ? `${base} ${unmapped.join(' ')}` : base)
      focusFirstInvalid()
    } finally {
      setSubmitting(false)
    }
  }

  const errorFor = (field: EventFormField): string | string[] | undefined => clientErrors[field] ?? serverErrors[field]

  return (
    <form ref={formRef} className="event-form" onSubmit={handleSubmit} noValidate aria-describedby={formError ? 'event-form-error' : undefined}>
      {formError && (
        <p id="event-form-error" className="form-error" role="alert">
          {formError}
        </p>
      )}

      <fieldset className="event-form__section">
        <legend>Titles</legend>
        <div className="event-form__grid event-form__grid--languages">
          <Input
            label="Title (Khmer)"
            name="titleKm"
            lang="km"
            className="km"
            value={values.titleKm}
            maxLength={TITLE_MAX}
            onChange={(e) => update('titleKm', e.target.value)}
            error={errorFor('titleKm')}
            required
          />
          <Input
            label="Title (English)"
            name="titleEn"
            value={values.titleEn}
            maxLength={TITLE_MAX}
            onChange={(e) => update('titleEn', e.target.value)}
            error={errorFor('titleEn')}
            required
          />
          <Input
            label="Title (Chinese)"
            name="titleZh"
            lang="zh-Hans"
            value={values.titleZh}
            maxLength={TITLE_MAX}
            onChange={(e) => update('titleZh', e.target.value)}
            error={errorFor('titleZh')}
            hint="Optional. The app shows the English title when empty."
          />
          <Textarea
            label="Description (Khmer)"
            name="descriptionKm"
            lang="km"
            className="km"
            value={values.descriptionKm}
            maxLength={DESCRIPTION_MAX}
            onChange={(e) => update('descriptionKm', e.target.value)}
            error={errorFor('descriptionKm')}
          />
          <Textarea
            label="Description (English)"
            name="descriptionEn"
            value={values.descriptionEn}
            maxLength={DESCRIPTION_MAX}
            onChange={(e) => update('descriptionEn', e.target.value)}
            error={errorFor('descriptionEn')}
          />
          <Textarea
            label="Description (Chinese)"
            name="descriptionZh"
            lang="zh-Hans"
            value={values.descriptionZh}
            maxLength={DESCRIPTION_MAX}
            onChange={(e) => update('descriptionZh', e.target.value)}
            error={errorFor('descriptionZh')}
          />
        </div>
      </fieldset>

      <fieldset className="event-form__section">
        <legend>Details</legend>
        <div className="event-form__grid">
          <Select
            label="Category"
            name="category"
            options={categoryOptions}
            placeholder="Select a category"
            value={values.category}
            onChange={(e) => update('category', e.target.value as EventCategory | '')}
            error={errorFor('category')}
            required
          />
          {!hideStatus && (
            <Select
              label="Status"
              name="status"
              options={statusOptions}
              value={values.status}
              onChange={(e) => update('status', e.target.value as EventStatus)}
              error={errorFor('status')}
              hint="Only published events are visible in the public calendar."
            />
          )}
          <Input
            label="Start date"
            name="startDate"
            type="date"
            value={values.startDate}
            onChange={(e) => update('startDate', e.target.value)}
            error={errorFor('startDate')}
            required
          />
          <Input
            label="End date"
            name="endDate"
            type="date"
            min={values.startDate || undefined}
            value={values.endDate}
            onChange={(e) => update('endDate', e.target.value)}
            error={errorFor('endDate')}
            hint="Inclusive. Same as the start date for one-day events."
            required
          />
        </div>
        <Checkbox
          label="Public day off"
          hint="Shown in red in the calendar."
          name="isDayOff"
          checked={values.isDayOff}
          onChange={(e) => update('isDayOff', e.target.checked)}
        />
      </fieldset>

      <div className="event-form__actions">
        {onCancel && (
          <Button variant="ghost" onClick={onCancel} disabled={submitting}>
            Cancel
          </Button>
        )}
        <Button type="submit" variant="primary" loading={submitting}>
          {submitLabel}
        </Button>
      </div>
    </form>
  )
}
