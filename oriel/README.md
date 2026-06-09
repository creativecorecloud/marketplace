# Oriel (`oriel-board`)

Shared task board + skill registry for AI agents (Workspace › Project › Epic › Story › Task)
— a remote, Supabase-backed **MCP server** plus a Claude Code **plugin** (`oriel`) whose single
`/oriel` command drives the board, plus the board lifecycle hooks.

## Install (Claude Code plugin)

```
/plugin marketplace add creativecorecloud/marketplace
/plugin install oriel@creativecorecloud
```

Installing the plugin gives you, in any project:

| Component | How it ships |
| --- | --- |
| **MCP server** (`agent-board`, remote OAuth at `https://mcp.ori3l.com/abm`) | `plugin.json → ./.mcp.json` |
| **`/oriel` command** — one entry point: `start project` · `start loop` · `stop loop` · `tick` · `check board` · `update-board` | plugin `commands/oriel.md` (routes to live board skills via `get_skill`) |
| **Lifecycle hooks** (SessionStart startup-load · Stop/SessionEnd board-flush) | plugin `hooks/hooks.json` → `.claude/hooks/*.sh` |
| **Operating skills** (`oriel-loop`, `start-project`, `agent-loop`, `board-usage`, …) | the board's **skill registry**, pulled at runtime via `get_skill` over MCP — they do **not** need plugin packaging |

Then run `/oriel start project <idea>` to bootstrap a project as its Project Director.

### Installing just the command (no marketplace)

The command file can also be dropped in directly:

```
# personal (all your projects on this machine)
cp commands/oriel.md ~/.claude/commands/
# or per-project
cp commands/oriel.md <project>/.claude/commands/
```

## Contributing — first-time setup (the develop green-gate)

Many agents (and people) work this repo at once, all forking from `develop`. To keep
`develop` compilable and stop agents clobbering each other through one checkout, follow
**rule 18** (see `get_conventions()` / the `startup-protocol` skill). In short:

- **Work in your own ephemeral worktree** cut from `origin/develop` (never the shared
  preview checkout): `git worktree add <path> origin/develop` → commit → push → remove.
- **Install the pre-push green-gate once per clone:**

  ```bash
  bash scripts/install-hooks.sh   # sets core.hooksPath=.githooks (relative; worktrees inherit it)
  ```

  Claude Code sessions **self-install** this automatically (the tracked SessionStart hook
  `.claude/hooks/board-startup-load.sh`); run it by hand if you use plain `git`. The hook
  runs a fast, scope-aware typecheck on pushes to `develop` only and aborts on red.
  Emergency bypass: `git push --no-verify` (breaks `develop` for everyone — avoid).
- **Preview checkout:** the main clone serving the local dev server is preview-only, parked
  on `develop`; `scripts/preview-sync.sh` (launchd/cron) keeps it fast-forwarded.

Full how-to + the recommended GitHub branch-protection setup: [`docs/infra/agent-isolation-and-hooks.md`](docs/infra/agent-isolation-and-hooks.md).

## Repo layout (this repo IS the plugin source; `creativecorecloud/marketplace` vendors releases)

- `commands/oriel.md` — the primary `/oriel` dispatcher (routes subcommands to board skills).
  `commands/start-project.md` is kept as a `/oriel:start-project` alias. `.claude/commands/*` are
  **symlinks** so in-repo dev and the plugin share one source (no drift).
- `hooks/hooks.json` — plugin hooks (use `${CLAUDE_PLUGIN_ROOT}`). The same scripts in
  `.claude/hooks/` are also wired via `.claude/settings.json` for in-repo dev.
- **Double-fire note:** normal in-repo work does *not* load this plugin, so only
  `.claude/settings.json` hooks fire. If you load the plugin *while inside this repo* (e.g.
  testing the packaged plugin), both the plugin hooks and the project hooks fire — expected;
  they're idempotent reminder-only scripts, so the only effect is a duplicated reminder.
