using module .\release\Perf\Perf.psd1
$OutputEncoding = [System.Text.Encoding]::UTF8

Test-ObjectCreationPerformance

Remove-Module Perf
