---
name: workflow-memory-skillsmith
description: Mandatory workflow for turning repeated task lessons, tool discoveries, failure fixes, user-specific procedures, and practical troubleshooting records into global Codex skills under ~/.codex/skills. Use after tasks that reveal reusable methods, recurring failure patterns, installation fixes, domain procedures, or user-provided operational notes.
---

# Workflow Memory Skillsmith

This skill is mandatory when a task reveals a reusable lesson, workaround, method, tool path, domain checklist, failure fix, or user-specific procedure. Its purpose is to make future similar work faster by saving practical experience as global Codex skills and, when available, MCP-backed memory/SQLite records.

Global skill root on this machine:

```text
C:\Users\t250c\.codex\skills
```

Local MCP memory data, when configured:

```text
C:\Users\t250c\.codex\mcp_data\memory.sqlite
C:\Users\t250c\.codex\mcp_data\records.sqlite
```

## Strict Rule

At the end of substantial tasks, check whether any part of the work should be preserved as a global skill, appended to an existing global skill, and/or saved through the local Memory/SQLite MCP tools.

Do this especially when:

- A problem was blocked and then solved by finding a specific tool, path, command, API, workaround, or procedure.
- The task is likely to repeat.
- The user provides personal notes or prior records.
- A tool installation or environment issue was solved.
- A domain-specific workflow was clarified.
- A failure mode was diagnosed.
- A file encoding, firmware, measurement, Excel, image, browser, GitHub, or embedded-development trick was learned.

If the lesson is clearly reusable and low risk, save it. If it could be controversial, destructive, security-sensitive, or too user-specific to generalize safely, ask before saving.

When Memory/SQLite MCP tools are available, prefer this pattern:

- Save concise searchable lesson summaries with `memory_add`.
- Save structured operational records with `sqlite_add_record`.
- Continue updating `SKILL.md` files for durable workflow rules and domain checklists.

The three layers serve different purposes:

- `SKILL.md`: teaches future behavior.
- Memory MCP: stores searchable lessons and user preferences.
- SQLite MCP: stores structured records such as bin patches, calibration records, GPIO cases, tool-install outcomes, and repeatable troubleshooting tables.

## Where To Save

Prefer appending to an existing relevant skill:

- Keil/MDK/C/Chinese comments: `keil5-embedded-c`
- MCU GPIO/peripherals: `mcu-gpio-peripheral`
- ARM Cortex-M: `arm-cortex-expert`
- ESP32: `esp32`
- Firmware binary/bin/hex/CRC: `firmware-binary-reverse`
- Reverse engineering/radare2: `reverse_engineer` or `radare2`
- OpenCV/vision: `opencv-terminalskills`, `robot-perception`, or `senior-computer-vision`
- Excel/table workflows: use the plugin `spreadsheets` if available; create a local helper only for user-specific recurring procedures.
- PPT: use `presentations` if available.
- Word/docs: use `documents` if available.
- PDF: `pdf`
- Total station calibration: `total-station-calibration`
- Survey data: `survey-data-processor`
- Skill management and installation lessons: this skill or `skill-installer`

Create a new skill only when no existing skill naturally owns the lesson.

## What To Save

Save high-signal, operational knowledge:

- Trigger: when to use the lesson.
- Symptoms: how the problem appears.
- Cause: what was actually wrong.
- Fix: exact method that worked.
- Verification: how to confirm success.
- Caveats: when not to use it.
- File paths or commands only when stable and machine-specific paths are useful.

Do not save:

- One-off guesses.
- Unverified speculation.
- Secrets, keys, passwords, private URLs, tokens, or customer confidential data.
- Large logs.
- Temporary paths that will not matter later.
- Harmful instructions such as bypassing authorization, malware deployment, credential theft, DRM/license bypass, or unauthorized access.

## Personal Records

When the user provides prior operational records, preserve them as structured notes, not vague memory.

Recommended format:

```text
## Records

### YYYY-MM-DD - Short title

- Context:
- Device/project:
- Symptom:
- Method that worked:
- Exact values/paths/offsets:
- Verification:
- Caveats:
- Source:
```

For firmware/bin records, use:

```text
Device / project:
MCU:
File type:
Known flash base:
Patch purpose:
Offset / address:
Original bytes:
New bytes:
Checksum method:
Verification result:
Date/source:
```

## Skill Update Procedure

1. Identify the owning skill.
2. Read the current `SKILL.md`.
3. Append a concise section such as `## Field Notes`, `## Local Workflow Notes`, `## Records`, or a domain-specific heading.
4. Preserve existing content.
5. Keep wording practical and testable.
6. After writing, verify the `SKILL.md` still exists and can be found by scanning the skills directory.

## End-Of-Task Checklist

Before final response on substantial tasks, ask internally:

- Did I find a reusable tool path, command, workaround, or failure diagnosis?
- Did the user give personal knowledge that should become a record?
- Did I create a script or process likely to be reused?
- Did I discover a missing skill category?
- Should I update an existing skill or create a new one?

If yes, save it globally or tell the user what should be saved and why.

## MCP Record Categories

Use these categories for `sqlite_add_record` when the SQLite MCP is available:

- `skill-update`
- `tool-install`
- `mcp-config`
- `firmware-bin-record`
- `keil-mdk-record`
- `gpio-peripheral-record`
- `vision-opencv-record`
- `survey-calibration-record`
- `excel-spreadsheet-record`
- `photoshop-image-record`
- `general-workflow-record`

## Response Style

When a reusable lesson is saved, briefly tell the user:

- Which skill was updated or created.
- Whether a Memory/SQLite MCP record was saved.
- What kind of lesson was saved.
- Whether Codex should be restarted for the skill to load in future sessions.

Keep the message short. The goal is not ceremony; the goal is compounding practical speed.
