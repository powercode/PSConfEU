using module .\measure.psm1

enum FileAccessKind {
    ChildItemName
    ChildItem
    ProviderChildItem
    DotNetEnum
    FastDotNetEnum
}

function Get-AllFile {
    [CmdletBinding()]
    param(
        [FileAccessKind] $Kind = [FildAccessKind]::ChildItem
    )
    switch ($Kind) {
        ([FileAccessKind]::ChildItemName) {  Get-ChildItem -Recurse -File -Name C:\windows\System32 -force -ErrorAction:SilentlyContinue}
        ([FileAccessKind]::ChildItem) { Get-ChildItem -Recurse -File C:\windows\System32 -force -ErrorAction:SilentlyContinue}
        ([FileAccessKind]::ProviderChildItem) { $pscmdlet.WriteObject($pscmdlet.InvokeProvider.ChildItem.Get((, 'C:\Windows\System32'), $true, $true, $true)) }
        ([FileAccessKind]::DotNetEnum) { $pscmdlet.WriteObject([DirectoryEnumerator]::GetDirectoryFiles('c:\windows\system32', '*.*', 'AllDirectories'), $true) }
        ([FileAccessKind]::FastDotNetEnum) { $pscmdlet.WriteObject([PowerCode.FastDirectoryEnumerator]::EnumerateFiles('c:\windows\system32', '*.*', 'AllDirectories'), $true) }
    }
}





