Function Get-GW2Achievement {
    <#
.SYNOPSIS
Get achievement or list of achievements from GW2 API
.PARAMETER Daily
List achievements in the Daily category for today
.PARAMETER Tomorrow
List achievements in the Daily category for tomorrow
.PARAMETER Groups
List achievement groups
.PARAMETER Categories
List achiveemtnt categories
#>
    [cmdletbinding()]
    param(
        [switch]$Daily,
        [switch]$Tomorrow,
        [switch]$Groups,
        [switch]$Categories,
        [switch]$Completed,
        [switch]$Lookup,
        [switch]$All
    )
    DynamicParam {
        CommonGW2APIParameters -IDType "Achievement"
    }
    Process {
        $APIEndpoint = "achievements"
        If ($Daily -or $Tomorrow) {
            return (Get-GW2AchievementDaily @PSBoundParameters )

        }
        elseif ($Groups) {
            return (Get-GW2AchievementGroup @PSBoundParameters )

        }
        elseif ($Categories) {
            return (Get-GW2AchievementCategory @PSBoundParameters )

        }
        else {
            Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
        }
    }
}

Function Get-GW2AchievementDaily {
    <#
.SYNOPSIS
Get daily achievements
#>
    [cmdletbinding()]
    param(
        [ValidateSet("pvp", "pve", "wvw", "fractals", "special", "All")]
        [string]$Section = "All",
        [switch]$Tomorrow,
        [parameter(ValueFromRemainingArguments)]
        $ExtraArgs
    )
    DynamicParam {
        CommonGW2APIParameters -IDType "Achievement"
    }

    Process {
        If ($Tomorrow) {
            $Dailies = Get-GW2APIValue -APIValue "achievements/daily/tomorrow" @PSBoundParameters
        }
        else {
            $Dailies = Get-GW2APIValue -APIValue "achievements/daily" @PSBoundParameters
        }
        switch ($Section) {
            "All" {
                return $Dailies
            }
            Default { 
                $Dailies.$Section
            }
        }
    }
}

Function Get-GW2AchievementCategory {
    <#
.SYNOPSIS
Get categories of achievements
#>
    [cmdletbinding()]
    param(
        [parameter(ValueFromRemainingArguments)]
        $ExtraArgs
    )
    DynamicParam {
        CommonGW2APIParameters -IDType "Category"
    }
    Process {
        $APIEndpoint = "achievements/categories"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}

Function Get-GW2AchievementGroup {
    <#
.SYNOPSIS
Get groups of achievements
#>
    [cmdletbinding()]
    param(
        [parameter(ValueFromRemainingArguments)]
        $ExtraArgs
    )
    DynamicParam {
        CommonGW2APIParameters -IDType "Category"
    }
    Process {
        $APIEndpoint = "achievements/groups"
        Get-GW2APIValue -APIValue $APIEndpoint @PSBoundParameters
    }
}

    