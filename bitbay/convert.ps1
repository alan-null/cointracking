Clear-Host
$inputFileName = "$PSScriptRoot\bitbay-test.csv"
$outputFileName = "$PSScriptRoot\bitbay-next.csv"

function Convert-Number($no) {
    $no.Replace(",", ".").Replace("-", [string]::Empty)
}

function Convert-Transaction($group) {
    $sell = $group | ? { $_.Rodzaj -eq "Pobranie środków z transakcji z rachunku" } | Select-Object -First 1
    $buy = $group | ? { $_.Rodzaj -eq "Otrzymanie środków z transakcji na rachunek" } | Select-Object -First 1
    $fee = $group | ? { $_.Rodzaj -eq "Pobranie prowizji za transakcję" } | Select-Object -First 1

    $obj = New-CsvObject
    $obj.Type = "Trade"
    $obj.Buy = Convert-Number $buy."Wartość"
    $obj.CurB = $buy.Waluta
    $obj.Sell = Convert-Number $sell."Wartość"
    $obj.CurS = $sell.Waluta
    $obj.Fee = Convert-Number $fee."Wartość"
    $obj.CurF = $fee.Waluta
    $obj.Date = $buy."Data operacji"
    $obj
}

function New-CsvObject {
    [ordered] @{
        "Type"     = [string]::Empty
        "Buy"      = [string]::Empty
        "CurB"     = [string]::Empty
        "Sell"     = [string]::Empty
        "CurS"     = [string]::Empty
        "Fee"      = [string]::Empty
        "CurF"     = [string]::Empty
        "Exchange" = "BitBay"
        "Group"    = [string]::Empty
        "Comment"  = [string]::Empty
        "Date"     = [string]::Empty
    }
}

Import-Csv $inputFileName  -Delimiter ';' | `
    ? { $_.Rodzaj -ne "Utworzenie rachunku" } | `
    ? { $_.Rodzaj -ne "Anulowanie oferty poniżej wartości minimalnych" } | `
    ? { $_.Rodzaj -ne "Blokada środków" } | `
    Group-Object -Property "Data operacji" | % {
    $_ | % {
        if ($_.Count % 3 -eq 0) {
            for ($i = 0; $i -lt $_.Count; $i += 3) {
                $z = $_.Group | Select-Object -First 3 -Skip $i
                Convert-Transaction $z
            }
        }
        elseif ($_.Count -eq 1) {
            $operation = $_.Group
            $obj = New-CsvObject
            $obj.Date = $operation."Data operacji"
            if ($operation.Rodzaj -eq "Wpłata na rachunek") {
                $obj."Type" = "Deposit"
                $obj."Buy" = Convert-Number $operation."Wartość"
                $obj."CurB" = $operation.Waluta
            }
            elseif ($operation.Rodzaj -eq "Wypłata środków") {
                $obj."Type" = "Withdrawal"
                $obj."Sell" = Convert-Number $operation."Wartość"
                $obj."CurS" = $operation.Waluta
            }
            else {
                Write-Host "[ERROR]$($_.Name) [$($_.Count)]" -f red
            }
            $obj
        }
        else {
            Write-Host "[ERROR]$($_.Name) [$($_.Count)]" -f red
        }
    }
} | Export-Csv -Delimiter ',' -Path $outputFileName

$content = [System.IO.File]::ReadAllText($outputFileName)
$content = $content.Replace("CurB", "Cur.").Replace("CurS", "Cur.").Replace("CurF", "Cur.").Trim()
[System.IO.File]::WriteAllText($outputFileName, $content)