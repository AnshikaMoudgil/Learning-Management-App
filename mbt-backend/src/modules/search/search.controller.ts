import { Controller, Get, Query, Res, UseGuards } from '@nestjs/common';
import type { Response } from 'express';
import { AuthGuard } from '../../common/guards/auth.guard';
import { DeviceGuard } from '../../common/guards/device.guard';
import { SearchService } from './search.service';

@Controller('api/v1/search')
@UseGuards(AuthGuard, DeviceGuard)
export class SearchController {
  constructor(private readonly searchService: SearchService) {}

  @Get()
  async search(
    @Query('q') query: string,
    @Res({ passthrough: true }) res?: Response,
  ) {
    if (!query) {
      return { courses: [], recordings: [], teachers: [] };
    }
    res?.setHeader(
      'Cache-Control',
      's-maxage=30, stale-while-revalidate=120',
    );
    return this.searchService.globalSearch(query);
  }
}
