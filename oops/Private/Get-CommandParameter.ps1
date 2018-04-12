function Get-CommandParameter {
    [CmdletBinding()]
    param (
        # The CommandInfo of the command to extract parameters from
        # Typically "Get-Command Your-Command | Get-CommandParameter"
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [System.Management.Automation.CommandInfo]$Command
    )

    Write-Verbose '[Get-CommandParameter] started'

    # Because we need the full parameter info, and because
    # "Get-Unique" / "Select-Object -Unique" can't figure out multi-property objects,
    # Create an empty list to append into
    $List = New-Object System.Collections.Generic.List[Object]

    # Get a list of default parameters in an advanced function
    $DefaultParamList = Get-DefaultParameter

    # Append all parameters that are not default
    $Command.ParameterSets.Parameters |
        Where-Object Name -notin $DefaultParamList |
        ForEach-Object {
            [void]$List.Add($_)
        }

    # Output the list of non-default parameters
    $List
}
