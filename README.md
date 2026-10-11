# Flow Driven Development (FDD)

**Lightweight end-to-end business flow contracts for Claude Code and OpenAI Codex.**

A flow is one business outcome from trigger to result, including validations, failures, side effects and asynchronous continuations. It can span UI, APIs, persistence, queues and jobs. **Not** one document per endpoint or class.

FDD needs no Python, MCP server, orchestration framework, proposal/task files, or special development commands.

## Install (Windows, without Python)

Extract the archive, then in PowerShell run:

```powershell
.\install.ps1 -Project 'C:\Projects\MyProject' -Agent Both
```

Run from the extracted kit directory, or provide the full path to `install.ps1`. `-Agent Claude` or `-Agent Codex` installs just one integration. Add `-DryRun` to preview files. Windows PowerShell 5.1+ is enough; PowerShell 7+ also works.

Example using an absolute installer path:

```powershell
& 'C:\Downloads\flow-driven-development-kit\install.ps1' -Project 'C:\Projects\MyProject' -Agent Both
```

The installer preserves existing `AGENTS.md`, `CLAUDE.md`, and `docs/flows/*`, refuses to overwrite customized Skills, and can be run again. It does not offer migrations. If your execution policy blocks local scripts, use the manual installation instructions below rather than changing a machine-wide security setting.

### Installed layout

```text
project/
  AGENTS.md / CLAUDE.md               # FDD rules appended to existing instructions
  docs/flows/
    index.md                           # flow inventory + unmapped entry points
    _template.md                       # contract template
    booking-create.md                  # generated later during bootstrap
  .agents/skills/                     # Codex: three Skills
  .claude/skills/                     # Claude: same three Skills
```

Only the agent-specific Skills and routing rules are duplicated. Both tools use the **same** `docs/flows/`.

## Bootstrap an existing repository

Claude Code: `/flow-bootstrap`  
Codex: `$flow-bootstrap`

> Discover the end-to-end business flows in this repository. Inventory user and background entry points in `docs/flows/index.md`. Trace and document the first 3-5 related flows, recording evidence and coverage gaps. Keep newly discovered flow docs Draft and do not change application code. Continue in batches from the index.

`Discovered` = candidate, `Draft` = traced but not approved, `Active` = *human-approved* contract. Review Drafts before making them Active. Incomplete scans must say what was not inspected.

## Everyday development

Simply describe the change normally. Project instructions route Claude Code and Codex to `flow-develop` and `flow-verify` when applicable. The agents should locate affected complete flows, track reverse dependencies, update only intentionally changed behavior *before code*, preserve all other Active requirements, and run relevant tests.

| Purpose | Claude Code | Codex |
| --- | --- | --- |
| Discover existing flows | `/flow-bootstrap` | `$flow-bootstrap` |
| Develop or change behavior | `/flow-develop` | `$flow-develop` |
| Review flow regression risks | `/flow-verify` | `$flow-verify` |

The commands are optional for normal coding. `flow-verify` checks document consistency together with code behavior and available tests. Scenarios link real regression tests as `[test: repo/relative/path]` or are marked `[untested]`. No separate validator or BDD framework is required.

## Manual installation (no installer)

1. Copy `templates/flows/index.md` and `_template.md` to `docs/flows/` (do not overwrite existing flow files).
2. Copy each `skills/<name>/SKILL.md` to `.claude/skills/<name>/SKILL.md` for Claude Code and/or `.agents/skills/<name>/SKILL.md` for Codex.
3. Append the contents of `templates/policies/CLAUDE.block.md` to `CLAUDE.md`, and/or `templates/policies/AGENTS.block.md` to `AGENTS.md`. Keep any existing project instructions.

## Design inspiration (concepts only; no runtime dependencies)

- [GSD codebase mapping](https://github.com/gsd-build/get-shit-done) - scoped scans, coverage audit and resumable inventory.
- [Tessl spec-driven development](https://tessl.io/registry/tessl-labs/spec-driven-development) - links between requirements and tests, plus post-implementation checking.
- [OpenSpec](https://github.com/Fission-AI/OpenSpec) - intentional changes to just affected requirements, without proposals or archive mechanics.

The sample `examples/booking-create.md` is illustrative and is **not** installed as an approved contract.
