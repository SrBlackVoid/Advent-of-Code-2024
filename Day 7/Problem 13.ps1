function GetAllOperatorCombos {
	[CmdletBinding()]
	param (
	    [int]$Length
	)

	$script:results = @()

	function GenerateSequence {
		param(
			[string]$CurrentString,
			[int]$Remaining
		)

		if ($Remaining -eq 0) {
			$script:results += $CurrentString
			return
		}

		GenerateSequence -CurrentString ($CurrentString + "+") -Remaining ($Remaining - 1)
		GenerateSequence -CurrentString ($CurrentString + "*") -Remaining ($Remaining - 1)
	}

	GenerateSequence -CurrentString "" -Remaining $Length

	return $script:results
}

function TestEquation {
	[CmdletBinding()]
	[OutputType([boolean])]
	param(
		[Parameter(Mandatory)]
		$Equation
	)

	$Equation -match "^(\d+):" | Out-Null
	$testValue = $Matches[1]
	$operands = ($Equation -split ": ")[1] -split " "
	$operatorCount = (($Equation -split ": ")[1].ToCharArray() |
		Where-Object {$_ -eq " "}).count

	$allCombinations = GetAllOperatorCombos -Length $operatorCount
	[array]::Reverse($allCombinations)

	:MainLoop foreach ($sequence in $allCombinations) {
		$currentTotal = $operands[0]
		for ($i = 0; $i -lt $operatorCount; $i++) {
			$currentBlock = "$currentTotal $($sequence[$i]) $($operands[$i+1])"
			$scriptBlock = [ScriptBlock]::Create($currentBlock)
			$currentTotal = & $scriptBlock
			if ($currentTotal -gt $testValue) {
				continue :MainLoop
			}
		}
		if ($currentTotal -eq $testValue) {
			return $true
		}
	}

	return $false
}

function SolveProblem13 {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		$InputPath
	)
	
	$inputData = Get-Content -Path $InputPath

	$sum = 0

	#PERF: Horribly slow, completion time ~35 mins. Probably would utilize
	# parallel processing w/ ConcurrentBag
	foreach ($line in $inputData) {
		Write-Verbose "Checking #$($inputData.IndexOf($line)): $line"
		if (TestEquation $line) {
			$line -match "^(\d+):" | Out-Null
			$sum += $Matches[1]
			Write-Information "Adding $($Matches[1]). New Sum: $sum" -InformationAction Continue
		}
	}

	return $sum
}
