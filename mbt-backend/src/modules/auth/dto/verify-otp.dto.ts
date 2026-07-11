import { IsString, IsNotEmpty, IsOptional } from 'class-validator';

export class VerifyOtpDto {
  @IsString()
  @IsNotEmpty()
  phone: string;

  @IsString()
  @IsNotEmpty()
  token: string;

  @IsString()
  @IsOptional()
  deviceId?: string;
}
