class ColorPrinter{
  
  static [ConsoleColor] GetColor([uint16] $p)
  {
    if ($p -lt 100)
    {
      return [ConsoleColor]::Green
    }
    if ($p -gt 500)
    {
      return [ConsoleColor]::Red
    }
    return [ConsoleColor]::White
  }
  
  
  static [void] Print([uint32] $xy)
  {
    $defaultForColor = [Console]::ForegroundColor
    [uint16]$x = $xy -shr 16
    [uint16]$y = $xy -band 0xFFFF
    [Console]::Write('X=')
    [Console]::ForegroundColor = [ColorPrinter]::GetColor($x)
    [Console]::Write($x)
    [Console]::ForegroundColor = $defaultForColor
    [Console]::Write('Y=')
    [Console]::ForegroundColor = [ColorPrinter]::GetColor($y)
    [Console]::WriteLine($y)
    [Console]::ForegroundColor = $defaultForColor    
  }
}


function Show-MouseCoord
{
  $msg = Invoke-DbgExpression '@rcx'
  if ($msg -eq 0x200){
    $lparam = ide 'poi(@rbp-59+18)' Int32
    [ColorPrinter]::Print($lparam)
  }
}

function Set-GetMessageBreakpoint
{
  idc 'bp User32!GetMessageW "gu;!ps Show-MouseCoord; g"' 
}

function Out-HexString{
  [CmdletBinding()]
  [Alias('hex')]
  param(
    [Parameter(ValueFromPipeline, Mandatory)]
    [object[]] $InputObject,
    [ValidateSet(2,4,8,16)]
    [int] $Digit,
    [switch] $NoHexSpecifier
  )
  begin{
    [string] $format = if ($PSBoundParameters.ContainsKey('Digit')){ "x$Digit"} else { 'x'}      
    [string] $pattern = if ($NoHexSpecifier){ "{0:$format}"} else { "0x{0:$format}"}      
  }
  process{
    foreach($i in $InputObject)
    {
      $pattern -f $i
    }
  }
  
}

function prompt{
  'PSExt> '
}