Function Get-GW2HomeCat {
    <#
    .SYNOPSIS
    Get the home/cat from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "Cat"
    }
    Process {
        $APIEndpoint = "home/cat"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}

Function Get-GW2HomeNode {
    <#
    .SYNOPSIS
    Get the home/node from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "Node"
    }
    Process {
        $APIEndpoint = "home/node"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}
        
