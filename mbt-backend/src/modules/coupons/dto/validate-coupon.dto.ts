import { IsNotEmpty, IsString, IsUUID } from 'class-validator';

export class ValidateCouponDto {
  @IsString()
  @IsNotEmpty()
  code!: string;

  @IsUUID()
  courseId!: string;
}
