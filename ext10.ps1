param($logfile = "0",  $identity_name = "0",  $ad_server = "0", $Ext10Position = "0", $newExt10ValueByPosition = "0")
$timestamp = Get-Date -Format o
$opScriptName = $MyInvocation.MyCommand.Name
Write-Output "[$timestamp] Started $opScriptName"

$match_status = "No changes made"

try
	{
		try
			{
			
				$currentExt10Value = (Get-ADUser -Identity "$identity_name" -properties extensionAttribute10 -server $ad_server).extensionAttribute10
				Write-Output "currentExt10Value:$currentExt10Value" ;
			}
		catch
			{
			};
		if ( -not ([string]::IsNullOrEmpty($currentExt10Value)))
			{
				$currentExt10ValueByPosition=$currentExt10Value.Split(";")[$Ext10Position]
				if ($currentExt10ValueByPosition -ne $newExt10ValueByPosition -and -not ([string]::IsNullOrEmpty($newExt10ValueByPosition)))
					{
						$newExt10Value = ""
						$opCounter = 1
						$Ext10PositionInt = [Int]$Ext10Position
						foreach ($opValues in $currentExt10Value.Split(";"))
							{	
								if ($Ext10PositionInt -eq $opCounter)
								{
									$newExt10Value +="$newExt10ValueByPosition;"
								}
								else
								{								
									$newExt10Value +="$opValues;"
								}
								
								$opCounter++
							}
						$match_status = "extensionAttribute10 updated"
						Write-Output "extensionAttribute10 updated Ext10Position=$Ext10Position; newExt10ValueByPosition=$newExt10ValueByPosition"
						Set-ADUser -Identity "$identity_name" -Replace @{extensionAttribute10="$newExt10Value"} -server $ad_server
		}
		else
		{$match_status = "No changes made"}
	}
catch
	{
	}
finally
	{
		Write-Output "identity_name:$identity_name" ;
		Write-Output "match_status:$match_status" ;
		Write-Output "Ext10Position:$Ext10Position" ;
		Write-Output "newExt10ValueByPosition:$newExt10ValueByPosition" ;
		$error_count=$error.Count
		$i=0
		if ($error_count -gt 0)
		{
			while ($i -lt $error_count) 
				{
					Write-Output $error[$i].CategoryInfo;
					Write-Output $error[$i].ErrorDetails;
					Write-Output $error[$i].Exception;
					Write-Output $error[$i].FullyQualifiedErrorId;
					Write-Output $error[$i].InvocationInfo;
					Write-Output $error[$i].TargetObject;
					$i++
				}
			Write-Output "errors_count:$error_count" ;
			exit $error_count
		}
	}

$timestamp = Get-Date -Format o
Write-Output "[$timestamp] Finished $opScriptName" 
