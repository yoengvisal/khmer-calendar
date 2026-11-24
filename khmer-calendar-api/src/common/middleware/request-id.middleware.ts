import { Injectable, type NestMiddleware } from '@nestjs/common';
import { randomUUID } from 'node:crypto';
import type { NextFunction, Response } from 'express';
import type { AppRequest } from '../http/request-context.js';

const SAFE_REQUEST_ID = /^[A-Za-z0-9-]{8,64}$/;

/** Propagates a client-supplied x-request-id (if well-formed) or generates one. */
@Injectable()
export class RequestIdMiddleware implements NestMiddleware {
  use(req: AppRequest, res: Response, next: NextFunction) {
    const incoming = req.header('x-request-id');
    req.requestId =
      incoming && SAFE_REQUEST_ID.test(incoming) ? incoming : randomUUID();
    res.setHeader('x-request-id', req.requestId);
    next();
  }
}
