using module ./release/perf
$largerFile = "ftp://ftp.vim.org/pub/vim/pc/gvim80-586.exe"


Measure-WebDownload -Uri $largerFile -ov res

$res | Out-Chart -Property Kind, TimeMs -Title "Web download" -ChartType Bar

