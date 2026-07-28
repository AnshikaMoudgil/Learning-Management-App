import { Module } from '@nestjs/common';
import { SupabaseModule } from '../supabase/supabase.module';
import { MyCoursesController } from './my-courses.controller';
import { MyCoursesService } from './my-courses.service';
import { MyCoursesRepository } from './my-courses.repository';

@Module({
  imports: [SupabaseModule],
  controllers: [MyCoursesController],
  providers: [MyCoursesService, MyCoursesRepository],
})
export class MyCoursesModule {}