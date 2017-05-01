using module .\release\Perf\Perf.psd1
[CmdletBinding()]
param()

Measure-ObjectCreationPerformance -ov res
$res | out-chart -Property type, mem, ticks -ChartType Column -ChartSettings @{LabelFormatString = 'N0'}