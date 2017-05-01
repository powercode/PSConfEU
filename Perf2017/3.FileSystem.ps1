using module .\release\Perf
[CmdletBinding()]
param()

Measure-FileSystemIteration -ov res

$res | Out-Chart -Property Kind, TimeMs -ChartType Column -Title 'File system enumeration'