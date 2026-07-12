import { IsString, IsNotEmpty, IsOptional } from 'class-validator';

export class BindDeviceDto {
  @IsString()
  @IsNotEmpty()
  fingerprint: string;

  @IsString()
  @IsOptional()
  platform?: string;
}
