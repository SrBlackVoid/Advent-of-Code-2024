function SolveProblem18 {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		$InputPath,

		$logPath
	)

	begin {
		if ($logPath) {
			Start-Transcript -Path $logPath
		}
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

		$checksum = 0
		$freespaceMap = $inputData.ToCharArray() | ForEach-Object {[int]::Parse($_)}
		for ($k = 0; $k -lt $freespaceMap.Length; $k += 2) {
			$freespaceMap[$k] = 'X'
		}

		for ($fileId = $lastFileID; $fileId -gt 0; $fileId--) {
			Write-Verbose "Processing fileID $fileId"
			$fileSize = $shiftQueue.Dequeue()
			Write-Debug "File size: $fileSize"
			$origFileIndex = $fileId * 2

			Write-Verbose "Looking for available free space"
			$spaceIndex = ($freespaceMap -join "" |
				Select-String -Pattern "[$fileSize-9]" |
				Select-Object -ExpandProperty Matches -First 1).Index
			if ($null -ne $spaceIndex -and $spaceIndex -lt $origFileIndex) {
				Write-Verbose "Getting exact location of free space index"
				$origFreeSpace = $origDiskmap[$spaceIndex]
				Write-Debug "Original free space: $origFreeSpace"
				$origBlockIndex = ($origDiskmap[0..($spaceIndex -1)] |
					Measure-Object -Sum).Sum

				$newBlockIndex = $origBlockIndex
				$blockSegment = $blockMap[$origBlockIndex..($origBlockIndex + $origFreeSpace - 1)]
				Write-Debug "Original block segment: $($blockSegment -join '')"
				$newBlockIndex += (($blockSegment | ForEach-Object {
						if ($_ -is [int]) {0} else {$_}
					}) -join "" |
					Select-String -Pattern "\.{$fileSize}" |
					Select-Object -ExpandProperty Matches -First 1
				).Index
				Write-Debug "Block index for move: $newBlockIndex"

				Write-Verbose "Moving file $fileId"
				1..$fileSize | ForEach-Object {
					$blockMap[$newBlockIndex + $_ - 1] = $fileId
					$blockMap[$blockMap.LastIndexOf($fileId)] = '.'
				}

				Write-Verbose "Updating freespace map"
				$newBlockSegment = $blockMap[$origBlockIndex ..($origBlockIndex + $origFreeSpace - 1)] -join ""
				Write-Debug "new block segment: $newBlockSegment"
				if ($newBlockSegment -match "\d*(\.+)\d*") {
					$freespaceMap[$spaceIndex] = $Matches[1].Length
					Write-Debug "Setting Freespace value to $($Matches[1].Length)"
				} else {
					Write-Debug "Freespace all taken up"
					$freespaceMap[$spaceIndex] = 0
				}
			}

			Write-Verbose "Updating checksum"
			$fileIndex = $blockMap.IndexOf($fileId)
			1..$fileSize | ForEach-Object {
				$checksum += ($fileId * $fileIndex)
				$fileIndex++
			}
		}

		return $checksum
	}

	end {
		if ($logPath) {
			Stop-Transcript
		}
	}
}
