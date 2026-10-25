# Global rules for every project

These apply to all my projects unless a project's own CLAUDE.md says otherwise.

## How to work
- Work in small, verified steps: one feature or fix at a time. Don't change unrelated files.
- Before a non-trivial change, state a short plan (files to touch, approach) and wait if the change is risky (auth, payments, migrations, deletes, deploy).
- After each change: run the relevant tests / lint / build and show the result. Never say "done" without verifying.
- If a fix fails twice, stop and explain the root cause instead of trying random fixes.
- Ask when requirements are ambiguous; don't invent business rules.
- Proactively flag licensing, security, and privacy risks in anything you write or install.

## Security (non-negotiable)
- Never hardcode secrets, keys, or passwords. Use env variables; update `.env.example` with placeholders only.
- Never read, print, or commit real `.env` files or credentials.
- All DB queries use prepared statements / ORM bindings. No SQL string concatenation with user input.
- Validate every input server-side. Use allowlists (`$fillable`, DTOs, schemas) — no mass assignment.
- Every route/endpoint that touches user data checks authentication AND ownership/authorization (policies, gates, middleware).
- Escape all output. Don't use `{!! !!}`, `dangerouslySetInnerHTML`, `innerHTML`, or `eval` unless I approve and input is sanitized.
- CSRF protection on all state-changing forms; cookies `HttpOnly`, `Secure`, `SameSite=Lax`.
- Rate-limit login, register, password reset, OTP, and public APIs.
- File uploads: validate MIME + extension + size, rename files, store outside web root, never execute them.
- Passwords: bcrypt/argon2 only. Sensitive fields (IDs, tokens): encrypt at rest.
- Production config: debug off, generic error pages, detailed errors only in logs. Never log passwords or tokens.
- Before adding any package: confirm it exists, is maintained, and its license is compatible (flag GPL/AGPL). Prefer fewer dependencies.

## Database
- Schema changes only through migrations. Never edit production schema by hand.
- Use transactions for multi-step writes (e.g. sale + stock + ledger).
- Money as integer (smallest unit) or DECIMAL — never float.
- Store timestamps in UTC; convert for display.
- Add indexes for columns used in WHERE / JOIN / ORDER BY. Avoid N+1 (eager load). Paginate lists.
- Destructive operations (DROP, DELETE without WHERE, truncate, mass update) require my explicit approval.

## Bugs and quality
- Handle edge cases: empty/null, very long input, Bangla/Unicode, zero/negative numbers, duplicate submits, concurrent updates.
- Write or update tests with each feature; for bug fixes, write a failing test first.
- Tests must assert real behaviour — no tests that always pass.
- Keep functions small and named clearly. No dead code, no commented-out blocks left behind.

## Performance
- Cache expensive reads; move slow work (email, AI calls, image/PDF processing) to queues.
- Optimize images (WebP/AVIF, correct size, lazy-load). Keep JS bundles small.
- Measure before optimizing; mention the bottleneck you found.

## All-device friendliness
- Mobile-first, responsive layouts (Flexbox/Grid, relative units). Viewport meta tag always present.
- Must work at 360px width with no horizontal scroll; touch targets ≥ 44px; no hover-only actions.
- Semantic HTML, labels on inputs, alt text, visible focus, sufficient contrast.
- Bangla text: proper font (Hind Siliguri / Noto Sans Bengali) and `lang="bn"` where used.
- Consider slow networks: loading states, graceful errors, light pages.

## Git
- Small, focused commits with clear messages. Never commit secrets, `vendor/`, `node_modules/`, build output, or `.env`.
- Never force-push or rewrite history on shared branches without asking.

## When finishing a task, report
1. What changed (files), 2. how it was verified (commands + result), 3. any risks, TODOs, or security/licensing notes.
