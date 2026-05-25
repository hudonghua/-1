---
name: memory
description: Load consolidated user memory for Cursor — discipline summary, Claude/Codex status, and links to project memory under .claude/projects/C--Users-DELL/memory.
---

# memory

Use this skill when the user says **恢复记忆**, starts a sensitive task (embedded C, GBK files, hardware protocols), or asks to align with their saved preferences.

## Primary document

1. Read **`C:\Users\DELL\.cursor\memory\CURSOR_AGENT_MEMORY.md`** first. It summarizes:
   - Discipline from `编程手册与纪律.md` (canonical rules stay in that file)
   - Claude global memory under `C:\Users\DELL\.claude\memory`
   - Codex `memories` workspace status (do not infer preferences when empty)
   - Index of project memory files under `C:\Users\DELL\.claude\projects\C--Users-DELL\memory`

2. Then follow the **恢复记忆** flow in the handbook: read **`C:\Users\DELL\.claude\projects\C--Users-DELL\memory\编程手册与纪律.md`**, then **`MEMORY.md`** in that folder, then task-specific `project_*`, `reference_*`, or `feedback_*` files.

## Related skill locations

- **`C:\Users\DELL\.claude\skills`** — user workflows (backup, GBK-safe edit, verify-before-answer, etc.)
- **`C:\Users\DELL\.cursor\skills-cursor`** — Cursor-specific skills

Do not duplicate long rule text here; keep `CURSOR_AGENT_MEMORY.md` and the handbook as the source of truth.
