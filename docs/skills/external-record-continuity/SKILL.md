---
name: external-record-continuity
description: Use when the user provides records from a USB drive, GitHub toolkit upload, Cursor/Codex transcripts, or old-machine skill folders and asks Codex to read them, learn them, merge useful lessons, or continue previous work.
---

# External Record Continuity

Use this skill when the user asks to read records from another machine, a USB drive, or a GitHub upload, especially when the goal is to continue work rather than merely summarize a transcript.

## First Pass

1. Identify the source root and inventory it read-only.
2. Look for these high-value entry points before scanning large caches:
   - `.codex/history.jsonl`
   - `.codex/sessions/**/rollout-*.jsonl`
   - `.codex/memories/MEMORY.md`
   - `.codex/memories/memory_summary.md`
   - `.cursor/memory/CURSOR_AGENT_MEMORY.md`
   - `.cursor/projects/**/agent-transcripts/**/*.jsonl`
   - `handoff/CURRENT_TASK.md`, `handoff/LAST_STATUS.md`, `handoff/DECISIONS.md`
   - any `SKILL.md` files under `.codex/skills`, `.cursor/skills`, or uploaded toolkit `skills/`
3. If text appears as Chinese mojibake such as `浣犲ソ`, decode it as GBK-displayed UTF-8 when summarizing:
   - interpret the visible string as GBK bytes
   - decode those bytes as UTF-8
4. Do not read or upload obvious secrets such as `auth.json`, API keys, private keys, `.env`, or token-bearing config unless the user explicitly asks and the task is security-safe.

## How To Continue Work

Build a short continuation state before editing:

- current task or latest unresolved request
- confirmed decisions
- files/projects involved
- last known working state
- known failure modes
- exact next action

For large transcript sets, prefer the latest main transcript first, then sample earlier records by topic. Do not brute-force summarize every cache file unless the user asks for an archive.

## Learning Old Skills

When old-machine skills are present:

1. Read the old `SKILL.md` files that match current work.
2. Compare against this machine's existing `~/.codex/skills`.
3. Import lessons, not whole folders, unless the skill is missing and clearly useful.
4. Prefer appending to an existing owner skill:
   - Keil, GBK C, CAN, PWM, HMI: `keil5-embedded-c`
   - OpenCV / AprilTag / visual calibration: `opencv-terminalskills`, `robot-perception`, or a project-specific vision skill
   - GitHub/toolkit handoff: `external-record-continuity` or `work-continuity-sync`
5. If a new skill is created, keep it focused on triggers, source paths, method, verification, and caveats.

## Imported Lessons From 2026-05-23 USB Records

- The user's historical records may live under `.codex` and `.cursor` roots on a removable drive. The useful files are usually memory summaries and latest agent transcripts, not the bundled plugin caches.
- Cursor/Codex transcripts from older Windows setups can contain mojibake but are still recoverable enough to extract task state.
- For legacy embedded C/Keil work, preserve GBK/GB2312 encoding. Back up target files before edits, modify GBK C/H files by byte-safe decode/edit/encode, and verify comments/functions afterward.
- For garbled Chinese comments, change comments only. Do not change protocol IDs, variable names, business logic, or call order merely while cleaning text.
- For hardware protocol documents, read actual source code and call paths first. Do not generate protocol tables from expectation alone.
- For AprilTag / total-station validation, compare calculated world coordinates against measured world coordinates. Prefer `TagCenter_world_calc` vs `TagCenter_world_measured` over vague distance checks.

## Upload After Learning

When the user asks to upload after reading/learning records:

1. Update or create the local skill under `C:\Users\t250c\.codex\skills`.
2. Mirror the updated skill into `C:\Users\t250c\Documents\Codex\codex-personal-toolkit\skills`.
3. Run the toolkit upload workflow:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
C:\Users\t250c\Documents\Codex\codex-personal-toolkit\upload-work.ps1
```

4. Report the archive path, commit hash, and any skill names that were created or changed.

## Caveats

- Do not overwrite newer local skills with older USB skills.
- Do not treat old transcript conclusions as currently verified if the project files may have changed. Re-check code before editing.
- If an upload script detects secrets, stop and report the blocker instead of forcing the upload.
