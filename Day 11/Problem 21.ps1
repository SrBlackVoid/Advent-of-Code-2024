function SolveProblem21 {
	[CmdletBinding()]
	[OutputType([int])]
	param(
		[Parameter(Mandatory = $true)]
		[ValidateScript({Test-Path $_})]
		[string]$InputFilePath,

		[int]$NumOfBlinks = 1
	)

	$inputData = Get-Content -Path $InputFilePath

	$stones = $inputData.ToString() -split ' '

    $progressParams = @{
        Activity = "Processing stone blinks"
        Status = "Processing..."
        PercentComplete = 0
    }
	1..$NumOfBlinks | ForEach-Object {
        $progressParams.PercentComplete = ($_ / $NumOfBlinks) * 100
        $progressParams.Status = "Processing blink $_ of $NumOfBlinks"
        Write-Progress @progressParams

        $newStones = [System.Collections.ArrayList]::new()
        foreach ($stone in $stones) {
            $newStones.AddRange(@(StoneChange -Stone $stone))
        }
        $stones = $newStones.ToArray()
        Write-Debug "New stones: $stones"
	}
    Write-Progress -Activity "Processing stone blinks" -Completed

	$stones.Count
}

function StoneChange {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[string]$Stone
	)

	if ($Stone -eq "0") {
		return "1"
	}

    if ($Stone.Length % 2 -eq 0) {
		return @(
			[int]($Stone.Substring(0, $Stone.Length / 2)).ToString(),
			[int]($Stone.Substring($Stone.Length / 2, $Stone.Length / 2)).ToString()
		)
    }

	return ([int]$Stone * 2024)
}
