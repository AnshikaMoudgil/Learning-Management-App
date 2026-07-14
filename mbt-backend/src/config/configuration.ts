export default () => ({
  port: parseInt(process.env.PORT || '3000', 10),
  environment: process.env.NODE_ENV || 'development',
  supabase: {
    url: process.env.SUPABASE_URL,
    anonKey: process.env.SUPABASE_ANON_KEY,
    serviceRoleKey: process.env.SUPABASE_SERVICE_ROLE_KEY,
  },
  database: {
    url: process.env.DATABASE_URL,
  },
  redis: {
    url: process.env.REDIS_URL,
  },
  jwt: {
    secret: process.env.JWT_SECRET,
  },
  razorpay: {
    currency: process.env.PAYMENT_CURRENCY || 'INR',
    hardware: {
      keyId: process.env.RAZORPAY_KEY_ID_A,
      keySecret: process.env.RAZORPAY_KEY_SECRET_A,
      webhookSecret: process.env.RAZORPAY_WEBHOOK_SECRET_A,
    },
    software: {
      keyId: process.env.RAZORPAY_KEY_ID_B,
      keySecret: process.env.RAZORPAY_KEY_SECRET_B,
      webhookSecret: process.env.RAZORPAY_WEBHOOK_SECRET_B,
    },
  },
  deviceCheckEnabled: process.env.DEVICE_CHECK_ENABLED !== 'false',
  zoom: {
    clientId: process.env.ZOOM_CLIENT_ID,
    clientSecret: process.env.ZOOM_CLIENT_SECRET,
    accountId: process.env.ZOOM_ACCOUNT_ID,
    webhookSecret: process.env.ZOOM_WEBHOOK_SECRET,
  },
});
