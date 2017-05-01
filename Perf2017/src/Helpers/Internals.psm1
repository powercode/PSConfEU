using module .\measure.psm1

$count = 100000
$value = 1 .. $Count

enum ObjectOutputKind{
    WriteOutputCmdletForeach
    WriteOutputCmdletPipe
    WriteOutputCmdletNoEnum
    WriteObjectFunction
    WriteObjectFunctionNoEnum
    WriteObjectFunctionForeach
    NonCaptured
}

class ObjectOutputResult {
    [ObjectOutputKind] $Kind
    [timespan] $Time
    [int] $count
    [int] $TimeMs
    [long] $Ticks
}

function Write-ObjectOutput {
    [CmdletBinding()]
    [OutputType([ObjectOutputResult])]
    param([ObjectOutputKind] $kind, [int] $count)

    [int[]] $i = 1..$Count

    $res = switch ($kind) {
        ([ObjectOutputKind]::WriteOutputCmdletForeach) { foreach ($v in $i) { Write-Output $v } }
        ([ObjectOutputKind]::WriteOutputCmdletPipe) { $i | Write-Output }
        ([ObjectOutputKind]::WriteOutputCmdletNoEnum) { Write-Output $i -NoEnumerate }
        ([ObjectOutputKind]::WriteObjectFunctionForeach) { foreach ($v in $i) { $pscmdlet.WriteObject($v) }}
        ([ObjectOutputKind]::WriteObjectFunction) { $pscmdlet.WriteObject($i, $true) }
        ([ObjectOutputKind]::WriteObjectFunctionNoEnum) {$pscmdlet.WriteObject($i, $false)}
        ([ObjectOutputKind]::NonCaptured) { $i }
    }
}

