function Export-Parameter {
    <#
    .SYNOPSIS
    Export parameter details of the supplied command(s) to a JSON file.

    .DESCRIPTION
    Records command details in a param.json file. By storing this JSON with your
    module tests, you persist a previous, known-good record of command parameters.

    Export-Parameter expects an output folder, and currently always creates a
    file named `param.json`. A -Force parameter is available for file overwrite.
    
    Intended to intake piped output from Get-Parameter.

    .EXAMPLE
    Get-Command -Module oops | Get-Parameter | Export-Parameter
    Collects command and parameter info for module oops.
    Converts data to JSON and saves in `param.json` at the current location.
    
    .EXAMPLE
    Get-Command -Module oops | Get-Parameter | Export-Parameter -OutputFolder C:\
    Collects command and parameter info for module oops.
    Converts data to JSON and saves in `param.json` at the root of the C:\ drive.

    .LINK
    https://github.com/brianbunke/oops
    #>
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Low')]
    param (
        # Select a folder to create a new DemoModule.json file inside
        [ValidateScript({Test-Path $_ -PathType Container})]
        $OutputFolder = (Get-Location),

        # Accepts command/parameter object output from Get-Parameter
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [PSCustomObject[]]$CmdParam
    )

    BEGIN {
        # Create an empty list to hold all commands
        $List = New-Object System.Collections.Generic.List[Object]
    }

    PROCESS {
        ForEach ($c in $CmdParam) {
            # Append the command into $List
            [void]$List.Add($c)
        }
    }

    END {
        # WhatIf
        If ($PSCmdlet.ShouldProcess(
            "$OutputFolder\param.json",
            "Record state of commands and parameters"
        )) {
            # Output commands, parameters, and notable attributes to JSON file
            Try {
                Write-Verbose "Exporting state to $OutputFolder\param.json"
                # Just needs depth 3 for sure, but ¯\_(ツ)_/¯
                $List | ConvertTo-Json -Depth 5 | Out-File $OutputFolder\param.json -ErrorAction Stop
            } Catch {
                throw "Unable to create '$OutputFolder\param.json'. Do you need admin rights?"
            }
        } #WhatIf
    } #END
}
