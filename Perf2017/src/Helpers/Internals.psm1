using module .\measure.psm1

$count = 100000
$value = 1 .. $Count

enum ObjectOutputKind{
    WriteOutputCmdlet
    WriteOutputCmdletNoEnum
    WriteObjectFunction
    WriteObjectFunctionNoEnum
    NonCaptured
}

class ObjectOutputResult {
    [ObjectOutputKind] $Kind
    [timespan] $Time
    [int] $count
    [int] $TimeMs
}

function Write-ObjectOutput {
    [CmdletBinding()]
    [OutputType([ObjectOutputResult])]
    param([ObjectOutputKind] $kind, [int] $count)

    [int[]] $i = 1..$Count

    $res = switch ($kind) {
        ([ObjectOutputKind]::WriteOutputCmdlet) { $i | Write-Output }
        ([ObjectOutputKind]::WriteOutputCmdletNoEnum) { Write-Output $i }
        ([ObjectOutputKind]::WriteObjectFunction) { $pscmdlet.WriteObject($i) }
        ([ObjectOutputKind]::WriteObjectFunctionNoEnum) {$pscmdlet.WriteObject($i, $false)}
        ([ObjectOutputKind]::NonCaptured) { $i }
    }
}

