import {
  Controller,
  Get,
  Param,
  Query,
  Req,
  Res,
  UseGuards,
} from '@nestjs/common';
import type { Response } from 'express';
import { AuthGuard } from '../../common/guards/auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { DeviceGuard } from '../../common/guards/device.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CoursesService } from './courses.service';
import type { CourseLevel } from '../../common/types/course.type';
import type { AuthenticatedRequest } from '../../common/types/authenticated-request.type';

@Controller('api/v1/courses')
@UseGuards(AuthGuard, RolesGuard, DeviceGuard)
@Roles('learner', 'admin', 'superadmin', 'instructor')
export class CoursesController {
  constructor(private readonly coursesService: CoursesService) {}

  @Get()
  async findAll(
    @Query('category') category?: string,
    @Query('level') level?: CourseLevel,
    @Query('search') search?: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
    @Res({ passthrough: true }) res?: Response,
  ) {
    const result = await this.coursesService.findAll({
      category,
      level,
      is_published: true,
      search,
      page: page ? +page : undefined,
      limit: limit ? +limit : undefined,
    });
    res?.setHeader('Cache-Control', 's-maxage=60, stale-while-revalidate=300');
    return result;
  }

  @Get(':idOrSlug')
  async findOne(
    @Param('idOrSlug') idOrSlug: string,
    @Req() req: AuthenticatedRequest,
    @Res({ passthrough: true }) res?: Response,
  ) {
    const result = await this.coursesService.findByIdOrSlug(
      idOrSlug,
      req.user.id,
    );
    res?.setHeader('Cache-Control', 's-maxage=300, stale-while-revalidate=600');
    return result;
  }
}
