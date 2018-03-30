function Assert-ModuleHelp {
    <#
    .SYNOPSIS
    Checks for common command help issues for the supplied command.

    .DESCRIPTION
    Runs Pester tests against supplied command(s) to check for common issues:
    - Help contains a Synopsis and Description
    - Help contains example code and explanations
    - Help exists for all non-default parameters
    - Help does not list non-existent parameters

    .EXAMPLE
    Get-Command Get-Date | Assert-ModuleHelp
    Runs Pester tests to ensure the help for Get-Date isn't missing anything obvious.

    .EXAMPLE
    Get-Command -Module oops | Assert-ModuleHelp -Verbose
    Perform help coverage tests against all commands in the oops module.

    .NOTES
    All of the thanks to June Blender (@juneb_get_help) for the precursor to this work,
    a *.Help.Tests.ps1 file, in 2016. This function slightly modifies some checks and
    makes things slightly more generic, but the original skeleton remains intact.
    #>
    [CmdletBinding()]
    param (
        # Command(s) to extract relevant info from
        # Most easily supplied by piping in Get-Command
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [System.Management.Automation.CommandInfo[]]$Command
    )

    BEGIN {
        # Create an empty list to hold all commands
        $List = New-Object System.Collections.Generic.List[Object]
    }

    PROCESS {
        ForEach ($GetCommand in $Command) {
            $Name    = $GetCommand.Name
            Write-Verbose "Processing $Name"

            $GetHelp = Get-Help $Name

            # Get a list of all non-default parameters in the command
            $CmdParam = Get-CommandParameter $GetCommand

            # Get a list of all non-default parameters in the help
            $HelpParam = $GetHelp.Parameters.Parameter |
                Where-Object Name -notin (Get-DefaultParameter)

            # Record all examples in the command help
            $ExampleList = $GetHelp.Examples.Example

            $cmd = [PSCustomObject]@{
                Name        = $Name
                Help        = $GetHelp
                Command     = $GetCommand
                CmdParam    = $CmdParam
                HelpParam   = $HelpParam
                ExampleList = $ExampleList
            }

            # Append the command into $List
            [void]$List.Add($cmd)
        } #ForEach $c
    }

    END {
        Describe 'Ensure commands contain proper help' {
            ForEach ($cmd in $List) {
                Context "$($cmd.Name) help coverage" {
                    It 'Synopsis should not be auto-generated' {
                        $cmd.Help.Synopsis | Should -Not -BeLike '*`[<CommonParameters>`]*'
                    }

                    It 'Synopsis should not be empty' {
                        $cmd.Help.Synopsis | Should -Not -BeNullOrEmpty
                    }

                    It 'Description should not be empty' {
                        $cmd.Help.Description | Should -Not -BeNullOrEmpty
                    }

                    It 'Contains at least one example' {
                        ($cmd.ExampleList | Select-Object -First 1).Code | Should -Not -BeNullOrEmpty
                    }

                    # Loop through all examples
                    for ($i = 0; $i -lt $cmd.ExampleList.Count; $i++) {
                        It "Explains Example $($i+1)" {
                            $cmd.ExampleList[$i].Remarks.Text[0] | Should -Not -BeNullOrEmpty
                        }
                    }

                    If ($cmd.CmdParam) {
                        ForEach ($Parameter in $cmd.CmdParam) {
                            $pName = $Parameter.Name
                            $pHelp = $cmd.HelpParam | Where-Object Name -eq $pName

                            It "-$pName parameter contains help" {
                                $pHelp.Description.Text | Should -Not -BeNullOrEmpty
                            }
                        } #ForEach $Parameter
                    } #If $cmd.ParamList

                    It 'Parameters found in help still exist in code' {
                        $cmd.HelpParam.Name | ForEach-Object {
                            $_ -in $cmd.CmdParam.Name | Should -Be $true
                        }
                    }
                } #Context
            } #ForEach $cmd
        } #Describe
    } #END
}
