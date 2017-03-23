using module .\PathProcessing.psm1
using module .\IncludeExclude.psm1



function Get-FileData {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Path')]
    param(
        # Specifies a path to one or more locations. Wildcards are permitted.
        [Parameter(Mandatory, Position = 0, ParameterSetName = "Path", ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = "Path to one or more locations.")]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]] $Path,

        # Specifies a path to one or more locations. Unlike the Path parameter, the value of the LiteralPath parameter is
        # used exactly as it is typed. No characters are interpreted as wildcards. If the path includes escape characters,
        # enclose it in single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any
        # characters as escape sequences.
        [Parameter(Mandatory, Position = 0, ParameterSetName = "LiteralPath", ValueFromPipelineByPropertyName, HelpMessage = "Literal path to one or more locations.")]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [string[]] $LiteralPath,

        [string[]] $Include,

        [string[]] $Exclude
    )

    begin {
        $wildCardFilter = [IncludeExcludeFilter]::new($Include, $Exclude)
    }

    process {
        $pathResults = $null
        if ($psCmdlet.ParameterSetName -eq 'Path') {
            $pathResults = [PathProcessor]::ResolvePaths($Path, $psCmdlet.SessionState.Path)
        }
        else {
            $pathResults = [PathProcessor]::ResolveLiteralPaths($LiteralPath, $psCmdlet.SessionState.Path)
        }

        foreach ($pathRes in $pathResults) {
            if ($pathRes.IsError()) {
                $pscmdlet.WriteError($pathRes.GetError())
                continue
            }
            $aPath = $pathRes.GetPath()
            if ($wildCardFilter.ShouldOutput($aPath)) {
                if ($pscmdlet.ShouldProcess($aPath, 'Operation')) {
                    # Process each path
                    $pscmdlet.WriteObject($aPath)
                }
            }
        }
    }
}
