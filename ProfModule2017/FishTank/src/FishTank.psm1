using module .\model.psm1
using module .\Completion.psm1
using module .\Error.psm1
using module .\PathProcessing.psm1
using module .\IncludeExclude.psm1
using module .\Progress.psm1


function Import-FishTank {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([FishTank])]
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
                # Process each path
                if ([IO.Path]::GetExtension($aPath) -ne '.ftk') {
                    $psCmdlet.WriteError([Error]::UnsupportedFileFormat($aPath))
                }
                else {
                    Get-Content -LiteralPath $aPath | ConvertFrom-Json | ForEach-Object {
                        [FishTank] $_
                    }
                }
            }
        }
    }
}

function Export-FishTank {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = "Path")]
    param(
        # Specifies a path to one or more locations. Wildcards are permitted.
        [Parameter(Mandatory, Position = 0, ParameterSetName = "Path", HelpMessage = "Path to one or more locations.")]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string] $Path,

        # Specifies a path to one or more locations. Unlike the Path parameter, the value of the LiteralPath parameter is
        # used exactly as it is typed. No characters are interpreted as wildcards. If the path includes escape characters,
        # enclose it in single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any
        # characters as escape sequences.
        [Parameter(Mandatory, Position = 0, ParameterSetName = "LiteralPath", HelpMessage = "Literal path to one or more locations.")]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [string] $LiteralPath,
        [Parameter(Mandatory, ValueFromPipeline)]
        [FishTank[]] $FishTank,
        [switch]$Force,
        [switch] $NoClobber
    )
    begin {
        $tanks = [List[FishTank]]::new()
    }
    process {
        $tanks.AddRange($FishTank)
    }
    end {
        $pathResult = $null
        if ($psCmdlet.ParameterSetName -eq 'Path') {
            $pathResult = [PathProcessor]::ResolveUniquePath($Path, $PSCmdlet.SessionState.Path)
        }
        else {
            $pathResult = [PathProcessor]::ResolveLiteralPath($LiteralPath, $PSCmdlet.SessionState.Path)
        }
        if ($PSCmdlet.ShouldProcess("Export-FishTank", $pathResult)) {
            if ($pathResult.IsError()) {
                $PSCmdlet.WriteError($pathResult.Error)
            }
            else {
                $tanks | ConvertTo-Json -Depth 5 -Compress | Set-Content -LiteralPath $pathResult.Path
            }
        }
    }
}



function Add-Fish {
    param(
        [Parameter(Mandatory)]
        [FishTank] $FishTank,
        [Parameter(Mandatory, ValueFromPipeline)]
        [Fish[]] $Fish
    )
    foreach ($a in $b) {}
}

function Clean-FishTank {
    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        [FishTank[]] $FishTank
    )

    foreach ($ft in $FishTank) {

    }
}
