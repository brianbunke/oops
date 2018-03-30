function Assert-Parameter {
    <#
    .SYNOPSIS
    Compares stored state of a command's parameters against actual state.

    .DESCRIPTION
    Ingests stored JSON of a previous known-good state.

    Compares current code (supplied command parameter info) to the JSON,
    running Pester tests to assert no known breaking changes have occurred.

    Pester tests assert:
    - Any command stored in JSON should still exist in the current code
    - Any command parameter stored in JSON hasn't changed,
        because changing a stored parameter would be a known breaking change

    .EXAMPLE
    Get-Command -Module oops | Get-Parameter | Assert-Parameter
    Collects command and parameter info for module oops, piping into Assert-Parameter.
    Assert-Parameter looks for `param.json` in the current directory,
    then compares the piped info to the known-good version stored in JSON.
    Pester tests will fail if any known breaking changes are found.
    
    .EXAMPLE
    Get-Command -Module oops | Get-Parameter | Assert-Parameter -Json C:\oops.json
    Collects command and parameter info for module oops, piping into Assert-Parameter.
    Assert-Parameter looks for `oops.json` at the root of the C:\ drive,
    then compares the piped info to the known-good version stored in JSON.
    Pester tests will fail if any known breaking changes are found.
    #>
    [CmdletBinding()]
    param (
        # JSON file previously created by Export-Parameter
        # Typically meant to be stored with a module's tests
        # Defaults to `param.json` in the current directory
        [Parameter(Mandatory = $true)]
        [ValidateScript({(Get-Item $_).Extension -eq '.json'})]
        $Json = ".\param.json",

        # Accepts command/parameter object output from Get-Parameter
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [PSCustomObject[]]$CmdParam
    )

    BEGIN {
        # Create an empty list to hold all commands
        $Current = New-Object System.Collections.Generic.List[Object]
    }

    PROCESS {
        ForEach ($c in $CmdParam) {
            Write-Verbose "Assert-Parameter intaking $($c.Command)"
            # Append the command into $Current
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

                It "$CommandName from JSON still exists in code" {
                    $CommandName | Should -BeIn $Current.Command
                }

                ForEach ($Param in $Recorded.Parameters) {
                    $CurrentParam = $CurrentCommand.Parameters | Where-Object Name -eq $Param.Name

                    It "$CommandName -$($Param.Name) - recorded matches actual" {
                        ForEach ($Prop in $PropList) {
                            $Param.$Prop | Should -Be $CurrentParam.$Prop
                        }
                    }
                } #ForEach $Param
            } #ForEach $Recorded
        } #Describe
    } #END
}
