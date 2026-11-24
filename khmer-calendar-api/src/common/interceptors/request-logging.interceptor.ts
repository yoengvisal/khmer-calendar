import {
  type CallHandler,
  type ExecutionContext,
  Injectable,
  Logger,
  type NestInterceptor,
} from '@nestjs/common';
import type { Response } from 'express';
import { type Observable, tap } from 'rxjs';
import type { AppRequest } from '../http/request-context.js';

/** One structured line per request. Never logs bodies, headers or query values (may contain PII/tokens). */
@Injectable()
export class RequestLoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP');

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const http = context.switchToHttp();
    const req = http.getRequest<AppRequest>();
    const started = performance.now();
    const log = (status: number) =>
      this.logger.log({
        msg: 'request completed',
        requestId: req.requestId,
        method: req.method,
        route: (req.route as { path?: string } | undefined)?.path ?? req.path,
        status,
        durationMs: Math.round(performance.now() - started),
        userId: req.user?.id,
      });
    return next.handle().pipe(
      tap({
        next: () => log(http.getResponse<Response>().statusCode),
        error: (err: { getStatus?: () => number }) =>
          log(err.getStatus?.() ?? 500),
      }),
    );
  }
}
