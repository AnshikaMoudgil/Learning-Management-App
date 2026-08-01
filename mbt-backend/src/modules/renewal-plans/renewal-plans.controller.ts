import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { AuthGuard } from '../../common/guards/auth.guard';
import { DeviceGuard } from '../../common/guards/device.guard';
import { RenewalPlansService } from './renewal-plans.service';
import { QueryRenewalPlansDto } from './dto/query-renewal-plans.dto';

@Controller('api/v1/renewal-plans')
@UseGuards(AuthGuard, DeviceGuard)
export class RenewalPlansController {
  constructor(private readonly renewalPlansService: RenewalPlansService) {}

  @Get()
  getPlans(@Query() query: QueryRenewalPlansDto) {
    return this.renewalPlansService.getPlansForCourse(query.courseId);
  }
}
