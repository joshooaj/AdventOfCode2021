function ConvertTo-DivePlan {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript({
            if (-not $_ -match 'up|down|forward \d+') {
                throw 'DivePlan text must be in the format "up|down|forward \d+"'
            }
            return $true
        })]
        [string[]]
        $Text
    )
    
    process {
        foreach ($s in $Text) {
            $direction, [int]$units = $s -split ' ';
            [pscustomobject]@{
                Direction = $direction
                Units = $units
            }
        }
    }
}
function Get-AoCDay2Q1Answer {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [pscustomobject[]]
        $DivePlan 
    )
    
    begin {
        $x = $depth = 0
    }
    
    process {
        foreach ($step in $DivePlan) {
            switch ($step.Direction) {
                'forward' { $x += $step.Units }
                'down' { $depth += $step.Units}
                'up' { $depth -= $step.Units }
            }
        }
    }
    
    end {
        [PSCustomObject]@{
            Distance = $x
            Depth = $depth
            Product = $x * $depth
        }
    }
}

function Get-AoCDay2Q2Answer {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [pscustomobject[]]
        $DivePlan 
    )
    
    begin {
        $x = $depth = $aim = 0
    }
    
    process {
        foreach ($step in $DivePlan) {
            switch ($step.Direction) {
                'forward' { 
                    $x += $step.Units
                    $depth += ($aim * $step.Units)
                }
                'down' { $aim += $step.Units}
                'up' { $aim -= $step.Units }
            }
        }
    }
    
    end {
        [PSCustomObject]@{
            Distance = $x
            Depth = $depth
            Product = $x * $depth
        }
    }
}


$data = Get-Content -Path $PSScriptRoot/day02.txt | ConvertTo-DivePlan
$data | Get-AoCDay2Q1Answer
$data | Get-AoCDay2Q2Answer
