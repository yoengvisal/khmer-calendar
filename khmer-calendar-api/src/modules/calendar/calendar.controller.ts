import { Controller, Get, Header, Param } from '@nestjs/common';
import { ApiOkResponse, ApiTags } from '@nestjs/swagger';
import { Public } from '../../common/decorators/auth.decorators.js';
import {
  DateParam,
  YearMonthParam,
  YearParam,
} from '../../common/validation/params.js';
import { AppException } from '../../common/errors/app.exception.js';
import { parseIsoDate } from '../lunar/domain/civil-date.js';
import {
  MAX_SUPPORTED_YEAR,
  MIN_SUPPORTED_YEAR,
} from '../lunar/lunar-calendar.service.js';
import { CalendarService } from './calendar.service.js';
import {
  CalendarDayDto,
  CalendarMonthDto,
  NewYearDto,
} from './dto/calendar.dto.js';

@ApiTags('calendar')
@Public()
@Controller('calendar')
export class CalendarController {
  constructor(private readonly calendar: CalendarService) {}

  @Get('days/:date')
  @Header('Cache-Control', 'public, max-age=300')
  @ApiOkResponse({ type: CalendarDayDto })
  getDay(@Param() { date }: DateParam): Promise<CalendarDayDto> {
    const year = parseIsoDate(date)!.year;
    if (year < MIN_SUPPORTED_YEAR || year > MAX_SUPPORTED_YEAR) {
      throw AppException.validation([
        { field: 'date', messages: ['Supported years are 1900-2100'] },
      ]);
    }
    return this.calendar.getDay(date);
  }

  @Get('months/:year/:month')
  @Header('Cache-Control', 'public, max-age=300')
  @ApiOkResponse({ type: CalendarMonthDto })
  getMonth(
    @Param() { year, month }: YearMonthParam,
  ): Promise<CalendarMonthDto> {
    return this.calendar.getMonth(year, month);
  }

  @Get('new-year/:year')
  @Header('Cache-Control', 'public, max-age=86400')
  @ApiOkResponse({ type: NewYearDto })
  getNewYear(@Param() { year }: YearParam): NewYearDto {
    return this.calendar.getNewYear(year);
  }
}
