using module "./Release/FishTank/FishTank.psd1"

$ModuleManifestName = 'FishTank.psd1'
$moduleManifestPath = "$PSScriptRoot/../Release/FishTank/$ModuleManifestName"


Describe 'Fishtank tests' {
    It 'Imports a fishtank' {
        set-testInconclusive
    }

    It 'Can ToString FishTankMOdel' {
        #"Aquarium Evolution 50", 118.5, 500, 300, 460)
        $ft = [FishTankModel]::new("Aquarium Evolution 50", 118.5, 500, 300, 460)
        $ft.ToString() | Should Be "Aquarium Evolution 50 50x30x46 cm - 69 liter"
    }

}

Describe 'Fishtank completion' {
    It 'can complete fishtankmodel' {
        $cmp = [FishTankCompleter]::new()
        $res = $cmp.CompleteArgument("", "ModelName", "Aquarium", $null, $null)
        $res.Count | Should be 5
        $res[0].ToolTip | Should Match 'Evolution 40'
    }
}

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModuleManifestPath
        $? | Should Be $true
    }
}

Remove-Module Fishtank
