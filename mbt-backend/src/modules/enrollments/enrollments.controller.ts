import { Controller, Get, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '../../common/guards/auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { DeviceGuard } from '../../common/guards/device.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { EnrollmentsService } from './enrollments.service';
import type { AuthenticatedRequest } from '../../common/types/authenticated-request.type';

@Controller('api/v1/enrollments')
@UseGuards(AuthGuard, RolesGuard, DeviceGuard)
@Roles('learner', 'admin', 'superadmin', 'instructor')
export class EnrollmentsController {
  constructor(private readonly enrollmentsService: EnrollmentsService) {}

  @Get()
  getMyEnrollments(@Req() req: AuthenticatedRequest) {
    return this.enrollmentsService.getMyEnrollments(req.user.id);
  }
}
