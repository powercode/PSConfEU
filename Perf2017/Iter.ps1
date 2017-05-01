using module .\release\Perf
[CmdletBinding()]
param( $Count = 10000, [switch] $AsArray)

if ($AsArray) {
    Measure-ArraySumIter -Count $Count -ov res
}
else {
    Measure-ArrayPipeIter -Count $Count -ov res
}
$res | Out-Chart -Property Kind, TimeMs -ChartType Column