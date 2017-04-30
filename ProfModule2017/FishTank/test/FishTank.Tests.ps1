using module "../release/FishTank"

$ModuleManifestName = 'FishTank.psd1'
$moduleManifestPath = "$PSScriptRoot/../release/fishtank/$ModuleManifestName"


Describe 'Fishtank tests' {
    BeforeAll {
        $i = 1
        $ts = foreach ($m in [FishTankModel]::GetAll()) {
            [FishTank]::new($i, $m, "Somewhere")
            $i++
        }
        $ts | ConvertTo-Json | Set-Content -LiteralPath TestDrive:\tanks.ftk
    }
    It 'Imports a fishtank' {
        $tanks = Import-FishTank -LiteralPath TestDrive:\tanks.ftk
        $tanks.Count | Should Be 5
    }

    It 'Can ToString FishTankModel' {
        #"Aquarium Evolution 50", 118.5, 500, 300, 460)
        $ft = [FishTankModel]::new("Aquarium Evolution 50", 118.5, 500, 300, 460)
        $ft.ToString() | Should Be "Aquarium Evolution 50 50x30x46 cm - 69 liter"
    }

    It 'cannot import non-ftk extension' {
        set-content testdrive:\foo.txt ''
        Import-FishTank -LiteralPath TestDrive:\foo.txt -ErrorVariable e -ErrorAction:SilentlyContinue
        $e | Should not Be $Null
        $e.FullyQualifiedErrorId | Should be 'InvalidFileFormat,Import-FishTank'
        $e.CategoryInfo.Category | Should be 'InvalidArgument'
        $p = (Resolve-Path "TestDrive:\foo.txt").ProviderPath
        $e.TargetObject | Should be $p
    }

    It 'should tabexpand add-fishtank -ModelName ' {
        $cmd = 'add-fishtank -ModelName '
        $res = TabExpansion2 -inputScript $cmd -cursorColumn $cmd.Length
        $res.CompletionMatches.Count -gt 0 | Should be true
    }

    It 'can add fish tank' {
        $t = Add-FishTank -ModelName 'Aquarium Evolution 40' -Location Livingroom

        $n = Get-FishTank

    }
}

Describe 'Fishtank completion' {
    It 'can complete fishtankmodel' {
        $cmp = [FishTankCompleter]::new()
        $res = $cmp.CompleteArgument("", "ModelName", "Aquarium", $null, $null)
        $res.Count | Should be 3
        $res[0].ToolTip | Should Match 'Evolution 40'
        $res[0].CompletionText[0] | Should Be "'"
    }
}

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModuleManifestPath
        $? | Should Be $true
    }
}

Remove-Module Fishtank