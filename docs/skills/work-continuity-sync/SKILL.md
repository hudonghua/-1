---
name: work-continuity-sync
description: Triggered when the user says "上传" as a standalone command or asks for seamless work handoff across computers. Create and upload a complete work-state snapshot including current workspace, session transcript/raw record, skills/MCP/toolkit state, Memory/SQLite records when available, and restore instructions.
---

# Work Continuity Sync

Use this skill when the user says `上传` as a standalone command, or asks to continue the same work on another computer.

The user's intent is not only chat archival. The intent is cross-computer continuity: another computer should be able to download the GitHub toolkit and resume the work with current files, context, skills, MCP servers, and records.

## Required Behavior

When triggered:

1. Export the latest work state into the private toolkit repository:

```text
C:\Users\t250c\Documents\Codex\codex-personal-toolkit
```

2. Include:

- current workspace snapshot as a zip
- readable session transcript
- raw local session `.jsonl`
- manifest with source paths and timestamps
- installed skill list
- MCP config/server list
- Memory/SQLite data when safe and available
- restore instructions

3. Commit and push to:

```text
https://github.com/hudonghua/codex-personal-toolkit
```

4. Report the archive path, commit hash, and restore command.

## Preferred Script

Use:

```text
C:\Users\t250c\Documents\Codex\codex-personal-toolkit\upload-work.ps1
```

If PowerShell script execution is blocked, run the same steps inline or use:

```text
C:\Users\t250c\Documents\Codex\codex-personal-toolkit\scripts\export_work_state.py
```

## Archive Layout

```text
work-states/YYYY/topic_YYYYMMDD-HHMMSS/
  manifest.json
  README.md
  transcript.md
  raw-session.jsonl
  workspace.zip
  skill-list.txt
  mcp-summary.txt
  mcp-data/
```

## Privacy

Do not upload obvious secrets such as GitHub tokens, OpenAI API keys, private keys, or `.env` files.

The workspace zip must exclude common private or bulky folders:

- `.git`
- `node_modules`
- `.venv`, `venv`
- `__pycache__`
- `.cache`
- `dist`, `build`
- `.env`, `.env.*`
- key/certificate files such as `.pem`, `.key`, `.pfx`

If real secrets are detected, stop and ask. Do not stop merely because the conversation mentions the words password/token.

## Restore On Another Computer

On another computer:

1. Download or clone the private toolkit repository.
2. Run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\install.ps1 -IncludeData
```

3. Open the latest `work-states/.../README.md`.
4. Extract `workspace.zip` to continue from the saved workspace.
5. Restart Codex so skills/MCP load.

## After Upload

Save a Memory/SQLite record if available with:

- archive path
- commit hash
- source workspace
- source session file
- restore command
