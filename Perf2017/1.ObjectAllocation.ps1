using module .\release\Perf
[CmdletBinding()]
param($Count = 100000)

Measure-ObjectCreationPerformance -ov res -Count $Count
$res | Out-Chart -Property type, mem, Ticks -ChartType Column -ChartSettings @{LabelFormatString = 'N0'} -Title "Object Creation Count=$count"