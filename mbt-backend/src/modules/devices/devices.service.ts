import { Injectable, UnauthorizedException } from '@nestjs/common';
import { DevicesRepository } from './devices.repository';
import { Device } from '../../common/types/device.type';

@Injectable()
export class DevicesService {
  constructor(private readonly devicesRepository: DevicesRepository) {}

  async getUserDevices(userId: string): Promise<Device[]> {
    return this.devicesRepository.findByUserId(userId);
  }

  async getActiveDevice(userId: string): Promise<Device | null> {
    return this.devicesRepository.findActiveByUserId(userId);
  }

  async bindDevice(
    userId: string,
    fingerprint: string,
    platform?: string,
  ): Promise<Device> {
    const existing = await this.devicesRepository.findByUserAndFingerprint(
      userId,
      fingerprint,
    );

    if (existing) {
      return this.devicesRepository.updateLastSeen(existing.id);
    }

    const anyDevice = await this.devicesRepository.findAnyByUserId(userId);
    if (anyDevice) {
      throw new UnauthorizedException(
        'This account is permanently bound to another device. Login from this device is not allowed.',
      );
    }

    return this.devicesRepository.create(userId, fingerprint, platform);
  }
}
