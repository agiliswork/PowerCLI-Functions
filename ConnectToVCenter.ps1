function ConnectToVCenter {
    param (
        [string]$vCenterServerName,
        [System.Management.Automation.PSCredential]$credential = $null
    )

    if ([string]::IsNullOrWhiteSpace($vCenterServerName)) {
        Write-Warning 'ConnectToVCenter: vCenterServerName is NULL or Empty'
    }

    if (-not (Get-Command -Name 'Connect-VIServer' -ErrorAction SilentlyContinue)) {
        try {
																											  
            Import-Module VMware.VimAutomation.Core -Global -ErrorAction Stop
            Start-Sleep -Milliseconds 1000
        }
        catch {
            Write-Error "ConnectToVCenter: Unable to import VMware.VimAutomation.Core module: $_"
        }
    }


    try {
        if ($credential) {
            $currentConnection = $global:DefaultVIServer | Where-Object { $_.Name -eq $vCenterServerName -and $_.User -match $credential.UserName }

            if ($currentConnection.IsConnected) {
                Write-Host "ConnectToVCenter: Used Connection from global:DefaultVIServers $($global:DefaultVIServer.Name)" -ForegroundColor Green
                return $currentConnection
            }

            $vCenterId =  Connect-VIServer $vCenterServerName -Credential $credential -ErrorAction Stop -WarningAction SilentlyContinue
            Write-Host "ConnectToVCenter: Credential $($credential.GetType().FullName) $($credential.UserName)"
        } 
        else {
            $currentConnection = $global:DefaultVIServer | Where-Object { $_.Name -eq $vCenterServerName -and $_.User -match $env:USERNAME }

            if ($currentConnection.IsConnected) {
                Write-Host "ConnectToVCenter: Used Connection from global:DefaultVIServers $($global:DefaultVIServer.Name)" -ForegroundColor Green
                return $currentConnection
            }

            $vCenterId =  Connect-VIServer $vCenterServerName -ErrorAction Stop -WarningAction SilentlyContinue
        } 
    }
    catch [VMware.VimAutomation.ViCore.Types.V1.ErrorHandling.InvalidLogin] {
        Write-Warning "ConnectToVCenter: Invalid credentials or access denied"
        return $null
    }
    catch [System.Management.Automation.RuntimeException] {
        Write-Warning "ConnectToVCenter: Invalid Host Name"
        return $null
    }
    catch {
        Write-Error "ConnectToVCenter: Connect-VIServer $vCenterServerName Error: $_"
					
    }

    if ($null -eq $vCenterId) {
        Write-Warning 'ConnectToVCenter: vCenterId is NULL'
				 
    }

    if ($vCenterId.IsConnected) {
        Write-Host "ConnectToVCenter: $($vCenterId.Name), Connection status: $($vCenterId.IsConnected), Type: $($vCenterId.GetType().FullName)" -ForegroundColor Green
        return $vCenterId
    }
    else {
        Write-Warning 'ConnectToVCenter: Not Connected' -ForegroundColor Yellow
        return $null
    }
}
