import {
  type CallHandler,
  type ExecutionContext,
  Injectable,
  type NestInterceptor,
} from '@nestjs/common';
import { map, type Observable } from 'rxjs';
import { Paginated } from '../http/paginated.js';

/** Wraps successful responses in `{ success: true, data, meta? }`. */
@Injectable()
export class ResponseEnvelopeInterceptor implements NestInterceptor {
  intercept(
    _context: ExecutionContext,
    next: CallHandler,
  ): Observable<unknown> {
    return next.handle().pipe(
      map((body: unknown) => {
        if (body instanceof Paginated) {
          return { success: true, data: body.items, meta: body.meta };
        }
        return { success: true, data: body ?? null };
      }),
    );
  }
}
