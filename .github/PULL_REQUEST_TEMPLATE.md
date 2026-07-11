## What does this PR do?

<!-- 1-2 sentences. What feature or fix does this implement? -->

Closes #

## Screenshots

<!-- Required for UI changes. Paste before/after screenshots or a screen recording. Write "N/A" for non-UI changes. -->

---

## Self-Review Checklist

### Global
- [ ] PR is from **my fork** and targets `dev`
- [ ] No `git push --force` used
- [ ] Only touches files related to the assigned issue
- [ ] No real names, emails, or hardcoded test data
- [ ] No `console.log` / `print` / `debugPrint` left in code
- [ ] No new packages without team lead approval
- [ ] `.env.example` updated if new env vars added

### Backend (`mbt-backend`)
- [ ] All new files are `.ts`
- [ ] `npm run build` passes
- [ ] Migration SQL added for any schema / storage / RPC changes
- [ ] New endpoints use `@UseGuards(AuthGuard)` where applicable
- [ ] DTOs use `class-validator` decorators (`@IsString`, `@IsOptional`, etc.)
- [ ] Service layer handles business logic; controller is thin

### Frontend (`mbt-app`)
- [ ] All new files are `.dart`
- [ ] Did not modify auto-generated files (`*.g.dart`, `*.freezed.dart`)
- [ ] Used theme tokens (`AppColors.*`), not hardcoded colors
- [ ] `flutter build` passes
- [ ] Model `fromJson` handles both `snake_case` and `camelCase` keys
- [ ] Screens use domain services (`ProfileService`), not `ApiClient` directly
- [ ] All HTTP calls go through `ApiClient` singleton, not raw `http`

---

## Reviewer Notes

<!-- Delete this section if not applicable -->
PR size: <!-- small (<50 lines), medium (50-400), large (>400) -->
Area: <!-- backend | frontend | both | infra -->
