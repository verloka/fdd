# Business Flow Index

One entry per **complete business outcome**, not per endpoint/class. Use stable IDs.

- `Discovered`: candidate identified, not yet fully traced; spec file optional.
- `Draft`: traced/documented observation or proposed behavior; not approved.
- `Active`: explicitly approved business behavior; the authoritative contract.

| Flow ID | Status | Trigger -> outcome | Depends on (flow IDs) | Entry-point hints |
| --- | --- | --- | --- | --- |

## Unmapped Entry Points

- Not inventoried yet. Record entry points that cannot be mapped to a known business outcome; remove them as coverage improves.

## Coverage Notes

- Areas inspected: none yet.
- Areas not yet checked: entire repository.
- Do not claim complete coverage without comparing the inventory with actual UI/API/job/event entry points and tests.
