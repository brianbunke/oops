# TODO: Change name
    # Param name ok?
    # Param type ok?
    # Write function description
    # Redo description
    # Redo example

function Compare-Parameter {
    <#
    .SYNOPSIS
    Compares stored state of a command's parameters against actual state.

    .DESCRIPTION
    Runs Pester tests against a command to check for common issues, like:
    - Help contains a Synopsis and Description
    - Help contains example code and explanations
    - Help exists for all non-default parameters
    - Help does not list non-existent parameters

    .EXAMPLE
    Get-ModuleHelp Get-Date
    Runs Pester tests to ensure the help for Get-Date isn't missing anything obvious.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({(Get-Item $_).Extension -eq '.json'})]
        $Json,

        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        $Command
    )

    BEGIN {
        # Create an empty list to hold all commands
        $Current = New-Object System.Collections.Generic.List[Object]
    }

    PROCESS {
        ForEach ($c in $Command) {
            # Append the command into $List
            [void]$Current.Add($c)
        }
    }

    END {
        $ConvertJson = Get-Content $Json -Raw | ConvertFrom-Json

        # Hard-coded list of possible parameters from Get-ParameterDetail
        # hashtag SorryNotSorry ;)
        $PropList = @(
            'Name',
            'Type',
            'Position',
            'Mandatory',
            'ValueFromPipeline',
            'ValueFromPipelineByPropertyName',
            'DefaultValue'
        )

        Describe "Compare JSON-recorded values for breaking changes" {
            ForEach ($Recorded in $ConvertJson) {
                $CommandName = $Recorded.Command
                $CurrentCommand = $Current | Where-Object Command -eq $CommandName

                It "Code still contains command $CommandName" {
                    $CommandName | Should -BeIn $Current.Command
                }

                ForEach ($Param in $Recorded.Parameters) {
                    $CurrentParam = $CurrentCommand.Parameters | Where-Object Name -eq $Param.Name

                    ForEach ($Prop in $PropList) {
                        It "-$($Param.Name) property $Prop - recorded matches actual" {
                            $Param.$Prop | Should -Be $CurrentParam.$Prop
                        }
                    }
                }
            } #ForEach
        }
    }
}
