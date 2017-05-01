using namespace System.Collections.Generic
using namespace System.Diagnostics

class MemoryPerfCounters : IDisposable {
    [PerformanceCounter] $BytesInAllHeaps
    MemoryPerfCounters() {
        $clrmem = '.NET CLR Memory'
        $perfInstance = [PerformanceCounterCategory]::new($clrmem).GetInstanceNames().Where{$_ -match '^powershell(#\d)?$'}.Foreach{
            try {
                $cnt = [PerformanceCounter]::new($clrmem, "Process ID", $_, $true)
                if ($cnt.RawValue -eq $global:pid) {
                    $this.BytesInAllHeaps = [PerformanceCounter]::new($clrmem, '# Bytes in all Heaps', $_, $true)
                }
            }
            finally {
                $cnt.Dispose()
            }
        }

    }

    [long] GetBytesInAllHeaps() {
        return $this.BytesInAllHeaps.RawValue
    }

    hidden [void] Dispose() {
        $this.BytesInAllHeaps.Dispose()
    }
}


enum ObjType {
    DotNet
    PSClass
    Hashtable
    PSObject
}

class ObjectCreationResult {
    [ObjType] $Type
    [long] $Mem
    [TimeSpan] $time
    [int] $Count
    [int] $BytesPerObject
    [long] $TimeMs
    [long] $Ticks

    ObjectCreationResult([ObjType] $Type, [long] $Mem, [TimeSpan] $time, [int] $Count, [int] $BytesPerObject) {
        $this.Type = $type
        $this.Mem = $mem
        $this.Time = $time
        $this.Count = $count
        $this.BytesPerObject = [int] ($mem / $Count)
        $this.TimeMs = $time.TotalMilliseconds
        $this.Ticks = $time.Ticks
    }
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
    [MemoryPerfCounters] $counter
    [int] $Count

    Tester([int] $count, [MemoryPerfCounters] $counter) {
        $this.Count = $count
        $this.Counter = $counter
    }

    static  [psobject] CreatePSObject([string] $name, [int] $age) {
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

    [object] CreateObjects([ObjType] $type) {
        $local:count = $this.Count
        $l = $null
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
        return $l
    }

    [psobject] TestCreation([ObjType] $type) {
        $local:count = $this.Count
        [GC]::Collect(2, [GCCollectionMode]::Forced, $true, $true)
        Start-Sleep -seconds 1
        [Runtime.GCSettings]::LargeObjectHeapCompactionMode = 'CompactOnce'
        [GC]::Collect(3)
        $memBaseLine = $this.Counter.GetBytesInAllHeaps()
        $sw = [Stopwatch]::StartNew()
        $o = $this.CreateObjects($type)
        $elapsed = $sw.Elapsed
        Start-Sleep -seconds 1
        $mem = $this.Counter.GetBytesInAllHeaps()
        $o = $null;
        $memDiff = $mem - $memBaseLine
        [GC]::Collect(2, [GCCollectionMode]::Forced, $true, $true)
        [GC]::WaitForPendingFinalizers()
        return [ObjectCreationResult]::new($type, $memDiff, $elapsed, $count, [int] ($memdiff / $Count))

    }
}