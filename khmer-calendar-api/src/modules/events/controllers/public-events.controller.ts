import { Controller, Get, Header, Param, Query } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { Public } from '../../../common/decorators/auth.decorators.js';
import { UuidParam } from '../../../common/validation/params.js';
import { EventDto } from '../dto/event.dto.js';
import { PublicEventsQueryDto } from '../dto/event-queries.dto.js';
import { EventsService } from '../events.service.js';

@ApiTags('events')
@Public()
@Controller('events')
export class PublicEventsController {
  constructor(private readonly events: EventsService) {}

  @Get()
  @Header('Cache-Control', 'public, max-age=300')
  @ApiOperation({
    summary: 'Published events overlapping a date range (max 400 days)',
  })
  list(@Query() query: PublicEventsQueryDto): Promise<EventDto[]> {
    return this.events.listPublished(query.from, query.to, query.category);
  }

  @Get(':id')
  @Header('Cache-Control', 'public, max-age=300')
  get(@Param() { id }: UuidParam): Promise<EventDto> {
    return this.events.getPublished(id);
  }
}
