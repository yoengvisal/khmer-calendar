import { ApiProperty, ApiPropertyOptional, PartialType } from '@nestjs/swagger';
import {
  IsBoolean,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';
import { EventCategory, EventStatus } from '../../../generated/prisma/enums.js';
import { IsCivilDate } from '../../../common/validation/validation.js';

export class CreateEventDto {
  @ApiProperty({ maxLength: 200 })
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  titleKm: string;
  @ApiProperty({ maxLength: 200 })
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  titleEn: string;
  @ApiPropertyOptional({
    type: String,
    nullable: true,
    maxLength: 200,
    description: 'Simplified Chinese',
  })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  titleZh?: string | null;
  @ApiPropertyOptional({ type: String, nullable: true })
  @IsOptional()
  @IsString()
  @MaxLength(5000)
  descriptionKm?: string | null;
  @ApiPropertyOptional({ type: String, nullable: true })
  @IsOptional()
  @IsString()
  @MaxLength(5000)
  descriptionEn?: string | null;
  @ApiPropertyOptional({ type: String, nullable: true })
  @IsOptional()
  @IsString()
  @MaxLength(5000)
  descriptionZh?: string | null;
  @ApiProperty({ enum: EventCategory })
  @IsEnum(EventCategory)
  category: EventCategory;
  @ApiProperty({ example: '2026-05-01' }) @IsCivilDate() startDate: string;
  @ApiProperty({ example: '2026-05-01' }) @IsCivilDate() endDate: string;
  @ApiPropertyOptional({ default: false })
  @IsOptional()
  @IsBoolean()
  isDayOff?: boolean;
  @ApiPropertyOptional({ enum: EventStatus, default: EventStatus.DRAFT })
  @IsOptional()
  @IsEnum(EventStatus)
  status?: EventStatus;
}

export class UpdateEventDto extends PartialType(CreateEventDto) {}
