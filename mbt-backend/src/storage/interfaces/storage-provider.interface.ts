import { UploadResult } from './upload-result.interface';

export interface StorageProvider {
  upload(
    file: Buffer,
    fileName: string,
    mimeType: string,
  ): Promise<UploadResult>;

  delete(fileKey: string): Promise<void>;

  exists(fileKey: string): Promise<boolean>;

  getSignedUrl(fileKey: string, expiresInSeconds?: number): Promise<string>;
}
export const STORAGE_PROVIDER_TOKEN = 'STORAGE_PROVIDER_TOKEN';
