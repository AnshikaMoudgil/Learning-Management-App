import { Injectable, NotFoundException } from '@nestjs/common';
import { RenewalPlansRepository } from './renewal-plans.repository';

@Injectable()
export class RenewalPlansService {
  constructor(
    private readonly renewalPlansRepository: RenewalPlansRepository,
  ) {}

  async getPlansForCourse(courseId: string) {
    const plans =
      await this.renewalPlansRepository.findActivePlansByCourseId(courseId);
    return plans.map((plan) => ({
      id: plan.id,
      courseId: plan.course_id,
      label: plan.label,
      durationValue: plan.duration_value,
      durationUnit: plan.duration_unit,
      price: Number(plan.price),
      sortOrder: plan.sort_order,
    }));
  }

  async getPlanById(planId: string) {
    const plan = await this.renewalPlansRepository.findPlanById(planId);
    if (!plan) {
      throw new NotFoundException('Renewal plan not found or inactive');
    }
    return plan;
  }
}
