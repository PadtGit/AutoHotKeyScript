# IT-Workflow

Windows automation for day-to-day IT support tasks with AutoHotkey v2.

The main entrypoint is [script/IT-Workflow.ahk](./script/IT-Workflow.ahk). It loads workstation-specific settings from layered INI files, registers hotstrings, and runs a hardened `Ctrl+L` startup workflow that creates your daily notes folder and launches your support tools.

## What It Does

- Expands common support replies with hotstrings
- Creates a dated notes folder on `Ctrl+L`
- Creates a `note.txt` file only when missing
- Opens File Explorer, the note file, and your configured support tools
- Writes a local log for startup actions and failures

## Repo Layout

```text
README.md
script/
  IT-Workflow.ahk
  main.ahk
  hotstrings.ahk
  startup.ahk
  config.example.ini
  lib/
    config.ahk
    logging.ahk
```

## Requirements

- Windows
- AutoHotkey v2
- Full executable paths for the apps you want to launch
- A valid ticketing URL

## Installation

1. Install AutoHotkey v2 on Windows.
2. Clone or download this repository.
3. Copy `script/config.example.ini` to `script/config.local.ini`.
4. Fill in your local paths and URL in `script/config.local.ini`.
5. Run `script/IT-Workflow.ahk` with AutoHotkey.
6. Test the hotstrings, then press `Ctrl+L` to verify the startup workflow.

## Sample Config

`config.example.ini` is intentionally incomplete so workstation-specific values stay out of git. Start from a local copy like this:

```ini
[paths]
notes_root=C:\Users\YourUser\OneDrive - YourOrg\Desktop\Capture
outlook=C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE
labtech=C:\Program Files (x86)\LabTech Client\LTClient.exe
onenote=C:\Program Files (x86)\Microsoft Office\root\Office16\ONENOTE.EXE
softphone=C:\Users\YourUser\AppData\Local\Programs\3CXDesktopApp\3CXDesktopApp.exe

[urls]
ticket=https://your-ticketing-system.example

[settings]
date_format=yy-MM-dd
note_filename=note.txt
log_dir=.\logs
```

## How Startup Works

When you press `Ctrl+L`, the script:

1. Builds a folder name from the current date.
2. Creates the notes root and daily folder only if they do not already exist.
3. Creates `note.txt` only if it is missing.
4. Validates each configured app path before launching it.
5. Validates the ticket URL before opening it.
6. Continues launching valid targets even if one target fails.
7. Shows one summary message at the end if anything failed.

The log file is written to `script/logs/IT-Workflow.log` by default.

## Troubleshooting

If `Ctrl+L` does nothing:

- Confirm you are running `script/IT-Workflow.ahk` with AutoHotkey v2.
- Check `script/config.local.ini` for blank required values.
- Open `script/logs/IT-Workflow.log` for startup details.

If an app does not launch:

- Use a full executable path in `config.local.ini`.
- Verify the file exists on disk.
- Check the log for the exact missing path that was skipped.

If the ticket page does not open:

- Make sure the URL starts with `http://` or `https://`.
- Check the startup summary message and the log for the invalid value.

If the notes folder is not created:

- Confirm `paths.notes_root` points to a writable folder location.
- Check whether OneDrive or another sync tool changed the local path.

## Customize For Another Workstation

- Keep `script/config.example.ini` as the shared template.
- Create a different `script/config.local.ini` on each workstation.
- Update only the local file when usernames, install locations, or URLs differ.
- Leave the script logic unchanged unless the workflow itself changes.

## Later

Packaging is intentionally out of scope for this pass. Future work can add:

- Compiled AutoHotkey builds if needed
- Version numbers
- A changelog
- GitHub releases
