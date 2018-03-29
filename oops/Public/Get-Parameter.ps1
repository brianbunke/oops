# TODO: Ctrl + H "DemoModule"
    # OutputFolder hardcoded
    # Write help
    # Remove $List ?

function Get-Parameter {
    [CmdletBinding()]
    param (
        # Command (cmdlet/function/etc.) to read
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
