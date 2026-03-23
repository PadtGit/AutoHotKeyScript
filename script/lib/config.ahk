LoadConfig(baseDir) {
    config := CreateEmptyConfig()

    for _, fileName in ["config.example.ini", "config.local.ini"] {
        configPath := CombinePath(baseDir, fileName)

        if IsExistingFile(configPath) {
            LoadConfigFile(config, configPath)
        }
    }

    return config
}

CreateEmptyConfig() {
    config := Map()

    for section, keys in GetConfigSchema() {
        sectionValues := Map()

        for _, key in keys {
            sectionValues[key] := ""
        }

        config[section] := sectionValues
    }

    return config
}

LoadConfigFile(config, configPath) {
    for section, keys in GetConfigSchema() {
        sectionValues := config[section]

        for _, key in keys {
            value := IniRead(configPath, section, key, "__MISSING__")

            if (value != "__MISSING__") {
                sectionValues[key] := Trim(value)
            }
        }
    }
}

GetMissingRequiredConfig(config) {
    missing := []

    for section, keys in GetConfigSchema() {
        for _, key in keys {
            if (config[section][key] = "") {
                missing.Push(section . "." . key)
            }
        }
    }

    return missing
}

GetConfigSchema() {
    return Map(
        "paths", ["notes_root", "outlook", "labtech", "onenote", "softphone"],
        "urls", ["ticket"],
        "settings", ["date_format", "note_filename", "log_dir"]
    )
}

ResolveConfigPath(baseDir, configuredPath) {
    path := Trim(configuredPath)

    if (path = "") {
        return ""
    }

    if IsAbsolutePath(path) {
        return StrReplace(path, "/", "\")
    }

    if (SubStr(path, 1, 2) = ".\") || (SubStr(path, 1, 2) = "./") {
        path := SubStr(path, 3)
    }

    path := StrReplace(path, "/", "\")
    return CombinePath(baseDir, path)
}

IsAbsolutePath(path) {
    return RegExMatch(path, "i)^[A-Z]:\\") || (SubStr(path, 1, 2) = "\\")
}

CombinePath(left, right) {
    if (left = "") {
        return right
    }

    if (right = "") {
        return left
    }

    return RTrim(StrReplace(left, "/", "\"), "\") . "\" . LTrim(StrReplace(right, "/", "\"), "\")
}

IsExistingDirectory(path) {
    return (path != "") && InStr(FileExist(path), "D")
}

IsExistingFile(path) {
    attributes := FileExist(path)
    return (path != "") && (attributes != "") && !InStr(attributes, "D")
}
