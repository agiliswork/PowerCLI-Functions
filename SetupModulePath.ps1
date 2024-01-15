function SetupModulePath {
    param (
        [string]$currentScriptRoot = $PSScriptRoot
    )

    try {
        if([string]::IsNullOrEmpty($currentScriptRoot)) {
            $currentScriptRoot = $PWD
        }

        $newModulePath = Join-Path -Path $currentScriptRoot -ChildPath "modules"
        $currentModulePath = [Environment]::GetEnvironmentVariable("PSModulePath", "process")

        if (-not ($currentModulePath -like "*$newModulePath*")) {
            $newPSModulePath = $currentModulePath + ";" + $newModulePath
            [Environment]::SetEnvironmentVariable("PSModulePath", $newPSModulePath, "process")
            Write-Host "SetupModulePath: Configured: $newModulePath" -ForegroundColor Green
        }
        else
        {
            Write-Host "SetupModulePath: Already configured:$newModulePath" -ForegroundColor Green
        }
    }
    catch {
        Write-Error "SetupModulePath:Error setting module path: $_"
    }
}
