using module .\measure.psm1

$count = 100000
$value = 1 .. $Count



function Write-TestData {
    param(
        [int[]]$value
    )
    end {
        foreach ($v in $value) {
            Write-output $v
        }
    }
}

Measure-CommandEx {Write-TestData $value} -Count $count -Label 'Foreach Write-Output'

function Write-TestData {
    param(
        [int[]]$value
    )
    end {
        foreach ($v in $value) {
            $v
        }
    }
}

Measure-CommandEx {Write-TestData $value} -Count $count -Label 'Foreach $v'

function Write-TestData2 {
    param(
        [int[]]$value
    )
    end {
        Write-output $value
    }
}

Measure-CommandEx {Write-TestData2 $value} -Count $count -Label 'Write-Output enumerate'

function Write-TestData3 {
    [cmdletBinding()]
    param(
        [int[]]$value
    )
    end {
        $PSCmdlet.WriteObject($value, $true)
    }
}

Measure-CommandEx {Write-TestData3 } -Count $count -Label '$pscmdlet enumerate'

function Write-TestData4 {
    [cmdletBinding()]
    param(
        [int[]]$value
    )
    end {
        $PSCmdlet.WriteObject($value, $false)
    }
}

Measure-CommandEx {Write-TestData4 } -Count $count -Label '$pscmdlet noenumerate'