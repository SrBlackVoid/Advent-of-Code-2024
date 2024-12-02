function CheckLevelChange {
	[CmdletBinding()]
	param(
		$PriorLevel,
		$NextLevel
	)

	$change = [Math]::Abs($NextLevel - $PriorLevel)
	$changeType = if ($NextLevel -eq $PriorLevel) {
			"None"
		} elseif ($NextLevel -gt $PriorLevel) {
			"Increase"
		} else { "Decrease" }

	Write-Debug "$PriorLevel -> $NextLevel = $change"
	Write-Debug "Change Type: $changeType"

	return [PSCustomObject]@{
		Change = $change
		ChangeType = $changeType 	
	}
}

function CheckReport {
	[CmdletBinding()]
	[OutputType([Boolean])]
	param(
		$Report
	)

	[int[]]$reportLevels = $Report -split " "
	$changeType = $null

	for ($i = 0; $i -lt ($reportLevels.count - 1); $i++) {
		$currentCheck = CheckLevelChange $reportLevels[$i] $reportLevels[$i+1]
		if ($currentCheck.ChangeType -eq "None") {
			Write-Verbose "Marking as unsafe: No change detected"
			return $false
		}
		if ($currentCheck.Change -gt 3) {
			Write-Verbose "Marking as unsafe: Large change detected"
			return $false
		}
		if (!$changeType) {
			$changeType = $currentCheck.ChangeType
		} elseif ($changeType -ne $currentCheck.ChangeType) {
			Write-Verbose "Marking as unsafe: change type detected"
			return $false
		}
	}

	return $true
}

function SolveProblem3 {
	[CmdletBinding()]
	param($inputPath)

	$inputData = Get-Content -Path $inputPath

	$safeReportCount = 0

	foreach ($report in $inputData) {
		if (CheckReport $report) {
			$safeReportCount++
		}
	}

	return $safeReportCount
}
