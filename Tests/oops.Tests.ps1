Remove-Module oops -ErrorAction SilentlyContinue -Force
Import-Module $PSScriptRoot\..\oops\oops.psd1

Describe 'Module-level oops tests' {
    $GCM = Get-Command -Module oops

    # A basic test before getting meta
    It 'Contains four commands' {
        $GCM.Count | Should -Be 4
    }

    # Ensure each command has proper help coverage
    $GCM | Assert-ModuleHelp

    # Check for breaking changes in command parameters
    $GCM | Get-Parameter | Assert-Parameter "$PSScriptRoot\param.json"
}
