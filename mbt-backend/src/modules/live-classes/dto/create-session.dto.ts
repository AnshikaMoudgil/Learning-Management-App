import {
  IsNotEmpty,
  IsString,
  IsOptional,
  IsDateString,
  IsInt,
  Min,
} from 'class-validator';

export class CreateSessionDto {
  @IsNotEmpty()
  @IsString()
  title: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsNotEmpty()
  @IsDateString()
  start_time: string;

  @IsNotEmpty()
  @IsInt()
  @Min(1)
  duration: number;

  @IsNotEmpty()
  @IsString()
  course_id: string;

  @IsOptional()
  @IsString()
  section_id?: string;
}
