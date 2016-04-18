using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation

class DbgCompleter : IArgumentCompleter
{
    [IEnumerable[CompletionResult]] CompleteArgument(
        [string] $CommandName,
        [string] $ParameterName,
        [string] $WordToComplete,
        [Language.CommandAst] $CommandAst,
        [IDictionary] $FakeBoundParameters)
        {
            
            switch($ParameterName)
            {
                'Dump' { return $this.CompleteDump($WordToComplete, $pwd.ProviderPath)}
                'ProcessId' { return $this.CompleteProcessId($WordToComplete)}                
            }
            return $null
        }

        [IEnumerable[CompletionResult]] CompleteProcessID([string] $WordToComplete)
        {
            $res = [List[CompletionResult]]::new(20)
            (Get-Process | Sort ID).Where{$_.Id.ToString().StartsWith($WordToComplete)}.Foreach{
                [string] $id = $_.Id
                $list = '{0} ({1})' -f $Id, $_.ProcessName
                $tool = $_.MainWindowTitle
                if ([string]::IsNullOrEmpty($tool)) { $tool = $_.Description }
                if ([string]::IsNullOrEmpty($tool)) {$tool = $_.ProcessName }
                $cr =[CompletionResult]::new($id, $list,[CompletionResultType]::ParameterValue, $tool)
                $res.Add($cr)
            }
            return $res
        }
        
        [IEnumerable[CompletionResult]] CompleteDump([string] $WordToComplete, [string] $CurrentDirectory)
        {   
            $pathInclude = @($CurrentDirectory)
            if ($WordToComplete) {$pathInclude += $WordToComplete}         
            $searchArgs = @{
                'Extension' = 'dmp'
                'PathInclude' = $PathInclude
            }            
            
            $res = [List[CompletionResult]]::new(20)

            (Search-Everything @searchArgs -AsArray).Foreach{
                $res.Add([CompletionResult]::new($_, [io.path]::GetFileName($_), [CompletionResultType]::ParameterValue, $_))
            }
            if ($res.Count -eq 0)
            {
                (Search-Everything -Extension dmp -PathInclude $WordToComplete -Global -AsArray).Foreach{
                   $res.Add([CompletionResult]::new($_, [io.path]::GetFileName($_), [CompletionResultType]::ParameterValue, $_))
                }   
            }
            return $res
        }
}


function Invoke-Debugger
{
    [CmdletBinding(DefaultParameterSetName='path')]
    [Alias('dbg')]
    param(
        [Parameter(Mandatory, ParameterSetName='dump', ValueFromPipeline)]        
        [ArgumentCompleter([DbgCompleter])]
        [string] $Dump
        ,        
        [Parameter(Mandatory, ParameterSetName='id', ValueFromPipeline)]        
        [ArgumentCompleter([DbgCompleter])]
        [Alias('id')]
        [int] $ProcessId
        ,
        [Parameter(Mandatory, ParameterSetName='path', ValueFromPipelineByPropertyName, position=1)]                
        [Alias('PSPath')]
        [string] $LiteralPath
        ,
        [string] $SymbolPath
        ,
        [string] $ImagePath
        ,        
        [string] $DefaultExtension
        ,        
        [Alias('iib')]
        [Parameter(ParameterSetName='path')]
        [Parameter(ParameterSetName='id')]        
        [switch] $IgnoreInitialBreakpoint
        ,
        [Alias('ifb')]
        [Parameter(ParameterSetName='path')]
        [Parameter(ParameterSetName='id')]        
        [switch] $IgnoreFinalBreakpoint
        ,
        [string] $Command
        ,
        [string] $ScriptFile
        ,
        [Alias('o')]
        [switch] $AllProcesses
        ,
        [Parameter(ValueFromRemainingArguments)]
        [string[]] $ExtraArgs
        ,
        [Alias('n')]
        [switch] $SymbolVerbose
        ,
        [Parameter()]
        [PSDefaultValue(Help = 'cdb', Value='cdb')]        
        [ValidateSet('cdb', 'windbg')]
        [string] $Debugger = 'cdb'
    )
    
    process{
        if ($Command -and $ScriptFile)
        {
            $msg = "'Command' and 'ScriptFile' is mutually exclusive"
            $PSCmdlet.ThrowTerminatingError([ErrorRecord]::new([Exception]::new($msg), 'CommandAndScriptFile', [ErrorCategory]::InvalidArgument,$null))
        }
        $dbgArgs = @()
        if ($Command)                 { $dbgArgs += '-c', "`"$Command`"" }
        if ($ScriptFile)              { $dbgArgs += '-cf', $ScriptFile }
        if ($SymbolPath)              { $dbgArgs += '-y', $SymbolPath }
        if ($ImagePath)               { $dbgArgs += '-i', $ImagePath }
        if ($IgnoreInitialBreakpoint) { $dbgArgs += '-g'}
        if ($IgnoreFinalBreakpoint)   { $dbgArgs += '-G'}
        if ($AllProcesses)            { $dbgArgs += '-o'}
        if ($SymbolVerbose)           { $dbgArgs += '-n'}
        if ($DefaultExtension)        { $dbgArgs += "-a$DefaultExtension"}
        if ($ExtraArgs)               { $dbgArgs += $ExtraArgs}

        switch($PSCmdlet.ParameterSetName)
        {
            'dump' {$dbgargs += '-z', (Resolve-Path -LiteralPath $Dump -ea:Stop).ProviderPath}
            'id'   {$dbgargs += '-p', $ProcessId}
            'path' {$dbgargs += (Resolve-Path -LiteralPath $LiteralPath -ea:Stop).ProviderPath}
        }
        

        $PSCmdlet.WriteVerbose("$Debugger $dbgArgs")
        & $Debugger $dbgArgs
    }
}

$PSDefaultParameterValues['Invoke-Debugger:SymbolPath'] = "$PSScriptRoot\dmp;srv*c:\sym*http://msdl.microsoft.com/download/symbols"
$PSDefaultParameterValues['Invoke-Debugger:DefaultExtension'] = "$PSScriptRoot\bin\PSExt.dll"