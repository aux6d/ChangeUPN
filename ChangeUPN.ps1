Start-Transcript -OutputDirectory "C:\Temp"

#Added UPN suffix in the forest
$AllUPNSuffixes = Get-ADForest
if (($AllUPNSuffixes.UPNSuffixes) -eq "NewDomainName")
{
	Write-Output = "UPN suffix already present in the forest"
}
else
{
	Get-ADForest | Set-ADForest -UPNSuffixes @{ add = "NewDomainName" }
}

#Changed all "@OldDomainName" UPNs to "@NewDomainName"
$AllUPN = Get-ADUser -Filter { UserPrincipalName -like '*@OldDomainName' } -Properties UserPrincipalName, ProxyAddresses, Mail
foreach ($UPN in $AllUPN)
{
	$OldUPN = $UPN.UserPrincipalName;
	$SplitUPN = $OldUPN.split("@")[0];
	$NewUPN = $UPN.UserPrincipalName.Replace("OldDomainName", "NewDomainName");
	$NewDomainCom = "Modification: $OldUPN => $SplitUPN@NewDomainName";
	Write-Output $NewDomainCom
	$UPN | Set-ADUser -UserPrincipalName $NewUPN -Add @{ proxyAddresses = "smtp:$OldUPN" } -replace @{ mail = "$NewUPN" }
}
Stop-Transcript
