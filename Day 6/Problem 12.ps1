class Guard {
	[int[]]$CurrentSpot
	[ValidateSet(
		"Up",
		"Down",
		"Left",
		"Right"
	)]
	[string]$Direction
	[System.Collections.Generic.HashSet[string]]$MoveList

	Guard([int[]]$coordinate,[string]$startingDirection) {
		$this.CurrentSpot = $coordinate
		$this.Direction = $startingDirection
		$this.MoveList = New-Object -TypeName System.Collections.Generic.HashSet[string]
	}

	[bool] UpdateMoveList() {
		return ($this.MoveList.Add("$($this.CurrentSpot[0])-$($this.CurrentSpot[1])-$($this.Direction)"))
	}

	[int[]] GetNextCoordinate() {
		$nextStepCoord = switch ($this.Direction) {
			"Up" { @(($this.CurrentSpot[0] - 1), $this.CurrentSpot[1]) }
			"Down" { @(($this.CurrentSpot[0] + 1), $this.CurrentSpot[1]) }
			"Left" { @($this.CurrentSpot[0], ($this.CurrentSpot[1] - 1)) }
			"Right" { @($this.CurrentSpot[0], ($this.CurrentSpot[1] + 1)) }
		}

		return $nextStepCoord
	}

	[void] MoveForward() {
		$this.CurrentSpot = $this.GetNextCoordinate()
	}

	static [hashtable] $MapSymbolTable = @{
		Up = '^'
		Down = 'v'
		Left = '<'
		Right = '>'
	}

	static [char] GetMapSymbol($Direction) {
		return [Guard]::MapSymbolTable.($Direction)
	}

	[void] TurnRight() {
		$this.Direction = switch ($this.Direction) {
			"Up" { "Right" }
			"Right" { "Down" }
			"Down" { "Left" }
			"Left" { "Up" }
		}
	}
}

class Lab {
	[char[][]]$Map
	[Guard]$Guard

	static [char[][]] GenerateFormattedMap($InputData) {
		$formattedMap = @()
		foreach ($line in $InputData) {
			$formattedMap += ,($line.ToCharArray())
		}

		return $formattedMap
	}

	Lab([char[][]]$StartingMap) {
		$this.Map = $StartingMap
		:GuardSearch for ($i = 0; $i -lt $this.Map.Length; $i++) {
			foreach ($symbol in [Guard]::MapSymbolTable.GetEnumerator()) {
				$index = ($this.Map[$i] -join "").IndexOf($symbol.Value)
				if ($index -ne -1) {
					$this.Guard = [Guard]::New(@($i,$index),$symbol.Key)
					break :GuardSearch
				}
			}
		}
	}

	[int[]] GetGuardPosition() {
		return $this.Guard.CurrentSpot
	}

	[bool] IsLeavingLab([int[]]$Coordinate) {
		return (
			$Coordinate[0] -lt 0 -or
			$Coordinate[1] -lt 0 -or
			$Coordinate[0] -ge $this.Map.Length -or
			$Coordinate[1] -ge $this.Map[0].Length
		)
	}

	[bool] IsObstructed([int[]]$Coordinate) {
		return ($this.Map[$Coordinate[0]][$Coordinate[1]] -eq '#')
	}

	[string]$RouteOutcome

	[void] MoveGuard() {
		$currentSpot = $this.GetGuardPosition()
		$this.Map[$currentSpot[0]][$currentSpot[1]] = "X"
		if ($this.IsLeavingLab($this.Guard.GetNextCoordinate())) {
			$this.RouteOutcome = "Guard Left Lab"
			return
		}

		while ($this.IsObstructed($this.Guard.GetNextCoordinate())) {
			$this.Guard.TurnRight()
		}

		$this.Guard.MoveForward()
		if (-NOT ($this.Guard.UpdateMoveList())) {
			$this.RouteOutcome = "Infinite Loop"
			return
		}
		$newSpot = $this.GetGuardPosition()
		$this.Map[$newSpot[0]][$newSpot[1]] = [Guard]::GetMapSymbol($this.Guard.Direction)
	}

	[void] GetMapReadout() {
		foreach ($line in $this.Map) {
			Write-Information ($line -join "") -InformationAction Continue
		}
	}
}

function SolveProblem12 {
	param(
		[Parameter(Mandatory)]
		$InputPath
	)

	$inputData = Get-Content -Path $InputPath
	$startMap = [Lab]::GenerateFormattedMap($inputData.Clone())

	$Lab = [Lab]::New($startMap)
	$startPos = $Lab.GetGuardPosition()
	$obstacleList = New-Object -TypeName System.Collections.Generic.HashSet[string]

	while (!$Lab.RouteOutcome) {
		$Lab.MoveGuard()
		$obstacleList.Add($Lab.GetGuardPosition()) | Out-Null
	}
	$obstacleList.Remove($startPos) | Out-Null

	$sum = 0

	foreach ($entry in $obstacleList.GetEnumerator()) {
		Write-Verbose "Testing obstacle at $entry"
		$obstacleCoord = $entry -split " "
		$testLabMap = [Lab]::GenerateFormattedMap($inputData.Clone())
		$testLabMap[$obstacleCoord[0]][$obstacleCoord[1]] = '#'
		$testLab = [Lab]::New($testLabMap)
		while (!$testLab.RouteOutcome) {
			$testLab.MoveGuard()
		}
		Write-Debug "Guard position: $($testLab.GetGuardPosition())"
		if ($testLab.RouteOutcome -eq "Infinite Loop") {
			$sum++
		}
	}

	return $sum
}
