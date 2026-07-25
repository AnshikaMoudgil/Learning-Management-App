import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { json, urlencoded } from 'express';
import type { IncomingMessage } from 'http';
import compression from 'compression';
import { AppModule } from './app.module';

interface RawBodyIncomingMessage extends IncomingMessage {
  rawBody?: Buffer;
}

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { bodyParser: false });

  app.use(
    json({
      verify: (req, _res, buf) => {
        const rawReq = req as RawBodyIncomingMessage;
        rawReq.rawBody = Buffer.from(buf);
      },
    }),
  );
  app.use(urlencoded({ extended: true }));

  // eslint-disable-next-line @typescript-eslint/no-unsafe-call
  app.use(compression());

  app.enableCors({
    origin: '*',
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    allowedHeaders:
      'Content-Type,Authorization,X-Device-Fingerprint,X-Razorpay-Signature',
  });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  await app.listen(process.env.PORT ?? 3000);
}
void bootstrap();
