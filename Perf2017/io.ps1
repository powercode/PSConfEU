using module .\measure.psm1

function Get-AllFile{
    [CmdletBinding()]
    param()
    Get-ChildItem -Recurse -File -Name C:\windows\System32 -force
}


function Get-AllFile1{
    [CmdletBinding()]
    param()
    Get-ChildItem -Recurse -File C:\windows\System32 -force
}

function Get-AllFile2{
    [CmdletBinding()]
    param()
    $pscmdlet.InvokeProvider.GetType()
    
    $pscmdlet.WriteObject($pscmdlet.InvokeProvider.ChildItem.Get((,'C:\Windows\System32'),$true,$true,$true))
}


Add-Type -TypeDefinition (Get-Content $PSScriptRoot\EnumDirectory.cs -raw)

function Get-AllFile3{
    [CmdletBinding()]
    param()
    $pscmdlet.WriteObject([DirectoryEnumerator]::GetDirectoryFiles('c:\windows\system32', '*.*', 'AllDirectories'), $true)
}

MeasureAndTime-Command { Get-AllFile       } -Count 100 -Label 'Get-ChildItem -Name'
MeasureAndTime-Command { Get-AllFile1 -ea 0} -Count 100 -Label 'Get-ChildItem'
MeasureAndTime-Command { Get-AllFile2      } -Count 100 -Label 'ItemProvider'
MeasureAndTime-Command { Get-AllFile3      } -Count 100 -Label '.NET'


