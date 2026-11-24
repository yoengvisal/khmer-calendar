import { ApiPropertyOptional, ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  MaxLength,
  Max,
  Min,
} from 'class-validator';
import { EventCategory, EventStatus } from '../../../generated/prisma/enums.js';
import { IsCivilDate } from '../../../common/validation/validation.js';

export class PublicEventsQueryDto {
  @ApiProperty({ example: '2026-01-01' }) @IsCivilDate() from: string;
  @ApiProperty({ example: '2026-12-31' }) @IsCivilDate() to: string;
  @ApiPropertyOptional({ enum: EventCategory })
  @IsOptional()
  @IsEnum(EventCategory)
  category?: EventCategory;
}

export class AdminEventsQueryDto {
  @ApiPropertyOptional() @IsOptional() @IsCivilDate() from?: string;
  @ApiPropertyOptional() @IsOptional() @IsCivilDate() to?: string;
  @ApiPropertyOptional({ enum: EventStatus })
  @IsOptional()
  @IsEnum(EventStatus)
  status?: EventStatus;
  @ApiPropertyOptional({ enum: EventCategory })
  @IsOptional()
  @IsEnum(EventCategory)
  category?: EventCategory;
  @ApiPropertyOptional({ description: 'Search in Khmer/English titles' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  q?: string;
  @ApiPropertyOptional({ default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page = 1;
  @ApiPropertyOptional({ default: 20, maximum: 100 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit = 20;
}

export class GenerateEventsDto {
  @ApiProperty({ example: 2027 }) @IsInt() @Min(1900) @Max(2100) year: number;
}
