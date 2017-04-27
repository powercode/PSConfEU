using module .\Helpers\object_creation.psm1
using module .\Helpers\member_access.psm1
using module .\Helpers\measure.psm1
using module .\Helpers\iter.psm1
using module .\Helpers\io.psm1
using module .\Helpers\internals.psm1

function Test-ObjectCreationPerformance {
    [CmdletBinding()]
    param(

    )
    clear-host
    Write-Host ("`n" * 5)

    $count = 1000000

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
