import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { CloudinaryStorageService } from './cloudinary/cloudinary-storage.service';
import { R2StorageService } from './r2/r2-storage.service';
import { StorageProvider } from './interfaces/storage-provider.interface';
import { UploadResult } from './interfaces/upload-result.interface';

@Injectable()
export class StorageService implements StorageProvider {
  private readonly logger = new Logger(StorageService.name);
  private readonly providerInstance: StorageProvider;

  constructor(
    private readonly configService: ConfigService,
    private readonly cloudinaryStorageService: CloudinaryStorageService,
    private readonly r2StorageService: R2StorageService,
  ) {
    const provider =
      this.configService.get<string>('storage.provider') || 'cloudinary';
    this.logger.log(`Initializing StorageService with provider: ${provider}`);

    if (provider.toLowerCase() === 'r2') {
      this.providerInstance = this.r2StorageService;
    } else {
      this.providerInstance = this.cloudinaryStorageService;
    }
  }

  async upload(
    file: Buffer | string,
    fileName: string,
    mimeType: string,
  ): Promise<UploadResult> {
    return this.providerInstance.upload(file, fileName, mimeType);
  }

  async delete(fileKey: string): Promise<void> {
    return this.providerInstance.delete(fileKey);
  }

  async exists(fileKey: string): Promise<boolean> {
    return this.providerInstance.exists(fileKey);
  }

  async getSignedUrl(
    fileKey: string,
    expiresInSeconds?: number,
  ): Promise<string> {
    return this.providerInstance.getSignedUrl(fileKey, expiresInSeconds);
  }
}
