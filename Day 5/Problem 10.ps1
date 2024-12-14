function CheckUpdate {
	[CmdletBinding()]
	[OutputType([boolean])]
	param(
		[Parameter(Mandatory)]
		$UpdateData
	)

	foreach ($page in ($UpdateData | Select-Object -SkipLast 1)) {
		$followingPages = $UpdateData[($UpdateData.IndexOf($page)+1)..($UpdateData.Count - 1)]
		$relevantRules = $orderingRules.where({
			$_[1] -eq $page
		})
		if ($relevantRules.where({
			$followingPages -contains $_[0]
		})) {
			return $false
		}
	}

	return $true
}

function FixUpdateOrder {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		$UpdateData,

		[int]$StartIndex = 0
	)
	$newUpdateOrder = New-Object -TypeName System.Collections.Generic.List[int]
	foreach ($entry in $UpdateData) {
		$newUpdateOrder.Add($entry)
	}

	$index = 0
	while ($index -lt $UpdateData.Count) {
		$currentPage = $newUpdateOrder[$index]
		$followingPages = $newUpdateOrder[($index+1)..($UpdateData.Count - 1)]

		$relevantRules = $orderingRules.where({
			$_[1] -eq $currentPage
		})
		$brokenRules = $relevantRules.where({
			$followingPages -contains $_[0]
		})

		if ($brokenRules) {
			#Using lift and shift approach
			$newUpdateOrder.Remove($currentPage)
			$brokenRuleIndexes = @(foreach ($rule in $brokenRules) {
				$newUpdateOrder.IndexOf($rule[0])
			})
			$shiftPoint = $brokenRuleIndexes | 
				Sort-Object -Descending |
				Select-Object -First 1
			$shiftedEntries = $newUpdateOrder[($shiftPoint+1)..($UpdateData.Count - 1)]

			foreach ($entry in $shiftedEntries) {
				$newUpdateOrder.Remove($entry)
			}
			$newUpdateOrder.Add($currentPage)
			foreach ($page in $shiftedEntries) {
				$newUpdateOrder.Add($page)
			}
			
			$newUpdateOrder = FixUpdateOrder $newUpdateOrder -StartIndex ($index+1)
			break
		} else {
			$index++
		}

	}

	return $newUpdateOrder
}

function SolveProblem10 {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		$InputPath
	)

	$inputData = Get-Content -Path $InputPath
	$orderingRules = New-Object -TypeName System.Collections.ArrayList
	$updateList = New-Object -TypeName System.Collections.ArrayList
	$badUpdateList = New-Object -TypeName System.Collections.ArrayList

	foreach ($line in $inputData) {
		if ($line -match "(\d+)\|(\d+)") {
			$orderingRules.Add(@($Matches[1],$Matches[2])) > $null
		}elseif ($line -match "(\d+,){1,}\d+") {
			$updateList.Add($line -split ",") > $null
		}
	}

	foreach ($update in $updateList) {
		if (-NOT (CheckUpdate $update)) {
			$badUpdateList.Add($update) > $null
		}
	}

	$middleNumSum = 0

	foreach ($update in $badUpdateList) {
		$fixedUpdate = FixUpdateOrder $update | Where-Object { $_ -is [int]}
		$middleNum = $fixedUpdate[[Math]::Floor($fixedUpdate.Length / 2)]
		$middleNumSum += $middleNum
	}

	return $middleNumSum
}
