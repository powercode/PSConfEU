using module .\release\Perf
[CmdletBinding()]
param()

$res = Measure-FileSystemIteration

$res | Out-Chart -Property Kind, TimeMs -ChartType Column -Title 'File system enumeration'