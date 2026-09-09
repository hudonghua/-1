---
name: chat-transcript-uploader
description: Export local Codex chat/session records to timestamped documents and upload them to the user's GitHub toolkit repository. Use for explicit chat transcript/archive requests. For standalone "上传", prefer work-continuity-sync.
---

# Chat Transcript Uploader

Use this skill when the user explicitly asks to upload or archive the chat transcript. For a standalone `上传` command, use `work-continuity-sync` instead because the user wants cross-computer work continuity, not only a chat transcript.

## Required Behavior

When triggered:

1. Locate the current or latest Codex session `.jsonl` under:

```text
C:\Users\t250c\.codex\sessions
```

2. Generate an archive folder named from the chat topic plus timestamp.
3. Save both:
   - a readable Markdown transcript
   - the original raw `.jsonl` session file
4. Commit and push the archive to:

```text
https://github.com/hudonghua/codex-personal-toolkit
```

5. Report the GitHub path/commit after upload.

## Exactness Rule

For "一字不漏", the raw `.jsonl` must be included. The Markdown is a readable rendering and may omit internal harness metadata unless the user explicitly asks for raw internals in the rendered document.

If the local session file cannot be found, say that exact export is blocked and do not pretend the in-context conversation is complete.

## Naming

Use a filename/folder format like:

```text
chat-archives/YYYY/topic-slug_YYYYMMDD-HHMMSS/
```

The topic should come from the main content of the conversation, not just generic words.

## Privacy

Do not upload secrets, passwords, tokens, or private credentials if detected. If sensitive content appears in the transcript, stop and ask whether to redact or proceed with raw archival.

## Tools

Prefer the toolkit script:

```text
C:\Users\t250c\Documents\Codex\codex-personal-toolkit\scripts\export_chat_archive.py
```

Use portable tools when available:

```text
C:\Users\t250c\.codex\tools\mingit\cmd\git.exe
C:\Users\t250c\.codex\tools\gh\bin\gh.exe
```

## After Upload

Save a Memory/SQLite record if available:

- repository URL
- archive path
- timestamp
- commit hash
- source session file
