#Requires -Modules PSScriptAnalyzer

Remove-Module oops -ErrorAction SilentlyContinue -Force
Import-Module $PSScriptRoot\..\oops\oops.psd1

Describe 'Module-level oops tests' {
    $GCM = Get-Command -Module oops

    # A basic test before getting meta
    It 'Contains four public commands' {
        $GCM.Count | Should -Be 4
    }

    # Call PSScriptAnalyzer with the default rule set
    Describe 'Ensure commands pass default PSScriptAnalyzer rules' {
        $ViolationSet = Invoke-ScriptAnalyzer -Path $PSScriptRoot\..\oops\ -Recurse
        $RuleSet      = Get-ScriptAnalyzerRule

        ForEach ($Rule in $RuleSet) {
            It "Should pass $Rule" {
                If (($ViolationSet) -and ($ViolationSet.RuleName -contains $Rule)) {
                    $ViolationSet | Where-Object RuleName -eq $Rule -OutVariable Failures | Out-Default
                    $Failures.Count | Should -Be 0
                }
            }
        }
    } #Describe PSScriptAnalyzer

    # Ensure each command has proper help coverage
    $GCM | Assert-ModuleHelp

    # Check for breaking changes in command parameters
    $GCM | Get-Parameter | Assert-Parameter "$PSScriptRoot\param.json"
}
