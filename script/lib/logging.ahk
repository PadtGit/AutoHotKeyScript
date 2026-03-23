global g_LogFilePath := ""

InitLogger(baseDir, configuredLogDir := ".\logs") {
    global g_LogFilePath

    logDir := ResolveConfigPath(baseDir, configuredLogDir)
    createdLogDir := false

    if (logDir = "") {
        logDir := CombinePath(baseDir, "logs")
    }

    if !IsExistingDirectory(logDir) {
        try {
            DirCreate(logDir)
            createdLogDir := true
        } catch Error as err {
            MsgBox("Unable to initialize the log directory.`n`n" . logDir . "`n`n" . err.Message, "IT-Workflow logging error", 0x10)
            g_LogFilePath := ""
            return ""
        }
    }

    g_LogFilePath := CombinePath(logDir, "IT-Workflow.log")

    try {
        if !IsExistingFile(g_LogFilePath) {
            FileAppend("", g_LogFilePath, "UTF-8")
        }
    } catch Error as err {
        MsgBox("Unable to initialize the log file.`n`n" . g_LogFilePath . "`n`n" . err.Message, "IT-Workflow logging error", 0x10)
        g_LogFilePath := ""
        return ""
    }

    if createdLogDir {
        LogInfo("Log directory created: " . logDir)
    } else {
        LogInfo("Log directory ready: " . logDir)
    }

    LogInfo("Logger initialized: " . g_LogFilePath)
    return g_LogFilePath
}

LogInfo(message) {
    WriteLog("INFO", message)
}

LogWarn(message) {
    WriteLog("WARN", message)
}

LogError(message) {
    WriteLog("ERROR", message)
}

WriteLog(level, message) {
    global g_LogFilePath

    if (g_LogFilePath = "") {
        return
    }

    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")

    try {
        FileAppend(timestamp . " [" . level . "] " . message . "`r`n", g_LogFilePath, "UTF-8")
    } catch {
        return
    }
}
