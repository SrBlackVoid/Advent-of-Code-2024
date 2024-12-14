function CheckUpdate {
	[CmdletBinding()]
	[OutputType([boolean])]
	param(
		[Parameter(Mandatory)]
		$UpdateData
	)

	foreach ($page in ($UpdateData | Select-Object -SkipLast 1)) {
		$followingPages = $UpdateData[($UpdateData.IndexOf($page)+1)..($UpdateData.Length - 1)]
		$relevantRules = $orderingRules | Where-Object {
			$_[1] -eq $page
		}
		if ($relevantRules | Where-Object {
			$followingPages -contains $_[0]
		}) {
			return $false
		}
	}

	return $true
}

function SolveProblem9 {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		$InputPath
	)

	$inputData = Get-Content -Path $InputPath
	$orderingRules = New-Object -TypeName System.Collections.Generic.List[int[]]
	$updateList = New-Object -TypeName System.Collections.Generic.List[int[]]

	$goodUpdateList = New-Object -TypeName System.Collections.Generic.List[int[]]

	foreach ($line in $inputData) {
		if ($line -match "(\d+)\|(\d+)") {
			$orderingRules.Add(@($Matches[1],$Matches[2]))
		}elseif ($line -match "(\d+,){1,}\d+") {
			$updateList.Add($line -split ",")
		}
	}

	foreach ($update in $updateList) {
		if (CheckUpdate $update) {
			$goodUpdateList.Add($update)
		}
	}

	$middleNumSum = 0

	foreach ($update in $goodUpdateList) {
		$middleNum = $update[[Math]::Floor($update.Length / 2)]
		$middleNumSum += $middleNum
	}

	return $middleNumSum
}
