import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { v2 as cloudinary } from 'cloudinary';
import type { UploadApiResponse, UploadApiErrorResponse } from 'cloudinary';
import * as fs from 'fs';
import { StorageProvider } from '../interfaces/storage-provider.interface';
import { UploadResult } from '../interfaces/upload-result.interface';

interface CloudinaryVideoUploadResponse extends UploadApiResponse {
  duration?: number;
  bit_rate?: number;
  video?: {
    codec?: string;
  };
}

@Injectable()
export class CloudinaryStorageService implements StorageProvider {
  private readonly logger = new Logger(CloudinaryStorageService.name);

  constructor(private readonly configService: ConfigService) {
    cloudinary.config({
      cloud_name: this.configService.get<string>('cloudinary.cloudName'),
      api_key: this.configService.get<string>('cloudinary.apiKey'),
      api_secret: this.configService.get<string>('cloudinary.apiSecret'),
    });
  }

  async upload(
    file: Buffer | string,
    fileName: string,
    mimeType: string,
  ): Promise<UploadResult> {
    this.logger.log(`Uploading file ${fileName} to Cloudinary`);
    return new Promise((resolve, reject) => {
      const options = {
        public_id: fileName.split('.')[0] || fileName,
        resource_type: 'video' as const,
      };

      const callback = (
        error?: UploadApiErrorResponse,
        result?: CloudinaryVideoUploadResponse,
      ) => {
        if (error) {
          this.logger.error(`Cloudinary upload failed: ${error.message}`);
          return reject(new Error(error.message));
        }
        if (!result) {
          return reject(new Error('Cloudinary upload result was empty'));
        }

        const sizeFallback =
          typeof file === 'string' ? fs.statSync(file).size : file.length;

        resolve({
          provider: 'cloudinary',
          key: result.public_id,
          url: result.secure_url,
          size: result.bytes || sizeFallback,
          mimeType,
          duration:
            typeof result.duration === 'number' ? result.duration : null,
          width: typeof result.width === 'number' ? result.width : null,
          height: typeof result.height === 'number' ? result.height : null,
          bitrate: typeof result.bit_rate === 'number' ? result.bit_rate : null,
          codec:
            typeof result.video?.codec === 'string' ? result.video.codec : null,
          thumbnailUrl: cloudinary.url(result.public_id, {
            secure: true,
            resource_type: 'video',
            format: 'jpg',
          }),
        });
      };

      if (typeof file === 'string') {
        cloudinary.uploader.upload(file, options, callback);
      } else {
        const uploadStream = cloudinary.uploader.upload_stream(
          options,
          callback,
        );
        uploadStream.end(file);
      }
    });
  }

  async delete(fileKey: string): Promise<void> {
    this.logger.log(`Deleting file ${fileKey} from Cloudinary`);
    return new Promise((resolve, reject) => {
      void cloudinary.uploader.destroy(
        fileKey,
        { resource_type: 'video' },
        (error: unknown, result: unknown) => {
          if (error) {
            const err = error as Record<string, unknown>;
            const errMsg =
              typeof err.message === 'string'
                ? err.message
                : 'Unknown delete error';
            this.logger.error(`Cloudinary delete failed: ${errMsg}`);
            return reject(new Error(errMsg));
          }
          this.logger.log(
            `Cloudinary delete result: ${JSON.stringify(result)}`,
          );
          resolve();
        },
      );
    });
  }

  async exists(fileKey: string): Promise<boolean> {
    this.logger.log(`Checking existence of file ${fileKey} in Cloudinary`);
    try {
      const result = (await cloudinary.api.resource(fileKey, {
        resource_type: 'video',
      })) as Record<string, unknown>;
      return !!result;
    } catch (error: unknown) {
      const err = error as Record<string, unknown>;
      if (err && typeof err.http_code === 'number' && err.http_code === 404) {
        return false;
      }
      const errMsg =
        err && typeof err.message === 'string' ? err.message : 'Unknown error';
      this.logger.error(`Cloudinary existence check failed: ${errMsg}`);
      throw new Error(errMsg);
    }
  }

  getSignedUrl(fileKey: string, expiresInSeconds = 60): Promise<string> {
    const url = cloudinary.url(fileKey, {
      secure: true,
      resource_type: 'video',
      sign_url: true,
      expires_at: Math.floor(Date.now() / 1000) + expiresInSeconds,
    });
    return Promise.resolve(url);
  }
}
