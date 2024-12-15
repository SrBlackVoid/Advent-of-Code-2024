Describe "Guard" -Tag "Guard" {
	BeforeAll {
		. "$PSScriptRoot\Problem 11.ps1"
	}

	Context "Turning" {
		It "Starts facing right when originally facing up" {
			#Arrange
			$guard = [Guard]::New(@(1,1),"Up")

			#Act
			$guard.TurnRight()

			#Assert
			$guard.Direction | Should -Be "Right"
		}

		It "Starts facing down when originally facing right" {
			#Arrange
			$guard = [Guard]::New(@(1,1),"Right")

			#Act
			$guard.TurnRight()

			#Assert
			$guard.Direction | Should -Be "Down"
		}

		It "Starts facing left when originally facing down" {
			#Arrange
			$guard = [Guard]::New(@(1,1),"Down")

			#Act
			$guard.TurnRight()

			#Assert
			$guard.Direction | Should -Be "Left"
		}

		It "Starts facing up when originally facing left" {
			#Arrange
			$guard = [Guard]::New(@(1,1),"Left")

			#Act
			$guard.TurnRight()

			#Assert
			$guard.Direction | Should -Be "Up"
		}
	}

	Context "GetNextCoordinate" {
		It "Provides the next coordinate when facing up" {
			#Arrange
			$guard = [Guard]::New(@(1,1),"Up")

			#Act
			$results = $guard.GetNextCoordinate()

			#Assert
			$expected = @(0,1)
			$results | Should -Be $expected
		}


		It "Provides the next coordinate when facing right" {
			#Arrange
			$guard = [Guard]::New(@(1,1),"Right")

			#Act
			$results = $guard.GetNextCoordinate()

			#Assert
			$expected = @(1,2)
			$results | Should -Be $expected
		}

		It "Provides the next coordinate when facing down" {
			#Arrange
			$guard = [Guard]::New(@(1,1),"Down")

			#Act
			$results = $guard.GetNextCoordinate()

			#Assert
			$expected = @(2,1)
			$results | Should -Be $expected
		}

		It "Provides the next coordinate when facing left" {
			#Arrange
			$guard = [Guard]::New(@(1,1),"Left")

			#Act
			$results = $guard.GetNextCoordinate()

			#Assert
			$expected = @(1,0)
			$results | Should -Be $expected
		}
	}
}

Describe "Lab" -Tag "Lab" {
	BeforeAll {
		. "$PSScriptRoot\Problem 11.ps1"
		$testFile = "TestDrive:\map.txt"
	}

	Context "IsLeavingLab" {
		BeforeAll {
			$mapData = [Lab]::GenerateFormattedMap(
				(0..9 | ForEach-Object { @("." * 10) })
			)
			$lab = [Lab]::New($mapData)
		}

		It "Does not flag when in the middle of the map" {
			$lab.IsLeavingLab(@(3,4)) | Should -Be $false
		}

		It "Does not flag when on an edge of the map" {
			$lab.IsLeavingLab(@(0,2)) | Should -Be $false
		}

		It "Does flag when leaving the top side of the map" {
			$lab.IsLeavingLab(@(-1,2)) | Should -Be $true
		}

		It "Does flag when leaving the right side of the map" {
			$lab.IsLeavingLab(@(3,10)) | Should -Be $true
		}

		It "Does flag when leaving the bottom side of the map" {
			$lab.IsLeavingLab(@(3,10)) | Should -Be $true
		}

		It "Does flag when leaving the left side of the map" {
			$lab.IsLeavingLab(@(3,-1)) | Should -Be $true
		}
	}

	Context "IsObstructed" {
		BeforeAll {
			$lab = [Lab]::New("....#....")
		}

		It "Does not flag an obstruction when there isn't one" {
			$lab.IsObstructed(@(0,1)) | Should -Be $false
		}

		It "Does flag an obstruction when there is one" {
			$lab.IsObstructed(@(0,4)) | Should -Be $true
		}
	}

	Context "Initialization" {
		It "Initializes guard position with a 1-D array" {
			#Arrange
			"....^....." > $testFile
			$map = [Lab]::GenerateFormattedMap((Get-Content $testFile))

			#Act
			$lab = [Lab]::New($map)

			#Assert
			$expected = @(0,4)
			$lab.GetGuardPosition() | Should -Be $expected
		}

		It "Initializes guard position within a 2-D array" {
			#Arrange
			@"
..........
..........
.....^....
..........
"@ > $testFile
			$map = Get-Content -Path $testFile


			#Act
			$lab = [Lab]::New($map)

			#Assert
			$expected = @(2,5)
			$lab.GetGuardPosition() | Should -Be $expected
		}

		It "Initializes guard facing right" {
			"....>....." > $testFile
			$map = Get-Content $testFile

			#Act
			$lab = [Lab]::New($map)

			#Assert
			$lab.Guard.Direction | Should -Be "Right"
		}

		It "Initializes guard facing down" {
			"....v....." > $testFile
			$map = Get-Content $testFile

			#Act
			$lab = [Lab]::New($map)

			#Assert
			$lab.Guard.Direction | Should -Be "Down"
		}

		It "Initializes guard facing left" {
			"....<....." > $testFile
			$map = Get-Content $testFile

			#Act
			$lab = [Lab]::New($map)

			#Assert
			$lab.Guard.Direction | Should -Be "Left"
		}

		AfterEach {
			Remove-Item $testFile -ErrorAction SilentlyContinue
		}
	}

	Context "MoveGuard" {
		Context "Basic Moves" {
			It "Moves the guard up and marks his original spot with an X" {
				#Arrange
				@"
..........
....^.....
..........
"@ > $testFile
				$map = [Lab]::GenerateFormattedMap((Get-Content $testFile))
				$lab = [Lab]::New($map)

				#Act
				$lab.MoveGuard()

				#Assert
				$expectedNewCoord = @(0,4) 
				$lab.GetGuardPosition() | Should -Be $expectedNewCoord
				$lab.Map[1][4] | Should -Be "X"

			}

			It "Moves the guard down and marks his original spot with an X" {
				#Arrange
				@"
..........
....v.....
..........
"@ > $testFile
				$map = [Lab]::GenerateFormattedMap((Get-Content $testFile))
				$lab = [Lab]::New($map)

				#Act
				$lab.MoveGuard()

				#Assert
				$expectedNewCoord = @(2,4) 
				$lab.GetGuardPosition() | Should -Be $expectedNewCoord
				$lab.Map[1][4] | Should -Be "X"

			}

			It "Moves the guard right and marks his original spot with an X" {
				#Arrange
				@"
..........
....>.....
..........
"@ > $testFile
				$map = [Lab]::GenerateFormattedMap((Get-Content $testFile))
				$lab = [Lab]::New($map)

				#Act
				$lab.MoveGuard()

				#Assert
				$expectedNewCoord = @(1,5) 
				$lab.GetGuardPosition() | Should -Be $expectedNewCoord
				$lab.Map[1][4] | Should -Be "X"

			}

			It "Moves the guard left and marks his original spot with an X" {
				#Arrange
				@"
..........
....<.....
..........
"@ > $testFile
				$map = [Lab]::GenerateFormattedMap((Get-Content $testFile))
				$lab = [Lab]::New($map)

				#Act
				$lab.MoveGuard()

				#Assert
				$expectedNewCoord = @(1,3) 
				$lab.GetGuardPosition() | Should -Be $expectedNewCoord
				$lab.Map[1][4] | Should -Be "X"

			}
		}

		Context "Moving Around Obstacles" {
			It "Moves the guard right if there is an obstacle trying to move up" {
				#Arrange
				@"
....#.....
....^.....
..........
"@ > $testFile
				$map = [Lab]::GenerateFormattedMap((Get-Content $testFile))
				$lab = [Lab]::New($map)

				#Act
				$lab.MoveGuard()

				#Assert
				$expectedNewCoord = @(1,5) 
				$lab.GetGuardPosition() | Should -Be $expectedNewCoord
				$lab.Map[1][4] | Should -Be "X"

			}

			It "Moves the guard down if there is an obstacle trying to move right" {
				#Arrange
				@"
..........
....>#....
..........
"@ > $testFile
				$map = [Lab]::GenerateFormattedMap((Get-Content $testFile))
				$lab = [Lab]::New($map)

				#Act
				$lab.MoveGuard()

				#Assert
				$expectedNewCoord = @(2,4) 
				$lab.GetGuardPosition() | Should -Be $expectedNewCoord
				$lab.Map[1][4] | Should -Be "X"

			}

			It "Moves the guard left if there is an obstacle trying to move down" {
				#Arrange
				@"
..........
....v.....
....#.....
"@ > $testFile
				$map = [Lab]::GenerateFormattedMap((Get-Content $testFile))
				$lab = [Lab]::New($map)

				#Act
				$lab.MoveGuard()

				#Assert
				$expectedNewCoord = @(1,3) 
				$lab.GetGuardPosition() | Should -Be $expectedNewCoord
				$lab.Map[1][4] | Should -Be "X"

			}

			It "Moves the guard up if there is an obstacle trying to move right" {
				#Arrange
				@"
..........
...#<.....
..........
"@ > $testFile
				$map = [Lab]::GenerateFormattedMap((Get-Content $testFile))
				$lab = [Lab]::New($map)

				#Act
				$lab.MoveGuard()

				#Assert
				$expectedNewCoord = @(0,4) 
				$lab.GetGuardPosition() | Should -Be $expectedNewCoord
				$lab.Map[1][4] | Should -Be "X"

			}
		}

		AfterEach {
			Remove-Item $testFile
		}
	}

	Context "Leaving Lab" {
		BeforeAll {
			$testFile = "TestDrive:\map.txt"
		}

		It "Throws if the next guard move is leaving the lab" {
			#Arrange
			@"
....^.....
..........
..........
"@ > $testFile
			$map = [Lab]::GenerateFormattedMap((Get-Content $testFile))
			$lab = [Lab]::New($map)

			#Act/Assert
			{ $lab.MoveGuard() } | Should -Throw "Guard is leaving lab!"
		}

		AfterEach {
			Remove-Item $testFile
		}
	}
}
