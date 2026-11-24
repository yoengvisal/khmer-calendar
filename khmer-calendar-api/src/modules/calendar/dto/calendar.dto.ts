import { ApiProperty } from '@nestjs/swagger';
import { EventSummaryDto } from '../../events/dto/event.dto.js';

export class LunarDateDto {
  @ApiProperty({ minimum: 1, maximum: 15 }) day: number;
  @ApiProperty({ enum: ['WAXING', 'WANING'] }) moonPhase: 'WAXING' | 'WANING';
  @ApiProperty({ minimum: 0, maximum: 13 }) monthIndex: number;
  @ApiProperty({ example: 'មិគសិរ' }) monthNameKm: string;
  @ApiProperty({ example: 'Migasir' }) monthNameEn: string;
  @ApiProperty() beYear: number;
  @ApiProperty() jsYear: number;
  @ApiProperty({ minimum: 0, maximum: 11 }) animalYear: number;
  @ApiProperty() animalYearNameKm: string;
  @ApiProperty() animalYearNameEn: string;
  @ApiProperty({ minimum: 0, maximum: 9 }) sak: number;
  @ApiProperty() sakNameKm: string;
  @ApiProperty({ description: 'ថ្ងៃសីល (Buddhist holy day)' }) isHolyDay: boolean;
  @ApiProperty() formattedKm: string;
}

export class CalendarDayDto {
  @ApiProperty({ example: '2026-11-15' }) date: string;
  @ApiProperty({ description: '0 = Sunday' }) dayOfWeek: number;
  @ApiProperty({ type: LunarDateDto }) lunar: LunarDateDto;
  @ApiProperty({ type: [EventSummaryDto] }) events: EventSummaryDto[];
}

export class CalendarMonthDto {
  @ApiProperty() year: number;
  @ApiProperty() month: number;
  @ApiProperty({ type: [CalendarDayDto] }) days: CalendarDayDto[];
}

export class NewYearDto {
  @ApiProperty() gregorianYear: number;
  @ApiProperty({ example: '2026-04-14' }) mohaSongkran: string;
  @ApiProperty({ example: '10:48' }) time: string;
  @ApiProperty({ example: '2026-04-16' }) lerngSak: string;
  @ApiProperty({ enum: [3, 4] }) numberOfDays: number;
}
