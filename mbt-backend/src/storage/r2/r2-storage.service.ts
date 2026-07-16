/* eslint-disable @typescript-eslint/no-unused-vars */
import { Injectable, NotImplementedException } from '@nestjs/common';
import { StorageProvider } from '../interfaces/storage-provider.interface';
import { UploadResult } from '../interfaces/upload-result.interface';

@Injectable()
export class R2StorageService implements StorageProvider {
  upload(
    file: Buffer,
    fileName: string,
    mimeType: string,
  ): Promise<UploadResult> {
    return Promise.reject(
      new NotImplementedException(
        'R2 storage provider upload is not implemented yet.',
      ),
    );
  }

  delete(fileKey: string): Promise<void> {
    return Promise.reject(
      new NotImplementedException(
        'R2 storage provider delete is not implemented yet.',
      ),
    );
  }

  exists(fileKey: string): Promise<boolean> {
    return Promise.reject(
      new NotImplementedException(
        'R2 storage provider exists is not implemented yet.',
      ),
    );
  }

  getSignedUrl(fileKey: string): Promise<string> {
    return Promise.reject(
      new NotImplementedException(
        'R2 storage provider getSignedUrl is not implemented yet.',
      ),
    );
  }
}
