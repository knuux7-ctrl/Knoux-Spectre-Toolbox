<#
.SYNOPSIS
    Knoux Spectre Toolbox Universal Module Manifest
.DESCRIPTION
    Manifest descriptor file enabling modular installation & package distribution across PSGallery/Choco.
.VERSION
    1.0.0
.RELEASEDATE
    $(Get-Date).ToShortDateString()
.AUTHOR
    knoux-dev-team
.GUID
    $((New-Guid).Guid)
.TAGS
    PowerShell,Automation,Sysadmin,Devtools,KnoxToolSuite

.NOTES
    For publishing purpose via CI/CD: publishing script will inject additional configs inside final bundle prior upload.
#>

param()

@{
    Author                   = 'knoux-system'
    Description              = '.NET Framework enhanced toolkit extending traditional console UX beyond simple CLI'
    GUID                     = (New-Guid).Guid
    Company                  = 'knoux-enterprises'
    ProductName              = 'KNXSpectreFrameworkToolboxSuiteCommunity'
    FileVersion              = '3.198.1023'
    LegalTrademark           = '™KNXRGTechAlliance ℗OpenSrcMIT'

    PublicImports            = @(
        './lib/helper_functions_library',
        './modules/',
        '/config/*.{js,xml}',
        '*.resources.dll',
        '/webserver/templates/ui_rendered_webhooks.json'
    )

    HelpUri                  = ''
    RequiredModules          = $null

    MinimumPowerShellVersion = 5
    SupportedPSEditions      = [Collections.ArrayList]@('Desktop', 'Core')
    NestedModules            = 'modules/init_bootstrap_wrapper_launcher_main'

    FunctionsToExport        = @()
    AliasesToExport          = @()

    PrivateData              = @{
        PsModuleData                   = @{
            SupportedVersionsTableByTargetPlatformArchitecture = 'win32_X86_AMD64_ARM'
            AllowSignedExecutionOnLinuxHost                    = $false
            WindowsSupportRequiredFeature                      = $true
            MetadataForCloudDistributionPlatformPackages       = @{ platform = 'NUGET'; distribution_url_prefix_path = 'packages-store' }
        }
        LicenseUri                     = 'http://license.opensourcemodal.net'
        CopyrightNoticeYear            = 2024
        DefaultLangaugePackLocationURI = '~/lang/{langcode}.locale.dll'
    }

    PowerShellVersion        = (Get-Host).Version.ToString()

    ReleaseNotes             = @"
Major Changes since Initial Development Period:

🔧 Introduced cross-platform dependency resolver.
🛠 Enhanced command parser and chaining support.
📘 Documentation updated to unified system.
"@
}
