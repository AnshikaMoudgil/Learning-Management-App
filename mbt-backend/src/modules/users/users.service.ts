import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
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
      throw new NotFoundException('Profile not found');
    }

    return data;
  }

  async updateProfile(userId: string, updateData: UpdateProfileDto) {
    const dbUpdate: Record<string, unknown> = {};
    const metaUpdate: Record<string, unknown> = {};

    if (updateData.fullName !== undefined) {
      dbUpdate.full_name = updateData.fullName;
      metaUpdate.custom_full_name = updateData.fullName;
      metaUpdate.full_name = updateData.fullName;
    }

    if (updateData.phone !== undefined) {
      dbUpdate.phone = updateData.phone;
      metaUpdate.custom_phone = updateData.phone;
      metaUpdate.phone = updateData.phone;
    }

    if (updateData.email !== undefined) {
      dbUpdate.email = updateData.email;
      metaUpdate.custom_email = updateData.email;
      metaUpdate.email = updateData.email;
    }

    if (updateData.about !== undefined) {
      dbUpdate.about = updateData.about;
    }

    if (
      Object.keys(dbUpdate).length === 0 &&
      Object.keys(metaUpdate).length === 0
    ) {
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

    const metaUpdate: Record<string, unknown> = {
      custom_full_name: createData.fullName,
      full_name: createData.fullName,
    };

    if (createData.phone !== undefined) {
      metaUpdate.custom_phone = createData.phone;
      metaUpdate.phone = createData.phone;
    }

    if (createData.email !== undefined) {
      metaUpdate.custom_email = createData.email;
      metaUpdate.email = createData.email;
    }

    if (existing) {
      const dbUpdate: Record<string, unknown> = {
        full_name: createData.fullName,
        onboarding_completed: true,
        last_login_at: new Date().toISOString(),
      };

      if (createData.phone !== undefined) dbUpdate.phone = createData.phone;
      if (createData.email !== undefined) dbUpdate.email = createData.email;

      const data = await this.usersRepository.update(userId, dbUpdate);

      await this.db.auth.admin.updateUserById(userId, {
        user_metadata: metaUpdate,
      });

      return data;
    }

    const newProfile: Record<string, unknown> = {
      is_active: true,
      is_deleted: false,
      onboarding_completed: true,
      full_name: createData.fullName,
    };

    if (createData.phone !== undefined) newProfile.phone = createData.phone;
    if (createData.email !== undefined) newProfile.email = createData.email;

    const data = await this.usersRepository.create(userId, newProfile);

    await this.db.auth.admin.updateUserById(userId, {
      user_metadata: metaUpdate,
    });

    return data;
  }

  async updateLoginDetails(userId: string) {
    const updates: Record<string, unknown> = {
      last_login_at: new Date().toISOString(),
    };

    return this.usersRepository.update(userId, updates);
  }

  async uploadAvatar(
    userId: string,
    fileBuffer: Buffer,
    originalName: string,
    mimeType: string,
  ) {
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
      throw new BadRequestException(
        `Failed to upload avatar: ${uploadError.message}`,
      );
    }

    const {
      data: { publicUrl },
    } = this.db.storage.from('avatars').getPublicUrl(filePath);

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
