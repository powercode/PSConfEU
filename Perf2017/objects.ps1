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
    }

    static [psobject] TestCreation([ObjType] $type, [int] $count, [long] $memBaseLine ) {                
        
        [GC]::Collect(2)
        $sw = [Stopwatch]::StartNew()
        [Tester]::CreateObjects($type, $count)
        $elapsed = $sw.Elapsed
        $mem = [Diagnostics.Process]::GetCurrentProcess().PrivateMemorySize64
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
$memBaseLine = [Process]::GetCurrentProcess().PrivateMemorySize64

[Enum]::GetValues([ObjType]) | ForEach-Object {
    [Tester]::TestCreation($_, $count, $memBaseLine)
} 

 