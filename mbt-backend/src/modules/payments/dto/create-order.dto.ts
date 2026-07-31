import {
  IsArray,
  IsBoolean,
  IsOptional,
  IsString,
  IsUUID,
} from 'class-validator';

export class CreateOrderDto {
  @IsArray()
  @IsUUID('4', { each: true })
  courseIds!: string[];

  @IsOptional()
  @IsString()
  couponCode?: string;

  @IsOptional()
  @IsBoolean()
  allowRenewal?: boolean;

  @IsOptional()
  @IsUUID('4')
  renewalPlanId?: string;
}
