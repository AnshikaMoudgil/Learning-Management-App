import { IsString, IsNotEmpty, IsOptional } from 'class-validator';

export class CreateChangeRequestDto {
  @IsString()
  @IsNotEmpty()
  fingerprint: string;

  @IsString()
  @IsOptional()
  reason?: string;
}
