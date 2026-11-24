import {
  type ArgumentsHost,
  Catch,
  type ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import type { Response } from 'express';
import { Prisma } from '../../generated/prisma/client.js';
import { ErrorCode } from '../errors/error-codes.js';
import type { AppRequest } from '../http/request-context.js';

interface ErrorBody {
  code: string;
  message: string;
  details: unknown[];
}

const STATUS_CODES: Record<number, ErrorBody> = {
  400: {
    code: ErrorCode.VALIDATION_ERROR,
    message: 'The request is invalid',
    details: [],
  },
  401: {
    code: ErrorCode.UNAUTHORIZED,
    message: 'Authentication required',
    details: [],
  },
  403: {
    code: ErrorCode.FORBIDDEN,
    message: 'You do not have permission to perform this action',
    details: [],
  },
  404: {
    code: ErrorCode.NOT_FOUND,
    message: 'Resource not found',
    details: [],
  },
  409: {
    code: ErrorCode.CONFLICT,
    message: 'The request conflicts with the current state',
    details: [],
  },
  429: {
    code: ErrorCode.RATE_LIMITED,
    message: 'Too many requests, please try again later',
    details: [],
  },
};

/** Single place that turns any thrown error into the safe public error envelope. */
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger('Exceptions');

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const req = ctx.getRequest<AppRequest>();
    const res = ctx.getResponse<Response>();
    const { status, body } = this.toErrorBody(exception);

    if (status >= 500) {
      this.logger.error({
        msg: 'unhandled error',
        requestId: req.requestId,
        method: req.method,
        path: req.path,
        error:
          exception instanceof Error ? exception.message : String(exception),
        stack: exception instanceof Error ? exception.stack : undefined,
      });
    }

    res
      .status(status)
      .json({ success: false, error: { ...body, requestId: req.requestId } });
  }

  private toErrorBody(exception: unknown): { status: number; body: ErrorBody } {
    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const response = exception.getResponse();
      const fallback = STATUS_CODES[status] ?? {
        code: status >= 500 ? ErrorCode.INTERNAL_ERROR : 'HTTP_ERROR',
        message:
          status >= 500 ? 'An unexpected error occurred' : exception.message,
        details: [],
      };
      if (
        typeof response === 'object' &&
        response !== null &&
        'code' in response
      ) {
        const r = response as Partial<ErrorBody>;
        return {
          status,
          body: {
            code: r.code ?? fallback.code,
            message: r.message ?? fallback.message,
            details: r.details ?? [],
          },
        };
      }
      return { status, body: fallback };
    }

    if (exception instanceof Prisma.PrismaClientKnownRequestError) {
      if (exception.code === 'P2002') {
        return {
          status: HttpStatus.CONFLICT,
          body: {
            ...STATUS_CODES[409],
            message: 'A record with these values already exists',
          },
        };
      }
      if (exception.code === 'P2025') {
        return { status: HttpStatus.NOT_FOUND, body: STATUS_CODES[404] };
      }
    }

    return {
      status: HttpStatus.INTERNAL_SERVER_ERROR,
      body: {
        code: ErrorCode.INTERNAL_ERROR,
        message: 'An unexpected error occurred',
        details: [],
      },
    };
  }
}
