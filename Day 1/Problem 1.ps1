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

$distance = 0

for ($i = 0; $i -lt $ListA.count; $i++) {
	$distance += [Math]::Abs($sortedListA[$i] - $sortedListB[$i])
}

return $distance
