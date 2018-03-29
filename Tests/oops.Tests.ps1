Remove-Module DemoModule -ErrorAction SilentlyContinue -Force
Import-Module $PSScriptRoot\..\DemoModule.psd1

Describe 'Test DemoModule' {
    $GCM = Get-Command -Module DemoModule

    It 'Contains two commands' {
        # This is a test of a test of a test, my friends
        $GCM.Count | Should -Be 2
    }

    ForEach ($Command in $GCM) {
        Get-ModuleHelp $Command

        $Command | Get-Parameter | Compare-Parameter C:\Users\brian.bunke\Desktop\param.json
    }
}
