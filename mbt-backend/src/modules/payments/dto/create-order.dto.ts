import { IsBoolean, IsOptional, IsString, IsUUID } from 'class-validator';

export class CreateOrderDto {
  @IsUUID()
  courseId!: string;

  @IsOptional()
  @IsString()
  couponCode?: string;

  @IsOptional()
  @IsBoolean()
  allowRenewal?: boolean;
}
