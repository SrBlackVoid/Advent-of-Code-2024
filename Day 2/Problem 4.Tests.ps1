Describe "Problem Dampener" -Tag "Problem4" {
	BeforeAll {
		. ".\Problem 4.ps1"
	}

	It "Marks 7 6 4 2 1 as safe" {
		$inputData = "7 6 4 2 1"
		$results = CheckReport $inputData
		$results | Should -Be $true
	}

	It "Marks 1 2 7 8 9 as unsafe" {
		$inputData = "1 2 7 8 9"
		$results = CheckReport $inputData
		$results | Should -Be $false
	}

	It "Marks 9 7 6 2 1 as unsafe" {
		$inputData = "9 7 6 2 1"
		$results = CheckReport $inputData
		$results | Should -Be $false
	}

	It "Marks 9 7 6 2 1 as unsafe" {
		$inputData = "1 3 2 4 5"
		$results = CheckReport $inputData
		$results | Should -Be $true
	}

	It "Marks 8 6 4 4 1 as safe" {
		$inputData = "8 6 4 4 1"
		$results = CheckReport $inputData
		$results | Should -Be $true
	}

	It "Marks 1 3 6 7 9 as safe" {
		$inputData = "1 3 6 7 9"
		$results = CheckReport $inputData
		$results | Should -Be $true
	}
}
