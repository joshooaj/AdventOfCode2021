class SchoolOfLanternFish {
    [System.Collections.Generic.List[double]] $Fish
    [hashtable] $FishTimers = @{}
    SchoolOfLanternFish([double[]]$Fish) {
        $this.Fish = [System.Collections.Generic.List[double]]::new()
        foreach ($f in $Fish) {
            $this.Fish.Add($f)
        }
        0..8 | ForEach-Object { $this.FishTimers[$_.ToString()] = [double]0 }
        $Fish | Foreach-Object { $this.FishTimers[$_.ToString()] += 1 }
    }

    [void] AddDays([int]$days) {
        for ($day = 0; $day -lt $days; $day++) {
            Write-Information ('Day {0}: {1}' -f $day, ([string]::join(',', $this.Fish)))
            $fishCount = $this.Fish.Count
            for ($i = 0; $i -lt $fishCount; $i++) {
                $this.Fish[$i] = $this.Fish[$i] - 1
                if ($this.Fish[$i] -lt 0) {
                    $this.Fish[$i] = 6
                    $this.Fish.Add(8)
                }
            }
        }
    }


    [void] AddDays2([int]$days) {
        $x = @{}
        for ($day = 0; $day -lt $days; $day++) {
            0..8 | ForEach-Object { $x[$_.ToString()] = $this.FishTimers[$_.ToString()] }
            for ($i = 7; $i -ge 0; $i--) {
                $this.FishTimers[$i.ToString()] = $x[($i + 1).ToString()]
            }
            $this.FishTimers['6'] += $x['0']
            $this.FishTimers['8'] = $x['0']
        }
    }
}

$testData = (Get-Content -Path "$PSScriptRoot/data/day06-sample.txt") -split ','
$school = [SchoolOfLanternFish]::new($testData)
$school.AddDays2(80)
$p1Test = $school.FishTimers.Values | Measure-Object -Sum | Select-Object -ExpandProperty Sum

$data = (Get-Content -Path "$PSScriptRoot/data/day06.txt") -split ','
$school = [SchoolOfLanternFish]::new($data)
$school.AddDays2(80)
$p1 = $school.FishTimers.Values | Measure-Object -Sum | Select-Object -ExpandProperty Sum

$testData = (Get-Content -Path "$PSScriptRoot/data/day06-sample.txt") -split ','
$school = [SchoolOfLanternFish]::new($testData)
$school.AddDays2(256)
$p2Test = $school.FishTimers.Values | Measure-Object -Sum | Select-Object -ExpandProperty Sum


$data = (Get-Content -Path "$PSScriptRoot/data/day06.txt") -split ','
$school = [SchoolOfLanternFish]::new($data)
$school.AddDays2(256)
$p2 = $school.FishTimers.Values | Measure-Object -Sum | Select-Object -ExpandProperty Sum

[pscustomobject]@{
    'Day'    = 6
    'Part 1 Test' = $p1Test
    'Part 1' = $p1
    'Part 2 Test' = $p2Test
    'Part 2' = $p2
}
