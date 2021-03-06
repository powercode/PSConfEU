param(
  [int] $ThrottleLimit = 4,
  [int] $Milliseconds = 100
)

Import-Module PSParallel -RequiredVersion 2.2.2

function New-Philosopher {
  param($name, [string[]] $treats)
  [PSCustomObject] @{		
    Name = $name
    Treats = $treats
  }
}


$philosopherData = @(
      new-philosopher 'Immanuel Kant' 'was a real pissant','who where very rarely stable'
      new-philosopher 'Heidegger' 'was a boozy beggar', 'Who could think you under the table'
      new-philosopher 'David Hume' 'could out-consume Schopenhauer and Hegel'	
      new-philosopher 'Wittgenstein' 'was a beery swine', 'Who was just as sloshed as Schlegel'
      new-philosopher 'John Stuart Mill' 'of his own free will', 'On half a pint of shandy was particularly ill'
      new-philosopher 'Nietzsche' 'There''s nothing Nietzsche couldn''t teach ya', 'Bout the raising of the wrist.'	
      new-philosopher 'Plato' 'they say, could stick it away', 'Half a crate of whiskey every day'
      new-philosopher 'Aristotle' 'was a bugger for the bottle'
      new-philosopher 'Hobbes' 'was fond of his dram'
      new-philosopher 'Rene Descartes' 'was a drunken fart:', 'I drink, therefore I am'
      new-philosopher 'Socrates' 'is particularly missed','A lovely little thinker but a bugger when he''s pissed!'
    )

function DoPhilosophy {
  $pd = $philosopherData[($_ -1)% $philosopherData.Count]
	
  $step = 5
  $to = 100/$step
  1..$to | foreach {
    $pc = $_ * $step
    $op = switch($_ % 8)
    {
      0 { 'sleeping' }
      1 { 'drinking' }
      2 { 'drinking' }
      3 { 'thinking' }
      4 { 'drinking' }
      5 { 'drinking' }
      6 { 'eating' }
      7 { 'drinking' }
    }

        $status = $pd.Treats[$pc % $pd.Treats.Length]		

        $name = $pd.Name
        $currentOperation = "$name is currently $op"
    Write-Progress -id $PSParallelProgressId -percent $pc -activity $pd.Name -Status $status  -CurrentOperation $currentOperation
    Start-Sleep -milliseconds ($Milliseconds + 100 * (Get-Random -Minimum 3 -Maximum 7))	    			
  }
  Write-Progress -id $PSParallelProgressId -Completed -activity $pd.Name -Status $status
}

1..10 | Invoke-Parallel -ThrottleLimit $ThrottleLimit   {
    DoPhilosophy
}