function SolveProblem5 {
	[CmdletBinding()]
	param($inputPath)

	$inputContent = Get-Content -Path $inputPath

	$instructions = foreach ($line in $inputContent) {
		($line | Select-String -Pattern "mul\(\d+,\d+\)" -AllMatches).Matches.Value
	}

	$sum = 0

	foreach ($entry in $instructions) {
		$entry -match "(\d+),(\d+)" | Out-Null
		$sum += ([Int]::Parse($Matches[1]) * [Int]::Parse($Matches[2]))
	}

	return $sum
}
