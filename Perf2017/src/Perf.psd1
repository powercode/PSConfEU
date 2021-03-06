

@{

    # Script module or binary module file associated with this manifest.
    RootModule = 'Perf.psm1'

    # Version number of this module.
    ModuleVersion = '0.1.0'

    # Supported PSEditions
    # CompatiblePSEditions = @()

    # ID used to uniquely identify this module
    GUID = 'd96bebb8-c28a-468c-bbc7-83f13d232c83'

    # Author of this module
    Author = 'Staffan Gustafsson'

    # Company or vendor of this module
    CompanyName = 'PowerCode Consulting AB'

    # Copyright statement for this module
    Copyright = '(c) 2017 Staffan. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'PowerShell performance examples for PSConfEU 2017'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.0.0'

    # Assemblies that must be loaded prior to importing this module
    RequiredAssemblies = @("powercode.dll")

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess = 'perf.formats.ps1xml'

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Measure-ObjectCreationPerformance'
        'Measure-Sum'
        'Measure-FileSystemIteration'
        'Measure-FileSystemIter'
        'Get-Sum'
        'Measure-ObjectOutput'
        'Measure-MemberAccess'
        'Measure-WebDownload'
        'Measure-StringFormat'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = ''

    # Variables to export from this module
    VariablesToExport = ''

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = ''

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            # Tags = @()

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            # ProjectUri = ''

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}

