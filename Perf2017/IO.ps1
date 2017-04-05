using module .\release\Perf

MeasureAndTime-Command { Get-AllFile -Kind ChildItem     } -Count 100 -Label 'Get-ChildItem'
MeasureAndTime-Command { Get-AllFile -Kind ChildItemName -ea 0} -Count 100 -Label 'Get-ChildItem -Name'
MeasureAndTime-Command { Get-AllFile -Kind ItemProvider  } -Count 100 -Label 'ItemProvider'
MeasureAndTime-Command { Get-AllFile -Kind DotNetEnum    } -Count 100 -Label '.NET'
