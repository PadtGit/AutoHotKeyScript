RunStartupWorkflow(config, baseDir) {
    failures := []
    paths := config["paths"]
    urls := config["urls"]
    settings := config["settings"]

    LogInfo("Startup launched.")

    dateStamp := FormatTime(, settings["date_format"])
    notesRoot := ResolveConfigPath(baseDir, paths["notes_root"])
    todayPath := CombinePath(notesRoot, dateStamp)
    todayNote := CombinePath(todayPath, settings["note_filename"])

    notesRootReady := EnsureDirectory(notesRoot, "Notes root", failures)
    dailyFolderReady := false
    noteReady := false

    if notesRootReady {
        dailyFolderReady := EnsureDirectory(todayPath, "Daily notes folder", failures)
    } else {
        LogWarn("Daily notes folder skipped because the notes root is unavailable.")
    }

    if dailyFolderReady {
        noteReady := EnsureNoteFile(todayNote, dateStamp, failures)
    } else {
        LogWarn("Daily note creation skipped because the daily folder is unavailable.")
    }

    if dailyFolderReady {
        LaunchCommand("Explorer", "explorer.exe " . QuoteArg(todayPath), failures)
    } else {
        LogWarn("Explorer launch skipped because the daily folder is unavailable.")
    }

    LaunchConfiguredApp("Outlook", ResolveConfigPath(baseDir, paths["outlook"]), failures)
    LaunchConfiguredUrl("Ticket URL", urls["ticket"], failures)
    LaunchConfiguredApp("LabTech", ResolveConfigPath(baseDir, paths["labtech"]), failures)
    LaunchConfiguredApp("OneNote", ResolveConfigPath(baseDir, paths["onenote"]), failures)
    LaunchConfiguredApp("Softphone", ResolveConfigPath(baseDir, paths["softphone"]), failures)

    if noteReady {
        LaunchCommand("Notepad", "notepad.exe " . QuoteArg(todayNote), failures)
    } else {
        LogWarn("Notepad launch skipped because the daily note is unavailable.")
    }

    if (failures.Length > 0) {
        summary := "Startup finished with issues:`n`n- " . JoinArray(failures, "`n- ")
        LogWarn("Startup finished with issues: " . JoinArray(failures, " | "))
        MsgBox(summary, "IT-Workflow startup summary", 0x30)
        return
    }

    LogInfo("Startup finished successfully.")
}

EnsureDirectory(path, label, failures) {
    if (path = "") {
        failures.Push(label . " path is missing.")
        LogError(label . " path is missing.")
        return false
    }

    if IsExistingDirectory(path) {
        LogInfo(label . " already exists: " . path)
        return true
    }

    try {
        DirCreate(path)
        LogInfo(label . " created: " . path)
        return true
    } catch Error as err {
        failures.Push(label . " could not be created: " . path)
        LogError(label . " could not be created: " . path . " | " . err.Message)
        return false
    }
}

EnsureNoteFile(notePath, initialContent, failures) {
    if IsExistingFile(notePath) {
        LogInfo("Daily note already exists: " . notePath)
        return true
    }

    if IsExistingDirectory(notePath) {
        failures.Push("Daily note path points to a folder: " . notePath)
        LogError("Daily note path points to a folder: " . notePath)
        return false
    }

    try {
        FileAppend(initialContent . "`r`n", notePath, "UTF-8")
        LogInfo("Daily note created: " . notePath)
        return true
    } catch Error as err {
        failures.Push("Daily note could not be created: " . notePath)
        LogError("Daily note could not be created: " . notePath . " | " . err.Message)
        return false
    }
}

LaunchConfiguredApp(label, path, failures) {
    if !IsExistingFile(path) {
        failures.Push(label . " path is missing: " . path)
        LogError(label . " path is missing: " . path)
        return false
    }

    return LaunchCommand(label, QuoteArg(path), failures)
}

LaunchConfiguredUrl(label, url, failures) {
    if (url = "") {
        failures.Push(label . " is missing.")
        LogError(label . " is missing.")
        return false
    }

    if !RegExMatch(url, "^https?://") {
        failures.Push(label . " is invalid: " . url)
        LogError(label . " is invalid: " . url)
        return false
    }

    return LaunchCommand(label, url, failures)
}

LaunchCommand(label, command, failures) {
    try {
        Run(command)
        LogInfo(label . " launched: " . command)
        return true
    } catch Error as err {
        failures.Push(label . " failed to launch.")
        LogError(label . " failed to launch: " . command . " | " . err.Message)
        return false
    }
}

QuoteArg(value) {
    return Chr(34) . value . Chr(34)
}
