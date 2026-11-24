import { Injectable } from '@nestjs/common';
import type {
  Event,
  EventCategory,
  EventStatus,
  Prisma,
} from '../../generated/prisma/client.js';
import { civilDateToDb } from '../../database/date-mapping.js';
import { PrismaService } from '../../database/prisma.service.js';

export interface AdminEventFilter {
  from?: string;
  to?: string;
  status?: EventStatus;
  category?: EventCategory;
  q?: string;
}

export const PUBLIC_EVENTS_MAX_ROWS = 500;

/** All event persistence lives here; services never build Prisma queries themselves. */
@Injectable()
export class EventsRepository {
  constructor(private readonly prisma: PrismaService) {}

  findPublishedOverlapping(
    from: string,
    to: string,
    category?: EventCategory,
  ): Promise<Event[]> {
    return this.prisma.event.findMany({
      where: {
        status: 'PUBLISHED',
        startDate: { lte: civilDateToDb(to) },
        endDate: { gte: civilDateToDb(from) },
        ...(category ? { category } : {}),
      },
      orderBy: [{ startDate: 'asc' }, { titleEn: 'asc' }],
      take: PUBLIC_EVENTS_MAX_ROWS,
    });
  }

  findById(id: string): Promise<Event | null> {
    return this.prisma.event.findUnique({ where: { id } });
  }

  async findPage(
    filter: AdminEventFilter,
    page: number,
    limit: number,
  ): Promise<[Event[], number]> {
    const where: Prisma.EventWhereInput = {
      ...(filter.status ? { status: filter.status } : {}),
      ...(filter.category ? { category: filter.category } : {}),
      ...(filter.to ? { startDate: { lte: civilDateToDb(filter.to) } } : {}),
      ...(filter.from ? { endDate: { gte: civilDateToDb(filter.from) } } : {}),
      ...(filter.q
        ? {
            OR: [
              { titleEn: { contains: filter.q, mode: 'insensitive' } },
              { titleZh: { contains: filter.q } },
              { titleKm: { contains: filter.q } },
            ],
          }
        : {}),
    };
    return this.prisma.$transaction([
      this.prisma.event.findMany({
        where,
        orderBy: [{ startDate: 'asc' }, { titleEn: 'asc' }],
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.event.count({ where }),
    ]);
  }

  create(data: Prisma.EventUncheckedCreateInput): Promise<Event> {
    return this.prisma.event.create({ data });
  }

  update(id: string, data: Prisma.EventUncheckedUpdateInput): Promise<Event> {
    return this.prisma.event.update({ where: { id }, data });
  }

  async delete(id: string): Promise<void> {
    await this.prisma.event.delete({ where: { id } });
  }

  async findExistingSourceKeys(keys: string[]): Promise<Set<string>> {
    const rows = await this.prisma.event.findMany({
      where: { sourceKey: { in: keys } },
      select: { sourceKey: true },
    });
    return new Set(rows.map((r) => r.sourceKey!));
  }

  /** Inserts generated events atomically; rows whose sourceKey already exists are skipped. */
  createGenerated(rows: Prisma.EventUncheckedCreateInput[]): Promise<Event[]> {
    return this.prisma.$transaction(async (tx) => {
      await tx.event.createMany({ data: rows, skipDuplicates: true });
      return tx.event.findMany({
        where: { sourceKey: { in: rows.map((r) => r.sourceKey!) } },
        orderBy: { startDate: 'asc' },
      });
    });
  }
}
