import { IsUUID } from 'class-validator';

export class QueryRenewalPlansDto {
  @IsUUID('4')
  courseId!: string;
}
