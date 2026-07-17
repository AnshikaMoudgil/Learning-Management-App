import { Controller, Get, Post, Param, Body, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '../../common/guards/auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { DeviceGuard } from '../../common/guards/device.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { MyCoursesService } from './my-courses.service';
import type { AuthenticatedRequest } from '../../common/types/authenticated-request.type';

@Controller('api/v1/my-courses')
@UseGuards(AuthGuard, RolesGuard, DeviceGuard)
@Roles('learner', 'admin', 'superadmin', 'instructor')
export class MyCoursesController {
  constructor(private readonly myCoursesService: MyCoursesService) {}

  @Get(':courseId/content')
  getCourseContent(
    @Param('courseId') courseId: string,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.myCoursesService.getCourseContent(courseId, req.user.id);
  }

  @Post(':courseId/lessons/:lessonId/progress')
  updateProgress(
    @Param('courseId') courseId: string,
    @Param('lessonId') lessonId: string,
    @Body() body: { is_completed: boolean; watched_seconds?: number },
    @Req() req: AuthenticatedRequest,
  ) {
    return this.myCoursesService.updateLessonProgress(
      courseId,
      lessonId,
      req.user.id,
      body.is_completed,
      body.watched_seconds,
    );
  }
}
