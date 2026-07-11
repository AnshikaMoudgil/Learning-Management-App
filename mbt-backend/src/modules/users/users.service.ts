import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { UsersRepository } from './users.repository';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { CreateProfileDto } from './dto/create-profile.dto';

@Injectable()
export class UsersService {
  constructor(
    private readonly usersRepository: UsersRepository,
    private readonly supabaseService: SupabaseService,
  ) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async getProfile(userId: string) {    
    const data = await this.usersRepository.findById(userId);

    if (!data) {
      throw new NotFoundException('Learner profile not found');
    }

    const { data: userData } = await this.db.auth.admin.getUserById(userId);

    return {
      ...data,
      email: userData?.user?.email ?? null,
      phone: userData?.user?.phone ?? null,
    };
  }

  async updateProfile(userId: string, updateData: UpdateProfileDto) {
    const dbUpdate: Record<string, any> = {};
    const metaUpdate: Record<string, any> = {};

    if (updateData.fullName !== undefined) {
      dbUpdate.full_name = updateData.fullName;
      metaUpdate.custom_full_name = updateData.fullName;
      metaUpdate.full_name = updateData.fullName;
    }

    if (updateData.phone !== undefined) {
      metaUpdate.custom_phone = updateData.phone;
      metaUpdate.phone = updateData.phone;
    }

    if (Object.keys(dbUpdate).length === 0 && Object.keys(metaUpdate).length === 0) {
      return this.getProfile(userId);
    }

    if (Object.keys(dbUpdate).length > 0) {
      await this.usersRepository.update(userId, dbUpdate);
    }

    if (Object.keys(metaUpdate).length > 0) {
      await this.db.auth.admin.updateUserById(userId, {
        user_metadata: metaUpdate,
      });
    }

    return this.getProfile(userId);
  }

  async completeProfile(userId: string, createData: CreateProfileDto) {
    const existing = await this.usersRepository.findById(userId);

    if (existing) {
      const dbUpdate: Record<string, any> = {
        full_name: createData.fullName,
        onboarding_completed: true,
        last_login_at: new Date().toISOString(),
      };

      const metaUpdate: Record<string, any> = {
        custom_full_name: createData.fullName,
        full_name: createData.fullName,
      };

      const data = await this.usersRepository.update(userId, dbUpdate);      

      await this.db.auth.admin.updateUserById(userId, {
        user_metadata: metaUpdate,
      });

      return data;
    }

    const newProfile = {
      is_active: true,
      is_deleted: false,
      onboarding_completed: true,
      full_name: createData.fullName,
    };

    const data = await this.usersRepository.create(userId, newProfile);

    await this.db.auth.admin.updateUserById(userId, {
      user_metadata: {
        custom_full_name: createData.fullName,
        full_name: createData.fullName,
      },
    });
    
    return data;
  }

  async updateLoginDetails(userId: string, deviceId?: string) {
    const existing = await this.usersRepository.findById(userId);

    const updates: Record<string, any> = {
      last_login_at: new Date().toISOString(),
    };

    if (deviceId && (!existing || !existing.device_id)) {
      updates.device_id = deviceId;
    }

    return this.usersRepository.update(userId, updates);
  }

  async uploadAvatar(userId: string, fileBuffer: Buffer, originalName: string, mimeType: string) {
    await this.removeExistingAvatar(userId);

    const fileExt = originalName.split('.').pop() || 'png';
    const filePath = `${userId}/avatar-${Date.now()}.${fileExt}`;

    const { error: uploadError } = await this.db.storage
      .from('avatars')
      .upload(filePath, fileBuffer, {
        contentType: mimeType,
        upsert: true,
      });

    if (uploadError) {
      throw new BadRequestException(`Failed to upload avatar: ${uploadError.message}`);
    }

    const { data: { publicUrl } } = this.db.storage
      .from('avatars')
      .getPublicUrl(filePath);

    const data = await this.usersRepository.upsertAvatarUrl(userId, publicUrl);

    await this.db.auth.admin.updateUserById(userId, {
      user_metadata: {
        custom_avatar_url: publicUrl,
        avatar_url: publicUrl,
      },
    });

    return data;
  }

  async deleteAvatar(userId: string) {
    await this.removeExistingAvatar(userId);

    await this.usersRepository.clearAvatarUrl(userId);

    await this.db.auth.admin.updateUserById(userId, {
      user_metadata: {
        custom_avatar_url: null,
        avatar_url: null,
      },
    });

    return { message: 'Avatar removed successfully' };
  }

  private async removeExistingAvatar(userId: string) {
    const profile = await this.usersRepository.findById(userId);
    if (!profile?.avatar_url) return;

    const marker = '/avatars/';
    const idx = profile.avatar_url.indexOf(marker);
    if (idx === -1) return;

    const filePath = profile.avatar_url.substring(idx + marker.length);
    if (!filePath) return;

    const { error } = await this.db.storage.from('avatars').remove([filePath]);
    if (error) {
      console.warn(`Failed to remove old avatar: ${error.message}`);
    }
  }
}
