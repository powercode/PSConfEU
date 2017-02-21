﻿class Result {
    $Time
    $ItemPerSecond
    $Label
}

Update-TypeData -Force -TypeName Result -DefaultKeyPropertySet ItemPerSecond
Update-FormatData -AppendPath .\perf.formats.ps1xml

function Measure-CommandTime{
    param(
        [scriptblock] $Expression,
        [int] $Count,
        [string] $Label
    )
    Write-Progress -Activity Performance -Status "Measuring the execution time of" -CurrentOperation $Label
    $time = Measure-Command -Expression $Expression
    [Result] @{
        Time = $time
        ItemPerSecond = $Count / $time.TotalSeconds
        Label = $label
    }
    Write-Progress -Activity Performance -Status "Measuring the execution time of" -CurrentOperation $Label -Completed
}