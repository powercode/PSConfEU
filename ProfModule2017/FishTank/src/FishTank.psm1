using module .\model.psm1
using module .\Completion.psm1
using module .\Error.psm1
using module .\PathProcessing.psm1
using module .\IncludeExclude.psm1
using module .\Progress.psm1

[List[FishTank]] $state = [List[FishTank]]::new(50)



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
                    (Get-Content -LiteralPath $aPath | ConvertFrom-Json) | ForEach-Object {
                        $model = [FishTankModel] $_.Model

                        $ft = [FishTank]::new($_.Id, $model, $_.Location)
                        $fish = [Fish[]]$_.fish
                        $ft.Fish.AddRange($fish)
                        $state.Add($ft)
                        $ft
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
                $p = $pathResult.Path
                if ($NoClobber -and (Test-Path $p)) {
                    throw [PathProcessor]::CreatePathAlreadyExistsError($p)
                }
                $tanks | ConvertTo-Json -Depth 5 -Compress | Set-Content -LiteralPath $p -Force:$force
            }
        }
    }
}



function Add-FishTank {
    [OutputType([FishTank])]
    param(
        [Parameter(Mandatory)]
        [ArgumentCompleter([FishTankCompleter])]
        [string] $ModelName,
        [Parameter(Mandatory)]
        [string] $Location,
        [Parameter(ValueFromPipeline)]
        [Fish[]] $Fish
    )
    $id = 0
    foreach ($tank in $state) {
        if ($tank.id -gt $id) {
            $id = $tank.Id
        }
    }
    $tankModel = [FishTankModel]::GetAll().Where{$_.Modelname -eq $ModelName}
    if (-not $tankModel) {
        throw "Cannot find model of type $ModelName"
    }
    $tank = [FishTank]::new($id + 1, $tankModel, $Location)
    $state.Add($tank)
    $tank
}

function Remove-FishTank {
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int[]] $Id)
    process {
        foreach ($tankId in $id) {
            $found = $false
            for ($i = 0; $i -lt $state.Count; $i++) {
                if ($state[$i].Id -eq $tankId) {
                    $state.RemoveAt($i)
                    $found = $true
                    break
                }
            }
            if (-not $found) {
                Write-Error -Message "No Tank was found with id '$tankId'" -TargetObject $tankId
            }
        }
    }
}

function Clear-FishTank {
    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        [FishTank[]] $FishTank,
        [switch] $Hurry
    )

    begin { $tanks = [List[FishTank]]::new(20) }
    process { $tanks.AddRange($FishTank) }
    end {

        $pm = [ProgressManager]::new("Clean fishtank", "Removing goo", $tanks.Count)
        $i = 0
        try {
            foreach ($ft in $FishTank) {
                $progress.WriteProgress( $pm.GetCurrentProgressRecord($i++, $ft.Id))
                $ft.Clean($Hurry)
            }
        }
        finally {
            $progress.WriteProgress( $pm.GetCompletedRecord($i++, $ft.Id))
        }
    }
}

function Get-FishTank {
    [CmdletBinding()]
    [OutputType([FishTank])]
    param(
        [string[]] $Include,
        [string[]] $Exclude
    )
    $filter = [IncludeExcludeFilter]::new($Include, $Exclude)
    foreach ($tank in $state) {
        if ($filter.ShouldOutput($tank.Location)) {
            $pscmdlet.WriteObject($State, $true)
        }
    }
}
