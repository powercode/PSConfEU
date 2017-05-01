using module .\release\Perf\Perf.psd1
[CmdletBinding()]
param([int] $Count = 100000)

Measure-ObjectOutput -ov res -Count $count
$res | out-chart -Property type, mem, ticks -ChartType Column -ChartSettings @{LabelFormatString = 'N0'}