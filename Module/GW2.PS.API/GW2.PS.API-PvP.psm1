Function Get-GW2Finisher {
    <#
    .SYNOPSIS
    Get the account/finisher from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType 'Finisher'
    }
    Process {
        $APIEndpoint = "finishers"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}

Function Get-GW2PvpAmulet {
    <#
    .SYNOPSIS
    Get the pvp/amulets from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "Amulet"
    }
    Process {
        $APIEndpoint = "pvp/amulets"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}
    
Function Get-GW2PvpGame {
    <#
    .SYNOPSIS
    Get the pvp/games from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "Game"
    }
    Process {
        $APIEndpoint = "pvp/games"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}

Function Get-GW2PvpHero {
    <#
        .SYNOPSIS
        Get the pvp/heroes from Guild Wars 2 API
        #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "Hero"
    }
    Process {
        $APIEndpoint = "pvp/heroes"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}

Function Get-GW2PvpRank {
    <#
    .SYNOPSIS
    Get the pvp/ranks from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "Rank"
    }
    Process {
        $APIEndpoint = "pvp/ranks"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}

Function Get-GW2PvpSeason {
    <#
    .SYNOPSIS
    Get the pvp/seasons from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "Season"
    }
    Process {
        $APIEndpoint = "pvp/seasons"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}

Function Get-GW2PvpStanding {
    <#
    .SYNOPSIS
    Get the pvp/standings from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "Standing"
    }
    Process {
        $APIEndpoint = "pvp/standings"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}

Function Get-GW2PvpStat {
    <#
    .SYNOPSIS
    Get the pvp/stats from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "Stat"
    }
    Process {
        $APIEndpoint = "pvp/stats"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}
    
Function Get-GW2PvpSeasonLeaderboard {
    <#
    .SYNOPSIS
    Get the pvp/seasons/:id/leaderboards from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "Leaderboard"
    }
    Process {
        $APIEndpoint = "pvp/seasons/:id/leaderboards"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}


