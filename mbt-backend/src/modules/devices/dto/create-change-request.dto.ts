import {
  IsString,
  IsNotEmpty,
  IsOptional,
  MinLength,
  MaxLength,
  Matches,
} from 'class-validator';

export class CreateChangeRequestDto {
  @IsString({ message: 'fingerprint must be a string' })
  @IsNotEmpty({ message: 'fingerprint is required' })
  @Matches(/^[a-f0-9\-]{36}$|^[a-f0-9]{32}$/i, {
    message: 'fingerprint must be a valid UUID',
  })
  fingerprint: string;

  @IsString({ message: 'reason must be a string' })
  @IsOptional()
  @MinLength(1, { message: 'reason must not be empty if provided' })
  @MaxLength(500, { message: 'reason must not exceed 500 characters' })
  reason?: string;
}
