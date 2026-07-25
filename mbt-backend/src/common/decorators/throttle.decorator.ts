import { SetMetadata } from '@nestjs/common';
import { THROTTLE_KEY } from '../guards/throttle.guard';
import type { ThrottleOptions } from '../guards/throttle.guard';

export const Throttle = (options: ThrottleOptions) =>
  SetMetadata(THROTTLE_KEY, options);
