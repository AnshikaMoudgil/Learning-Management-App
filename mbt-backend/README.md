# MBT Backend

Backend API for the MBT (Mind Body Training) platform — built with [NestJS](https://nestjs.com/) and [Supabase](https://supabase.com/).

## Prerequisites

Before you begin, ensure you have the following installed:

### Node.js

This project requires **Node.js v18 or later**. If you don't have Node.js installed, follow the steps below for your operating system:

#### Windows
1. Download the LTS installer from [nodejs.org](https://nodejs.org/)
2. Run the installer (check "Automatically install the necessary tools")
3. Verify installation by opening a terminal and running:
   ```bash
   node --version
   npm --version
   ```

#### macOS
Using [Homebrew](https://brew.sh/):
```bash
brew install node
```
Or download the LTS installer from [nodejs.org](https://nodejs.org/).

#### Linux (Ubuntu/Debian)
```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### npm (Node Package Manager)
npm is bundled with Node.js. Verify after installation:
```bash
npm --version
```

### Git
Required to clone the repository. Download from [git-scm.com](https://git-scm.com/).

---

## Step-by-Step Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd mbt-backend
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Environment Variables

Copy the example environment file and fill in your values:

```bash
cp .env.example .env
```

Open `.env` and configure the following required variables:

| Variable | Description |
|---|---|
| `PORT` | Server port (default: `3000`) |
| `NODE_ENV` | Environment mode (`development`, `production`, `test`) |
| `SUPABASE_URL` | Your Supabase project URL |
| `SUPABASE_ANON_KEY` | Supabase anonymous/public key |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase service role key (admin) |
| `DATABASE_URL` | Supabase PostgreSQL connection string |

Optional variables (uncomment and configure as needed):

| Variable | Description |
|---|---|
| `REDIS_URL` | Redis connection string (for caching / BullMQ queues) |
| `JWT_SECRET` | Secret key for JWT token generation |
| `RAZORPAY_KEY_ID_A` / `RAZORPAY_KEY_SECRET_A` | Razorpay payment gateway — Hardware integration |
| `RAZORPAY_KEY_ID_B` / `RAZORPAY_KEY_SECRET_B` | Razorpay payment gateway — Software integration |
| `ZOOM_CLIENT_ID` / `ZOOM_CLIENT_SECRET` / `ZOOM_REDIRECT_URI` / `ZOOM_TOKEN_ENCRYPTION_KEY` / `ZOOM_WEBHOOK_SECRET_TOKEN` | Zoom OAuth (General App) credentials |
| `FCM_SERVICE_ACCOUNT_JSON` | Firebase Cloud Messaging service account JSON |
| `SENDGRID_API_KEY` / `EMAIL_FROM` | SendGrid email integration |
| `SMS_PROVIDER_API_KEY` | SMS provider API key (Twilio / MSG91) |
| `DUBBING_API_KEY` | AI Dubbing pipeline vendor API key |

### 4. Supabase Migrations

The project includes Supabase migrations under `supabase/migrations/`. Apply them via the Supabase CLI or the Supabase dashboard SQL editor.

### 5. Run the Application

```bash
# development
npm run start

# watch mode (auto-restart on changes)
npm run start:dev

# debug mode
npm run start:debug

# production mode (build first, then run)
npm run build
npm run start:prod
```

The server will start at `http://localhost:3000` (or the port you configured in `.env`).

### 6. Run Tests

```bash
# unit tests
npm run test

# e2e (end-to-end) tests
npm run test:e2e

# test coverage
npm run test:cov

# watch mode
npm run test:watch
```

### 7. Lint & Format

```bash
# lint
npm run lint

# format with Prettier
npm run format
```

---

## Project Structure

```
mbt-backend/
├── src/
│   ├── common/           # Shared utilities, guards, interceptors, filters
│   ├── config/           # Configuration modules & validation schemas
│   ├── modules/          # Feature modules (auth, users, courses, etc.)
│   ├── app.module.ts     # Root module
│   ├── app.controller.ts # Root controller
│   ├── app.service.ts    # Root service
│   └── main.ts           # Application entry point
├── supabase/
│   └── migrations/       # SQL migration files for Supabase
├── test/                 # E2E test files
├── dist/                 # Compiled output (after build)
├── .env                  # Environment variables (not tracked in git)
├── .env.example          # Environment variable template
├── package.json
├── tsconfig.json
├── tsconfig.build.json
├── nest-cli.json
└── eslint.config.mjs
```

## Available Scripts

| Command | Description |
|---|---|
| `npm run build` | Compile TypeScript to JavaScript |
| `npm run start` | Start in development mode |
| `npm run start:dev` | Start with file watching (hot reload) |
| `npm run start:debug` | Start with debugger and watch mode |
| `npm run start:prod` | Start compiled production build |
| `npm run lint` | Run ESLint with auto-fix |
| `npm run format` | Format code with Prettier |
| `npm run test` | Run unit tests |
| `npm run test:watch` | Run unit tests in watch mode |
| `npm run test:cov` | Run unit tests with coverage report |
| `npm run test:e2e` | Run end-to-end tests |

## Tech Stack

- **Framework:** [NestJS](https://nestjs.com/) v11
- **Database:** [Supabase](https://supabase.com/) (PostgreSQL)
- **Validation:** class-validator + class-transformer
- **Config:** @nestjs/config
- **Language:** TypeScript
- **Testing:** Jest + Supertest
