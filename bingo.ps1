class BingoCard {
    [int[][]] $Grid
    [int[][]] $Marks
    [int] $LastCall = -1

    BingoCard([int[][]]$grid) {
        $this.Grid = $grid
        $this.Marks = [int[][]]::new($grid.Count, $grid[0].Count)
    }

    [int] GetWinningRound([int[]]$calls) {
        $winningRound = -1
        $quit = $false
        for ($round = 0; $round -lt $calls.Count; $round++) {
            for ($row = 0; $row -lt $this.Grid.Count; $row++) {
                for ($col = 0; $col -lt $this.Grid[$row].Count; $col++) {
                    $this.LastCall = $calls[$round]
                    if ($this.Grid[$row][$col] -eq $calls[$round]) {
                        $this.Marks[$row][$col] = 1
                        if ($this.IsWinner($row, $col)) {
                            $winningRound = $round
                            $quit = $true
                            break
                        }
                    }
                }
                if ($quit) {
                    break
                }
            }
            if ($quit) {
                break
            }
        }
        return $winningRound
    }

    [bool] IsWinner([int]$row, [int]$col) {
        if ($this.Marks[$row] -notcontains 0) {
            return $true
        } else {
            $result = $true
            for ($r = 0; $r -lt $this.Marks.Count; $r++) {
                if (-not $this.Marks[$r][$col]) {
                    $result = $false
                }
            }
            return $result
        }
    }

    [int] GetScore() {
        $sum = 0
        for ($row = 0; $row -lt $this.Grid.Count; $row++) {
            for ($col = 0; $col -lt $this.Grid[$row].Count; $col++) {
                if (-not $this.Marks[$row][$col]) {
                    $sum += $this.Grid[$row][$col]
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
            throw [exception]::new("Ran out of numbers")
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


$results = @()
$game = Import-BingoGame -path .\data\day04.txt
$i = 0
foreach ($card in $game.Cards) {
    $round = $card.GetWinningRound($game.Calls)
    $result = [pscustomobject]@{
        Card = $i
        Round = $round
        Score = $card.GetScore()
    }
    $results += $result
    $i++
}

$results | Sort-Object Round -Descending