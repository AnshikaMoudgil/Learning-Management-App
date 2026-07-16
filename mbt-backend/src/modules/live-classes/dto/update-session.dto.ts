import {
  IsOptional,
  IsString,
  IsDateString,
  IsInt,
  Min,
  IsIn,
} from 'class-validator';

const VALID_STATUSES = [
  'draft',
  'scheduled',
  'live',
  'finished',
  'recording_processing',
  'recording_ready',
  'cancelled',
] as const;

export class UpdateSessionDto {
  @IsOptional()
  @IsString()
  title?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsDateString()
  start_time?: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  duration?: number;

  @IsOptional()
  @IsString()
  @IsIn(VALID_STATUSES)
  status?: string;
}
