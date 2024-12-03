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
		$Report,
		[switch]$DampenerCheck
	)

	$reportLevels = New-Object -TypeName System.Collections.Generic.List[int]

	$Report -split " " | ForEach-Object {
		$reportLevels.Add($_)
	}

	$changeType = $null
	$problem = $false

	for ($i = 0; $i -lt ($reportLevels.count - 1) -and !$problemIndex; $i++) {
		Write-Debug "Testing changes between $($reportLevels[$i]) and $($reportLevels[$i+1])"
		$currentCheck = CheckLevelChange $reportLevels[$i] $reportLevels[$i+1]
		if ($currentCheck.ChangeType -eq "None") {
			$problem = $true
			break
		}
		if ($currentCheck.Change -gt 3) {
			break
		}
		if (!$changeType) {
			$changeType = $currentCheck.ChangeType
		} elseif ($changeType -ne $currentCheck.ChangeType) {
			$problem = $true
			break
		}
	}

	if ($problem) {
		if ($DampenerCheck) {
			return $false
		}

		Write-Debug "Brute-forcing Problem Dampener Checks"
		for ($i = 0; $i -lt $reportLevels.count; $i++) {
			$newReport = New-Object -TypeName System.Collections.Generic.List[int]

			$Report -split " " | ForEach-Object {
				$newReport.Add($_)
			}

			$newReport.RemoveAt($i)
			if (CheckReport $newReport -DampenerCheck) {
				return $true
			}
		}

		return $false
	}

	return $true
}

function SolveProblem4 {
	[OutputType([int])]
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
