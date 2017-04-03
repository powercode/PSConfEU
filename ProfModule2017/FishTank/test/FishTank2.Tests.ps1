$ModuleManifestName = 'FishTank.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\src\$ModuleManifestName"

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModuleManifestPath
        $? | Should Be $true
    }
}

