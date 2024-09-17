function ConnectToVCenter {
    param (
        [Parameter(Mandatory=$true)]
        [Alias("Server")] 
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
    
    Write-Host (Get-Module -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue | Format-List -Property Name,Path,Version | Out-String) -ForegroundColor Green 

    Set-PowerCLIConfiguration -Scope Session -ParticipateInCEIP          $false -Confirm:$false -ErrorAction Stop | Out-Null
    Set-PowerCLIConfiguration -Scope Session -InvalidCertificateAction   Ignore -Confirm:$false -ErrorAction Stop | Out-Null
    Set-PowerCLIConfiguration -Scope Session -DefaultVIServerMode        Single -Confirm:$false -ErrorAction Stop | Out-Null
    Set-PowerCLIConfiguration -Scope Session -WebOperationTimeoutSeconds 1800   -Confirm:$false -ErrorAction Stop | Out-Null

    Write-Host "PowerCLIConfiguration:$(Get-PowerCLIConfiguration -Scope Session | Format-List | Out-String )" -ForegroundColor Green
    try {
        if ($credential) {
            $currentConnection = $global:DefaultVIServer | Where-Object { $_.Name -eq $vCenterServerName -and $_.User -match $credential.UserName }

            if ($currentConnection.IsConnected) {
                Write-Host "ConnectToVCenter: Used Connection from global:DefaultVIServers $($currentConnection.Name)" -ForegroundColor Green
                return $currentConnection
            }

            $vCenterId =  Connect-VIServer $vCenterServerName -Credential $credential -ErrorAction Stop -WarningAction SilentlyContinue
            Write-Host "ConnectToVCenter: Credential $($credential.GetType().FullName) $($credential.UserName)"
        } 
        else {
            $currentConnection = $global:DefaultVIServer | Where-Object { $_.Name -eq $vCenterServerName -and $_.User -match $env:USERNAME }

            if ($currentConnection.IsConnected) {
                Write-Host "ConnectToVCenter: Used Connection from global:DefaultVIServer $($global:DefaultVIServer.Name)" -ForegroundColor Green
                return $currentConnection
            }

            $vCenterId =  Connect-VIServer $vCenterServerName -ErrorAction Stop -WarningAction SilentlyContinue
        } 
    }
    catch [VMware.VimAutomation.ViCore.Types.V1.ErrorHandling.InvalidLogin] {
        Write-Warning "ConnectToVCenter: Invalid credentials or access denied, Error: $_"
        return $null
    }
    catch [VMware.VimAutomation.Sdk.Types.V1.ErrorHandling.VimException.ViServerConnectionException] {
        Write-Warning "ConnectToVCenter: Invalid server name or ip, Error: $_"
        return $null
    }
    catch {
        Write-Error "ConnectToVCenter: Connect-VIServer $vCenterServerName Error: $_"
        return $null		
    }

    if ($null -eq $vCenterId) {
        Write-Warning 'ConnectToVCenter: vCenterId is NULL'
				 
    }

    if ($vCenterId.IsConnected) {
        $vcPropertyArr = @("Name", "User", "Version", "Build", "IsConnected", "Id", "ServiceUri", "Port")
        Write-Host "ConnectToVCenter: $($vCenterId | Format-List -Property $vcPropertyArr | Out-String )" -ForegroundColor Green
        return $vCenterId
    }
    else {
        Write-Warning 'ConnectToVCenter: Not Connected' -ForegroundColor Yellow
        return $null
    }
}
