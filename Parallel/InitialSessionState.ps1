using namespace System.Management.Automation.Runspaces
function Show-ISS
{   
    [CmdletBinding()]
    [Alias('siss')]
    param(                
        [Parameter(Mandatory, Position=0)]
        [ValidateSet('Default','Default2','Empty')]
        [string] $Name
        ,
        [Switch] $Commands
        ,
        [Switch] $Nouns
        ,
        [Switch] $Summary
    )
   
    $ISS = switch($Name)
    {
        'Default' {[InitialSessionState]::CreateDefault()}
        'Default2'{[InitialSessionState]::CreateDefault2()}
        'Empty'   {[InitialSessionState]::Create()}
    }    
    if ($Commands)
    {
        $ISS.Commands | Add-Member -NotePropertyName "ISS" -NotePropertyValue $Name -PassThru |   Format-Table ISS, CommandType,PSSnapin,Name
    }
    if ($Nouns)
    {
        $iss.Commands.Where{$_.CommandType -eq 'Cmdlet'}.Foreach{Get-Command $_.Name -ea:0} | Group Noun -NoElement | sort Count
    }
    if ($Summary)
    {         
        $ISS.Commands | Group CommandType -NoElement
    }        
}

# Show-ISS -Summary Empty 
# Show-ISS -Summary Default 
# Show-ISS -Summary Default2 

# Show-ISS -Nouns Default | Format-Wide
# Show-ISS -Nouns Default2 | Format-Wide