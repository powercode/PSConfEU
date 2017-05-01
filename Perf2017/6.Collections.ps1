using namespace System.Collections.Generic
using namespace System.Diagnostics


class ListResult {
    [int] $count
    [int] $ArrayMs
    [int] $ListMs
}

function Measure-Collection {
    [CmdletBinding()]
    [OutputType([ListResult])]
    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        [int] $count)
    process {
        [Stopwatch] $sw = [Stopwatch]::StartNew()
        $list = @()
        foreach ($i in 1..$count ) {
            $list += $i
        }
        $arrayMs = $sw.Elapsed.TotalMilliseconds

        $sw.Reset()
        $sw.Start()
        $list2 = [List[int]]::new($count)
        foreach ($i in 1..$count ) {
            $list2.Add($i)
        }
        $listMs = $sw.Elapsed.TotalMilliseconds
        [ListResult] @{
            Count = $count
            ArrayMs = $arrayMs
            ListMs = $listms
        }
    }
}
10000, 20000, 30000, 40000 <#50000, 60000, 70000 #> | Measure-Collection -ov res

$res | Out-Chart -Property Count, ArrayMs, ListMs -ChartType Column -Title 'Collection Addition' -Path img/collections.png

