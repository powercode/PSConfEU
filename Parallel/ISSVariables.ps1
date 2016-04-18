using namespace System.Management.Automation
using namespace System.Management.Automation.Runspaces
using namespace Microsoft.PowerShell.Commands

function Demo1{
    # This creates an empty SessionState
    $iss = [InitialSessionState]::Create()

    # Add the variable 'IISCreatedBy'
    $desc = 'The function that created the sessionstate'
    $v = [SessionStateVariableEntry]::new("ISSCreatedBy", "Create()", $desc)
    $iss.Variables.Add($v)


    # Add the Commands needed to display it
    $gv = [SessionStateCmdletEntry]::new('Get-Variable',[GetVariableCommand],'')
    $fl = [SessionStateCmdletEntry]::new('Format-List',[FormatListCommand],'')
    $fla = [SessionStateAliasEntry]::new('fl','Format-List','')
    $doit = [SessionStateFunctionEntry]::new('doit','Get-Variable ISSCreatedBy | fl')
    $iss.Commands.Add($gv)
    $iss.Commands.Add($fl)
    $iss.Commands.Add($fla)
    $iss.Commands.Add($doit)


    $rs = [RunspaceFactory]::CreateRunspace($iss)
    $rs.Open()
    $rs.LanguageMode = [PSLanguageMode]::FullLanguage
    $pipeline = $rs.CreatePipeline('doit')
    $pipeline.Invoke()
}