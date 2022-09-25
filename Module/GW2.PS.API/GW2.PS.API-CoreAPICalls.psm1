Function Split-GW2OversizedParam {
    <#
.SYNOPSIS
Split up parameter sets when a very long parameter is provided
#>
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline)]
        [string]$ParamName,
        $APIParams = @{},
        [int]$MaxCount = 200,
        [int]$MaxLength = 10000
    )

    Process {
        $returnParam = @{
            'front' = @{}
            'back'  = @{}
        }
        ForEach ($key in ($APIParams.keys | Where-Object { $_ -ne $ParamName })) {
            $returnParam.front.$key = $APIParams.$key
            $returnParam.back.$key = $APIParams.$key
        }
        
        $FocusParam = $APIParams.$ParamName
        $SplitParam = $FocusParam -split ","
        If ($SplitParam.Count -gt $MaxCount) {
            Write-Debug "Spliting count: $($SplitParam.Count)"
            $returnParam.front.$ParamName = (0..($MaxCount - 1) | ForEach-Object { $SplitParam[$_] }) -join "," 
            $returnParam.back.$ParamName = ($MaxCount..($SplitParam.Count - 1) | ForEach-Object { $SplitParam[$_] }) -join "," 
        }
        elseif ($SplitParam[0].Length -gt $MaxLength) {
            Write-Debug "Spliting length: $($SplitParam[0].Length)"
            $returnParam.front.$ParamName = $SplitParam[0].Substring(0, $MaxLength)
            $returnParam.back.$ParamName = $SplitParam[0].Substring($MaxLength, ($SplitParam[0].Length - $MaxLength))
        }
        else {
            $returnParam.front.$ParamName = $FocusParam
            $returnParam.Remove('back')
        }
        return $returnParam
    }
}

Function InvokeGetAPI {
    [cmdletbinding()]
    param(
        [string]$URI,
        [securestring]$Token,
        [hashtable]$APIParams = @{}
    )

    Process {
        Write-Debug "Calling $URI with $Token {$($APIParams.keys | ForEach-Object { ""$_=$($APIParams.$_ -join ',')"" })}"
        If ($PSVersionTable.PSVersion -ge "7.0") {
            (Invoke-RestMethod -Method Get -Uri $URI -Authentication Bearer -Token $Token -Body $APIParams -ErrorAction Stop)
        }
        elseif ($PSVersionTable.PSVersion -ge "5.1") {
            $APIKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureAPIKey))
            (Invoke-RestMethod -Method Get -Uri $URI -Header @{ "Authorization" = "Bearer $APIKey" } -Body $APIParams -ErrorAction Stop )
        }
        else {
            throw ("Current PS Version [$($PSVersionTable.PSVersion)] not supported!  Install the latest version of PowerShell for support")
        }
    }
}

Function Get-GW2APIValue {
    <#
.SYNOPSIS
Get a value from the Guild Wars 2 APIv2
#>
    [CmdletBinding(DefaultParameterSetName = "ProfileName")]
    param(
        [parameter(ParameterSetName = "SecureAPIKey", Position = 0, Mandatory)]
        [System.Security.SecureString]$SecureAPIKey,
        [parameter(ParameterSetName = "ClearAPIKey", Mandatory)]
        [string]$APIKey,
        [parameter(ParameterSetName = "ProfileName", Position = 0)]
        [string]$GW2Profile = (Get-GW2DefaultProfile),
        $APIValue = '',
        [parameter(ValueFromPipelineByPropertyName)]
        [string[]]$ID,
        [hashtable]$APIParams = @{},
        $APIBase = 'https://api.guildwars2.com/v2',
        [switch]$UseCache = (Get-GW2DefaultUseCache),
        [switch]$UseDB = (Get-GW2DefaultUseDB),
        [switch]$UpdateDB,
        [parameter(ValueFromRemainingArguments)]
        $ExtraArgs
    )

    Process {
        If ($Profile) {
            $SecureAPIKey = Get-GW2APIKey -GW2Profile $GW2Profile
        }
        elseIf (-not ([string]::IsNullOrEmpty($APIKey))) {
            $SecureAPIKey = ConvertTo-SecureString -String $APIKey -AsPlainText -Force 
        }

        $URI = "$APIBase/$APIValue"

        
        If ($ID) {
            $IDRegEx = "(.*;\s*)?id=(?<IDValue>[^;]*);?.*"
            $Res=[RegEx]::Matches($ID,$IDRegEx)
            If ($Res.Groups) {
                Write-Debug "Fixing value in $ID to $(($Res.Groups | Where-Object { $_.Name -eq 'IDValue' }).Value -join ',') [$URI]"
                $ID = ($Res.Groups | Where-Object { $_.Name -eq 'IDValue' }).Value -join ","
            }
            If ($URI -match "^(?<before>.+):id(?<after>.*)") {
                $URI = "{0}{1}{2}" -f $Matches.before,$ID[0],$Matches.after
            } else {
                $APIParams.ids += ($ID -join ',')
            }
        }

        $IsOversized = $false
        ForEach ($ParamName in ($APIParams.Keys)) {
            $SplitParams = Split-GW2OversizedParam -ParamName $ParamName -APIParams $APIParams
            If ($SplitParams.back) {
                $IsOversized = $true
                Get-GW2APIValue -APIBase $APIBase -SecureAPIKey $SecureAPIKey -APIValue $APIValue -UseCache:$UseCache -UseDB:$UseDB -APIParams $SplitParams.front
                Get-GW2APIValue -APIBase $APIBase -SecureAPIKey $SecureAPIKey -APIValue $APIValue -UseCache:$UseCache -UseDB:$UseDB -APIParams $SplitParams.back
            }
        }
        If (-not $IsOversized) {
            If ($APIParams.count -gt 0) {
                if ($UseDB) {
                    Write-Debug "attempting to use LiteDB to get $APIValue ($(($APIParams.Values | ForEach-Object { $_ }) -join ';'))"
                    Get-GW2DBValue -APIValue $APIValue -SecureAPIKey $SecureAPIKey -APIParams $APIParams
                } elseIf ($UseCache) {
                    Write-Debug "attempting to use CACHE to get $APIValue ($(($APIParams.Values | ForEach-Object { $_ }) -join ';'))"
                    Get-GW2CacheValue -APIValue $APIValue -SecureAPIKey $SecureAPIKey -APIParams $APIParams
                } else {
                    Write-Debug "calling REST GET: $URI ($(($APIParams.Values | ForEach-Object { $_ }) -join ';')) - ($($PSCmdlet.ParameterSetName)) [$(Get-GW2APIKey)]"
                    $result = InvokeGetAPI -Uri $URI -Token $SecureAPIKey -APIParams $APIParams
                    If ($UpdateDB) {
                        $result | Add-GW2DBEntry -CollectionName $APIValue -PassThru
                    } else {
                        $result
                    }
                }
            }
            else {
                Write-Debug "calling REST GET: $URI - ($($PSCmdlet.ParameterSetName)) [$(Get-GW2APIKey)]"
                InvokeGetAPI -Uri $URI -Token $SecureAPIKey
            }
        }
    }
}

Function Get-GW2Base {
    <#
.SYNOPSIS
Obtain the In Game Name (IGN) for the account
#>
    [cmdletbinding(DefaultParameterSetName = "ProfileName")]
    param(
        [parameter(ParameterSetName = "ProfileName", Position = 0)]
        [string]$GW2Profile = (Get-GW2DefaultProfile)
    )
    Process {
        ((Get-GW2APIValue -GW2Profile $GW2Profile) -split "`n") | ForEach-Object {
            If ($_ -match "(?<base>/v2/\S+) \[[^\[\]]\]") { $matches.base.tostring() }
        }
    }
}

Function Group-GW2ObjectByCount {
    [cmdletbinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [object[]]$InputObject,
        [int]$GroupSize=200,
        [switch]$Unique,
        [switch]$SkipJoin
    )

    Begin {
        $FullCollection = [System.Collections.ArrayList]::new()
    }

    Process {
        $FullCollection.AddRange(@($InputObject))
    }

    End {
        $x=0
        Write-Debug "Finding unique values out of $($FullCollection.count)..."
        $UniqueList = [System.Collections.ArrayList]($FullCollection | Select-Object -Unique:$Unique)
        Write-Debug "Putting $($UniqueList.count) into groups of $GroupSize..."
        While ($x -lt $UniqueList.Count) {
            $left = $UniqueList.Count - $x
            If ($Left -gt $GroupSize) { $left = $GroupSize }
            $subset = $UniqueList.GetRange($x, $left)
            Write-Debug "Output putting group starting at $x..."
            If ($SkipJoin) {
                $subset
            } else {
                $subset -join ','
            }
            $x+=$GroupSize
        }
    }

}

