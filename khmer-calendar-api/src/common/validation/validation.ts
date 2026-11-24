import { ValidationPipe, type ValidationError } from '@nestjs/common';
import { registerDecorator, type ValidationOptions } from 'class-validator';
import { parseIsoDate } from '../../modules/lunar/domain/civil-date.js';
import {
  AppException,
  type FieldErrorDetail,
} from '../errors/app.exception.js';

function flatten(errors: ValidationError[], parent = ''): FieldErrorDetail[] {
  return errors.flatMap((e) => {
    const field = parent ? `${parent}.${e.property}` : e.property;
    const own = e.constraints
      ? [{ field, messages: Object.values(e.constraints) }]
      : [];
    return [...own, ...flatten(e.children ?? [], field)];
  });
}

/** Global pipe: strips unknown props, rejects non-whitelisted ones, converts primitives explicitly. */
export function createValidationPipe() {
  return new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
    transformOptions: { enableImplicitConversion: false },
    exceptionFactory: (errors) => AppException.validation(flatten(errors)),
  });
}

/** Strict civil date `YYYY-MM-DD` that also exists on the calendar (rejects 2025-02-30). */
export function IsCivilDate(options?: ValidationOptions) {
  return (object: object, propertyName: string) =>
    registerDecorator({
      name: 'isCivilDate',
      target: object.constructor,
      propertyName,
      options: {
        message: `${propertyName} must be a valid date in YYYY-MM-DD format`,
        ...options,
      },
      validator: {
        validate: (value: unknown) =>
          typeof value === 'string' && parseIsoDate(value) !== null,
      },
    });
}
