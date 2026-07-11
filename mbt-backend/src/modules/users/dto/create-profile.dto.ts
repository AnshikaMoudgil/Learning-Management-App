import { IsString, IsNotEmpty, MinLength, MaxLength, IsOptional } from 'class-validator';

export class CreateProfileDto {
  @IsString()
  @IsNotEmpty()
  @MinLength(2)
  @MaxLength(100)
  fullName: string;

  @IsString()
  @IsOptional()
  phone?: string;
}
