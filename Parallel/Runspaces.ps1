using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace System.Management.Automation.Runspaces

$rs = [Runspace]::DefaultRunspace

function Invoke-PipelineCommand {
    param(
        [string] $Command
    )
    $rs = [RunspaceFactory]::CreateRunspace()
    $rs.Open()    
    $pipeline = $rs.CreatePipeline($Command)
    $pipeline.Invoke()
    $rs.Dispose()
}

function Invoke-PipelineCommandAsync {
    param(
        [string] $Command
    )
    $rs = [RunspaceFactory]::CreateRunspace()
    $rs.Open()    
    $pipeline = $rs.CreatePipeline($Command)
    $pipeline.InvokeAsync()        
}

# class to group a PowerShell with its output and async result
class Completion{
    [PowerShell] $PowerShell
    [IAsyncResult]$AsyncRes    
    [PSDataCollection[PSObject]] $Output
    
    Completion([PowerShell] $ps)
    {
        $this.PowerShell = $ps                
    }

    [void] BeginInvoke([PsObject] $o, $command)
    {
        $i  = [PSDataCollection[PSObject]]::new()
        $this.Output = [PSDataCollection[PSObject]]::new()                        
        $i.Add($o)
        $i.Complete()
        $cmd = $this.PowerShell.Commands.AddScript("param(`$_, `$PSItem) $command", $true )        
        $cmd.AddParameter("_", $o)
        $cmd.AddParameter("PSItem", $o)
        
        $this.AsyncRes = $this.PowerShell.BeginInvoke($i, $this.Output)
        
    }
}

function Invoke-MyParallel
{
    param(
        [Parameter(Mandatory)]
        [ScriptBlock] $Process,
        [Parameter(ValueFromPipeline, Mandatory)]
        [PSObject] $InputObject        
    )
    begin{
        function psInPool($pool, $command)
        {
            [PowerShell]$ps1 = [PowerShell]::Create()
            $ps1.RunspacePool = $pool                        
            $ps1
        }
        
        [RunspacePool] $pool = [RunspaceFactory]::CreateRunspacePool(2,8)
        $pool.Open()
        $shells = [List[Completion]]::new()
        $availableStates = [PSInvocationState]::NotStarted,[PSInvocationState]::Completed,[PSInvocationState]::Failed 
        $completedStates = [PSInvocationState]::Completed,[PSInvocationState]::Failed 
    }
    process
    {
        while($true)
        {
            while($pool.GetAvailableRunspaces() -eq 0)
            {                        
                Start-Sleep -Milliseconds 100
                $PSCmdlet.WriteDebug("No available runspaces")   
                if ($PSCmdlet.Stopping)
                {
                    $shells.Stop()
                    return
                }
                $PSCmdlet.WriteDebug("Waiting for available runspace")
            }
            $available, $running = $shells.Where({$_.PowerShell.InvocationStateInfo.State -in $availableStates}, 'Split')
            if ($available)
            {
                $available.Where{$_.PowerShell.InvocationStateInfo.State -in $completedStates}.Foreach{
                    $ps = $_.PowerShell
                    $state = $ps.InvocationStateInfo
                    $pscmdlet.WriteDebug(("{0} available in state {1}" -f $ps.InstanceId, $State.State))
                    $out = $_.Output                
                    $pscmdlet.WriteObject($out, $true)
                    if ($State -eq 'Failed')
                    {
                        $pscmdlet.WriteError($state.Reason)
                    }
                    if ($ps.HadErrors)
                    {
                        $ps.Streams.Error.ReadAll().Foreach{
                            $pscmdlet.WriteError($_)
                        }
                    }
                    $out.Clear()
                }
                $completion = $available[0]
            }
            elseif($Shells.Count -lt $pool.GetMaxRunspaces())
            {
                [PowerShell]$ps = psInPool $pool $foreachCommand                                                   
                $pscmdlet.WriteDebug(("{0} new shell with {1} commands" -f $ps.InstanceId, $ps.Commands.Commands.Count))
                $completion = [Completion]::new($ps)
                $null = $shells.Add($completion)                
            }
            else{
                $completion = $null                
            }
            if ($completion)
            {                
                $completion.AsyncRes = $completion.BeginInvoke($InputObject, $PRocess)
                $pscmdlet.WriteDebug(("{0} processing {1}" -f $completion.PowerShell.InstanceId, $InputObject))
                return                                             
            }
            
        }
    }
    end{
        while($pool.GetAvailableRunspaces() -ne $pool.GetMaxRunspaces())
        {                        
            Start-Sleep -Milliseconds 10    
            if ($PSCmdlet.Stopping)
            {
                $shells.Stop()
                return
            }
            $available, $running = $shells.Where({$_.PowerShell.InvocationStateInfo.State -in $availableStates}, 'Split')
            $available.Where{$_.PowerShell.InvocationStateInfo.State -in $completedStates}.Foreach{
                    $msg = "{0} available in state {1}" -f $_.PowerShell.InstanceId, $_.PowerShell.InvocationStateInfo.State
                    $pscmdlet.WriteDebug($msg)
                    $out = $_.Output                
                    $pscmdlet.WriteObject($out, $true)
                    $out.Clear()
                }
        }
        $shells.PowerShell.Dispose()
        $pool.Dispose()
        
    }
    
}


