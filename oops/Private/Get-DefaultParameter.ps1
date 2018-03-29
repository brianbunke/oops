# Return a list of default parameters

function Get-DefaultParameter {
    [CmdletBinding()]
    param (
        # Excludes WhatIf and Confirm parameters from output
        [switch]$ExcludeWhatIf
    )

    Write-Verbose '[Get-DefaultParameter] started'

    If ($ExcludeWhatIf) {
        # Create an advanced function
        function Dummy {
            [CmdletBinding()]
            param ()
        }
    } Else {
        # Create an advanced function that supports ShouldProcess
        # (this includes parameters WhatIf and Confirm)
        function Dummy {
            [CmdletBinding(
                SupportsShouldProcess = $true,
                ConfirmImpact = 'Medium'
            )]
            param ()
        }
    }

    # Output all parameter names supplied by a default advanced function
    (Get-Command Dummy).Parameters.Keys
}
