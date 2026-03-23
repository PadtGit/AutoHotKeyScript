global g_Config := ""
global g_StartupEnabled := false

InitializeWorkflow(baseDir) {
    global g_Config, g_StartupEnabled

    g_Config := LoadConfig(baseDir)
    InitLogger(baseDir, g_Config["settings"]["log_dir"])
    LogInfo("Script started.")

    missingKeys := GetMissingRequiredConfig(g_Config)
    if (missingKeys.Length > 0) {
        message := "Startup workflow is disabled until config.local.ini is completed."
            . "`n`nMissing values:`n- " . JoinArray(missingKeys, "`n- ")

        LogError("Startup workflow disabled. Missing config values: " . JoinArray(missingKeys, ", "))
        MsgBox(message, "IT-Workflow configuration required", 0x30)
        return
    }

    Hotkey("^l", StartupHotkeyHandler)
    g_StartupEnabled := true
    LogInfo("Startup hotkey registered: Ctrl+L")
}

StartupHotkeyHandler(*) {
    global g_Config, g_StartupEnabled

    if !g_StartupEnabled {
        MsgBox("Startup workflow is currently disabled. Review config.local.ini and try again.", "IT-Workflow startup unavailable", 0x30)
        return
    }

    RunStartupWorkflow(g_Config, A_ScriptDir)
}

JoinArray(items, delimiter := ", ") {
    output := ""

    for index, item in items {
        if (index > 1) {
            output .= delimiter
        }

        output .= item
    }

    return output
}
