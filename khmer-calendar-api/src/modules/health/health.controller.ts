import { Controller, Get, HttpStatus, Res } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { SkipThrottle } from '@nestjs/throttler';
import type { Response } from 'express';
import { Public } from '../../common/decorators/auth.decorators.js';
import { PrismaService } from '../../database/prisma.service.js';

@ApiTags('health')
@Public()
@SkipThrottle()
@Controller('health')
export class HealthController {
  constructor(private readonly prisma: PrismaService) {}

  /** Readiness: 200 when the database answers, 503 otherwise (for load balancers / orchestrators). */
  @Get()
  async check(@Res({ passthrough: true }) res: Response) {
    let database: 'up' | 'down' = 'up';
    try {
      await this.prisma.$queryRaw`SELECT 1`;
    } catch {
      database = 'down';
    }
    res.setHeader('Cache-Control', 'no-store');
    if (database === 'down') res.status(HttpStatus.SERVICE_UNAVAILABLE);
    return { status: database === 'up' ? 'ok' : 'degraded', database };
  }
}
