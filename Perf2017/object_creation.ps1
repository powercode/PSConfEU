using namespace System.Collections.Generic
using namespace System.Diagnostics
using module .\DotNetPerson.dll
clear-host


$perfInstance = [PerformanceCounterCategory]::new('Process').GetInstanceNames().Where( {$_ -match 'powershell#?'}).Foreach( {
        try {
            $cnt = [PerformanceCounter]::new("Process", "ID Process", $_, $true)
            if ($cnt.RawValue -eq $pid) {
                $cnt.InstanceName
            }
        }
        finally {
            $cnt.Dispose()
        }
    })

"Instance : $perfInstance - pid: $pid"

$EngCounters = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Perflib\009' -Name 'Counter').Counter
$SweCounters = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Perflib\01D' -Name 'Counter').Counter



$dotNetMemory = ($EngCounters | Select-String '.Net CLR Memory' -Context 1, 0).Context.PreContext[0]
$bytesInAllHeapsCounterId = ($EngCounters | Select-String '# Bytes in all Heaps' -Context 1, 0).Context.PreContext[0]
$processId = ($EngCounters | Select-String 'Process ID' -Context 1, 0).Context.PreContext[0]
$sweBytesInAll = ($sweCounters | Select-String $bytesInAllHeapsCounterId -Context 0, 1).Context.PostContext[0]
$swedotNetMemory = ($sweCounters | Select-String $dotNetMemory -Context 0, 1).Context.PostContext[0]
$sweProcessID = ($sweCounters | Select-String $processId -Context 0, 1).Context.PostContext[0]

"\$swedotNetMemory($perfInstance)\$sweBytesInAll"
"\$swedotNetMemory($perfInstance)\Process-ID"

$perfInstance = get-counter '\Process(powershell*)\Process-ID' -ea:0 | 
    ForEach-Object CounterSamples | 
    Where-Object CookedValue -eq $pid | 
    Where-Object Path -match '\((?<inst>[^\)]+)\)' | 
    ForEach-Object {$matches.inst}

function Get-BytesInAllHeaps {
    (Get-Counter "\$swedotNetMemory($perfInstance)\$sweBytesInAll").CounterSamples[0].CookedValue
}


enum ObjType {
    DotNet
    PSClass    
    Hashtable
    PSObject
}


class Person {
    [string] $Name
    [int] $Age
    Person([string] $name, [int] $age) {
        $this.Name = $name
        $this.Age = $age
    }
}

class Tester {
    static [psobject] CreatePSObject([string] $name, [int] $age) {
        return [PSCustomObject] @{
            Name = $Name
            Age = $Age
            PSTypeName = 'Person'
        }
    }

    static [hashtable] CreateHashTable([string] $name, [int] $age) {
        return @{
            Name = $name
            Age = $age
            Type = 'Person'
        }
    }

    static [void] CreateObjects([ObjType] $type, [int] $count) {
        switch ($type) {
            'DotNet' {
                $l = [List[DotNet.Person]]::new($count)
                foreach ($i in 1 .. $count) {
                    $l.Add([DotNet.Person]::new("Staffan", 45))
                } 
            }
            'PSClass' {
                $l = [List[Person]]::new($count)
                foreach ($i in 1 .. $count) {
                    $l.Add([Person]::new("Staffan", 45))
                }
            }
            'PSObject' {
                $l = [List[PSObject]]::new($count)
                foreach ($i in 1 .. $count) {                    
                    $l.Add([Tester]::CreatePSObject("Staffan", 45))
                }
            }
            'Hashtable' {
                $l = [List[HashTable]]::new($count)
                foreach ($i in 1 .. $count) {
                    $l.Add([Tester]::CreateHashTable("Staffan", 45))
                }
            }
        }
        $l = $null
    }

    static [psobject] TestCreation([ObjType] $type, [int] $count) {                        
        [GC]::Collect(2)
        [GC]::Collect(2)        
        $memBaseLine = Get-BytesInAllHeaps 
        $sw = [Stopwatch]::StartNew()
        [Tester]::CreateObjects($type, $count)
        $elapsed = $sw.Elapsed
        $mem = Get-BytesInAllHeaps 
        $memDiff = $mem - $memBaseLine
        [GC]::Collect(2)
        return [PsCustomObject] @{
            Type = $type
            Mem = $memDiff
            Time = $elapsed
            Count = $count
            PSTypeName = 'ObjAllocResult'
        }
      
    }
}

$count = 1000000

[GC]::Collect(2)

[Enum]::GetValues([ObjType]) | ForEach-Object {
    [void][Tester]::TestCreation($_, $count)
}
[GC]::Collect(2)

1 .. 3| foreach-object {
    [Enum]::GetValues([ObjType]) | ForEach-Object {
        #  [Tester]::TestCreation($_, $count)
    } 
}

 