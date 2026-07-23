import { IsBoolean, IsOptional } from 'class-validator';

export class UpdateNotificationSettingsDto {
  @IsBoolean()
  @IsOptional()
  liveClassReminders?: boolean;

  @IsBoolean()
  @IsOptional()
  courseExpiryAlerts?: boolean;

  @IsBoolean()
  @IsOptional()
  paymentConfirmations?: boolean;

  @IsBoolean()
  @IsOptional()
  deviceTransferStatus?: boolean;

  @IsBoolean()
  @IsOptional()
  promotionalMarketing?: boolean;

  @IsBoolean()
  @IsOptional()
  pushNotifications?: boolean;

  @IsBoolean()
  @IsOptional()
  email?: boolean;

  @IsBoolean()
  @IsOptional()
  sms?: boolean;
}
