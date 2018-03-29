# TODO: Change name
    # Param name ok?
    # Param type ok?
    # Write function description
    # Redo example

function Get-ModuleHelp {
    <#
    .SYNOPSIS
    Checks for common command help issues for the supplied command.

    .DESCRIPTION
    Runs Pester tests against a command to check for common issues, like:
    - Help contains a Synopsis and Description
    - Help contains example code and explanations
    - Help exists for all non-default parameters
    - Help does not list non-existent parameters

    .EXAMPLE
    Get-ModuleHelp Get-Date
    Runs Pester tests to ensure the help for Get-Date isn't missing anything obvious.

    .NOTES
    All of the thanks to June Blender (@juneb_get_help) for the precursor to this work,
    a *.Help.Tests.ps1 file, in 2016. This function slightly modifies some checks and
    makes things slightly more generic, but the original skeleton remains intact.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $Command
    )

    # Record the MamlCommandHelpInfo and FunctionInfo for the command
    $GetHelp     = Get-Help $Command
    $GetCommand  = Get-Command $Command

    If (-not $GetHelp -or -not $GetCommand) {
        throw "Unable to Get-Help or Get-Command against $Command"
    }

    $CommandName = $GetCommand.Name

    Write-Verbose "Processing $CommandName"

    # Record all examples in the command help
    $ExampleList = $GetHelp.Examples.Example

    # Get a list of all non-default parameters in the command
    $GCMParameterList = Get-CommandParameter $GetCommand

    Describe "$CommandName help coverage" {
        It "Synopsis should not be empty" {
            $GetHelp.Synopsis | Should -Not -BeNullOrEmpty
        }

        It "Synopsis should not be auto-generated" {
            $GetHelp.Synopsis | Should -Not -BeLike '*`[<CommonParameters>`]*'
        }

        It "Description should not be empty" {
            $GetHelp.Description | Should -Not -BeNullOrEmpty
        }

        It "Contains at least one example" {
            ($ExampleList | Select-Object -First 1).Code | Should -Not -BeNullOrEmpty
        }

        # Loop through all examples
        for ($i = 0; $i -lt $ExampleList.Count; $i++) {
            It "Explains Example $($i+1)" {
                $ExampleList[$i].Remarks.Text | Should -Not -BeNullOrEmpty
            }
        }

        If ($GCMParameterList) {
            ForEach ($Parameter in $GCMParameterList) {
                $pName = $Parameter.Name
                $pHelp = $GetHelp.Parameters.Parameter | Where-Object Name -EQ $pName

                It "-$pName parameter contains help" {
                    $pHelp.Description.Text | Should -Not -BeNullOrEmpty
                }

                ForEach ($helpParam in $pHelp.Name) {
                    It "-$helpParam parameter, found in help, still exists in code" {
                        $helpParam -in $GCMParameterList.Name | Should -Be $true
                    }
                }
            } #ForEach $Parameter
        } #If $ParameterList
    } #Describe
}
