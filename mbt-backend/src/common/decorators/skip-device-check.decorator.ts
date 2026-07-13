import { SetMetadata } from '@nestjs/common';

export const SKIP_DEVICE_CHECK_KEY = 'skip_device_check';

export const SkipDeviceCheck = () => SetMetadata(SKIP_DEVICE_CHECK_KEY, true);
