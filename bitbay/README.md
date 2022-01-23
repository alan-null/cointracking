# Account history converted for Zonda (BitBay)

This is converted for [**Zonda (BitBay)**](https://zondaglobal.com/en/home) exchange.

## Specification

- `INPUT`: **csv** exported from [**Zonda (BitBay)**](https://zondaglobal.com/en/home)

- `OUTPUT`: **csv** file compatible with [**cointracking**](https://cointracking.info/)

## Erors

### CSV structure

Error message

```powershell
[ERROR]2021-11-19 16:45:14 [1]
[ERROR]2021-11-19 16:45:15 [2]
```

Review your csv and manually update it.

Entries should be grouped by dates.

Standard **Trade** group consists of 3 entries (buy, sell, fee) - they should share the same date and time - so script can process them correctly.

It's unlike that operations of single trade will during different time but if it happens group them accordingly.

Example:

```csv
"2021-10-12 01:00:48";"Pobranie prowizji za transakcję";"-0,27";"PLN";"100,71";"0,00";"100,71"
"2021-10-12 01:00:48";"Otrzymanie środków z transakcji na rachunek";"89,03";"PLN";"100,98";"0,00";"100,98"
"2021-10-12 01:00:48";"Pobranie środków z transakcji z rachunku";"-22,597287";"USDT";"0,00";"0,00";"0,00"
```

### Encoding

Error message

```powershell
[ERROR]2021-11-19 17:24:50 [1]
[ERROR]2021-11-19 17:17:07 [1]
You cannot call a method on a null-valued expression.
At C:\repo\cointracking\bitbay\convert.ps1:6 char:5
```

Encoding **UTF-8** is required.

You can check your console encoding with this:

```powershell
([console]::InputEncoding , [console]::OutputEncoding).EncodingName
```

See [this](https://stackoverflow.com/a/57134096/6149877) article.

If you will run this script directly from VSCode problems shouldn't occur.