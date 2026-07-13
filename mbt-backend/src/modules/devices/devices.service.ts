import {
  Injectable,
  UnauthorizedException,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { DevicesRepository } from './devices.repository';
import { Device } from '../../common/types/device.type';
import { DeviceChangeRequest } from '../../common/types/device-change-request.type';

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
      const approved =
        await this.devicesRepository.findApprovedByUserAndFingerprint(
          userId,
          fingerprint,
        );

      if (approved) {
        await this.devicesRepository.deactivateDevice(anyDevice.id);
        return this.devicesRepository.create(userId, fingerprint, platform);
      }

      throw new UnauthorizedException(
        'This account is bound to another device. You can request a device change from the admin.',
      );
    }

    return this.devicesRepository.create(userId, fingerprint, platform);
  }

  // --- Device Change Requests ---

  async createChangeRequest(
    userId: string,
    newFingerprint: string,
    reason?: string,
  ): Promise<DeviceChangeRequest> {
    const lastApproved =
      await this.devicesRepository.findLastApprovedRequest(userId);

    if (lastApproved?.reviewed_at) {
      const daysSinceLastChange = Math.floor(
        (Date.now() - new Date(lastApproved.reviewed_at).getTime()) /
          (1000 * 60 * 60 * 24),
      );
      if (daysSinceLastChange < 30) {
        const daysRemaining = 30 - daysSinceLastChange;
        throw new BadRequestException(
          `You can only request a device change once every 30 days. Please try again in ${daysRemaining} day(s).`,
        );
      }
    }

    const existingPending =
      await this.devicesRepository.findPendingByUserAndFingerprint(
        userId,
        newFingerprint,
      );

    if (existingPending) {
      return existingPending;
    }

    const currentDevice = await this.devicesRepository.findAnyByUserId(userId);

    return this.devicesRepository.createChangeRequest(
      userId,
      newFingerprint,
      reason,
      currentDevice?.fingerprint,
    );
  }

  async getUserChangeRequests(userId: string): Promise<DeviceChangeRequest[]> {
    return this.devicesRepository.findUserChangeRequests(userId);
  }

  async getPendingChangeRequests(): Promise<DeviceChangeRequest[]> {
    return this.devicesRepository.findAllPendingRequests();
  }

  async reviewChangeRequest(
    requestId: string,
    reviewerId: string,
    status: 'approved' | 'rejected',
  ): Promise<DeviceChangeRequest> {
    const request =
      await this.devicesRepository.findChangeRequestById(requestId);

    if (!request) {
      throw new NotFoundException('Change request not found');
    }

    const updated = await this.devicesRepository.updateChangeRequestStatus(
      requestId,
      status,
      reviewerId,
    );

    if (status === 'approved') {
      const oldDevice = await this.devicesRepository.findActiveByUserId(
        request.user_id,
      );
      if (oldDevice) {
        await this.devicesRepository.deactivateDevice(oldDevice.id);
      }
      await this.devicesRepository.create(
        request.user_id,
        request.new_fingerprint,
        undefined,
      );
    }

    return updated;
  }

  async checkDeviceAllowed(
    userId: string,
    fingerprint: string,
  ): Promise<boolean> {
    const device = await this.devicesRepository.findAnyByUserId(userId);
    if (!device) return true;

    if (device.fingerprint === fingerprint) return true;

    const approved =
      await this.devicesRepository.findApprovedByUserAndFingerprint(
        userId,
        fingerprint,
      );

    return !!approved;
  }
}
