import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import {
  CurrentUser,
  Roles,
} from '../../../common/decorators/auth.decorators.js';
import type { AuthenticatedUser } from '../../../common/http/request-context.js';
import type { Paginated } from '../../../common/http/paginated.js';
import { UuidParam } from '../../../common/validation/params.js';
import { EventDto } from '../dto/event.dto.js';
import {
  AdminEventsQueryDto,
  GenerateEventsDto,
} from '../dto/event-queries.dto.js';
import { CreateEventDto, UpdateEventDto } from '../dto/write-event.dto.js';
import { EventsService } from '../events.service.js';

@ApiTags('admin / events')
@ApiBearerAuth()
@Roles('ADMIN', 'EDITOR')
@Controller('admin/events')
export class AdminEventsController {
  constructor(private readonly events: EventsService) {}

  @Get()
  list(@Query() query: AdminEventsQueryDto): Promise<Paginated<EventDto>> {
    return this.events.list(query);
  }

  @Get(':id')
  get(@Param() { id }: UuidParam): Promise<EventDto> {
    return this.events.get(id);
  }

  @Post()
  create(
    @Body() dto: CreateEventDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<EventDto> {
    return this.events.create(dto, user.id);
  }

  @Post('generate')
  @HttpCode(200)
  @ApiOperation({
    summary:
      'Draft the given year’s holidays from built-in lunar and fixed-date rules (idempotent)',
  })
  generate(
    @Body() dto: GenerateEventsDto,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.events.generateForYear(dto.year, user.id);
  }

  @Patch(':id')
  update(
    @Param() { id }: UuidParam,
    @Body() dto: UpdateEventDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<EventDto> {
    return this.events.update(id, dto, user.id);
  }

  @Delete(':id')
  @Roles('ADMIN')
  remove(@Param() { id }: UuidParam) {
    return this.events.remove(id);
  }
}
