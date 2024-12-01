param(
	$inputPath
)

$fullData = Get-Content $inputPath

$ListA = New-Object System.Collections.Generic.List[int]
$ListB = New-Object System.Collections.Generic.List[int]

$fullData | ForEach-Object {
	$_ -match "(\d+)\s+(\d+)" | Out-Null
	$ListA.Add($Matches[1])
	$ListB.Add($Matches[2])
}

$sortedListA = $ListA | Sort-Object
$sortedListB = $ListB | Sort-Object

$score = 0

for ($i = 0; $i -lt $sortedListA.count; $i++) {
	$multiplier = ($sortedListB | Where-Object {
		$_ -eq $sortedListA[$i]
	}).count
	$score += ($sortedListA[$i] * $multiplier)
}

$score
