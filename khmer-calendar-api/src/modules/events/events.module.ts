import { Module } from '@nestjs/common';
import { LunarModule } from '../lunar/lunar.module.js';
import { AdminEventsController } from './controllers/admin-events.controller.js';
import { PublicEventsController } from './controllers/public-events.controller.js';
import { EventsRepository } from './events.repository.js';
import { EventsService } from './events.service.js';

@Module({
  imports: [LunarModule],
  controllers: [PublicEventsController, AdminEventsController],
  providers: [EventsRepository, EventsService],
  exports: [EventsService],
})
export class EventsModule {}
