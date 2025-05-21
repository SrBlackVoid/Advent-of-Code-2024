function SolveProblem20 {
	[CmdletBinding()]
	[OutputType([int])]
	param(
		[Parameter(Mandatory)]
		[ValidateScript({Test-Path $_})]
		$inputFilePath
	)

	$inputData = Get-Content -Path $inputFilePath

	$trailStarts = New-Object -TypeName System.Collections.Generic.List[int[]]

	for ($i = 0; $i -lt $inputData.Length; $i++) {
		$startSpots = (Select-String -InputObject $inputData[$i] -Pattern "0" -AllMatches).Matches
		foreach ($spot in $startSpots) {
			$trailStarts.Add(@($i,$spot.Index))
		}
	}

	$map = [ref]$inputData

	$totalRating = ($trailStarts | ForEach-Object {
		WalkTheTrail -Coord $_ -Map $map
	} | Measure-Object -Sum).Sum


	return $totalRating
}

function WalkTheTrail {
	[OutputType([int])]
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[int[]]$Coord,
		[Parameter(Mandatory)]
		[ref]$Map
	)

    $currentValue = [int]::Parse("$($Map.Value[$Coord[0]][$Coord[1]])")
    Write-Debug "current value: $currentValue"
    if ($currentValue -eq 9) {
        Write-Debug "Found end of trail (value 9) at [$($Coord[0]),$($Coord[1])]"
		return 1
    }

	$directions = @(
        @(0, -1, "left"),
        @(0, 1, "right"),
        @(-1, 0, "up"),
        @(1, 0, "down")
    )

    foreach ($dir in $directions) {
        $row = $Coord[0] + $dir[0]
        $col = $Coord[1] + $dir[1]

        Write-Verbose "Attempting to walk $($dir[2]) from [$($Coord[0]),$($Coord[1])]"

        # Check bounds
        if ($row -ge 0 -and $row -lt $Map.Value.Length -and
            $col -ge 0 -and $col -lt $Map.Value[$row].Length) {

            $nextCoord = @($row, $col)
            $nextValue = [int]::Parse("$($Map.Value[$nextCoord[0]][$nextCoord[1]])")
            Write-Debug "$($dir[2]) square at [$($nextCoord[0]),$($nextCoord[1])] has value $nextValue"

            if ($nextValue -eq ($currentValue + 1)) {
                Write-Debug "Valid $($dir[2]) move found"
                WalkTheTrail -Coord $nextCoord -Map $Map
            }
        }
    }

}
