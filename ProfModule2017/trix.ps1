
function ctor($name = 'ClassName') {
    $members = Get-Clipboard | Foreach-Object Trim | Where-Object {$_}
    $params = $members -replace '\s+', '' | Join-Item -Delimiter ", "

    $impl = $members -replace '(\[\w+\])\s+\$(\w+)', '$this.$2 = $$$2'  | Join-Item -Delimiter "`r`n        "
    $ofs = "`r`n    "
    $ctor = @"
    $name($params) {
        $impl
    }
"@
    $ctor | Set-Clipboard
    $ctor
}
    