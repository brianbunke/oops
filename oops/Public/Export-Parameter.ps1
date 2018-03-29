# TODO: Change name
    # Hardcoded output
    # Param name ok?
    # Param type ok?
    # Write function description
    # Redo description
    # Redo example

function Export-Parameter {
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
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [PSCustomObject[]]$Command,

        # Select a folder to create a new DemoModule.json file inside
        [ValidateScript({Test-Path $_ -PathType Container})]
        $OutputFolder = 'C:\Users\brian.bunke\Desktop'
    )

    BEGIN {
        # Create an empty list to hold all commands
        $List = New-Object System.Collections.Generic.List[Object]
    }

    PROCESS {
        ForEach ($c in $Command) {
            # Append the command into $List
            [void]$List.Add($c)
        }
    }

    END {
        # Output commands, parameters, and notable attributes in JSON
        Try {
            # Just needs depth 3 for sure, but ¯\_(ツ)_/¯
            Write-Verbose "Exporting state to $OutputFolder\param.json"
            $List | ConvertTo-Json -Depth 5 | Out-File $OutputFolder\param.json -ErrorAction Stop
        } Catch {
            throw "Unable to create '$OutputFolder\param.json'. Do you need admin rights?"
        }
    }
}
