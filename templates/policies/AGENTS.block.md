<!-- FDD:START -->
## Flow Driven Development (FDD)

`docs/flows/` describes **complete business flows**, not individual endpoints or classes. `docs/flows/index.md` is the inventory: `Discovered` (candidate), `Draft` (unapproved), `Active` (human-approved contract).
- When documenting an existing codebase, use `flow-bootstrap` (`.agents/skills/flow-bootstrap/SKILL.md`). Work by scope and batch; create Drafts, record unmapped entry points; never edit code.
- Before changing business behavior, use `flow-develop` (`.agents/skills/flow-develop/SKILL.md`). Find impacted flows and reverse consumers; preserve all unrequested Active requirements.
- After flow-affecting changes, follow `flow-verify` (`.agents/skills/flow-verify/SKILL.md`). Inspect the actual diff and relevant scenarios/tests, not just filenames.
- Explicit user changes may update affected Active clauses before coding. Never approve Drafts silently or adjust contracts to justify a bug.
- Keep numbered scenarios tied to test files using `[test: path]` or mark `[untested]`. Review changed scenario links and dependencies as part of `flow-verify`; do not rely on a separate documentation checker.
- Skip FDD analysis for changes that cannot affect business behavior. Preserve existing project rules and avoid unrelated changes, extra plans and documentation churn.
<!-- FDD:END -->
