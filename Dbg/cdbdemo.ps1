. $PSScriptRoot\InvokeDebugger.ps1
cls
Read-Host 'Press Enter to do an automatic analysis of a crash dump'

dbg -Command '.reload -f;kp;lm;dv;q' -Dump  "$PSSCriptRoot\dmp\Sample.dmp"

Read-Host 'Press Enter to dbg notepad'
# kp = Display callstack
# lm = list modules
# dv = Display Variables
# q = quit

Invoke-Debugger -ScriptFile gm.dbg -LoadSymbols -Debugger windbg notepad.exe
