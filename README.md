# airbag 🛡️

**An airbag for AI coding.** Security, database, bug, performance and mobile-friendly rules for [Claude Code](https://claude.com/claude-code) — plus a one-command app audit and hard guardrails, so the code your AI writes is safe to ship.

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
![Claude Code](https://img.shields.io/badge/for-Claude%20Code-orange)
![Platforms](https://img.shields.io/badge/macOS%20%7C%20Linux%20%7C%20Windows-supported-blue)

AI coding tools are fast, but they happily write SQL injection, skip authorization checks, hardcode secrets and ship layouts that break on a phone. **airbag** gives Claude Code a set of rules it reads in every session, a `/app-audit` command that reviews your whole project, and permission rules that block the dangerous stuff outright.

> Free, MIT-licensed, no telemetry, no dependencies. Just markdown and JSON files in `~/.claude`.

---

## What's inside

| Layer | File | What it does | Strength |
|---|---|---|---|
| 1. Always-on rules | `claude/CLAUDE.md` → `~/.claude/rules/airbag.md` | Claude reads it at the start of **every** session: security, database, bugs, performance, responsive design, git, and how to report work | Guidance |
| 2. On-demand audit | `claude/skills/app-audit/` → `/app-audit` | Read-only audit of a whole project: runs dependency/secret scans and tests, checks 9 areas, returns a severity-ranked table with `file:line` evidence and a fix plan | Deep check |
| 3. Hard guardrails | `claude/settings.json` | Permission rules: Claude **can't** read `.env` or `~/.ssh`, **can't** force-push, and must **ask** before `git push` or wiping the database | Enforced |
| 4. Automatic review | `claude/claude-security-guidance.md` | Your rules for Anthropic's official `security-guidance` plugin, which reviews Claude's code after every turn and commit | Automatic |

Why four layers? A `CLAUDE.md` file is guidance — Claude follows it well, but it isn't a guarantee. Anything that must *never* happen belongs in permission rules; anything that needs a deep look belongs in an audit you run on purpose.

## Install (30 seconds)

**macOS / Linux / WSL**
```bash
git clone https://github.com/iqbalmbadhan/airbag.git
cd airbag && ./install.sh
```

**Windows (PowerShell)**
```powershell
git clone https://github.com/iqbalmbadhan/airbag.git
cd airbag; powershell -ExecutionPolicy Bypass -File .\install.ps1
```

The installer never overwrites your files:
- rules go to `~/.claude/rules/airbag.md`, so your own `~/.claude/CLAUDE.md` stays untouched
- permission rules are **merged** into your existing `settings.json` (a backup is saved first)
- an existing `app-audit` skill or security-guidance file is backed up or kept

**Recommended:** also install Anthropic's official security plugin inside Claude Code:
```
/plugin install security-guidance@claude-plugins-official
```

Uninstall any time: `./install.sh --uninstall` (or `.\install.ps1 -Uninstall`).

## Check it works

Open a new Claude Code session (terminal, VS Code or desktop) in any project:

- `/context` → `airbag.md` appears under **Memory files**
- type `/` → `app-audit` is listed
- `/permissions` → the deny rules are there

## Use it

```text
/app-audit                     # whole project, all areas
/app-audit security            # just security
/app-audit db                  # database security + performance
/app-audit responsive          # mobile / all-device friendliness
/app-audit app/Http/Controllers  # one folder
```

The audit never edits code. It ends with a numbered fix plan — tell Claude which items to fix, one at a time.

Example output:

| # | Severity | Area | Issue | Location | Fix |
|---|---|---|---|---|---|
| 1 | Critical | Access control | Invoice endpoint doesn't check ownership (IDOR) | `app/Http/Controllers/InvoiceController.php:42` | Add `$this->authorize('view', $invoice)` |
| 2 | High | Auth | No rate limit on `/login` | `routes/web.php:18` | Add `throttle:5,1` middleware |
| 3 | Medium | Performance | N+1 query in order list | `app/Http/Controllers/OrderController.php:27` | Eager load `->with('customer')` |

## What the rules cover

- **Security:** SQL injection, XSS, CSRF, IDOR / broken access control, mass assignment, file uploads, SSRF, secrets, rate limiting, security headers, AI prompt injection
- **Database:** least-privilege users, no public DB port, encryption at rest, migrations only, transactions, money never as float, UTC timestamps, backups you've actually restored
- **Bugs:** server-side validation, edge cases (empty, huge, Unicode/Bangla, negative), double submits, race conditions, tests that really assert something
- **Performance:** N+1 queries, indexes, pagination, queues, caching, image and bundle size
- **All devices:** mobile-first at 360px, 44px touch targets, no hover-only actions, accessibility, slow networks, iOS Safari quirks
- **Supply chain & licensing:** verify packages exist, audit dependencies, flag GPL/AGPL

Tuned for **Laravel/PHP, WordPress, Next.js/React, Python and PostgreSQL/MySQL**, but the rules are stack-agnostic.

## Customize

- Edit `~/.claude/rules/airbag.md` to add or remove rules. Keep it under ~200 lines — longer files get followed less reliably.
- Put project-specific rules in each repo's own `CLAUDE.md` (run `/init` to create one). They load on top of airbag.
- When Claude repeats a mistake, add one specific line, not a paragraph.

## FAQ

**Does this work with Cursor, Copilot or other AI tools?**
The rules are plain markdown. Copy `claude/CLAUDE.md` into `AGENTS.md`, `.cursor/rules/` or `.github/copilot-instructions.md`. The `/app-audit` skill follows the open [Agent Skills](https://agentskills.io) format. Permission rules and the plugin are Claude Code–specific.

**Will it slow Claude down or cost more?**
The rules file is ~60 lines, a small fixed cost per session. The audit only runs when you call it. The optional security plugin uses extra model calls for its reviews.

**Is it a replacement for a security review or pentest?**
No. It catches common mistakes early. Keep CI scanning, code review and real security testing for anything handling money or personal data.

## Contributing

Issues and PRs welcome — especially new checklist items with a real example of the bug they catch, and rules for stacks not covered yet. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE) © 2026 [Md. Iqbal Mahmud](https://iqbalmahmud.com)

*airbag is an independent community project and is not affiliated with or endorsed by Anthropic. Claude and Claude Code are trademarks of Anthropic.*
