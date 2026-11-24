import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsInt, IsUUID, Max, Min } from 'class-validator';
import { IsCivilDate } from './validation.js';

export class UuidParam {
  @ApiProperty({ format: 'uuid' }) @IsUUID() id: string;
}

export class DateParam {
  @ApiProperty({ example: '2026-11-15' }) @IsCivilDate() date: string;
}

export class YearParam {
  @ApiProperty({ example: 2026 })
  @Type(() => Number)
  @IsInt()
  @Min(1900)
  @Max(2100)
  year: number;
}

export class YearMonthParam extends YearParam {
  @ApiProperty({ example: 11 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(12)
  month: number;
}
