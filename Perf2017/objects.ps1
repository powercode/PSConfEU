using namespace System.Collections.Generic
using namespace System.Diagnostics

Add-Type -ea:0 -language CSharp -TypeDefinition  @"
namespace DotNet {
public class Person {
    public Person(){}
    public Person(string name, int age){
        Name = name;
        Age = age;
    }
    public string Name;
    public int Age;
}
}
"@ 

$EngCounters = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Perflib\009' -Name 'Counter').Counter
$SweCounters = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Perflib\01D' -Name 'Counter').Counter

$dotNetMemory = ($EngCounters | Select-String '.Net CLR Memory' -Context 1, 0).Context.PreContext[0]
$bytesInAllHeapsCounterId = ($EngCounters | Select-String '# Bytes in all Heaps' -Context 1, 0).Context.PreContext[0]
$sweCounter = ($sweCounters | Select-String $bytesInAllHeapsCounterId -Context 0, 1).Context.PostContext[0]
$swedotNetMemory = ($sweCounters | Select-String $dotNetMemory -Context 0, 1).Context.PostContext[0]

$perfInstance = get-counter '\Process(powershell*)\Process-ID' -ea:0 | 
    ForEach-Object CounterSamples | 
    Where-Object CookedValue -eq $pid | 
    Where-Object Path -match '\((?<inst>[^\)]+)\)' | 
    ForEach-Object {$matches.inst}

function Get-BytesInAllHeaps {
    (Get-Counter "\$swedotNetMemory($perfInstance)\$sweCounter" -MaxSamples 1).CounterSamples[0].CookedValue
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

    static [psobject] TestCreation([ObjType] $type, [int] $count, [long] $memBaseLine ) {                
        
        [GC]::Collect(2)
        $memBaseLine = Get-BytesInAllHeaps 
        $sw = [Stopwatch]::StartNew()
        [Tester]::CreateObjects($type, $count)
        $elapsed = $sw.Elapsed
        $mem = Get-BytesInAllHeaps 
        $memDiff = $mem - $memBaseLine
        [GC]::Collect(2)
        return [PsCUstomObject] @{
            Type = $type
            Mem = $memDiff
            Time = $elapsed
            Count = $count
            PSTypeName = 'ObjAllocResult'
        }
      
    }
}

$count = 1000000

[Enum]::GetValues([ObjType]) | ForEach-Object {
    [void][Tester]::TestCreation($_, $count, $memBaseLine)
}

[GC]::Collect(2)

1 .. 4 | foreach-object {
    [Enum]::GetValues([ObjType]) | ForEach-Object {
        [Tester]::TestCreation($_, $count, $memBaseLine)
    } 
}

 