using module .\release\Perf
[CmdletBinding()]
param()

Measure-CommandEx { Get-AllFile -Kind ChildItem     } -Count 100 -Label 'Get-ChildItem' -ov res
Measure-CommandEx { Get-AllFile -Kind ChildItemName -ea 0} -Count 100 -Label 'Get-ChildItem -Name' -ov +res
Measure-CommandEx { Get-AllFile -Kind ProviderChildItem  } -Count 100 -Label 'ItemProvider' -ov +res
Measure-CommandEx { Get-AllFile -Kind DotNetEnum    } -Count 100 -Label '.NET' -ov +res
Measure-CommandEx { Get-AllFile -Kind FastDotNetEnum    } -Count 100 -Label 'Fast.NET' -ov +res


$res | Out-Chart -Property Label, TimeInSeconds -ChartType Column