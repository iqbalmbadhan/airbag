---
name: app-audit
description: Full audit of the current project for security vulnerabilities, database security, bugs, performance, and mobile/all-device friendliness. Produces a prioritized report with file:line evidence and fixes. Run with /app-audit, optionally followed by a folder or focus area.
argument-hint: "[path or focus: security | db | bugs | performance | responsive]"
disable-model-invocation: true
---

# App audit

Audit this project. Scope / focus from the user (empty = whole project, all areas): $ARGUMENTS

**Rule: this is a read-only audit. Do NOT modify, delete, or commit any file. Do NOT print secret values — if you find one, show only the file, line, and the first 4 characters.**

## Step 1 — Understand the project
- Identify stack, framework versions, entry points, auth system, DB, how config/env is loaded, and deploy setup (Dockerfile, CI, server config).
- List the routes/endpoints and which ones are public vs authenticated vs admin.
- Briefly state what you found before continuing.

## Step 2 — Run available automated checks (skip any tool that isn't installed; say which were skipped)
- Dependencies: `composer audit`, `npm audit --omit=dev`, `pip-audit`
- Secrets: `gitleaks detect --no-banner` (also check git history if available)
- Static analysis / lint: PHPStan/Larastan, ESLint, `tsc --noEmit`, ruff/mypy — whatever the project already uses
- Tests: run the existing test suite and report pass/fail counts
Do not install new global tools without asking.

## Step 3 — Manual review
Work through every section of [checklist.md](checklist.md) that matches the scope. For each item, actually inspect the code — don't assume. Trace user input from request to database and back to output for the most important flows (login, registration, payments/money, file upload, admin actions, any API that returns user data).

## Step 4 — Report
Use this exact structure:

### Summary
- Stack, scope covered, tools run/skipped, overall risk level (Critical / High / Medium / Low), and the top 3 things to fix first.

### Findings
A table sorted by severity:

| # | Severity | Area | Issue | Location (file:line) | Why it matters | Fix |
|---|---|---|---|---|---|---|

Severity guide:
- **Critical**: exploitable now — data leak, auth bypass, RCE, SQL injection, exposed secrets, public DB.
- **High**: likely exploitable or data-loss risk — missing ownership checks, no rate limit on login, no backups, XSS.
- **Medium**: defense gaps, serious bugs, major performance problems, broken mobile layout.
- **Low**: hardening, best practice, minor UX/accessibility.

Only report issues you can point to in the code. Mark anything uncertain as "Needs verification" and say what to check. No generic advice without evidence.

### Passed checks
Short list of important things that are already done correctly.

### Fix plan
Ordered list of small, independent fix tasks (one per finding or group), each sized to be done and tested in one step. Ask me which ones to fix — don't start fixing.
