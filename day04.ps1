return
class BingoCard {
    [int[][]]$Numbers
    [int[][]]$Marks
    [int] $LastCall = -1
    [string] $Result = ''

    BingoCard([int[][]]$Numbers) {
        $this.Numbers = $Numbers
        $this.Marks = [int[][]]::new($this.Numbers.Count, $this.Numbers[0].Count)
    }

    [void] Reset() {
        $this.LastCall = -1
        $this.Result = ''
        for ($row = 0; $row -lt $this.Marks.Count; $row++) {
            for ($col = 0; $col -lt $this.Marks[$row].Count; $col++) {
                $this.Marks[$row][$col] = 0
            }
        }
    }

    [bool] InPlay() {
        $inPlay = $false
        for ($row = 0; $row -lt $this.Numbers.Count; $row++) {
            for ($col = 0; $col -lt $this.Numbers[$row].Count; $col++) {
                if (-not $this.Marks[$row][$col]) {
                    $inPlay = $true
                }
            }
        }
        if (-not [string]::IsNullOrWhiteSpace($this.Result)) {
            $inPlay = $false
        }        
        return $inPlay
    }

    [bool] Call([int]$Call) {
        $won = -1
        for ($row = 0; $row -lt $this.Numbers.Count; $row++) {
            for ($col = 0; $col -lt $this.Numbers[$row].Count; $col++) {
                if (-not $this.Marks[$row][$col] -and $this.Numbers[$row][$col] -eq $Call) {
                    $this.Marks[$row][$col] = 1
                    $won = $this.CheckCard($row, $col)
                    if ($won -gt -1) {
                        $this.LastCall = $Call
                        switch ($won) {
                            0 { $this.Result = "Row $row" }
                            1 { $this.Result = "Column $col"}
                        }
                    }
                    break
                }
            }
            if ($won -gt -1) { break }
        }
        return ($won -gt -1)
    }

    [int] CheckCard($row, $col) {
        # -1 = no win
        #  0 = row
        #  1 = column
        if ($this.Marks[$row] -notcontains 0) {
            return 0
        }
        for ($r = 0; $r -lt $this.Marks.Count; $r++) {
            if (-not $this.Marks[$r][$col]) {
                return -1
            }
        }
        return 1
    }

    [int] GetScore() {
        if ([string]::IsNullOrWhiteSpace($this.Result)) {
            throw "Not a winner"
        }
        $sum = 0
        for ($row = 0; $row -lt $this.Numbers.Count; $row++) {
            for ($col = 0; $col -lt $this.Numbers[$row].Count; $col++) {
                if (-not $this.Marks[$row][$col]) {
                    $sum += $this.Numbers[$row][$col]
                }
            }
        }
        return ($this.LastCall * $sum)
    }
}

class BingoResult {
    [int] $WinningCard
    [int] $Score
    [int] $WonRound
    [int] $WinningCall
    [string] $Description
    [BingoCard] $Card
}
class BingoGame {
    [int] $call = 0
    [System.Collections.Generic.List[int]] $CompletedCards = (New-Object System.Collections.Generic.List[int])
    [int[]] $Calls
    [BingoCard[]] $Cards
    [BingoResult] $LastResult

    [System.Collections.Generic.List[BingoResult]] $Results = (New-Object System.Collections.Generic.List[BingoResult])
    
    BingoGame ([int[]]$Calls, [BingoCard[]]$Cards) {
        $this.Calls = $Calls
        $this.Cards = $Cards
    }

    [bool] CanProceed() {
        $canProceed = ($this.Call -lt $this.Calls.Count)
        return $canProceed
    }

    [bool] HasActiveCards() {
        return $true
        #[bool]$hasActive = $false
        #0..($this.Cards.Count - 1) | Foreach-Object {
        #    if ($_ -notin $this.CompletedCards) {
        #        if ($this.Cards[$_].InPlay()) {
        #            $hasActive = $true
        #        }
        #    }
        #}
        #return $hasActive
    }

    [BingoResult] CallNext() {
        if ($this.Call -ge ($this.Calls.Count)) {
            #throw [exception]::new("Ran out of numbers")
        }
        $number = $this.Calls[$this.call++]
        for ($i = 0; $i -lt $this.Cards.Count; $i++) {
            if ($i -in $this.CompletedCards) {
                continue
            }
            $card = $this.Cards[$i]
            if ($card.Call($number)) {
                $this.CompletedCards.Add($i)
                $this.LastResult = $this.GetResult($i)
                $this.Results.Add($this.LastResult)
                #$this.Cards | Foreach-Object { $_.Reset() }
                return $this.LastResult
            }
        }
        return [BingoResult]::new()
    }

    hidden [BingoResult] GetResult([int]$cardNumber) {
        $card = $this.Cards[$cardNumber]
        $result = [BingoResult]@{
            WinningCard = $cardNumber
            Score = $card.GetScore()
            WonRound = $this.Call
            WinningCall = $this.Calls[$this.call]
            Description = $card.Result
            Card = $card
        }
        return $result
    }
}

function Import-BingoGame {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Path
    )
    
    process {
        $content = Get-Content -Path $Path
        $bingoCalls = [int[]]($content[0] -split ',' | Where-Object { ![string]::IsNullOrWhiteSpace($_) })
        $newBingoCards = New-Object System.Collections.Generic.List[BingoCard]
        $bingoCards = New-Object System.Collections.Generic.List[[System.Collections.Generic.List[int[]]]]]]
        $bingoCards.Add((New-Object System.Collections.Generic.List[int[]]]))
        $card = 0
        for ($line = 2; $line -lt $content.Count; $line++) {
            if ([string]::IsNullOrWhiteSpace($content[$line])) {
                $newBingoCards.Add([BingoCard]::new($bingoCards[$card]))
                $bingoCards.Add((New-Object System.Collections.Generic.List[int[]]]))
                $card++
                continue
            }
            $bingoCards[$card].Add([int[]]($content[$line] -split '\s+' | Where-Object { ![string]::IsNullOrWhiteSpace($_)} | Foreach-Object { $_.Trim() } ))            
            if ($line -eq $content.Count - 1) {
                $newBingoCards.Add([BingoCard]::new($bingoCards[$card]))
            }
        }
        $bingoGame = [BingoGame]::new($bingoCalls, $newBingoCards)
        $bingoGame
    }
}


$game1 = Import-BingoGame -Path "$PSScriptRoot/data/day04-sample.txt" # | ConvertTo-Json -Depth 5
do {
} until ($game1.CallNext().Score -gt 0) {}

$game2 = Import-BingoGame -Path "$PSScriptRoot/data/day04.txt" # | ConvertTo-Json -Depth 5
do {
} until ($game2.CallNext().Score -gt 0) {}

[pscustomobject]@{
    'Day'         = 4
    'Part 1 Test' = $game1.LastResult.Score
    'Part 1'      = $game2.LastResult.Score
    'Part 2 Test' = $game3.LastResult.Score
    'Part 2'      = 0
}