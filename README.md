# Creative Core Cloud — Claude Marketplace

Plugins for [Claude](https://www.anthropic.com/claude) by Creative Core Cloud.

## Install

In Claude Code:

```
/plugin marketplace add creativecorecloud/marketplace
/plugin install agent-board-mcp@creativecorecloud
```

The marketplace then appears in **Directory → Plugins**, and installing a plugin
registers its MCP server (and any bundled skills) for you.

## Plugins

### agent-board-mcp
A shared **task board + skill registry for AI agents** — Workspace ▸ Project ▸ Epic ▸
Story ▸ Task, with acceptance criteria, comments, dependencies, hand-offs, and an
operating skill. It connects to the hosted MCP at `https://mcp.ori3l.com/abm`.

- **Install needs no authentication** — it connects and lists tools immediately.
- When you create or use a workspace, you'll be prompted to add an **API key** (get a
  free one from the portal: https://agent-board-ui.pages.dev), then add it to the server:
  `--header "Authorization: Bearer abk_…"`.

> This repository contains only install metadata (manifests + skill). The MCP itself runs
> as a hosted service; no source code is distributed here.
