<#
.SYSNOPSIS
    Modify the Host Name of the Computer according to the MAC.
.DESCRIPTION
    This script only runs once automatically after the machine is ghosted successfully. It modifies the Host Name of the machine according to the machine's MAC.
#>
param
(
	[Switch]$Help
)
	
function WriteHelp()
{
    Write-Host ""
    Write-Host "This script only runs once automatically after the machine is ghosted successfully." -BackgroundColor DarkRed -ForegroundColor White
	Write-Host ""
    Write-Host "Please try to avoid running this script manually unless the Host Name of the machine is not modified successfully." -BackgroundColor DarkRed -ForegroundColor White
    Write-Host ""
    Write-Host ""
}

function WriteLog()
{
    $endTime = Get-Date
    $endTimeFormatted = $endTime.ToString("dddd M/dd - h:mm tt")
    "Ghosted Time: $endTimeFormatted" | Out-file $script:subPath\Ghost.log
    "MY Computer name: $env:COMPUTERNAME" | Out-file -Append $script:subPath\Ghost.log
 }
 
  
 ######################### SCRIPT START ################################
 
$script:startTime = Get-Date
$script:subPath =  'C:\Users\lvadmin\My Documents'
$script:indexName = New-Object 'System.Collections.Generic.Dictionary[string,string]'


$script:indexName = @{
					"D4-BE-D9-94-15-F7" = "SH-RD-HongHaier";
					"F8-B1-56-AF-FF-B5" = "SH-RD-SongJiang";
					"5C-F9-DD-6B-48-9E" = "SH-RD-LuJunYi";
					"90-2B-34-5B-51-4D" = "SH-RD-LongMa";
					"D4-BE-D9-8E-01-FA" = "SH-RD-GuanSheng";
					"D4-BE-D9-93-9E-42" = "SH-RD-LinChong";
					"90-2B-34-59-9F-46" = "SH-RD-TangSeng";
					"90-2B-34-59-85-31" = "SH-RD-ShaSeng";
					"90-2B-34-59-86-66" = "SH-RD-BaJie";
					"90-2B-34-59-A8-F6" = "SH-RD-WuKong";
					}
if ($Help)
{
	WriteHelp
	exit(0)
}
else{
	if(!(Test-path -LiteralPath "$script:subPath\Ghost.log")){
		$OS_Version = gwmi -class win32_operatingsystem|select-object -expandproperty caption
		$NetWork = GWMI -class Win32_NetworkAdapterConfiguration |where-object IpEnabled -EQ "True"
        if(($Network.MACAddress -is [array])){
			$MAC_List = $Network.MACAddress | sort-object
            $MAC = $MAC_List[-1].Replace(":","-")
        }
        else{
            $MAC = $Network.MACAddress.Replace(":","-")
        }
		if( $script:indexName.keys -contains $MAC ){
			$env:COMPUTERNAME = $script:IndexName[$MAC]
			WriteLog
			Rename-Computer -NewName $env:COMPUTERNAME -Restart
			exit(1)
		}
		else{
			$num = 10..99
			$random = Get-Random -InputObject $num
			$randomName = "SH-RD-FXP$random" 
			$env:COMPUTERNAME = $randomName
			WriteLog
			Rename-Computer -NewName $env:COMPUTERNAME -Restart
		}
	}
	else{
		exit(0)
	}
}