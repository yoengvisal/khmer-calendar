import { HttpException, HttpStatus } from '@nestjs/common';
import { ErrorCode } from './error-codes.js';

export interface FieldErrorDetail {
  field: string;
  messages: string[];
}

/** Domain/application error with a stable machine-readable code and a safe message. */
export class AppException extends HttpException {
  constructor(
    readonly code: ErrorCode,
    message: string,
    status: HttpStatus,
    readonly details: unknown[] = [],
  ) {
    super({ code, message, details }, status);
  }

  static notFound(what = 'Resource') {
    return new AppException(
      ErrorCode.NOT_FOUND,
      `${what} not found`,
      HttpStatus.NOT_FOUND,
    );
  }

  static conflict(message: string) {
    return new AppException(ErrorCode.CONFLICT, message, HttpStatus.CONFLICT);
  }

  static validation(
    details: FieldErrorDetail[],
    message = 'The request is invalid',
  ) {
    return new AppException(
      ErrorCode.VALIDATION_ERROR,
      message,
      HttpStatus.BAD_REQUEST,
      details,
    );
  }

  static unauthorized(
    code: ErrorCode = ErrorCode.UNAUTHORIZED,
    message = 'Authentication required',
  ) {
    return new AppException(code, message, HttpStatus.UNAUTHORIZED);
  }

  static forbidden(
    message = 'You do not have permission to perform this action',
  ) {
    return new AppException(ErrorCode.FORBIDDEN, message, HttpStatus.FORBIDDEN);
  }
}
