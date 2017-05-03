using module .\Helpers\ObjectCreation.psm1
using module .\Helpers\member_access.psm1
using module .\Helpers\iteration.psm1
using module .\Helpers\filesystem.psm1
using module .\Helpers\pipeline.psm1
using module .\Helpers\progress.psm1

Set-StrictMode -Version latest

function Measure-ObjectCreationPerformance {
    [CmdletBinding()]
    param(
        $Count = 1000000
    )
    [GC]::Collect(2)

    $perfCounter = [MemoryPerfCounters]::new()
    $tester = [Tester]::new($count, $perfCounter)
    [GC]::Collect(2, 'Forced')
    [GC]::WaitForPendingFinalizers()

    $i = 0
    $kinds = [Enum]::GetNames([ObjType])
    $pr = [Powercode.ProgressWriter]::Create($pscmdlet, "ObjectCreation", "Creating objects", $kinds.Count)
    try {
        $kinds | ForEach-Object {
            $pr.WriteNext($_)
            $tester.TestCreation($_)
        }
    }
    finally {
        $pr.WriteCompleted()
    }
}

function Measure-Sum {
    [CmdletBinding()]
    [OutputType([LoopResult])]
    param(
        [int] $Count = 1000000,
        [switch] $Chart,
        [switch] $Pipeline
    )
    $kinds = [Enum]::GetValues([LoopKind])
    $pr = [Powercode.ProgressWriter]::Create($pscmdlet, "ObjectCreation", "Creating objects", $kinds.Count)
    try {
        $kinds | ForEach-Object {
            $pr.WriteNext($_)
            $sw = [Diagnostics.Stopwatch]::StartNew()
            if ($Pipeline) {
                $sum = (1..$Count) | Get-Sum -Kind $_
            }
            else {
                $sum = Get-Sum -Number (1..$Count) -Kind $_
            }
            $e = $sw.Elapsed
            [LoopResult] @{  Kind = $_ ; Sum = $sum; Count = $count; Time = $e; TimeMs = $e.TotalMilliseconds; Ticks = $e.Ticks}
        }
    }
    finally {$pr.WriteCompleted()}
}


function Measure-FileSystemIteration {
    [CmdletBinding()]
    param(
        [string] $Path = "$env:SystemRoot\System32"
    )
    $kinds = [Enum]::GetValues([LoopKind])
    $pr = [Powercode.ProgressWriter]::Create($pscmdlet, "FileSystem enum", "traversing", $kinds.Count)
    try {
        $kinds | ForEach-Object {
            $res = [FileSystemIterator]::Iterate($Path, $_)
            $res
        }
    }
    finally {$pr.WriteCompleted()}

}

function Measure-ObjectOutput {
    [CmdletBinding()]
    [OutputType([ObjectOutputResult])]
    param(
        [Parameter(Mandatory)]
        [int]$Count)

    $kinds = [Enum]::GetNames([ObjectOutputKind])
    $pr = [Powercode.ProgressWriter]::Create($pscmdlet, "Pipeline output", "measuring", $kinds.Count)
    try {
        $kinds | ForEach-Object {
            $pr.WriteNext($_)
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            Write-ObjectOutput -Kind $_ -Count $Count | out-null
            $e = $sw.Elapsed
            return [ObjectOutputResult] @{
                Kind = $_
                Count = $count
                Time = $e
                TimeMs = $e.TotalMilliseconds
                Ticks = $e.Ticks
            }
        }
    }
    finally {
        $pr.WriteCompleted()
    }
}

function Measure-MemberAccess {
    [CmdletBinding()]
    [OutputType([MemberAccessResult])]
    param([int] $Count)
    $kinds = [Enum]::GetNames([TestMethodKind])
    $pr = [Powercode.ProgressWriter]::Create($pscmdlet, "Member Access", "Calling Members", $kinds.Count)
    try {
        $kinds | ForEach-Object {
            $pr.WriteNext($_)
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            $to = [TestObject]::new()
            $to.AddTest($_, $Count)
            $e = $sw.Elapsed
            return [MemberAccessResult]::new($_, $e, $count)
        }
    }
    finally {
        $pr.WriteCompleted()
    }
}


enum Downloadkind {
    WebClient
    IWR
    IWRProgress
}

class WebDownloadResult {
    [Downloadkind] $Kind
    [TimeSpan] $time
    [long] $TimeMs
    [long] $Ticks

    WebDownloadResult([Downloadkind] $Kind, [TimeSpan] $time) {
        $this.Kind = $Kind
        $this.Time = $time
        $this.TimeMs = $time.TotalMilliseconds
        $this.Ticks = $time.Ticks
    }
}


function Measure-WebDownload {
    [CmdletBinding()]
    [OutputType([MemberAccessResult])]
    param([uri] $Uri)

    $kinds = [Enum]::GetNames([Downloadkind])
    $pr = [Powercode.ProgressWriter]::Create($pscmdlet, "Web Download", "filling the pipes", $kinds.Count)
    $tmpFile = "$env:temp\webdownload.zip"
    try {
        $kinds | ForEach-Object {
            $pr.WriteNext($_)
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            switch ($_) {
                ([Downloadkind]::IWRProgress) {
                    $ProgressPreference = 'SilentlyContinue'
                    Invoke-WebRequest -Uri $Uri -OutFile $tmpFile
                }
                ([Downloadkind]::IWR) {Invoke-WebRequest -Uri $Uri -OutFile $tmpFile }
                ([Downloadkind]::WebClient) {[System.Net.WebClient]::new().DownloadFile($uri, $tmpFile)}
            }
            $e = $sw.Elapsed
            return [WebDownloadResult]::new($_, $e)
        }
    }
    finally {
        Remove-Item $tmpFile
        $pr.WriteCompleted()
    }
}