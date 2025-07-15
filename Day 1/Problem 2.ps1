using namespace System.Collections.Generic
param(
	$inputPath
)

$fullData = Get-Content $inputPath

$ListA = New-Object List[int]
$ListB = New-Object List[int]

$fullData | ForEach-Object {
	$_ -match "(\d+)\s+(\d+)" | Out-Null
	$ListA.Add($Matches[1])
	$ListB.Add($Matches[2])
}

$ListACounts = @{}
$ListA | Group-Object | ForEach-Object {
	$ListACounts[$_.Name] = $_.Count
}

$ListBCounts = @{}
$ListB | Group-Object | ForEach-Object {
	$ListBCounts[$_.Name] = $_.Count
}

$compareParams = @{
	ReferenceObject = [array]$ListACounts.Keys
	DifferenceObject = [array]$ListBCounts.Keys
	ExcludeDifferent = $true
}

$listComparison = Compare-Object @compareParams

$score = ($ListACounts.GetEnumerator() | Where-Object {
		$listComparison.InputObject -contains $_.Key
	} | ForEach-Object {
		[int]$_.Key * [int]$ListBCounts.($_.Key) * [int]$_.Value
	} | Measure-Object -Sum).Sum

return $score
