using namespace System.Reflection
using namespace System.Management.Automation
using namespace System.Management.Automation.Runspaces

enum TestMethodKind {
    CodeMethod
    ScriptMethod
    DotNet
    Function
}

function Add {
    [OutputType([long])]
    param([int]$i, [int] $j)
    return [long] $i + $j
}

class CodeMethods {
    static [int] Add([psobject] $obj, [int] $i) {
        $o = [TestObject] $obj
        return $o.Number + $i
    }
}

class TestObject {
    [int] $Number

    TestObject([int] $number) {
        $this.number = $number
    }

    [void] AddTest([TestMethodKind] $kind, [int] $number, $count) {
        $n = $this.number
        foreach ($i in 1..$Count) {
            switch ($kind) {
                ([TestMethodKind]::CodeMethod) { $this.AddCode($number)}
                ([TestMethodKind]::ScriptMethod) { $this.AddScript($number) }
                ([TestMethodKind]::Function) { Add -i $n -j $number}
                ([TestMethodKind]::DotNet) { [Dotnet.SimpleMath]::Add($n, $number) }
            }
        }
    }

    static [long] Add([int] $i, [int] $j) {
        return $i + $j
    }

}

$td = [TypeData]::new([TestObject])
$td.Members.Add("AddScript", [ScriptMethodData]::new("AddScript", {param([int] $i) return [long] $this.Number + $i}))
$codeMethod = [CodeMethods].GetMethod("Add", ([BindingFlags]::Static -bor [BindingFlags]::Public -bor [BindingFlags]::IgnoreCase))
$td.Members.Add("AddCode", [CodeMethodData]::new("AddCode", $codeMethod))

Update-TypeData -TypeData $td -Force

class MemberAccessResult {
    [TestMethodKind] $Kind
    [TimeSpan] $time
    [int] $Count
    [long] $TimeMs
    [long] $Ticks

    MemberAccessResult([TestMethodKind] $Kind, [TimeSpan] $time, [int] $Count) {
        $this.Kind = $Kind
        $this.Time = $time
        $this.Count = $count
        $this.TimeMs = $time.TotalMilliseconds
        $this.Ticks = $time.Ticks
    }
}

