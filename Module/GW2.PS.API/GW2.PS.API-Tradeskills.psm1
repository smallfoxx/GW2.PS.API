Function Get-GW2Dailycrafting {
    <#
    .SYNOPSIS
    Get the dailycrafting/ from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "dailycrafting"
    }
    Process {
        $APIEndpoint = "dailycrafting"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}

Function Get-GW2Recipe {
    <#
    .SYNOPSIS
    Get the recipes/ from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "Recipe"
    }
    Process {
        $APIEndpoint = "recipes"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}

Function Get-GW2RecipeSearch {
    <#
    .SYNOPSIS
    Get the recipes/search from Guild Wars 2 API
    #>
    [cmdletbinding(DefaultParameterSetName="InputContaining")]
    param(
        # Parameter help description
        [Parameter(ParameterSetName="InputContaining")]
        [String[]]
        $Ingredient,
        # Parameter help description
        [Parameter(ParameterSetName="OuputContaining",Mandatory)]
        [String[]]
        $Result
    )
    DynamicParam {
        CommonGW2APIParameters
    }
    Process {
        $APIEndpoint = "recipes/search"
        If ($Ingredient) {
            Get-GW2APIValue -APIValue $APIEndpoint -APIParams @{ 'input' = ($Ingredient -join ',' ) } @PSBoundParameters
        } elseif ($Result) {
            Get-GW2APIValue -APIValue $APIEndpoint -APIParams @{ 'output' = ($Result -join ',' ) } @PSBoundParameters
        }
    }
}
    
    