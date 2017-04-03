using namespace System.Diagnostics
using namespace System.Management.Automation

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

