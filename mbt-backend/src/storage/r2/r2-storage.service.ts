import {
  DeleteObjectCommand,
  HeadObjectCommand,
  NotFound,
  PutObjectCommand,
  S3Client,
  GetObjectCommand,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as fs from 'fs';
import { StorageProvider } from '../interfaces/storage-provider.interface';
import { UploadResult } from '../interfaces/upload-result.interface';

@Injectable()
export class R2StorageService implements StorageProvider {
  private readonly logger = new Logger(R2StorageService.name);
  private client: S3Client | null = null;
  private bucketName: string | null = null;
  private publicBaseUrl: string | undefined;

  constructor(private readonly configService: ConfigService) {
    this.publicBaseUrl = this.configService.get<string>('r2.publicBaseUrl');
  }

  private ensureClient(): { client: S3Client; bucketName: string } {
    if (this.client) {
      return { client: this.client, bucketName: this.bucketName! };
    }
    const endpoint = this.requireConfig('r2.endpoint');
    const accessKeyId = this.requireConfig('r2.accessKeyId');
    const secretAccessKey = this.requireConfig('r2.secretAccessKey');
    this.bucketName = this.requireConfig('r2.bucketName');

    this.client = new S3Client({
      region: 'auto',
      endpoint,
      credentials: { accessKeyId, secretAccessKey },
    });
    return { client: this.client, bucketName: this.bucketName };
  }

  async upload(
    file: Buffer | string,
    fileName: string,
    mimeType: string,
  ): Promise<UploadResult> {
    const { client, bucketName } = this.ensureClient();
    this.logger.log(`Uploading file ${fileName} to R2`);

    let body: Buffer | fs.ReadStream;
    let size: number;

    if (typeof file === 'string') {
      body = fs.createReadStream(file);
      size = fs.statSync(file).size;
    } else {
      body = file;
      size = file.length;
    }

    await client.send(
      new PutObjectCommand({
        Bucket: bucketName,
        Key: fileName,
        Body: body,
        ContentType: mimeType,
      }),
    );

    return {
      provider: 'r2',
      key: fileName,
      url: this.publicBaseUrl
        ? `${this.publicBaseUrl.replace(/\/$/, '')}/${fileName}`
        : fileName,
      size,
      mimeType,
    };
  }

  async delete(fileKey: string): Promise<void> {
    const { client, bucketName } = this.ensureClient();
    await client.send(
      new DeleteObjectCommand({
        Bucket: bucketName,
        Key: fileKey,
      }),
    );
  }

  async exists(fileKey: string): Promise<boolean> {
    const { client, bucketName } = this.ensureClient();
    try {
      await client.send(
        new HeadObjectCommand({
          Bucket: bucketName,
          Key: fileKey,
        }),
      );
      return true;
    } catch (error) {
      if (error instanceof NotFound) {
        return false;
      }
      const err = error as {
        name?: string;
        $metadata?: { httpStatusCode?: number };
      };
      if (err.name === 'NotFound' || err.$metadata?.httpStatusCode === 404) {
        return false;
      }
      throw error;
    }
  }

  async getSignedUrl(fileKey: string, expiresInSeconds = 60): Promise<string> {
    const { client, bucketName } = this.ensureClient();
    return getSignedUrl(
      client,
      new GetObjectCommand({
        Bucket: bucketName,
        Key: fileKey,
      }),
      { expiresIn: expiresInSeconds },
    );
  }

  private requireConfig(key: string): string {
    const value = this.configService.get<string>(key);
    if (!value) {
      throw new Error(`${key} is required for R2 storage`);
    }
    return value;
  }
}
