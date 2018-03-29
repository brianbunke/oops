function Get-ParameterDetail {
    [CmdletBinding()]
    param (
        # Get-Command against the command
        $Command,
        # Get-Help against the command
        $Help
    )

    Write-Verbose '[Get-ParameterDetail] started'

    # Store a list of common parameters available in an advanced function
    $DefaultParamList = Get-DefaultParameter

    # Throw out all parameters that come with a default advanced function
    $UserParamList = $Command.Parameters.Keys | Where-Object {$_ -NotIn $DefaultParamList}

    ForEach ($param in $UserParamList) {
        Write-Verbose "Processing $($Command.Name) -$param"

        $h = $Help | Where-Object {$_.Name -eq $param}

        $p = $Command.Parameters.$param

        $obj = [PSCustomObject]@{
            Name      = $param
            Type      = $p.ParameterType.FullName
            Position  = $p.Attributes.Position
        }
        # Only record the below properties if modification would be a breaking change
        If (-not ($v = $p.Attributes.Mandatory)) {
            $obj | Add-Member -MemberType NoteProperty -Value $v -Name 'Mandatory'
        }
        If ($v = $p.Attributes.ValueFromPipeline) {
            $obj | Add-Member -MemberType NoteProperty -Value $v -Name 'ValueFromPipeline'
        }
        If ($v = $p.Attributes.ValueFromPipelineByPropertyName) {
            $obj | Add-Member -MemberType NoteProperty -Value $v -Name 'ValueFromPipelineByPropertyName'
        }
        If ($v = $h.defaultValue) {
            $obj | Add-Member -MemberType NoteProperty -Value $v -Name 'DefaultValue'
        }

        $obj
    }
}
