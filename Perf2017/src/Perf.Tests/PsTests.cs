using System;
using System.Diagnostics;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using Xunit;
using Xunit.Abstractions;

namespace Perf.Tests {
    public class PsTests
    {
        private readonly ITestOutputHelper output;

        public PsTests(ITestOutputHelper output)
        {
            this.output = output;
        }

        [Theory]
        [InlineData(1000000, "PSObject")]
        [InlineData(1000000, "Hashtable")]
        [InlineData(1000000, "PSClass")]
        [InlineData(1000000, "DotNet")]
        public void TestPSObjectAlloc(int count, string kind)
        {
            var initialSessionState = InitialSessionState.CreateDefault2();
            var assm = typeof(DotNet.Person).Assembly;
            initialSessionState.Assemblies.Add(new SessionStateAssemblyEntry(assm.FullName, assm.CodeBase));
            using (var ps = PowerShell.Create(initialSessionState))
            {
                ps.AddScript(Script, false);
                ps.Invoke();
                ps.Commands.AddCommand("Test-Creation").AddParameter("Count", count).AddParameter("Kind", kind);
                var sw = Stopwatch.StartNew();
                var res = ps.Invoke();
                output.WriteLine(sw.Elapsed.ToString("c"));
                ps.Stop();
                Assert.False(ps.HadErrors);
            }
            GC.Collect(3, GCCollectionMode.Forced);
            GC.WaitForPendingFinalizers();
        }
        private const string Script = @"
using namespace System.Collections.Generic

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
    [int] $Count

    Tester([int] $count) {
        $this.Count = $count
    }

    static  [psobject] CreatePSObject([string] $name, [int] $age) {
        return [PSCustomObject] @{
            Name = $Name
            Age = $Age
            PSTypeName = 'PPerson'
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
                    $l.Add([DotNet.Person]::new('Staffan', 45))
                }
            }
            'PSClass' {
                $l = [List[Person]]::new($count)
                foreach ($i in 1 .. $count) {
                    $l.Add([Person]::new('Staffan', 45))
                }
            }
            'PSObject' {
                $l = [List[PSObject]]::new($count)
                foreach ($i in 1 .. $count) {
                    $l.Add([Tester]::CreatePSObject('Staffan', 45))
                }
            }
            'Hashtable' {
                $l = [List[HashTable]]::new($count)
                foreach ($i in 1 .. $count) {
                    $l.Add([Tester]::CreateHashTable('Staffan', 45))
                }
            }
        }
        return $l
    }
}

function Test-Creation($Count, $Kind){
    [Tester]::new($count).CreateObjects($kind)
}
";
    }
}