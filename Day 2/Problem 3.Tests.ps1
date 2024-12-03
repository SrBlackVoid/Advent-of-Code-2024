Describe "CheckLevelChange" -Tag "Functions","Problem3" {
	BeforeAll {
		. ".\Problem 3.ps1"
	}

	Context "Change values" {
		It "Sets the correct change value" {
			. ".\Problem 3.ps1"
			$results = CheckLevelChange 2 5
			$results.Change | Should -Be 3
		}

		It "Always takes absolute value of change" {
			$results = CheckLevelChange 5 2
			$results.Change | Should -Be 3
		}
	}

	Context "Change Types" {
		It "Should correctly identify increasing changes" {
			$results = CheckLevelChange 1 3
			$results.ChangeType | Should -Be "Increase"
		}

		It "Should correctly identify decreasing changes" {
			$results = CheckLevelChange 3 1
			$results.ChangeType | Should -Be "Decrease"
		}

		It "Should correctly identify no change" {
			$results = CheckLevelChange 3 3
			$results.ChangeType | Should -Be "None"
		}
	}
}

Describe "CheckReport" -Tag "Functions","Problem3" {
	BeforeAll {
		. ".\Problem 3.ps1"
	}

	Context "General Operation" {
		It "Is processing all the levels in the report" {
			Mock CheckLevelChange {return [PSCustomObject]@{
				Change = 1
				ChangeType = "Increase"
			}}

			$testData = "1 2 3 4 5 6"
			$results = CheckReport $testData
			Should -Invoke -CommandName CheckLevelChange -Times 5
		}
	}

	Context "Safe Reports" {
		It "Should mark a report as safe with increasing changes" {
			$inputData = "2 4 5 7 9"
			$results = CheckReport $inputData
			$results | Should -Be $true
		}

		It "Should mark a report as safe with decreasing changes" {
			$inputData = "8 6 4 2 1"
			$results = CheckReport $inputData
			$results | Should -Be $true
		}

		It "Should mark a report as safe with all changes being 1" {
			$inputData = "1 2 3 4 5"
			$results = CheckReport $inputData
			$results | Should -Be $true
		}

		It "Should mark a report as safe with all changes being 2" {
			$inputData = "1 3 5 7 9"
			$results = CheckReport $inputData
			$results | Should -Be $true
		}

		It "Should mark a report as safe with all changes being 3" {
			$inputData = "1 4 7 10 13"
			$results = CheckReport $inputData
			$results | Should -Be $true
		}
	}

	Context "Unsafe Reports" -Tag "Problem3" {
		It "Should mark as unsafe if there is no change between two levels" {
			$inputData = "1 3 3 7 9"
			$results = CheckReport $inputData
			$results | Should -Be $false
		}

		It "Should mark as unsafe if the change type changes" {
			$inputData = "3 5 6 4 2"
			$results = CheckReport $inputData
			$results | Should -Be $false
		}

		It "Should mark as unsafe if one change is too high" {
			$inputData = "2 7 8 10 12"
			$results = CheckReport $inputData
			$results | Should -Be $false
		}
	}

	Context "Problem Dampener" -Tag "Problem4" {
		
	}
}

Describe "SolveProblem3" -Tag "Problem3" {
	BeforeAll {
		. ".\Problem 3.ps1"
	}

	It "Should process all the rows" {
		Mock -CommandName CheckReport {return $true}
		$inputPath = ".\Problem 3 inputs.txt"
		$inputData = Get-Content -Path $inputPath
		
		$results = SolveProblem3 $inputPath
		$results | Should -Be $inputData.Length
	}
}
