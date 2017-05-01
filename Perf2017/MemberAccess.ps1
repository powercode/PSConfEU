using module .\release\Perf
[CmdletBinding()]
param( $Count = 1000)

Measure-MemberAccess -count $count -ov res
$res | Sort-Object TimeMS -Descending | Out-Chart -Property Kind, Ticks -ChartType Column -ChartSettings @{LabelFormatString = 'N0'}
