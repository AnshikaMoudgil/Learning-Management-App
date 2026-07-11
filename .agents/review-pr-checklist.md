# /review-pr — PR Review Checklist (MBT)

Run this workflow when reviewing a pull request from a team member against either `mbt-app` or `mbt-backend`.
Read the PR diff in full before starting any checklist item.

---

## 1. Scope Check (do this first)

The most common intern problem — a PR assigned to one thing touching ten things.

**Fork model checks (verify before anything else):**
- [ ] PR is opened from the intern's **fork**, not from a branch on the main repo
- [ ] PR targets `dev` on the main repo — **not** `main`
- [ ] Intern has NOT been given push access to the main repo directly

**Scope checks:**
- [ ] PR only touches files related to the assigned task/issue
- [ ] No unrelated refactors or "while I was here..." edits
- [ ] PR does **not** touch files in both `mbt-app/` and `mbt-backend/` in the same PR (unless the issue explicitly spans both)
- [ ] Feature branch was created off `dev`, not off `main`
- [ ] PR is a reasonable size — if >400 lines changed, flag for splitting
- [ ] No `lib/widgets/` modified unless the task explicitly requires a widget change (Flutter read-only surface)

---

## 2. Project Rules

### Global
- [ ] No `console.log` / `print` / `debugPrint` left in any file
- [ ] No `.env` or `.env*` file accidentally committed (both projects)
- [ ] Branch name follows convention: `feat/`, `fix/`, `chore/`

### Backend (`mbt-backend`)
- [ ] All files are `.ts` — no `.js`
- [ ] Follows NestJS naming: kebab-case directories, `*.module.ts`, `*.controller.ts`, `*.service.ts`, `*.repository.ts`, `*.guard.ts`, `dto/*.dto.ts`
- [ ] API routes are versioned: `/api/v1/...`
- [ ] New modules follow NestJS CLI structure — `nest g module`, not manual folder creation
- [ ] Uses `class-validator` decorators for DTO validation — no custom validation logic in services
- [ ] Uses `class-transformer` for request serialization
- [ ] No raw `express.Request` / `express.Response` typed parameters — use NestJS decorators (`@Body()`, `@Param()`, `@Query()`)
- [ ] Service classes handle business logic; controllers are thin (call service, return result)
- [ ] Repositories are separate from services (data access in `*.repository.ts`)
- [ ] Migration SQL files added under `supabase/migrations/` for schema/storage/RPC changes
- [ ] New environment variables are documented in `.env.example`
- [ ] All secrets and API keys come from `@nestjs/config` environment variables — never hardcoded

### Frontend (`mbt-app`)
- [ ] All files are `.dart` — no `.js` or `.ts`
- [ ] Follows Dart naming: `snake_case` file names, `PascalCase` classes, `camelCase` variables/functions, `_private` prefixed private members
- [ ] No hardcoded color values — must use design tokens from `lib/theme/app_colors.dart`
- [ ] Uses Material 3 widgets — no custom-painted UI without good reason
- [ ] No general-purpose UI framework installed (MUI, Chakra, etc.) — Flutter's built-in widgets suffice
- [ ] New widgets placed correctly: shared → `lib/widgets/`, screen-specific → co-located in `lib/screens/`
- [ ] All images use `Image.asset()` or `Image.network()` — no bare `Image.file()` without justification
- [ ] Icons use Material `Icons.*` or `CupertinoIcons.*` — no custom bitmap icons
- [ ] No payment stack decisions made without team consensus
- [ ] Did not modify auto-generated files (`*.g.dart`, `*.freezed.dart`)
- [ ] New screens follow the existing pattern: StatefulWidget with `_ScreenNameState`, using `SingleTickerProviderStateMixin` if tabs involved

---

## 3. Content Hygiene

Catches PII and stale content that gets shipped by accident.

- [ ] No real people's names in placeholder content or hardcoded data
- [ ] No real email addresses or phone numbers anywhere in source
- [ ] No hardcoded dates — dates must come from the database or be a `// TODO` comment
- [ ] No fake placeholder text shipped on a screen that already has a working implementation

---

## 4. Dependency Audit

### Backend (`mbt-backend/package.json`)
- [ ] No new general-purpose libraries added without team lead approval
- [ ] No second validation library added — `class-validator` is the only approved validation approach
- [ ] No ORM added (Prisma, TypeORM, Drizzle) — direct Supabase client (`@supabase/supabase-js`) is the standard
- [ ] Any new package is justified by the PR description — if there's no explanation, ask for one
- [ ] No new NestJS modules imported that aren't used in the PR

### Frontend (`mbt-app/pubspec.yaml`)
- [ ] No new state management package added (Riverpod, Bloc, Provider, GetX) without team lead approval
- [ ] No second HTTP client added — `http` package + `ApiClient` wrapper is the standard
- [ ] No new animation package added (`flutter_animate`, `rive`, `lottie`) without discussion
- [ ] No database/storage package added (`drift`, `hive`, `isar`) without team lead approval
- [ ] Any new package is justified by the PR description

---

## 5. Security (non-negotiable — flag any of these as blockers)

- [ ] No secrets, API keys, or credentials in code — env vars only
- [ ] No `.env` or `.env*` file accidentally committed
- [ ] No sensitive data (passwords, tokens, PII) logged or returned in API responses

### Backend-specific
- [ ] New API routes validate input with `class-validator` DTOs before processing
- [ ] New protected routes use `@UseGuards(AuthGuard)` — check server-side auth
- [ ] File uploads validate type, size, and content (Multer options + Supabase Storage bucket policies)
- [ ] No `any` type used to bypass type safety on auth or data-handling code
- [ ] Supabase service role key is only used in server-side code — never exposed to client
- [ ] No raw SQL concatenation — use Supabase client query builder or parameterized RPC functions
- [ ] Supabase Row-Level Security (RLS) policies are in place for any new table

### Frontend-specific
- [ ] No Supabase service role key or `supabase.auth.admin` calls in client code
- [ ] `ApiClient` uses the Supabase access token from `Supabase.instance.client.auth.currentSession?.accessToken`
- [ ] No hardcoded API base URLs pointing to production — must come from `.env` via `flutter_dotenv`
- [ ] No sensitive data displayed without checking auth state

---

## 6. Code Quality

### Backend
- [ ] No unused imports or dead code
- [ ] Proper TypeScript types — `any` must be justified with a comment
- [ ] No business logic inside controllers — data fetching/mutations go in services/repositories
- [ ] No `console.log` left in production code — use NestJS `Logger` or structured logging
- [ ] No placeholder API handlers (`setTimeout`, hardcoded mock data shipped as real)
- [ ] Async functions handle errors properly — `try/catch` or NestJS exception filters
- [ ] DTOs use `whitelist: true` (set globally in `ValidationPipe`) — reject unknown properties
- [ ] No circular module imports

### Frontend
- [ ] No unused imports or dead code
- [ ] Proper Dart types — no `dynamic` or bare `var` without justification
- [ ] No business logic inside widgets — data fetching/mutations belong in services, not `initState` or `build`
- [ ] No `print()` left in production code — use `debugPrint` or a logger
- [ ] No fake/mock data shipped as real (hardcoded lists pretending to be API responses)
- [ ] List rendering uses a stable, unique `key` prop — not index for mutable data
- [ ] `BuildContext` is not used across async gaps without checking `mounted`
- [ ] `const` constructors used where possible
- [ ] No `MediaQuery` / `LayoutBuilder` sprinkled everywhere — use existing responsive patterns

---

## 7. Commit Hygiene

- [ ] **No force push** — check the branch's push history on GitHub. If the timeline shows a rewrite or "force-pushed" label, this is an automatic blocker
- [ ] Conventional commit format (`feat:`, `fix:`, `chore:`, `docs:`)
- [ ] Descriptive commit messages — not "fix stuff" or "update"
- [ ] One logical change per commit (not 10 unrelated files in one commit)
- [ ] PR linked to a GitHub issue

---

## 8. Build & Regression Check

- [ ] **Backend:** `npm run build` passes (run from `mbt-backend/`)
- [ ] **Frontend:** `flutter analyze` passes with no new warnings (run from `mbt-app/`)
- [ ] **Frontend:** `flutter build` passes (APK / web depending on target)
- [ ] No new TypeScript/Dart errors introduced
- [ ] Existing endpoints/screens still work correctly
- [ ] No new lint warnings silenced with `// ignore` / `// eslint-disable` without justification
- [ ] Tests pass: `npm test` (backend) / `flutter test` (frontend)

---

## 9. Feedback

- Be specific — reference file name and line number
- Suggest a fix, don't just identify a problem
- Acknowledge good patterns when you see them
- **Blockers** (must fix before merge): security issues, unapproved packages, broken build, PII in code, env file committed, RLS missing on new tables
- **Non-blockers** (can merge, track as follow-up): style nits, minor refactors, missing `const` constructors, unused imports

---

## 10. Decision

- **Approve** — all blockers resolved, code is solid
- **Request Changes** — one or more blockers present, list them clearly
- **Escalate to team lead** — architectural decision or dependency question beyond intern scope
