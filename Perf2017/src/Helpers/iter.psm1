using module .\measure.psm1
enum LoopKind {  ForeachObject; ForeachLang ; MagicForeach; For }

class LoopResult {
    [LoopKind] $Kind
    [long] $Sum
    [TimeSpan] $Time
    [double] $TimeMs
    [long] $Ticks
}

function Get-Sum {
    [OutputType([long])]
    param(
        [Parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [int[]] $Number
        ,
        [LoopKind] $Kind
    )
    begin {
        [long]$sum = 0
    }
    process {
        switch ($Kind) {
            ([LoopKind]::ForeachObject) { $Number | ForEach-Object { $sum += $_ } ; break }
            ([LoopKind]::ForeachLang) { foreach ($n in $Number) { $sum += $n }   ; break }
            ([LoopKind]::MagicForeach) {  $Number.Foreach{$sum += $_ }           ; break }
            ([LoopKind]::For) {
                for ($i = 0; $i -lt $Number.Length; $i++) {
                    $sum += $Number[$i]
                }                 ; break
            }
        }
    }
    end {
        $sum
    }
}




function Test-Partition {
    [CmdletBinding()]
    param($count = 30000)

    $terms = 1..$count

    # fast partitioning
    (1..1000).Where($null, 'First', 10) -join ','
    $a, $b = (1..1000).Where($null, 'Split', 100)
    ($a.Count, $b.Count) -join ','
    (1..1000).Where($null, 'Last', 10) -join ','
    (1..110).Where($null, 'SkipUntil', 100) -join ','



}