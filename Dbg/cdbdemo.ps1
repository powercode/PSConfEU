. $PSScriptRoot\InvokeDebugger.ps1


$dargs = @{
    'Dump' = "$PSSCriptRoot\dmp\Sample.dmp"
    'SymbolPath' = 'srv*c:\sym*http://msdl.microsoft.com/download/symbols'
    'Command' = '.reload -f;kp;lm;dv;q'
}
dbg @dargs 

# kp = Display callstack
# lm = list modules
# dv = Display Variables
# q = quit

Invoke-Debugger -ScriptFile gm.dbg -LoadSymbols -Debugger windbg notepad.exe
