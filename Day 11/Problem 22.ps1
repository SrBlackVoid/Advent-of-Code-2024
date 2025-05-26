#Requires -Version 7.0
function SolveProblem22 {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path $_})]
        [string]$InputFilePath,

        [int]$NumOfBlinks = 1
    )

    $inputData = Get-Content -Path $InputFilePath
    # Use a hashtable to track count of each stone type
    $stoneCounts = @{}
    foreach($stone in ($inputData -split ' ')) {
        $stoneCounts[$stone] = ($stoneCounts[$stone] ?? 0) + 1
    }

    $progressParams = @{
        Activity = "Processing stone blinks"
        Status = "Processing..."
        PercentComplete = 0
    }

    for ($blink = 1; $blink -le $NumOfBlinks; $blink++) {
        $progressParams.PercentComplete = ($blink / $NumOfBlinks) * 100
        $progressParams.Status = "Processing blink $blink of $NumOfBlinks"
        Write-Progress @progressParams

        $newStoneCounts = @{}
        foreach ($stone in $stoneCounts.Keys) {
            $count = $stoneCounts[$stone]
            $newStones = StoneChange -Stone $stone
            foreach ($newStone in $newStones) {
                $newStoneCounts[$newStone] = ($newStoneCounts[$newStone] ?? 0) + $count
            }
        }
        $stoneCounts = $newStoneCounts
        Write-Debug "Distinct stones: $($stoneCounts.Keys.Count), Total stones: $($stoneCounts.Values | Measure-Object -Sum | Select-Object -ExpandProperty Sum)"
    }

    Write-Progress -Activity "Processing stone blinks" -Completed
    ($stoneCounts.Values | Measure-Object -Sum).Sum
}

function StoneChange {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Stone
    )

    if ($Stone -eq "0") {
        return @("1")
    }

    if ($Stone.Length % 2 -eq 0) {
        $halfLength = $Stone.Length / 2
        return @(
            [string]([long]$Stone.Substring(0, $halfLength)),
            [string]([long]$Stone.Substring($halfLength, $halfLength))
        )
    }

    return @([string]([long]$Stone * 2024))
}
