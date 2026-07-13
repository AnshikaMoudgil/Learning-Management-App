import { IsString, IsIn } from 'class-validator';

export class ReviewChangeRequestDto {
  @IsString()
  @IsIn(['approved', 'rejected'])
  status: 'approved' | 'rejected';
}
