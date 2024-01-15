function DisconnectFromVCenter {
    param (
        [Alias("Server")]
        [string]$vCenterId = '*'
    )
    if($null -eq $vCenterId) {
        Write-Warning 'DisconnectFromVCenter: vCenterId is NULL'
        return
    }
    try {

        Disconnect-VIServer -Server $vCenterId -Confirm:$false -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null 

        Start-Sleep -Milliseconds 1000
        Write-Host -ForegroundColor Green "DisconnectFromVCenter: Connected closed" $vCenterId
    }
    catch {
        Write-Warning "DisconnectFromVCenter: Warning for vCenterId=$vCenterId, $_"
    }
}
