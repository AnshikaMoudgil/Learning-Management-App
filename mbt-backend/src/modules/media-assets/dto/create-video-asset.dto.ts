import { IsOptional, IsString, IsUUID } from 'class-validator';

export class CreateVideoAssetDto {
  @IsOptional()
  @IsUUID()
  lessonId?: string;

  @IsOptional()
  @IsString()
  title?: string;

  @IsOptional()
  @IsString()
  videoUrl?: string;
}
