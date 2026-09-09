---
name: safe-collab-workflow
description: Safe collaborative code-edit workflow for shared workspaces. Use when Codex needs to edit, repair, or verify code/files safely, especially for legacy C/H projects, GBK or Chinese-comment source files, brace or scope issues that should be fixed in place, backup or restore decisions, timing-sensitive logic that must be traced before changing, or any task where the request should be restated and confirmed before editing and the result verified before answering.
---

# Safe Collab Workflow

Use this as the default behavior layer for risky or collaborative edits: understand first, protect the file before changing it, preserve encoding, repair problems in place, verify before answering, and be explicit about uncertainty.

## Default Workflow

### 1. Restate the task before editing

Before making changes, restate:

- the user goal
- the files likely to change
- the planned approach
- the critical execution path, trigger path, or data flow if timing/state matters

Pause for confirmation when there are multiple high-risk interpretations. Do not infer timing from function names alone; trace the real call site, condition, interrupt, scheduler, or state transition first.

### 2. Protect the file before changing it

- Create a backup before editing important or legacy files.
- For this workflow, the default backup form is a single sibling file named `original-file.bak`.
- Before editing an existing file, delete the previous `original-file.bak`, then create a fresh `original-file.bak`, then edit.
- Keep only one latest `.bak` by default unless the user explicitly asks to keep multiple backups.
- Never restore a backup or overwrite the current file without explicit user consent.

### 3. Match the editing method to the file

- Detect or preserve the file encoding before writing.
- For GBK files, especially with Chinese comments or strings, prefer encoding-aware scripted edits over tools that may corrupt text.
- After writing GBK content back, verify that comments and strings are still readable and not mojibake.

### 4. Fix locally instead of reflexively reverting

When a change introduces a local structural problem such as brace mismatch, scope drift, or nearby logic breakage:

- inspect the surrounding structure
- trace which block the code should belong to
- repair the file in place

Do not revert by default just because a local fix is needed. Revert or restore only when the user explicitly chooses that path.

### 5. Verify before answering

After editing:

- reopen the changed area
- run targeted checks, builds, or tests when practical
- confirm the expected text, logic, or structure is actually present

If verification fails, continue fixing instead of claiming success. If the user questions the result, re-check first and answer from evidence.

### 6. Report honestly

Report:

- what changed
- what was verified
- what remains uncertain, if anything

Prefer evidence-backed wording such as "I rechecked and found..." over unsupported certainty.

## Special Cases

### Timing-sensitive or stateful code

For counters, delays, polling, refresh cadence, interrupts, schedulers, or state machines:

- trace where the variable changes
- trace where the function is called
- trace the condition that gates execution
- confirm the real period or trigger source before editing

### GBK and legacy C/H source

For legacy embedded or Chinese-comment source trees:

- delete the old `.bak` first
- create a fresh `.bak`
- preserve encoding on write-back
- inspect nearby braces and function boundaries after editing
- verify that Chinese text is still intact

### Restore decisions

If restore becomes a real option:

- explain the problem
- list the available backups
- describe the likely tradeoff of each backup when possible
- wait for the user's choice before restoring

### Confirmation before editing

For code edits in this workflow:

- restate the task and likely files first
- wait for the user's confirmation when the task affects existing project code
- only then perform backup rotation and editing

## Guardrails

Do not:

- edit GBK files with tools likely to corrupt encoding
- delete the source file or unrelated backups when rotating backups
- use timestamped backups when this project expects a single `.bak` workflow
- claim success before checking the changed result
- revert or restore without the user's approval
- rely on function names alone for timing conclusions
- undo unrelated user changes in a dirty workspace

## Output Style

During work, keep the user informed with short progress updates. After completion, summarize the change, the verification, and any remaining risk in plain language.
