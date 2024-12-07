function SolveProblem6 {
	[CmdletBinding()]
	param($inputPath)

	$inputContent = Get-Content -Path $inputPath

	$instructions = foreach ($line in $inputContent) {
		($line | Select-String -Pattern "mul\(\d+,\d+\)|do\(\)|don't\(\)" -AllMatches).Matches.Value
	}

	$sum = 0
	$enabled = $true

	foreach ($entry in $instructions) {
		if ($entry -match "do\(\)") {
			$enabled = $true
		} elseif ($entry -match "don't\(\)") {
			$enabled = $false
		} elseif ($enabled) {
			$entry -match "(\d+),(\d+)" | Out-Null
			$sum += ([Int]::Parse($Matches[1]) * [Int]::Parse($Matches[2]))
		}
	}

	return $sum
}
