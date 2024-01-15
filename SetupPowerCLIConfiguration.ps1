function SetupPowerCLIConfiguration {
    param (
        [string]$scope,
        [string]$optionName,
        [object]$optionValue
    )

    try {
        $currentConfiguration = Get-PowerCLIConfiguration
        $currentOptionValue = $currentConfiguration | Where-Object { $_.Scope -eq $scope } | Select-Object -ExpandProperty $optionName

        if ($currentOptionValue -ne $optionValue) {
            Set-PowerCLIConfiguration -Scope $scope -Confirm:$false -ErrorAction Stop @{
                $optionName = $optionValue
            } | Out-Null
            Write-Host "SetupPowerCLIConfiguration: Configured:$optionName to $optionValue ($scope) " -ForegroundColor Green
        }
        else {
            Write-Host "SetupPowerCLIConfiguration: Already configured:$optionName to $optionValue ($scope) " -ForegroundColor Green
        }
    }
    catch {
        Write-Error "SetupPowerCLIConfiguration: Error setting PowerCLI configuration option '$optionName': $_"
    }
}
