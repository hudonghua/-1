---
name: multi-computer-toolkit-merge
description: Merge Codex toolkit uploads from multiple computers. Use when another computer has its own skills, MCP servers, work-states, memory/sqlite records, or task snapshots that need to be integrated without overwriting local work.
---

# Multi-Computer Toolkit Merge

Use this skill when the user says another computer also has tasks, skills, MCP servers, records, or work-state uploads that need to be integrated here.

The rule is: merge, do not blindly overwrite.

## Required Behavior

When syncing from GitHub or another computer:

1. Pull or download the latest toolkit repository.
2. Compare local and incoming:
   - `skills/`
   - `mcp_servers/`
   - `mcp_config_snippets/`
   - `work-states/`
   - `records/` or `mcp-data`
3. Add new items.
4. Preserve local-only items.
5. For same-name skill/MCP files with different content, create a conflict copy and a merge report.
6. Do not delete local skills or records unless the user explicitly requests deletion.
7. After merging, commit and push the integrated state.

## Conflict Handling

If a skill exists on both computers:

- If content is identical, keep one.
- If incoming is newer and local is unchanged, update.
- If both changed, keep local file and save incoming as:

```text
SKILL.incoming-YYYYMMDD-HHMMSS.md
```

Then create a merge report requiring user review.

## Memory/SQLite Records

When both sides have records:

- Do not overwrite `.sqlite` files blindly.
- Export/import row-level records when possible.
- Deduplicate by title + category + body hash.
- Keep source computer and timestamp in the record when known.

## Work States

Work-state folders are append-only:

```text
work-states/YYYY/topic_timestamp/
```

Never merge two work-state folders with the same timestamp unless they are identical. If collision occurs, append the source computer name or a suffix.

## Recommended Report

Create:

```text
merge-reports/YYYYMMDD-HHMMSS.md
```

Include:

- source
- added files
- unchanged files
- conflicts
- skipped private files
- recommended next actions

## Safety

- Do not sync secrets or credentials.
- Do not overwrite local `.codex/config.toml` without backing it up.
- Do not delete unrelated local workspaces.
- Prefer explicit conflict reports over clever automatic merges.
