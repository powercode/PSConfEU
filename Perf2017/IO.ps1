using module .\release\Perf

Measure-CommandTime { Get-AllFile -Kind ChildItem     } -Count 100 -Label 'Get-ChildItem'
Measure-CommandTime { Get-AllFile -Kind ChildItemName -ea 0} -Count 100 -Label 'Get-ChildItem -Name'
Measure-CommandTime { Get-AllFile -Kind ItemProvider  } -Count 100 -Label 'ItemProvider'
Measure-CommandTime { Get-AllFile -Kind DotNetEnum    } -Count 100 -Label '.NET'
