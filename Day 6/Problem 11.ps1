class Guard {
	[int[]]$CurrentSpot
	[ValidateSet(
		"Up",
		"Down",
		"Left",
		"Right"
	)]
	[string]$Direction

	Guard([int[]]$coordinate,[string]$startingDirection) {
		$this.CurrentSpot = $coordinate
		$this.Direction = $startingDirection
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

	static [hashtable] GetMapSymbolTable() {
		return @{
			Up = '^'
			Down = 'v'
			Left = '<'
			Right = '>'
		}
	}

	[char] GetMapSymbol() {
		return [Guard]::GetMapSymbolTable.($this.Direction)
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
			foreach ($symbol in [Guard]::GetMapSymbolTable().GetEnumerator()) {
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

	[void] MoveGuard() {
		$currentSpot = $this.GetGuardPosition()
		$this.Map[$currentSpot[0]][$currentSpot[1]] = "X"
		if ($this.IsLeavingLab($this.Guard.GetNextCoordinate())) {
			throw "Guard is leaving lab!"
		}
		if ($this.IsObstructed($this.Guard.GetNextCoordinate())) {
			$this.Guard.TurnRight()
		}
		$this.Guard.MoveForward()
		$nextCoord = $this.GetGuardPosition()
		$this.Map[$nextCoord[0]][$nextCoord[1]] = $this.Guard.GetMapSymbol()
	}

	[void] GetMapReadout() {
		foreach ($line in $this.Map) {
			Write-Information ($line -join "") -InformationAction Continue
		}
	}
}

function SolveProblem11 {
	param(
		[Parameter(Mandatory)]
		$InputPath
	)

	$inputData = Get-Content -Path $InputPath

	$Lab = [Lab]::New($inputData)

	while ($true) {
		try {
			$Lab.MoveGuard()
		} catch {
			break
		}
	}

	$sum = 0
	foreach ($line in $Lab.Map) {
		$sum += ($line | Where-Object {$_ -eq 'X'}).count
	}

	return $sum
}
