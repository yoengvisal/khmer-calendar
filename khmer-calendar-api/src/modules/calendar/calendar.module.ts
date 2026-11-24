import { Module } from '@nestjs/common';
import { EventsModule } from '../events/events.module.js';
import { LunarModule } from '../lunar/lunar.module.js';
import { CalendarController } from './calendar.controller.js';
import { CalendarService } from './calendar.service.js';

@Module({
  imports: [LunarModule, EventsModule],
  controllers: [CalendarController],
  providers: [CalendarService],
})
export class CalendarModule {}
