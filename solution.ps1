function Get-AoCDay1Q1Answer {
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [int[]]
        $Measurement
    )

    begin {
        $countOfIncreasedValues = 0
        $lastValue = $null
    }

    process {
        if ($null -eq $lastValue) {
            $lastValue = $Measurement[0]
        } else {
            foreach ($value in $Measurement) {
                if ($value -gt $lastValue) {
                    $countOfIncreasedValues++
                }
                $lastValue = $value
            }
        }
    }

    end {
        Write-Output $countOfIncreasedValues
    }
}

function Get-AoCDay1Q2Answer {
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [int[]]
        $Measurement,
        
        [Parameter()]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $WindowSize = 3
    )

    begin {
        $queue = [system.collections.generic.queue[int]]::new()
        $windowSums = New-Object system.collections.generic.list[int]
    }

    process {
        foreach ($value in $Measurement) {
            $queue.Enqueue($value)
            if ($queue.Count -lt $WindowSize) {
                continue
            }
            while ($queue.Count -gt $WindowSize) {
                $null = $queue.Dequeue()
            }
            $sumOfWindow = $queue | Measure-Object -Sum | Select-Object -ExpandProperty Sum
            $windowSums.Add($sumOfWindow)
        }
    }

    end {
        Write-Output ($windowSums | Get-AoCDay1Q1Answer)
    }
}

$day1Data = Get-Content -Path "$PSScriptRoot/day01.txt"
$answer1 = $day1Data | Get-AoCDay1Q1Answer
$answer2 = $day1Data | Get-AoCDay1Q2Answer
[pscustomobject]@{
    'Day'    = 1
    'Part 1' = $answer1
    'Part 2' = $answer2
}