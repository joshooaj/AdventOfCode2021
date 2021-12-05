<#
    So this day wasn't fun for me.

    Part one wasn't too bad, but I stumbled hard on part two.

    I'm not sure why I struggled so hard but I think it was that there were
    several small but important steps, and I struggled to find free time to
    focus.

    I'm not even going to try to clean up today's solution. I'm just done with
    it.
#>

function Get-MostCommonCharacter {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Data,

        [Parameter(Mandatory)]
        [string]
        $TieBreaker
    )
    
    process {
        $valueCounts = @{}
        for ($col = 0; $col -lt $Data.Length; $col++) {
            $key = $Data[$col].ToString()
            if (-not $valueCounts.ContainsKey($key)) {
                $valueCounts[$key] = 0
            }
            $valueCounts[$key]++
        }

        if ($valueCounts.Count -eq 1) {
            Write-Output $valueCounts.Keys[0]
            return
        }

        $topOne = $valueCounts.Keys | Select-Object -First 1
        $valueCounts.Keys | Foreach-Object {
            if ($valueCounts[$_] -gt $valueCounts[$topOne]) {
                $topOne = $_
            }
        }
        $topTwo = $valueCounts.Values | Sort-Object -Descending | Select-Object -First 2
        if ($topTwo[0] -eq $topTwo[1]) {
            Write-Output $TieBreaker
        }
        else {
            Write-Output $topOne
        }
    }
}

function Get-LeastCommonCharacter {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Data,

        [Parameter(Mandatory)]
        [string]
        $TieBreaker
    )
    
    process {
        $valueCounts = @{}
        for ($col = 0; $col -lt $Data.Length; $col++) {
            $key = $Data[$col].ToString()
            if (-not $valueCounts.ContainsKey($key)) {
                $valueCounts[$key] = 0
            }
            $valueCounts[$key]++
        }

        if ($valueCounts.Count -eq 1) {
            Write-Output $valueCounts.Keys[0]
            return
        }

        $topOne = $valueCounts.Keys | Select-Object -First 1
        $valueCounts.Keys | Foreach-Object {
            if ($valueCounts[$_] -lt $valueCounts[$topOne]) {
                $topOne = $_
            }
        }
        $topTwo = $valueCounts.Values | Sort-Object | Select-Object -First 2
        if ($topTwo[0] -eq $topTwo[1]) {
            Write-Output $TieBreaker
        }
        else {
            Write-Output $topOne
        }
    }
}

function Get-DataColumns {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]
        $Data
    )
    process {
        $columns = New-Object System.Collections.Generic.List[string]
        $sb = [text.stringbuilder]::new()
        for ($i = 0; $i -lt $Data[0].Length; $i++) {
            $null = $sb.Clear()
            foreach ($row in $Data) {
                $null = $sb.Append($row[$i])
            }
            $columns.Add($sb.ToString())
        }
        Write-Output $columns
    }
}
function Measure-PowerConsumption {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]
        $Data
    )
        
    process {
        $x = [int[]]::new($Data[0].Length)
        for ($row = 0; $row -lt $Data.Count; $row++) {
            for ($col = 0; $col -lt $Data[$row].Length; $col++) {
                if ($Data[$row][$col] -eq '1') {
                    $x[$col]++
                }
            }
        }
        $gammaString = ''
        foreach ($col in $x) {
            if ($col -gt ($Data.Count / 2)) {
                $gammaString += '1'
            }
            else {
                $gammaString += '0'
            }
        }
        $gamma = [convert]::ToInt32($gammaString, 2)
        $epsilon = $gamma -bxor ([convert]::ToInt32(('1' * $gammaString.Length), 2))
        Write-Output ($gamma * $epsilon)
    }
}


function Measure-LifeSupport {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]
        $Data
    )
    
    process {
        $oxyRatings = New-Object system.collections.generic.list[string]
        $co2Ratings = New-Object system.collections.generic.list[string]
        $Data | Foreach-Object {
            $oxyRatings.Add($_)
            $co2Ratings.Add($_)
        }

        while ($oxyRatings.Count -gt 1) {
            for ($col = 0; $col -lt $oxyRatings[0].Length; $col++) {
                $mostCommonBits = Get-DataColumns -Data $oxyRatings | Foreach-Object {
                    Get-MostCommonCharacter -Data $_ -TieBreaker '1'
                }
                for ($row = $oxyRatings.Count - 1; $row -ge 0; $row--) {
                    if ($oxyRatings[$row][$col] -ne $mostCommonBits[$col]) {
                        $oxyRatings.RemoveAt($row)
                    }
                }   
            }
        }

        while ($co2Ratings.Count -gt 1) {
            for ($col = 0; $col -lt $co2Ratings[0].Length; $col++) {
                $mostCommonBits = Get-DataColumns -Data $co2Ratings | Foreach-Object {
                    Get-LeastCommonCharacter -Data $_ -TieBreaker '0'
                }
                for ($row = $co2Ratings.Count - 1; $row -ge 0; $row--) {
                    if ($co2Ratings[$row][$col] -ne $mostCommonBits[$col]) {
                        $co2Ratings.RemoveAt($row)
                    }
                }   
            }
        }

        $result = [convert]::ToInt32($oxyRatings[0], 2) * [convert]::ToInt32($co2Ratings[0], 2)
        Write-Output $result
    }
}

$data = Get-Content -Path "$PSScriptRoot/data/day03.txt"
$testData = Get-Content -Path "$PSScriptRoot/data/day03-sample.txt"

$answer1Test = Measure-PowerConsumption -Data $testData
$answer1 = Measure-PowerConsumption -Data $data
$answer2Test = Measure-LifeSupport -Data $testData
$answer2 = Measure-LifeSupport -Data $data

[pscustomobject]@{
    'Day'         = 3
    'Part 1 Test' = $answer1Test
    'Part 1'      = $answer1
    'Part 2 Test' = $answer2Test
    'Part 2'      = $answer2
}
