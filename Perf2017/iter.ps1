using module .\measure.psm1

[CmdletBinding()]
param($count = 30000)

$terms = 1..$count

# fast partitioning
(1..1000).Where($null,'First', 10) -join ','
$a, $b = (1..1000).Where($null,'Split', 100)
($a.Count, $b.Count) -join ','
(1..1000).Where($null,'Last', 10) -join ','
(1..110).Where($null,'SkipUntil', 100) -join ','



function Sum{
    param(
        [Parameter(ValueFromPipeline)]
        [int[]] $Value)
    begin {
        [decimal] $res = 0
    }
    process{
        $value|foreach{ $res += $_ }
    }
    end {
        $res
    }
}



Measure-CommandTime -c $count { $terms | Sum } -label 'Sum pipe'
Measure-CommandTime -c $count { Sum ($terms) } -label 'Sum array'



function Sum2{
    param(
        [Parameter(ValueFromPipeline)]
        [int[]] $Value)
    begin {
        [decimal] $res = 0
    }
    process{
        foreach($v in $value) { $res += $v }
    }
    end {
        $res
    }
}


Measure-CommandTime -c $count { $terms | Sum2 } -label 'Sum2 pipe'
Measure-CommandTime -c $count { Sum2 $terms } -label 'Sum2 array'


function Sum3{
    param(
        [Parameter(ValueFromPipeline)]
        [int[]] $Value)
    begin {
        [decimal] $res = 0
    }
    process{
        for($i = 0; $i -lt $Value.Length; ++ $i){
            $res += $value[$i]
        }
    }
    end {
        $res
    }
}
Measure-CommandTime -c $count { $terms | Sum3 } -label 'Sum3 pipe'
Measure-CommandTime -c $count { Sum3 $terms } -label 'Sum3 array'



class SimpleMath{
    [decimal] $Result

    [void] Add([int[]] $values){
        [decimal] $res = 0;
        foreach($v in $Values){
            $res += $v
        }
        $this.Result += $res
    }

    [void] Add2([int[]] $values){
        [decimal] $res = 0;
        for($i = 0; $i -lt $Values.Length; ++ $i){
            $res += $values[$i]
        }
        $this.Result += $res
    }
}

function Sum4{
    param(
        [Parameter(ValueFromPipeline)]
        [int[]] $Value)
    begin {
        $adder =[SimpleMath]::new()
    }
    process{
        $adder.Add($value)
    }
    end {
        $adder.Result
    }
}


Measure-CommandTime -c $count { $terms | Sum4 } -label 'Sum4 pipe'
Measure-CommandTime -c $count { Sum4 $terms } -label 'Sum4 array'

function Sum5{
    param(
        [Parameter(ValueFromPipeline)]
        [int[]] $Value)
    begin {
        $adder =[SimpleMath]::new()
    }
    process{
        $adder.Add2($value)
    }
    end {
        $adder.Result
    }
}

Measure-CommandTime -c $count { $terms | Sum5 } -label 'Sum5 pipe'
Measure-CommandTime -c $count { Sum5 $terms } -label 'Sum5 array'
