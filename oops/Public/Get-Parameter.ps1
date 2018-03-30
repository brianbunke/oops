function Get-Parameter {
    <#
    .SYNOPSIS
    Extracts useful parameter info from the provided command(s).

    .DESCRIPTION
    Expects <CommandInfo> objects, most commonly from Get-Command.

    Intended to output each command, all user-created parameters,
    and parameter settings that would be a breaking change if modified.

    .EXAMPLE
    Get-Command -Module oops | Get-Parameter
    For all public commands in module oops, output non-default parameters
    and relevant parameter settings from command info and help.
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

    PROCESS {
        ForEach ($c in $Command) {
            Write-Verbose "Processing $($c.Name)"

            $Help = Get-Help $c.Name
        
            [PSCustomObject]@{
                Command    = $c.Name
                Parameters = Get-ParameterDetail $c $Help
            }
        } #ForEach $c
    } #PROCESS
}
