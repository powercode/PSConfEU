using module .\Helpers\ObjectCreation.psm1
using module .\Helpers\member_access.psm1
using module .\Helpers\measure.psm1
using module .\Helpers\iter.psm1
using module .\Helpers\io.psm1
using module .\Helpers\internals.psm1

function Measure-ObjectCreationPerformance {
    [CmdletBinding()]
    param(
        $Count = 1000000
    )
    [GC]::Collect(2)

    $perfCounter = [MemoryPerfCounters]::new()
    $tester = [Tester]::new($count, $perfCounter)
    [GC]::Collect(2, 'Forced')
    [GC]::WaitForPendingFinalizers()

    $i = 0

    [Enum]::GetValues([ObjType]) | ForEach-Object {
        $i++
        Write-Progress -id 1 -activity CreateObject -status "creating $count $_" -percentComplete ($i * 100 / 12)
        $tester.TestCreation($_)
    }
    Write-Progress -id 1 -activity CreateObject -status "creating $count $_" -completed
}

function Measure-ArraySumIter {
    [OutputType([LoopResult])]
    param(
        [int] $Count = 1000000,
        [switch] $Chart
    )
    [Enum]::GetValues([LoopKind]).Foreach{
        $sw = [Diagnostics.Stopwatch]::StartNew()

        $sum = Get-Sum -Number (1..$Count) -Kind $_

        $e = $sw.Elapsed
        [LoopResult] @{  Kind = $_ ; Sum = $sum; Time = $e; TimeMs = $e.TotalMilliseconds }
    }
}

function Measure-ArrayPipeIter {
    [OutputType([LoopResult])]
    param(
        [int] $Count = 1000000,
        [switch] $Chart
    )
    [Enum]::GetValues([LoopKind]).Foreach{
        $sw = [Diagnostics.Stopwatch]::StartNew()

        $sum = (1..$Count) | Get-Sum -Kind $_

        $e = $sw.Elapsed
        [LoopResult] @{  Kind = $_ ; Sum = $sum; Time = $e; TimeMs = $e.TotalMilliseconds }
    }
}


function Measure-FileSystemIteration {
    [CmdletBinding()]
    param(
        [string] $Path = "$env:SystemRoot\System32"
    )
    [Enum]::GetNames([FileAccessKind]) | ForEach-Object {
        $res = [FileSystemIterator]::Iterate($Path, $_)
        $res
    }

}
