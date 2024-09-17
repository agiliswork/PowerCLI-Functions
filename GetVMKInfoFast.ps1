function GetVMKInfoFast
{
    param(
    [Parameter()]
    $esxHost,
    [ValidateSet('faultToleranceLogging','management','nvmeRdma','nvmeTcp',
    'ptp','vSphereBackupNFC','vSphereProvisioning','vSphereReplication',
    'vSphereReplicationNFC','vmotion','vsan','vsanWitness','ALL-VMK-IP')]
    [string]
    $nicType
    )

    if($nicType -eq 'ALL-VMK-IP')
    {
        $CustomObjArr = @()
        $NicConfigObjArr = $esxHost.Config.VirtualNicManagerInfo.NetConfig | Where-Object {$_.SelectedVnic -ne $null } 
        foreach($NicConfigObj in $NicConfigObjArr)
        {
            $seclectedInfo = $NicConfigObj.CandidateVnic | Where-Object {$NicConfigObj.SelectedVnic -contains $_.Key} | Select-Object -ExpandProperty Spec
            if($null -ne $seclectedInfo)
            {
                $CustomObjArr += $seclectedInfo | Select-Object 'Portgroup','Mtu','Mac',
                                        @{Label='NicType'; Expression={$NicConfigObj.NicType}},
                                        @{Label='IP'; Expression={$_.Ip.IpAddress}},
                                        @{Label='SubnetMask'; Expression={$_.Ip.SubnetMask}}
            } 
        }
        return $CustomObjArr
    }
    else
    {
        $CustomObj = $null
        $NicConfigObj = $esxHost.Config.VirtualNicManagerInfo.NetConfig | Where-Object {$_.NicType -eq $nicType} 
        $seclectedInfo = $NicConfigObj.CandidateVnic | Where-Object {$NicConfigObj.SelectedVnic -contains $_.Key}  | Select-Object -ExpandProperty Spec

        if($null -ne $seclectedInfo)
        {
            $CustomObj = $seclectedInfo | Select-Object 'Portgroup','Mtu','Mac',
                                @{Label='NicType'; Expression={$nicType}},
                                @{Label='IP'; Expression={$_.Ip.IpAddress}},
                                @{Label='SubnetMask'; Expression={$_.Ip.SubnetMask}}
        }
        return $CustomObj
    }
}
