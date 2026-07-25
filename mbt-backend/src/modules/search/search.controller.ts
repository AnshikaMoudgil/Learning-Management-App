import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { AuthGuard } from '../../common/guards/auth.guard';
import { DeviceGuard } from '../../common/guards/device.guard';
import { ThrottleGuard } from '../../common/guards/throttle.guard';
import { Throttle } from '../../common/decorators/throttle.decorator';
import { SearchService } from './search.service';

@Controller('api/v1/search')
@UseGuards(AuthGuard, DeviceGuard, ThrottleGuard)
export class SearchController {
  constructor(private readonly searchService: SearchService) {}

  @Get()
  @Throttle({ limit: 30, windowMs: 60_000 })
  async search(@Query('q') query: string) {
    if (!query) {
      return { courses: [], recordings: [], teachers: [] };
    }
    return this.searchService.globalSearch(query);
  }
}
