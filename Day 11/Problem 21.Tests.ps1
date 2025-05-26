Describe "SolveProblem21" {
	BeforeAll {
		. ".\Problem 21 (2).ps1" 
	}

	It "Solves example problem #1" {
		$testInput = ".\demo inputs.txt"
		$expected = 7
		SolveProblem21 -InputFilePath $testInput | Should -Be $expected
	}

	It "Solves example problem #2" {
		$testInput = ".\demo inputs 2.txt"
		$expected = 22
		SolveProblem21 -InputFilePath $testInput -NumOfBlinks 6 | Should -Be $expected
	}

	It "Solves example problem #3" {
		$testInput = ".\demo inputs 2.txt"
		$expected = 55312
		SolveProblem21 -InputFilePath $testInput -NumOfBlinks 25 | Should -Be $expected
	}
}

Describe 'StoneChange' {
	BeforeAll {
		. ".\Problem 21 (2).ps1" 
	}

    It 'Returns "1" when input Stone is "0"' {
        $result = StoneChange -Stone "0"
        $result | Should -Be "1"
    }

    It 'Splits the stone evenly in two when it has an even number of digits' {
        $result = StoneChange -Stone "1000"
        $result | Should -HaveCount 2
        $result | Should -Be @("10", "0")
    }

    It "Multiplies the stone's number by 2024 when no other rules apply" {
        $result = StoneChange -Stone "1"
        $result | Should -Be "2024"
    }
}
