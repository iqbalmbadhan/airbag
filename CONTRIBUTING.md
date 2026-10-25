# Contributing to airbag

Thanks for helping make AI-written code safer.

## Good contributions
- **A new checklist item** in `claude/skills/app-audit/checklist.md` — include a short real-world example of the bug it catches.
- **A rule** in `claude/CLAUDE.md` — it must be specific and checkable ("Rate-limit /login" beats "be secure"). The file must stay under ~200 lines, so propose what to merge or remove if you add something.
- **Stack coverage** — Django, Rails, Go, Spring, mobile, etc.
- **Installer fixes** — especially Windows edge cases.

## Rules for PRs
- One topic per PR.
- No telemetry, network calls or dependencies in the installers beyond `git` and (optionally) `python3`.
- Test `install.sh` (fresh install, existing settings, re-run, `--uninstall`) and/or `install.ps1` before submitting, and say what you tested.
- Never commit real secrets, even as examples — use obvious placeholders.

## Reporting a problem
Open an issue with your OS, Claude Code version (`claude --version`), what you ran, and what happened.
