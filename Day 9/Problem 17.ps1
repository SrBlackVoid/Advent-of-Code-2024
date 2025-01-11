function SolveProblem17 {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		$InputPath
	)

	begin {
		$inputData = Get-Content -Path $InputPath
		$origDiskmap = $inputData.ToCharArray() | ForEach-Object {[int]::Parse($_)}
		$lastFileID = ($inputData.Length - 1) / 2
	}

	process {
		$endIndex = $inputData.Length - 1
		$shiftQueue = New-Object -TypeName System.Collections.Generic.Queue[int]
		for ($currentIndex = $endIndex; $currentIndex -ge 0; $currentIndex -= 2) {
			$shiftQueue.EnQueue($origDiskmap[$currentIndex])
			$currentFileID--
		}
		$currentfileID = 0
		$blockMap = New-Object -TypeName System.Collections.ArrayList
		for ($i = 0; $i -lt $origDiskmap.Length; $i++) {
			$value = $origDiskmap[$i]
			if ($value -gt 0) {
				1..$value | ForEach-Object {
					if (($i % 2) -eq 0) {
						$blockMap.Add($currentFileID) | Out-Null
					} else {
						$blockMap.Add('.') | Out-Null
					}
				}
			}
			if (($i % 2) -eq 0) {
				$currentfileID++
			}
		}

		$spacesToFill = $shiftQueue.Dequeue()
		while (($blockMap -join "") -notmatch "^\d+\.*$") {
			if ($spacesToFill -eq 0) {
				$spacesToFill = $shiftQueue.Dequeue()
				$lastFileID--
			}
			$blockMap[$blockMap.IndexOf('.')] = $lastFileID
			$blockMap[$blockMap.LastIndexOf($lastFileID)] = '.'
			$spacesToFill--
		}

		$checksum = 0
		for ($i = 0; $i -lt $blockMap.Count; $i++) {
			if ($blockMap[$i] -eq '.') {
				break
			}

			$checksum += ($blockMap[$i] * $i)
		}

	}

	end {
		return $checksum
	}
}
