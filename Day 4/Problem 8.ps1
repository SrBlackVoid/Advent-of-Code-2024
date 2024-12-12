function GetXDiagonal {
	param(
		[Parameter(Mandatory)]
		[ref]$InputData,

		[Parameter(Mandatory)]
		$Coordinate
	)

	$dataWidth = $inputData.Value[0].Length

	Write-Verbose "Getting top-left bottom-right diagonal"
	[string]$TLeftBRightString = ""
	if ($Coordinate[0] -ne 0 -and
		$Coordinate[1] -ne 0) {
			$TLeftBRightString += $InputData.Value[($Coordinate[0] - 1)][($Coordinate[1] - 1)]
	}

	$TLeftBRightString += $InputData.Value[$Coordinate[0]][$Coordinate[1]]

	if ($Coordinate[0] -ne ($dataHeight - 1) -and
		$Coordinate[1] -ne ($dataWidth - 1)) {
		try {
			$TLeftBRightString += $InputData.Value[($Coordinate[0] + 1)][($Coordinate[1] + 1)]
		} catch {
			Wait-Debugger
		}
	}

	Write-Verbose "Getting bottom-left top-right diagonal"
	[string]$BLeftTRightString = ""
	if ($Coordinate[0] -ne ($dataHeight - 1) -and
		$Coordinate[1] -ne 0) {
			$BLeftTRightString += $InputData.Value[($Coordinate[0] + 1)][($Coordinate[1] - 1)]
	}

	$BLeftTRightString += $InputData.Value[$Coordinate[0]][$Coordinate[1]]

	if ($Coordinate[0] -ne 0 -and
		$Coordinate[1] -ne ($dataWidth - 1)) {
			$BLeftTRightString += $InputData.Value[($Coordinate[0] - 1)][($Coordinate[1] + 1)]
	}

	return @{
		TLeftDiag = $TLeftBRightString
		BLeftDiag = $BLeftTRightString
	}
}

function SolveProblem8 {
	param(
		[Parameter(Mandatory)]
		$InputPath
	)

	$inputData = Get-Content $InputPath
	$dataHeight = $inputData.Length

	$indexList = New-Object System.Collections.Generic.List[int[]]

	foreach ($i in 0..($dataHeight - 1)) {
		$index = 0
		while ($index -ne -1) {
			$index = $inputData[$i].IndexOf('A',$index)
			if ($index -ne -1) {
				$indexList.Add(@($i,$index))
				$index++
			}
		}
	}

	$sum = 0

	foreach ($entry in $indexList) {
		$diagonals = GetXDiagonal ([ref]$InputData) $entry

		if (
			($diagonals.BLeftDiag -match "MAS" -or $diagonals.BLeftDiag -match "SAM") -and
			($diagonals.TLeftDiag -match "MAS" -or $diagonals.TLeftDiag -match "SAM")
		) {
			$sum++
		}
	}

	return $sum
}
