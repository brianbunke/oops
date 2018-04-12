Import-Module .\oops\oops.psd1
Get-Command -Module oops

# Step 1: Get command metadata
$GCM = Get-Command -Module oops
$GCM | Get-Parameter
# Step 2: Store in JSON
$GCM | Get-Parameter | Export-Parameter -OutputFolder .\Tests
code .\Tests\param.json
# Step 3: Current and recorded metadata note no breaking changes
$GCM | Get-Parameter | Assert-Parameter -Json .\Tests\param.json
# Step 4: (see oops.Tests.ps1)
code .\Tests\oops.Tests.ps1
