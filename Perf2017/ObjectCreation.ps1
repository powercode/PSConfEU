using module .\release\Perf\Perf.psd1
[CmdletBinding()]
param($Count = 100000)

Measure-ObjectCreationPerformance -ov res -Count $Count
$res | out-chart -Property type, mem, Ticks -ChartType Column -ChartSettings @{LabelFormatString = 'N0'} -Title 'Object Creation'