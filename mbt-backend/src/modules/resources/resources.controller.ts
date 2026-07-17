import { Controller, Get, Param, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '../../common/guards/auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { DeviceGuard } from '../../common/guards/device.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { ResourcesService } from './resources.service';
import type { AuthenticatedRequest } from '../../common/types/authenticated-request.type';

@Controller('api/v1/courses/:courseId/resources')
@UseGuards(AuthGuard, RolesGuard, DeviceGuard)
@Roles('learner', 'admin', 'superadmin', 'instructor')
export class ResourcesController {
  constructor(private readonly resourcesService: ResourcesService) {}

  @Get()
  getCourseResources(
    @Param('courseId') courseId: string,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.resourcesService.getCourseResources(courseId, req.user.id);
  }
}
