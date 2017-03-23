using namespace System.Management.Automation
using namespace System.Collections.Generic
using namespace System.Diagnostics

class PathResult {
    [object] $Result

    PathResult([string] $path) {
        $this.Result = $path
    }

    PathResult([ErrorRecord] $errorRecord) {
        $this.Result = $errorRecord
    }

    [string] GetPath() {
        $path = $this.Result -as [string]
        if ($null -eq $path) {
            throw [System.InvalidOperationException]::new("Result is not a path")
        }
        return $path
    }

    [ErrorRecord] GetError() {
        $err = $this.Result -as [ErrorRecord]
        if ($null -eq $err) {
            throw [System.InvalidOperationException]::new("Result is not an ErrorRecord")
        }
        return $err
    }

    [bool] IsError() {
        return $this.Result -is [ErrorRecord]
    }
}

class PathProcessor {
    static [PathResult[]] ResolveLiteralPaths([string[]] $paths, [PathIntrinsics] $pathIntrinsics) {
        $retVal = [PathResult[]]::new($paths.Length)
        for($i = 0; $i -lt $retVal.Length; $i++) {
            $aPath = $paths[$i]
            if (!(Test-Path -LiteralPath $aPath)) {
                $retVal[$i] = [PathProcessor]::CreatePathNotFoundErrorRecord($aPath)
            }
            else {
                $retVal[$i] = $pathIntrinsics.GetUnresolvedProviderPathFromPSPath($aPath)
            }
        }
        return $retVal
    }

    static [List[PathResult]] ResolvePaths([string[]] $paths, [PathIntrinsics] $pathIntrinsics) {
        $retVal = [List[PathResult]]::new($paths.Length)
        foreach($aPath in $paths) {
            if (!(Test-Path -Path $aPath)) {
                $retVal.Add([PathProcessor]::CreatePathNotFoundErrorRecord($aPath))
            }
            else {
                $provider = $null
                $resolved = $pathIntrinsics.GetResolvedProviderPathFromPSPath($aPath, [ref] $provider)
                foreach($r in $resolved) {
                    $retVal.Add([PathResult]::new($r))
                }
            }
        }
        return $retVal
    }

    static [string[]] ResolveNonExistingPaths([string[]] $paths, [PathIntrinsics] $pathIntrinsics) {
        $retVal = [string[]]::new($paths.Length)
        for($i = 0; $i -lt $retVal.Length; $i++) {
            $retVal[$i] = $pathIntrinsics.GetUnresolvedProviderPathFromPSPath($paths[$i])
        }
        return $retVal
    }

    static [ErrorRecord] CreatePathNotFoundErrorRecord([string] $path) {
        $ex = [ItemNotFoundException]::new("Cannot find path '$path' because it does not exist.")
        $category = [System.Management.Automation.ErrorCategory]::ObjectNotFound
        $errRecord = [ErrorRecord]::new($ex,'PathNotFound',$category,$path)
        return $errRecord
    }
}


class ProgressManager {
    [long] $TotalItemCount
    hidden [int] $ActivityId
    hidden [int] $ParentActivityId
    hidden [string] $Activity
    [string] $StatusDescription
    hidden [StopWatch] $Stopwatch

    ProgressManager([string] $activity, [string] $statusDescription, [long] $totalItemCount, [int] $activityId, [int] $parentActivityId) {
        $this.TotalItemCount = $totalItemCount
        $this.StatusDescription = $statusDescription
        $this.ActivityId = $activityId
        $this.ParentActivityId = $parentActivityId
        $this.Activity = $activity
        $this.Stopwatch = [Stopwatch]::StartNew()
    }

    [ProgressRecord] GetCurrentProgressRecord([long] $currentItemIndex, [string] $currentOperation) {
        $pr = [ProgressRecord]::new($this.ActivityId, $this.Activity, $this.StatusDescription)
        $pr.CurrentOperation = $currentOperation
        $pr.ParentActivityId = $this.ParentActivityId
        $pr.PercentComplete = $currentItemIndex * 100 / $this.TotalItemCount
        $secondsRemaining = ($this.TotalItemCount - $currentItemIndex) * ($this.Stopwatch.Elapsed.TotalSeconds / $currentItemIndex)
        $pr.SecondsRemaining = $secondsRemaining
        return $pr
    }

    [ProgressRecord] GetCompletedRecord() {
        $pr = [ProgressRecord]::new($this.ActivityId, $this.Activity, $this.StatusDescription)
        $pr.RecordType = [ProgressRecordType]::Completed
        return $pr
    }
}

