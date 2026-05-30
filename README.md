# salience

Private skill library for LLM coding agents — prompt emphasis (`tap`), immunology auto-tap (`immune`), and lab workflow skills for Claude Code, Codex, and Gemini.

## Quick install

```bash
git clone git@github.com:nakialw/salience.git
cd salience
./install.sh
```

**Claude Code:** `/tap`, `/immune`, and other commands in `SKILLS.md`  
**Codex:** skills symlinked to `~/.codex/skills/`  
**Gemini:** run `gemini skills link skills/<name>/gemini` if the CLI is installed

## Layout

```
salience/
├── install.sh / uninstall.sh   # Symlink skills into ~/.claude, ~/.codex
├── SKILLS.md                   # Command index
├── skills/                     # One directory per skill (claude/, codex/, gemini/)
├── docs/calibration/           # Tap-suite calibration prompts + results summary
├── scripts/                    # Smoke/full calibration runners
└── config/examples/            # Optional platform config samples (not auto-installed)
```

## Tap suite (v1.1)

| Command | Use when |
|---------|----------|
| `/tap` | You know which phrases matter — mark with `[[...]]` |
| `/immune` | Immunology interpretation; auto-brackets 3–6 spans then taps |

Smoke test (requires `claude` CLI):

```bash
SMOKE=1 ./scripts/run-immune-calibration.sh
```

## Uninstall

```bash
./uninstall.sh
```

Removes symlinks that point into this repo only.

## Adding a skill

1. Create `skills/<name>/` with `claude/`, `codex/`, and/or `gemini/`
2. Add entries to `install.sh`, `uninstall.sh`, and `SKILLS.md`
