# App audit checklist

Check only what applies to the stack. For each item: inspect the code, then mark pass / fail / needs verification.

## 1. Attacks and input handling
- SQL injection: any raw SQL, `DB::raw`, `whereRaw`, string-built queries, `$wpdb->query` without `prepare()`, f-string SQL in Python
- XSS: `{!! !!}`, `dangerouslySetInnerHTML`, `.innerHTML =`, `document.write`, unescaped `echo` in WordPress (missing `esc_html` / `esc_attr` / `wp_kses`)
- CSRF: token on every POST/PUT/PATCH/DELETE form; WordPress nonces checked (`check_admin_referer`, `wp_verify_nonce`); excluded routes justified
- Broken access control / IDOR: every query for user-owned data filtered by owner or checked by a policy; admin routes behind role middleware; WordPress `current_user_can()` on every admin action and AJAX handler
- Mass assignment: `$guarded = []`, `Model::create($request->all())`, unvalidated spreads into ORM
- File uploads: MIME + extension + size validated, files renamed, stored outside web root or private disk, never executable, image re-encoding where possible
- Path traversal: file paths built from user input (`../`)
- SSRF: any "fetch this URL" / webhook / image-from-URL feature; private IP ranges blocked
- Command injection: `exec`, `shell_exec`, `system`, `subprocess(..., shell=True)`, `child_process.exec` with user input
- Unsafe deserialization: `unserialize`, `pickle`, `yaml.load` without SafeLoader
- Open redirects: redirect targets taken from query params
- AI/LLM features: user input or fetched content can't make the model call privileged tools; model output treated as untrusted; no secrets in prompts

## 2. Authentication and sessions
- Passwords hashed with bcrypt/argon2; no MD5/SHA1/plaintext
- Rate limiting / lockout on login, register, password reset, OTP
- Session ID regenerated on login; logout invalidates session; sensible expiry
- Cookies `HttpOnly`, `Secure`, `SameSite`
- Password reset tokens single-use, expiring, not guessable
- 2FA available for admin accounts (note if missing)
- API tokens/JWT: signed with strong secret, expiry set, not stored in localStorage when avoidable

## 3. Secrets and configuration
- No secrets in code, git history, frontend bundles, or committed config
- `.env` in `.gitignore`; `.env.example` has placeholders only
- Production: `APP_DEBUG=false` / `WP_DEBUG` off / no debug toolbars; generic error pages
- HTTPS enforced; HSTS; security headers (CSP, X-Frame-Options, X-Content-Type-Options, Referrer-Policy)
- CORS not `*` for authenticated APIs
- Logs don't contain passwords, tokens, full card or ID numbers

## 4. Database security
- App DB user has least privilege (no root/superuser, no DROP in production)
- DB bound to localhost/private network; port not public (check docker-compose port mappings, server config)
- Strong unique DB password from env
- Sensitive fields encrypted at rest (Laravel `encrypted` cast or equivalent)
- Schema changes only via migrations; migrations are reversible
- Transactions around multi-step writes; row locks or atomic updates for stock/balance changes
- Money stored as integer or DECIMAL, never float
- Timestamps stored in UTC
- Soft deletes / audit trail for business and financial records
- Backups: automated, off-server, restore documented and tested (flag if no evidence)

## 5. Bugs and correctness
- Server-side validation on every input (types, length, ranges, required fields)
- Edge cases: empty/null, very long strings, Bangla/Unicode, zero/negative numbers, duplicates
- Double-submit protection on create/pay actions (idempotency, disabled buttons, unique constraints)
- Race conditions on counters, stock, balances, sequential numbers (invoice numbers)
- Error handling: no swallowed exceptions; failures shown to users clearly; external API failures handled with timeouts
- Timezone and date arithmetic correct
- Tests exist for critical flows and actually assert behaviour; test suite passes
- Dead code, TODO/FIXME in critical paths, commented-out logic

## 6. Dependencies and licensing
- Known vulnerable packages (from audit tools)
- Abandoned or very low-trust packages; suspicious package names
- License compatibility (flag GPL/AGPL in commercial/client code, missing licenses)
- Lock files committed

## 7. Performance
- N+1 queries (loops that query; missing eager loading)
- Missing indexes on columns used in WHERE / JOIN / ORDER BY / foreign keys
- Unpaginated lists; `SELECT *` on large tables; loading whole tables into memory
- Slow work done in the request (email, AI calls, PDF/image processing) instead of queues
- Caching for expensive reads; production caches enabled (config/route/view cache, OPcache)
- Images: oversized, not compressed, no WebP/AVIF, no lazy-loading
- JS/CSS: bundle size, unused libraries, render-blocking assets, compression (gzip/brotli)

## 8. All-device friendliness and accessibility
- Viewport meta tag present
- Layout works at 360px, 768px, 1024px, 1440px — no horizontal scroll, no fixed-width containers breaking mobile
- Tables usable on mobile (scroll wrapper or card layout)
- Touch targets ≥ 44px; no hover-only menus or actions
- Forms: labels, correct input types (`tel`, `email`, `number`, `inputmode`), errors visible on mobile
- Images responsive (`srcset`/`sizes` or max-width)
- Semantic HTML, alt text, visible focus states, colour contrast, keyboard navigation
- Bangla font loaded and `lang` attribute correct
- Loading states and offline/slow-network handling for key actions
- iOS Safari quirks (100vh, input zoom on <16px font, sticky positioning)

## 9. Deployment and operations
- Deploy process doesn't expose `.git`, `.env`, `storage/`, backups, or `vendor/` publicly
- Correct file permissions; web server can't write to code directories
- Error tracking / uptime monitoring in place (flag if missing)
- CI runs tests, lint, and dependency audit (flag if missing)
