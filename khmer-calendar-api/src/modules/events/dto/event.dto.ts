import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import type { Event } from '../../../generated/prisma/client.js';
import { EventCategory, EventStatus } from '../../../generated/prisma/enums.js';
import { dbDateToIso } from '../../../database/date-mapping.js';

export class EventSummaryDto {
  @ApiProperty({ format: 'uuid' }) id: string;
  @ApiProperty() titleKm: string;
  @ApiProperty() titleEn: string;
  @ApiPropertyOptional({
    type: String,
    nullable: true,
    description: 'Simplified Chinese; fall back to titleEn when null',
  })
  titleZh: string | null;
  @ApiProperty({ enum: EventCategory }) category: EventCategory;
  @ApiProperty({ example: '2026-04-14' }) startDate: string;
  @ApiProperty({ example: '2026-04-16' }) endDate: string;
  @ApiProperty() isDayOff: boolean;

  static from(this: void, e: Event): EventSummaryDto {
    return summaryFields(e);
  }
}

function summaryFields(e: Event) {
  return {
    id: e.id,
    titleKm: e.titleKm,
    titleEn: e.titleEn,
    titleZh: e.titleZh,
    category: e.category,
    startDate: dbDateToIso(e.startDate),
    endDate: dbDateToIso(e.endDate),
    isDayOff: e.isDayOff,
  };
}

export class EventDto extends EventSummaryDto {
  @ApiPropertyOptional({ type: String, nullable: true }) descriptionKm:
    string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) descriptionEn:
    string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) descriptionZh:
    string | null;
  @ApiProperty({ enum: EventStatus }) status: EventStatus;
  @ApiPropertyOptional({ type: String, nullable: true }) sourceKey:
    string | null;
  @ApiProperty() createdAt: string;
  @ApiProperty() updatedAt: string;
  @ApiPropertyOptional({ type: String, nullable: true }) publishedAt:
    string | null;

  static override from(this: void, e: Event): EventDto {
    return {
      ...summaryFields(e),
      descriptionKm: e.descriptionKm,
      descriptionEn: e.descriptionEn,
      descriptionZh: e.descriptionZh,
      status: e.status,
      sourceKey: e.sourceKey,
      createdAt: e.createdAt.toISOString(),
      updatedAt: e.updatedAt.toISOString(),
      publishedAt: e.publishedAt?.toISOString() ?? null,
    };
  }
}
