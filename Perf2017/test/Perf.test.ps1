using module ..\release\Perf\Perf.psd1

Describe 'Performance tests' {
    Test-ObjectCreationPerformance
}

Remove-Module Perf