import { IsArray, IsNotEmpty, IsString, IsUUID } from 'class-validator';

export class ValidateCartCouponDto {
  @IsString()
  @IsNotEmpty()
  code!: string;

  @IsArray()
  @IsUUID('4', { each: true })
  courseIds!: string[];
}
