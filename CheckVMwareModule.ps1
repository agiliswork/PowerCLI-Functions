function CheckVMwareModule {
    param (
        [string]$moduleName = 'VMware.VimAutomation.Core'
    )
    try {
        [array]$currentModuleArr = Get-Module -Name $moduleName -ListAvailable | Sort-Object Version -Descending 
        if ($moduleVersions -ne $null -and $moduleVersions.Count -gt 0) {
            foreach($currentModule in $currentModuleArr) {
                Write-Host $currentModule.Version  $currentModule.Path
            }
            Import-Module -Name $moduleName  -Global -RequiredVersion $currentModule[0].Version
        }
        else {
            Write-Error "CheckVMwareModule: Not found $moduleName in PSModulePath: $env:PSModulePath"
        }
    }
    catch {
        Write-Error "CheckVMwareModule: An error occurred: $_"
    }
}
