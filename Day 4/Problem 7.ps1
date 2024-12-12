function SolveProblem7 {
	[CmdletBinding()]
	param(
		$InputPath
	)

	$inputData = Get-Content -Path $InputPath
	Write-Verbose "Getting initial measurements"
	$dataHeight = $inputData.Length
	$dataWidth = $inputData[0].Length

	$sum = 0

	Write-Verbose "Getting all horizontal matches"
	
	Write-Verbose "Checking forward matches"
	$horizontalMatches = $inputData |
		Select-String -Pattern "XMAS" -AllMatches
	$sum += $horizontalMatches.Matches.Count

	Write-Verbose "Checking backwards matches"
	$horizontalMatches = $inputData |
		Select-String -Pattern "SAMX" -AllMatches
	$sum += $horizontalMatches.Matches.Count

	Write-Verbose "Extracting vertical matches" 
	foreach ($i in 0..($dataWidth - 1)) {
		[string]$vertString = ""
		$currentCoord = @(0,$i)
		while ($currentCoord[0] -lt $dataHeight) {
			$vertString += $inputData[$currentCoord[0]][$currentCoord[1]]
			$currentCoord[0]++
		}

		$vertMatches = $vertString |
			Select-String -Pattern "XMAS" -AllMatches
		$sum += $vertMatches.Matches.Count
		$vertMatches = $vertString |
			Select-String -Pattern "SAMX" -AllMatches
		$sum += $vertMatches.Matches.Count
	}

	Write-Verbose "Extracting diagonal matches"

	Write-Verbose "Getting forward diagonals"
	foreach ($i in 0..($dataHeight-1)) {
		[string]$diagString = ""
		$currentCoord = @($i,0)
		while ($currentCoord[0] -gt -1) {
			$diagString += $inputData[$currentCoord[0]][$currentCoord[1]]
			$currentCoord[0]--
			$currentCoord[1]++
		}

		$diagMatches = $diagString |
		Select-String -Pattern "XMAS" -AllMatches
		$sum += $diagMatches.Matches.Count

		$diagMatches = $diagString |
		Select-String -Pattern "SAMX" -AllMatches
		$sum += $diagMatches.Matches.Count
	}

	foreach ($i in 1..($dataWidth-1)) {
		[string]$diagString = ""
		$currentCoord = @(($dataHeight - 1),$i)
		while ($currentCoord[1] -lt $dataWidth) {
			$diagString += $inputData[$currentCoord[0]][$currentCoord[1]]
			$currentCoord[0]--
			$currentCoord[1]++
		}

		$diagMatches = $diagString |
		Select-String -Pattern "XMAS" -AllMatches
		$sum += $diagMatches.Matches.Count

		$diagMatches = $diagString |
		Select-String -Pattern "SAMX" -AllMatches
		$sum += $diagMatches.Matches.Count
	}

	Write-Verbose "Getting backwards diagonals"
	foreach ($i in 0..($dataHeight-1)) {
		[string]$diagString = ""
		$currentCoord = @($i,($dataWidth - 1))
		while ($currentCoord[0] -gt -1) {
			$diagString += $inputData[$currentCoord[0]][$currentCoord[1]]
			$currentCoord[0]--
			$currentCoord[1]--
		}

		$diagMatches = $diagString |
		Select-String -Pattern "XMAS" -AllMatches
		$sum += $diagMatches.Matches.Count

		$diagMatches = $diagString |
		Select-String -Pattern "SAMX" -AllMatches
		$sum += $diagMatches.Matches.Count
	}

	foreach ($i in ($dataWidth-2)..0) {
		[string]$diagString = ""
		$currentCoord = @(($dataHeight - 1),$i)
		while ($currentCoord[1] -gt -1) {
			$diagString += $inputData[$currentCoord[0]][$currentCoord[1]]
			$currentCoord[0]--
			$currentCoord[1]--
		}

		$diagMatches = $diagString |
		Select-String -Pattern "XMAS" -AllMatches
		$sum += $diagMatches.Matches.Count

		$diagMatches = $diagString |
		Select-String -Pattern "SAMX" -AllMatches
		$sum += $diagMatches.Matches.Count
	}

	return $sum
}
