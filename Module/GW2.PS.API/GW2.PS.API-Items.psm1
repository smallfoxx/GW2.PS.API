Function Get-GW2Color {
    <#
    .SYNOPSIS
    Get the colors/ from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param(
        [string]$GW2Profile = (Get-GW2DefaultProfile)
    )
    Process {
        Get-GW2APIValue -APIValue "colors" -GW2Profile $GW2Profile 
    }
}
    
Function Get-GW2Item {
    <#
    .SYNOPSIS
    Get the items from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "Item"
    }
    Process {
        $APIEndpoint = "items"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}
    
Function Get-GW2ItemStat {
    <#
    .SYNOPSIS
    Get the itemstats from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "Stat"
    }
    Process {
        $APIEndpoint = "itemstats"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}
    
Function Get-GW2Material {
    <#
    .SYNOPSIS
    Get the materials/ from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "Material"
    }
    Process {
        $APIEndpoint = "materials"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}

Function Get-GW2Skin {
    <#
    .SYNOPSIS
    Get the skins/ from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "Skin"
    }
    Process {
        $APIEndpoint = "skins"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}

Function Get-GW2LegendaryArmory {
    <#
    .SYNOPSIS
    Get the legendaryarmory/ from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "Armory"
    }
    Process {
        $APIEndpoint = "legendaryarmory"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}

