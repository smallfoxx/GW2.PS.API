Function Get-GW2Currency {
    <#
    .SYNOPSIS
    Get the currencies from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "Currency"
    }
    Process {
        $APIEndpoint = "currencies"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}

Function Get-GW2EventState {
    <#
    .SYNOPSIS
    Get the events-state from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param(
        [string]$GW2Profile = (Get-GW2DefaultProfile)
    )
    Process {
        Get-GW2APIValue -APIValue "events-state" -GW2Profile $GW2Profile 
    }
}
    
Function Get-GW2Mini {
    <#
        .SYNOPSIS
        Get the minis/ from Guild Wars 2 API
        #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "Mini"
    }
    Process {
        $APIEndpoint = "minis"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}

Function Get-GW2Novelty {
    <#
    .SYNOPSIS
    Get the novelties from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "Novelty"
    }
    Process {
        $APIEndpoint = "novelties"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}
    
Function Get-GW2Raid {
    <#
    .SYNOPSIS
    Get the raids/ from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "Raid"
    }
    Process {
        $APIEndpoint = "raids"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}
    
Function Get-GW2Title {
    <#
    .SYNOPSIS
    Get the titles/ from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "Title"
    }
    Process {
        $APIEndpoint = "titles"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}

Function Get-GW2World {
    <#
    .SYNOPSIS
    Get the worlds/ from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "World"
    }
    Process {
        $APIEndpoint = "worlds"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}

Function Get-GW2Build {
    <#
    .SYNOPSIS
    Get the build from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "Build"
    }
    Process {
        $APIEndpoint = "build"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}

Function Get-GW2File {
    <#
    .SYNOPSIS
    Get the files/ from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "File"
    }
    Process {
        $APIEndpoint = "files"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}

Function Get-GW2Quaggan {
    <#
    .SYNOPSIS
    Get the quaggans/ from Guild Wars 2 API
    #>
    [cmdletbinding()]
    param()
    DynamicParam {
        CommonGW2APIParameters -IDType "Quaggan"
    }
    Process {
        $APIEndpoint = "quaggans"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}

Function Get-GW2APIEndpointNoCache {
    <#
    .SYNOPSIS
    Get a listing of all the endpoints that are dynamic enough they shouldn't be cached for long.
    #>
    [cmdletbinding()]
    param(
        [switch]$Details
    )
    DynamicParam {
        CommonGW2APIParameters
    }
    Begin {
        $NoCacheEndpoints = @(
            'account/achievements',
            'account/bank',
            'account/buildstorage',
            'account/dailycrafting',
            'account/dungeons',
            'account/dyes',
            'account/emotes',
            'account/finishers',
            'account/gliders',
            'account/home',
            'account/home/cats',
            'account/home/nodes',
            'account/inventory',
            'account/legendaryarmory',
            'account/luck',
            'account/mail',
            'account/mailcarriers',
            'account/mapchests',
            'account/masteries',
            'account/mastery/points',
            'account/materials',
            'account/minis',
            'account/mounts',
            'account/mounts/skins',
            'account/mounts/types',
            'account/novelties',
            'account/outfits',
            'account/progression',
            'account/pvp/heroes',
            'account/raids',
            'account/recipes',
            'account/skins',
            'account/titles',
            'account/wallet',
            'account/worldbosses',
            'adventures/:id/leaderboards',
            'adventures/:id/leaderboards/:board/:region',
            'characters*',
            'commerce/delivery',
            'commerce/exchange',
            'commerce/listings',
            'commerce/prices',
            'commerce/transactions',
            'events-state',
            'gemstore/catalog',
            'guild/:id',
            'guild/:id/log',
            'guild/:id/members',
            'guild/:id/ranks',
            'guild/:id/stash',
            'guild/:id/storage',
            'guild/:id/teams',
            'guild/:id/treasury',
            'guild/:id/upgrades',
            'guild/permissions',
            'guild/search',
            'pvp/seasons',
            'pvp/seasons/:id/leaderboards',
            'pvp/seasons/:id/leaderboards/:board/:region',
            'wvw/matches',
            'wvw/matches/overview',
            'wvw/matches/scores',
            'wvw/matches/stats',
            'wvw/matches/stats/:id/guilds/:guild_id',
            'wvw/matches/stats/:id/teams/:team/top/kdr',
            'wvw/matches/stats/:id/teams/:team/top/kills',
            'wvw/objectives',
            'wvw/ranks',
            'wvw/rewardtracks',
            'wvw/upgrades'
        )
    }
    Process {
        If ($Details) {
            $NoCacheEndPoints | Get-GW2APIEndpoint @PSBoundParameters
        } else {
            $NoCacheEndPoints
        }
    }
}

Function Get-GW2APIEndpointCacheable {
    <#
    .SYNOPSIS
    Get a listing of all the endpoints that are static and should cause a problem to be cached.
    #>
    [cmdletbinding()]
    param(
        [switch]$Details
    )
    DynamicParam {
        CommonGW2APIParameters
    }
    Begin {
        $CacheableEndPoint = @(
            'achievements',
            'achievements/categories',
            'achievements/groups',
            'backstory/answers',
            'backstory/questions',
            'colors',
            'continents',
            'currencies',
            'dungeons',
            'emblem',
            'emotes',
            'finishers',
            'gliders',
            'guild/upgrades',
            'home/cats',
            'home/nodes',
            'items',
            'itemstats',
            'legendaryarmory',
            'legends',
            'mailcarriers',
            'mapchests',
            'maps',
            'masteries',
            'materials',
            'minis',
            'mounts/skins',
            'mounts/types',
            'novelties',
            'outfits',
            'pets',
            'professions',
            'pvp',
            'pvp/amulets',
            'pvp/games',
            'pvp/heroes',
            'pvp/ranks',
            'pvp/rewardtracks',
            'pvp/runes',
            'pvp/sigils',
            'pvp/standings',
            'quaggans',
            'quests',
            'races',
            'raids',
            'recipes',
            'skills',
            'skins',
            'specializations',
            'stories',
            'stories/seasons',
            'titles',
            'traits',
            'vendors',
            'worldbosses',
            'worlds',
            'wvw/abilities'
        )
    }
    Process {
        If ($Details) {
            $CacheableEndPoint | %{
                Get-GW2APIEndpoint -EPName $_ @PSBoundParameters 
            }
        } else {
            $CacheableEndPoint
        }
    }
}

Function Get-GW2APIEndpoint {
    <#
    .SYNOPSIS
    Get a listing of all the endpoints and their stats
    #>
    [cmdletbinding()]
    param(
        [switch]$Details,
        [string]$EPName
    )
    DynamicParam {
        CommonGW2APIParameters -IDType Value
        $APILineRegEx = "/v2/(?<name>{0})(\s+\[(?<flags>[^\]]+)\])?"
    }
    Begin {
        $v2Response = Get-GW2APIValue -Value ''
        $v2RespLineless = ($v2Response -replace "\r","%%r%%") -replace "\n","%%n%%"
        If ($v2RespLineless -match 'exposed by this API:(?<endpoints>.+)Key:') {
            $endpointLines = $matches.endpoints -split "%%r%%%%n%%"
        }
    }
    Process {
        If ($EPName) {
            $IDRegEx = $APILineRegEx -f [regex]::Escape($EPName)
            $endPointMatches = $endpointLines | Where-Object { $_ -match $IDRegEx }
            $ep = [PSCustomObject]@{
                Name = $matches.name
                Flags = $matches.flags -split ','
            }
            $ep | Add-Member ScriptProperty Enabled { -not ($this.Flags -contains 'd')}
            $ep | Add-Member ScriptProperty AuthOnly { $this.Flags -contains 'a' }
            $ep | Add-Member ScriptProperty Localized { $this.Flags -contains 'l' }
            $ep | Add-Member ScriptProperty IDRequired { $this.Name -match '(:id)|(search)' }
            $ep
        } else {
            $GeneralEPRegEx = $APILineRegEx -f "\S+"
            ForEach ($endPoint in $endpointLines) {
                If ($endPoint -match $GeneralEPRegEx) {
                    $ep = [PSCustomObject]@{
                        Name = $matches.name
                        Flags = $matches.flags -split ','
                    }
                    If ($Details) {
                        $ep | Add-Member ScriptProperty Enabled { -not ($this.Flags -contains 'd')}
                        $ep | Add-Member ScriptProperty AuthOnly { $this.Flags -contains 'a' }
                        $ep | Add-Member ScriptProperty Localized { $this.Flags -contains 'l' }
                        $ep | Add-Member ScriptProperty IDRequired { $this.Name -match '(:id)|(search)' }
                        $ep
                    } else {
                        $ep | Select-Object -ExpandProperty Name
                    }
                }
            }
        }
    }
}