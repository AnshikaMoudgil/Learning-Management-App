import { Module, Global } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { CloudinaryModule } from './cloudinary/cloudinary.module';
import { R2Module } from './r2/r2.module';
import { StorageService } from './storage.service';

@Global()
@Module({
  imports: [ConfigModule, CloudinaryModule, R2Module],
  providers: [StorageService],
  exports: [StorageService],
})
export class StorageModule {}
