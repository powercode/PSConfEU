class Result {
    $Time
    $ItemPerSecond
    $TimeInSeconds
    $Label
}

Update-TypeData -Force -TypeName Result -DefaultKeyPropertySet ItemPerSecond

function Measure-CommandEx {
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
        TimeInSeconds = $time.TotalSeconds
        Label = $label
    }
    Write-Progress -Activity Performance -Status "Measuring the execution time of" -CurrentOperation $Label -Completed
}