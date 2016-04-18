. $PSScriptRoot\InvokeDebugger.ps1

$script = "$PSScriptRoot\psextdemo.txt"

$dargs = @{
    'Dump' = "$PSSCriptRoot\dmp\Sample.dmp"
    'SymbolPath' = 'srv*c:\sym*http://msdl.microsoft.com/download/symbols'
    'ScriptFile' = $script
    'SymbolVerbose' = $false
    'ImagePath' = "$PSSCriptRoot\dmp"
}
dbg @dargs -verbose

# kp = Display callstack
# lm = list modules
# dv = Display Variables
# q = quit