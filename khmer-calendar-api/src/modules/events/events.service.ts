import { Injectable } from '@nestjs/common';
import type {
  Event,
  EventCategory,
  EventStatus,
} from '../../generated/prisma/client.js';
import { AppException } from '../../common/errors/app.exception.js';
import { Paginated } from '../../common/http/paginated.js';
import { civilDateToDb } from '../../database/date-mapping.js';
import {
  daysBetween,
  formatIsoDate,
  parseIsoDate,
} from '../lunar/domain/civil-date.js';
import { LunarCalendarService } from '../lunar/lunar-calendar.service.js';
import { generateHolidayCandidates } from './domain/holiday-rules.js';
import { EventDto } from './dto/event.dto.js';
import type { AdminEventsQueryDto } from './dto/event-queries.dto.js';
import type { CreateEventDto, UpdateEventDto } from './dto/write-event.dto.js';
import { EventsRepository } from './events.repository.js';

export const MAX_PUBLIC_RANGE_DAYS = 400;

@Injectable()
export class EventsService {
  constructor(
    private readonly events: EventsRepository,
    private readonly lunar: LunarCalendarService,
  ) {}

  // ---- public ---------------------------------------------------------------

  async listPublished(
    from: string,
    to: string,
    category?: EventCategory,
  ): Promise<EventDto[]> {
    assertRange(from, to, 'to', MAX_PUBLIC_RANGE_DAYS);
    const rows = await this.events.findPublishedOverlapping(from, to, category);
    return rows.map(EventDto.from);
  }

  /** Raw rows for internal composition (e.g. the calendar month view). */
  findPublishedEntities(from: string, to: string): Promise<Event[]> {
    return this.events.findPublishedOverlapping(from, to);
  }

  async getPublished(id: string): Promise<EventDto> {
    const event = await this.events.findById(id);
    if (!event || event.status !== 'PUBLISHED')
      throw AppException.notFound('Event');
    return EventDto.from(event);
  }

  // ---- admin ----------------------------------------------------------------

  async list(query: AdminEventsQueryDto): Promise<Paginated<EventDto>> {
    if (query.from && query.to) assertRange(query.from, query.to, 'to');
    const [rows, total] = await this.events.findPage(
      query,
      query.page,
      query.limit,
    );
    return new Paginated(
      rows.map(EventDto.from),
      query.page,
      query.limit,
      total,
    );
  }

  async get(id: string): Promise<EventDto> {
    return EventDto.from(await this.findOrThrow(id));
  }

  async create(dto: CreateEventDto, actorId: string): Promise<EventDto> {
    assertRange(dto.startDate, dto.endDate);
    const status = dto.status ?? 'DRAFT';
    const event = await this.events.create({
      titleKm: dto.titleKm.trim(),
      titleEn: dto.titleEn.trim(),
      titleZh: optionalText(dto.titleZh),
      descriptionKm: dto.descriptionKm ?? null,
      descriptionEn: dto.descriptionEn ?? null,
      descriptionZh: optionalText(dto.descriptionZh),
      category: dto.category,
      status,
      startDate: civilDateToDb(dto.startDate),
      endDate: civilDateToDb(dto.endDate),
      isDayOff: dto.isDayOff ?? false,
      publishedAt: status === 'PUBLISHED' ? new Date() : null,
      createdById: actorId,
      updatedById: actorId,
    });
    return EventDto.from(event);
  }

  async update(
    id: string,
    dto: UpdateEventDto,
    actorId: string,
  ): Promise<EventDto> {
    const existing = await this.findOrThrow(id);
    const startDate =
      dto.startDate ?? existing.startDate.toISOString().slice(0, 10);
    const endDate = dto.endDate ?? existing.endDate.toISOString().slice(0, 10);
    assertRange(startDate, endDate);

    const event = await this.events.update(id, {
      ...(dto.titleKm !== undefined ? { titleKm: dto.titleKm.trim() } : {}),
      ...(dto.titleEn !== undefined ? { titleEn: dto.titleEn.trim() } : {}),
      ...(dto.descriptionKm !== undefined
        ? { descriptionKm: dto.descriptionKm }
        : {}),
      ...(dto.descriptionEn !== undefined
        ? { descriptionEn: dto.descriptionEn }
        : {}),
      ...(dto.titleZh !== undefined
        ? { titleZh: optionalText(dto.titleZh) }
        : {}),
      ...(dto.descriptionZh !== undefined
        ? { descriptionZh: optionalText(dto.descriptionZh) }
        : {}),
      ...(dto.category !== undefined ? { category: dto.category } : {}),
      ...(dto.isDayOff !== undefined ? { isDayOff: dto.isDayOff } : {}),
      ...(dto.status !== undefined
        ? {
            status: dto.status,
            publishedAt: publishedAtFor(existing, dto.status),
          }
        : {}),
      startDate: civilDateToDb(startDate),
      endDate: civilDateToDb(endDate),
      updatedById: actorId,
    });
    return EventDto.from(event);
  }

  async remove(id: string): Promise<{ deleted: true }> {
    await this.findOrThrow(id);
    await this.events.delete(id);
    return { deleted: true };
  }

  /** Drafts the year's holidays from built-in rules. Safe to run repeatedly. */
  async generateForYear(
    year: number,
    actorId: string,
  ): Promise<{ created: EventDto[]; skipped: string[] }> {
    const candidates = generateHolidayCandidates(year, this.lunar);
    const existing = await this.events.findExistingSourceKeys(
      candidates.map((c) => c.sourceKey),
    );
    const fresh = candidates.filter((c) => !existing.has(c.sourceKey));
    const created = fresh.length
      ? await this.events.createGenerated(
          fresh.map((c) => ({
            titleKm: c.titleKm,
            titleEn: c.titleEn,
            titleZh: c.titleZh,
            category: c.category,
            isDayOff: c.isDayOff,
            status: 'DRAFT' as const,
            sourceKey: c.sourceKey,
            startDate: civilDateToDb(c.startDate),
            endDate: civilDateToDb(c.endDate),
            createdById: actorId,
            updatedById: actorId,
          })),
        )
      : [];
    return {
      created: created.map(EventDto.from),
      skipped: [...existing].sort(),
    };
  }

  private async findOrThrow(id: string): Promise<Event> {
    const event = await this.events.findById(id);
    if (!event) throw AppException.notFound('Event');
    return event;
  }
}

/** Optional free text: trimmed, and blank becomes null. */
function optionalText(value: string | null | undefined): string | null {
  const trimmed = value?.trim();
  return trimmed ? trimmed : null;
}

function publishedAtFor(existing: Event, nextStatus: EventStatus): Date | null {
  if (nextStatus !== 'PUBLISHED') return existing.publishedAt;
  return existing.publishedAt ?? new Date();
}

function assertRange(
  from: string,
  to: string,
  endField = 'endDate',
  maxDays?: number,
) {
  const a = parseIsoDate(from);
  const b = parseIsoDate(to);
  if (!a || !b)
    throw AppException.validation([
      { field: 'from', messages: ['Invalid date range'] },
    ]);
  const span = daysBetween(a, b);
  if (span < 0) {
    throw AppException.validation([
      {
        field: endField,
        messages: ['End date must be on or after start date'],
      },
    ]);
  }
  if (maxDays !== undefined && span > maxDays) {
    throw AppException.validation([
      {
        field: endField,
        messages: [
          `Date range must not exceed ${maxDays} days (from ${formatIsoDate(a)})`,
        ],
      },
    ]);
  }
}
