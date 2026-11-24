import { Injectable } from '@nestjs/common';
import { dbDateToIso } from '../../database/date-mapping.js';
import { EventSummaryDto } from '../events/dto/event.dto.js';
import { EventsService } from '../events/events.service.js';
import {
  type CivilDate,
  daysInGregorianMonth,
  formatIsoDate,
  parseIsoDate,
} from '../lunar/domain/civil-date.js';
import {
  formatLunarKm,
  lunarNames,
} from '../lunar/domain/khmer-lunar.formatter.js';
import { LunarCalendarService } from '../lunar/lunar-calendar.service.js';
import type {
  CalendarDayDto,
  CalendarMonthDto,
  LunarDateDto,
  NewYearDto,
} from './dto/calendar.dto.js';

@Injectable()
export class CalendarService {
  constructor(
    private readonly lunar: LunarCalendarService,
    private readonly events: EventsService,
  ) {}

  async getDay(iso: string): Promise<CalendarDayDto> {
    const events = await this.events.findPublishedEntities(iso, iso);
    return this.buildDay(parseIsoDate(iso)!, events.map(EventSummaryDto.from));
  }

  async getMonth(year: number, month: number): Promise<CalendarMonthDto> {
    const last = daysInGregorianMonth(year, month);
    const from = formatIsoDate({ year, month, day: 1 });
    const to = formatIsoDate({ year, month, day: last });
    const events = (await this.events.findPublishedEntities(from, to)).map(
      (e) => ({
        summary: EventSummaryDto.from(e),
        start: dbDateToIso(e.startDate),
        end: dbDateToIso(e.endDate),
      }),
    );

    const days: CalendarDayDto[] = [];
    for (let day = 1; day <= last; day++) {
      const date = { year, month, day };
      const iso = formatIsoDate(date);
      // ISO strings compare lexicographically in date order.
      days.push(
        this.buildDay(
          date,
          events
            .filter((e) => e.start <= iso && e.end >= iso)
            .map((e) => e.summary),
        ),
      );
    }
    return { year, month, days };
  }

  getNewYear(year: number): NewYearDto {
    const ny = this.lunar.newYear(year);
    const pad = (n: number) => String(n).padStart(2, '0');
    return {
      gregorianYear: year,
      mohaSongkran: formatIsoDate(ny.mohaSongkran),
      time: `${pad(ny.hour)}:${pad(ny.minute)}`,
      lerngSak: formatIsoDate(ny.lerngSak),
      numberOfDays: ny.numberOfDays,
    };
  }

  private buildDay(date: CivilDate, events: EventSummaryDto[]): CalendarDayDto {
    const l = this.lunar.toLunar(date);
    const lunar: LunarDateDto = {
      day: l.day,
      moonPhase: lunarNames.phase(l.moonPhase),
      monthIndex: l.monthIndex,
      monthNameKm: lunarNames.monthKm(l.monthIndex),
      monthNameEn: lunarNames.monthEn(l.monthIndex),
      beYear: l.beYear,
      jsYear: l.jsYear,
      animalYear: l.animalYear,
      animalYearNameKm: lunarNames.animalKm(l.animalYear),
      animalYearNameEn: lunarNames.animalEn(l.animalYear),
      sak: l.sak,
      sakNameKm: lunarNames.sakKm(l.sak),
      isHolyDay: l.isHolyDay,
      formattedKm: formatLunarKm(l),
    };
    return { date: formatIsoDate(date), dayOfWeek: l.dayOfWeek, lunar, events };
  }
}
