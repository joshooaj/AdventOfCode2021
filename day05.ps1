return
class AoCPoint {
    [int] $X
    [int] $Y

    AoCPoint([int]$x, [int]$y) {
        $this.X = $x
        $this.Y = $y
    }
}
class AoCLine {
    [AoCPoint] $PointA
    [AoCPoint] $PointB

    AoCLine([AocPoint]$pointA, [AocPoint]$pointB) {
        $points = $pointA, $pointB | Sort-Object { $_.X }
        $this.PointA = $points[0]
        $this.PointB = $points[1]
    }

    [double] GetSlope() {
        $run =  $this.PointB.X - $this.PointA.X
        $rise = $this.PointB.Y - $this.PointA.Y
        if ($run -eq 0) {
            return [double]::NaN
        } else {
            $slope = $rise / $run
            return ($slope)
        }
    }
}

class AoCGrid {
    [int[][]] $Grid

    AoCGrid([int]$width, [int]$height) {
        $this.Grid = [int[][]]::new($width, $height)
    }

    [void] Plot([AoCLine[]]$Lines) {
        $z = 0
        foreach ($line in $Lines) {
            $slope = $line.GetSlope()
            Write-Information "$z - $slope"
            $z++
            if ([double]::IsNaN($slope)) {
                #Write-Information "Horizontal"
                $x = $line.PointA.X
                $start, $end = $line.PointA.Y, $line.PointB.Y | Sort-Object
                for ($y = $start; $y -le $end; $y++) {
                    $this.Grid[$y][$x]++
                }
            } elseif ($slope -eq 0) {
                #Write-Information "Vertical"
                $y = $line.PointA.Y
                $start, $end = $line.PointA.X, $line.PointB.X | Sort-Object
                for ($x = $start; $x -le $end; $x++) {
                    $this.Grid[$y][$x]++
                }
            } else {
                #Write-Information ($line | ConvertTo-Json)
                #Write-Information $slope
                $x = $line.PointA.X
                $y = $line.PointA.Y
                do {
                    #Write-Information "Plotting $x, $y"
                    $this.Grid[$y][$x]++
                    $x++
                    $y += $slope
                } until ($x -eq $line.PointB.X)
                #Write-Information "Plotting $x, $y"
                $this.Grid[$y][$x]++
            }
            #Write-Host ("`r`n`r`n" + $this.ToString())
        }
    }

    [string] ToString() {
        $sb = [text.stringbuilder]::new()
        $this.Grid | Foreach-Object {
            $null = $sb.AppendLine(([string]::Join(' ', $_)))
        }
        return $sb.ToString()
    }
}
function Import-AoCLines {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Path,

        [Parameter()]
        [switch]
        $AllowDiagonals
    )
    
    process {
        foreach ($line in Get-Content -Path $Path) {
            if ($line -match '(?<x1>[+\-]?\d+),(?<y1>[+\-]?\d+)\s+\-\>\s+(?<x2>[+\-]?\d+),(?<y2>[+\-]?\d+)') {
                $pointA = [AoCPoint]::new($Matches.x1, $Matches.y1)
                $pointB = [AoCPoint]::new($Matches.x2, $Matches.y2)
                $newLine = [AoCLine]::new($pointA, $pointB)
                $slope = $newLine.GetSlope()
                if ($slope -eq 0 -or [double]::isnan($slope) -or ($AllowDiagonals -and [math]::abs($slope) -eq 1)) {
                    Write-Output $newLine
                }
            }
        }
    }
}
$InformationPreference = 'SilentlyContinue'
$sampleLines = Import-AoCLines -Path "$PSScriptRoot/data/day05.txt" -AllowDiagonals

$maxX = $sampleLines.PointA + $sampleLines.PointB | Sort-Object X -Descending | Select-Object -First 1 -ExpandProperty X
$maxY = $sampleLines.PointA + $sampleLines.PointB | Sort-Object Y -Descending | Select-Object -First 1 -ExpandProperty Y

$grid = [AoCGrid]::new(1000, 1000)
$grid.Plot($sampleLines)
$hotSpots = 0
for ($x = 0; $x -lt $grid.Grid.Count; $x++) {
    for ($y = 0; $y -lt $grid.Grid[$x].Count; $y++) {
        if ($grid.Grid[$x][$y] -gt 1) {
            $hotSpots++
        }
    }
}


