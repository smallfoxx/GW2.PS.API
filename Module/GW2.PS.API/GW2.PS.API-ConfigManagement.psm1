$MyPublisher = "SMFX"
$MyModuleName = "GW2.PS"

$ReservedSettings = @(
    #'DefaultProfile',
    'Module',
    'Publisher',
    'Cache',
    'Profiles'
)

Function ConfigPath {
    <#
.SYNOPSIS
Return the path to the configuration file; might depend on platform.
#>
    "$env:AppData\$MyPublisher\$MyModuleName.xml"
}

Function BasicProfile {
    <#
.SYNOPSIS
Provide standard template structure for a profile
#>
    [CmdletBinding()]
    param([string]$Name)
    [ordered]@{
        "GW2Profile" = $Name
        "APIKey"     = $null
    }
}

Function LoadConfig {
    <#
.SYNOPSIS
Load details from configuration file
.DESCRIPTION
Import configuration details from file system and generate a default template if not available.
#>
    [CmdletBinding()]
    param([switch]$PassThru)
    Process {
        If (-not (Test-Path (ConfigPath))) {
            IF (-not (Test-Path (Split-Path (ConfigPath) -Parent))) {
                $Null = mkdir (Split-Path (ConfigPath) -Parent)
            }
            $BasicConfig = [ordered]@{
                'Module'         = $MyModuleName
                'Publisher'      = $MyPublisher
                'Cache'          = (New-GW2CacheSettings)
                'DefaultProfile' = "Default"
                'Profiles'       = @{
                    'Default' = BasicProfile -Name "Default"
                }
            }
            #$BasicConfig | ConvertTo-Json | Set-Content -Path (ConfigPath)
            $BasicConfig | Save-GW2Config
        }
        #$ConfigValue = (Get-Content (ConfigPath) | ConvertFrom-Json )
        $ConfigValue = Import-Clixml (ConfigPath) 
        Set-Variable -Name 'ModConfig' -Scope Global -Value $ConfigValue -Option ReadOnly -Force
        If ($PassThru) { $ConfigValue }
    }
}

Function Get-GW2DefaultProfile {
    <#
.SYNOPSIS
Return the name of the current default
#>
    $ModConfig.DefaultProfile
}

Function Save-GW2Config {
    <#
.SYNOPSIS
Export settings to configuration file
#>
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline)]
        $InputObject
    )

    Process {
        #$InputObject | ConvertTo-Json | Set-Content (ConfigPath)
        $InputObject | Export-Clixml -Path (ConfigPath)
    }
}

Function Set-GW2ConfigValue {
    <#
.SYNOPSIS
Set a value for the configuration
.DESCRIPTION
Will store a value in a profile unless -Section indicates otherwise. If no profile or system is specified, it store in the default profile.
#>
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [string]$Name,
        [parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $Value,
        [parameter(ValueFromPipelineByPropertyName)]
        [string]$GW2Profile = (Get-GW2DefaultProfile),
        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet("Profile","System","Cache")]
        [string]$Section="Profile"
    )

    Begin {
        $TempConfig = LoadConfig -PassThru
    }

    Process {
        switch ($Section) {
            "System" {
                If ($Name -notin $ReservedSettings) {
                    $TempConfig.$Name = $Value
                }
            }
            "Cache" {
                If (-not ($TempConfig.Cache)) { $TempConfig.Cache = (New-GW2CacheSettings) }
                $TempConfig.Cache.$Name = $Value
            }
            default {
                If (-not ($TempConfig.Profiles.containsKey($GW2Profile))) {
                    $TempConfig.Profiles.$GW2Profile = BasicProfile -Name $GW2Profile
                }
                $TempConfig.Profiles.$GW2Profile.$Name = $Value
            }
        }
    }

    End {
        $TempConfig | Save-GW2Config
        LoadConfig
    }
}

Function Set-GW2DefaultProfile {
    <#
    .SYNOPSIS
    Set the default profile name
    #>
    [CmdletBinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters
    }
    Begin {
        $CommParams = CommonGW2APIParameters
    }
    Process {
        ForEach ($Comm in ($CommParams.Keys)) {
            Set-Variable -Name $Comm -Value ($PSBoundParameters.$Comm) -Scope 0
            If (-not [string]::IsNullOrEmpty((Get-Variable -Name $Comm))) {
                Set-Variable -Name $Comm -Value $CommParams.$Comm.Value -Scope 0
            }
        }
        If ($GW2Profile) {
            Write-Debug "Setting default profile to $GW2Profile" 
            Set-GW2ConfigValue -Section System -Name DefaultProfile -Value $GW2Profile
        }
    }
}    

Function NewGW2Function {
    param(
        [string]$Base,
        [string[]]$Subsection
    )

    $FunctionSections = ForEach ($Section in (@($Base) + $Subsection)) {
        If (-not [string]::IsNullOrEmpty($Section)) {
            ($Section.Substring(0, 1).ToUpper() + $Section.Substring(1).ToLower()) -replace "s$", ""
        }
    }
    
    If ($FunctionSections.count -gt 1) {
        $FinalSection = $FunctionSections[-1]
    } else {
        $FinalSection = $FunctionSections
    }
    $FunctionString = "Get-GW2$($FunctionSections -join '')" -replace ":id",""
    $URIStub = ((@($Base) + $Subsection) -join "/").ToLower()

    @"
Function $FunctionString {
<#
.SYNOPSIS
Get the $URIStub from Guild Wars 2 API
#>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "$FinalSection"
    }
    Process {
        `$APIEndpoint = "$URIStub"
        Get-GW2APIValue -APIValue `$APIEndpoint @PSBoundParameters
    }
}

"@ 

}

Function BuildGW2Functions {
    [cmdletbinding(DefaultParameterSetName="WebBase")]
    param(
        [parameter(ParameterSetName="WebBase")]
        $Bases = ((Get-GW2Base) -replace "^/v2/", "" ),
        [parameter(ParameterSetName="MissingAPIs",Mandatory)]
        [switch]$Missing,
        [parameter(ParameterSetName="MissingAPIs")]
        [string]$MissingPath="C:\Repo\SmFx\GW2\PoShGW2\Module\GW2.PS\missingAPIs.txt"
        )

    Process {
        if ($Missing) {
            $MissingBases=Get-Content $MissingPath
            BuildGW2Functions -Bases $MissingBases
        } else {
            ForEach ($Base in $Bases) {
                $Sections = $Base -split '/'
                $Root = $Sections[0]
                If ($Sections.Length -gt 1) {
                    $Subs = $Sections[1..($Sections.Length - 1)]
                }
                else {
                    $Subs = $null
                }
                NewGW2Function -Base $Root -Subsection $Subs | Set-Clipboard
                Write-Host "Function for $base on clipboard"
                Pause
            }
        }
    }
}

Function CommonGW2APIParameters {
    <#
.SYNOPSIS
Create standard, dynamic parameters for GW2 functions.
.DESCRIPTION
This will create standard parameters for GW2 functions to provide values such as GW2Profile, ID, and other attributes
.PARAMETER IDType
Specifies that function calling this uses ID parameters
#>
    param([string]$IDType, [switch]$IDMandatory)
    $RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
    $StandardProps = @('Mandatory', 'ValueFromPipelineByPropertyName', 'ValueFromPipeline', 'ParameterSetName', 'Position')
    $Attrib = [ordered]@{
        'GW2Profile' = @{
            'AttribType'                      = [string]
            'Mandatory'                       = $false
            'ValueFromPipelineByPropertyName' = $true
            'Position'                        = 1
            'ValidSet'                        = ([string[]]($ModConfig.Profiles.Keys))
            'DefaultValue'                    = (Get-GW2DefaultProfile)
        }
        'Online' = @{
            'AttribType'                      = [switch]
            'ParameterSetName'                = 'OnlineLookup'
            'Mandatory'                       = $true
            'Position'                        = 2
            'DefaultValue'                    = (-not ((Get-GW2DefaultUseCache) -or (Get-GW2DefaultUseDB)))
        }
        'UseCache' = @{
            'AttribType'                      = [switch]
            'ParameterSetName'                = 'UseLocalInfo'
            'Mandatory'                       = $false
            'Position'                        = 3
            'DefaultValue'                    = ((-not $Online ) -and (Get-GW2DefaultUseCache))
        }
        'UseDB' = @{
            'AttribType'                      = [switch]
            'ParameterSetName'                = 'UseLocalInfo'
            'Mandatory'                       = $false
            'Position'                        = 4
            'DefaultValue'                    = ((-not $Online ) -and (Get-GW2DefaultUseDB))
        }
    }
    If ($IDType -or $IDMandatory) {
        $Attrib.ID = @{
            'AttribType'                      = [string]
            'Mandatory'                       = $IDMandatory
            'ValueFromPipelineByPropertyName' = $true
            'ValueFromPipeline'               = $true
            'Position'                        = 0
            'Alias'                           = @('ids','name')
        }
        If ($IDType -ne 'id') {
            $Attrib.ID.'Alias' += "$($IDType)ID" 
        }
    }
    
    ForEach ($AttribName in $Attrib.Keys) {
        #[string]$AttribName = $Key.ToString()
        $ThisAttrib = New-Object System.Management.Automation.ParameterAttribute
        ForEach ($Prop in $StandardProps) {
            If ($null -ne $Attrib.$AttribName.$Prop) {
                $ThisAttrib.$Prop = $Attrib.$AttribName.$Prop
            }
        }
        $ThisCollection = New-Object  System.Collections.ObjectModel.Collection[System.Attribute]
        $ThisCollection.Add($ThisAttrib)

        If ($Attrib.$AttribName.ValidSet) {
            $ThisValidation = New-Object  System.Management.Automation.ValidateSetAttribute($Attrib.$AttribName.ValidSet)
            $ThisCollection.Add($ThisValidation)
        }

        if ($Attrib.$AttribName.Alias) {
            $ThisAlias = New-Object -Type `
                System.Management.Automation.AliasAttribute -ArgumentList @($Attrib.$AttribName.Alias)
            $ThisCollection.Add($ThisAlias)
        }
    
        $ThisRuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter($AttribName, $Attrib.$AttribName.AttribType, $ThisCollection)
        If ($Attrib.$AttribName.DefaultValue) {
            $ThisRuntimeParam.Value = $Attrib.$AttribName.DefaultValue
        }
        $RuntimeParamDic.Add($AttribName, $ThisRuntimeParam)
    }

    return  $RuntimeParamDic

}
Function Get-GW2ConfigValue {
    <#
.SYNOPSIS
Set a value for the configuration
.DESCRIPTION
Will store a value in a profile unless -Section indicates otherwise. If no profile or system is specified, it store in the default profile.
#>
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [string]$Name,
        [parameter(ValueFromPipelineByPropertyName)]
        [string]$GW2Profile = (Get-GW2DefaultProfile),
        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet("Profile","System","Cache")]
        [string]$Section="Profile"
    )

    Begin {
        $TempConfig = $ModConfig #LoadConfig -PassThru
    }

    Process {
        switch ($Section) {
            "System" {
                If ($Name -notin $ReservedSettings) {
                    return $TempConfig.$Name
                }
            }
            "Cache" {
                return $TempConfig.Cache.$Name 
            }
            default {
                return $TempConfig.Profiles.$GW2Profile.$Name
            }
        }
    }

}

Function Get-GW2DefaultUseCache {
    If ((Get-Module -Name 'GW2.PS.Cache' -ListAvailable)) {
        Write-Output ($true -eq (Get-GW2ConfigValue -Section Cache -Name 'UseCache'))
    } else {
        Write-Output $false
    }
}

LoadConfig
