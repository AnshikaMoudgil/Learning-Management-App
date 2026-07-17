import { Module } from '@nestjs/common';
import { SupabaseModule } from '../supabase/supabase.module';
import { MyCoursesService } from './my-courses.service';
import { MyCoursesController } from './my-courses.controller';

@Module({
  imports: [SupabaseModule],
  providers: [MyCoursesService],
  controllers: [MyCoursesController],
  exports: [MyCoursesService],
})
export class MyCoursesModule {}
