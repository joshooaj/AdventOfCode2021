Get-ChildItem .\day*.ps1 | Foreach-Object {
    & $_.FullName
} | Format-Table
