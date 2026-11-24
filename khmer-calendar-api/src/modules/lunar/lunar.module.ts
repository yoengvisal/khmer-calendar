import { Module } from '@nestjs/common';
import { LunarCalendarService } from './lunar-calendar.service.js';

@Module({
  providers: [LunarCalendarService],
  exports: [LunarCalendarService],
})
export class LunarModule {}
