param(
    [string]$OutputPath = (Join-Path $PSScriptRoot "..\assets\mock-clinical-data.csv")
)

$random = [System.Random]::new(20260630)
function Normal([double]$Mean, [double]$Sd) {
    $u1 = [Math]::Max($random.NextDouble(), 1e-12)
    $u2 = $random.NextDouble()
    $Mean + $Sd * [Math]::Sqrt(-2 * [Math]::Log($u1)) * [Math]::Cos(2 * [Math]::PI * $u2)
}
function Clamp([double]$Value, [double]$Min, [double]$Max) {
    [Math]::Min([Math]::Max($Value, $Min), $Max)
}
function RoundValue([double]$Value, [int]$Digits = 1) {
    [Math]::Round($Value, $Digits)
}

$rows = for ($i = 1; $i -le 100; $i++) {
    $sex = if ($random.NextDouble() -lt 0.5) { "Female" } else { "Male" }
    $male = if ($sex -eq "Male") { 1 } else { 0 }
    $age = $random.Next(20, 83)
    $bmi = Clamp (Normal (23.5 + 0.035 * ($age - 45)) 3.2) 16.5 36.5
    $hgb = Clamp (Normal (128 + 18 * $male - 0.12 * ($age - 50)) 10) 95 175
    $neut = Clamp (Normal (58 + 0.08 * ($age - 50)) 8) 38 82
    $alt = Clamp ([Math]::Exp((Normal ([Math]::Log(20 + 0.35 * ($bmi - 22) + 3 * $male)) 0.42))) 6 110
    $alb = Clamp (Normal (44 - 0.035 * ($age - 50)) 2.6) 35 51
    $tc = Clamp (Normal (4.55 + 0.012 * ($age - 45) + 0.035 * ($bmi - 23)) 0.7) 2.7 7.2
    $tg = Clamp ([Math]::Exp((Normal ([Math]::Log([Math]::Max(0.5, 1.25 + 0.055 * ($bmi - 22)))) 0.42))) 0.35 4.8
    $hdl = Clamp (Normal (1.42 - 0.17 * $male - 0.018 * ($bmi - 23)) 0.25) 0.65 2.25

    [ordered]@{
        ID = "P{0:D3}" -f $i
        Sex = $sex
        Age = $age
        BMI = RoundValue $bmi
        WBC = RoundValue (Clamp (Normal (6.2 + 0.015 * ($age - 50)) 1.35) 3.1 12.8)
        RBC = RoundValue (Clamp (Normal (4.35 + 0.42 * $male - 0.003 * ($age - 50)) 0.35) 3.3 5.9) 2
        HGB = RoundValue $hgb 0
        HCT = RoundValue (Clamp ($hgb * 0.30 + (Normal 0 1.5)) 29 53)
        PLT = RoundValue (Clamp (Normal (235 - 0.25 * ($age - 50)) 48) 110 410) 0
        NEUT = RoundValue $neut
        LYMPH = RoundValue (Clamp (88 - $neut + (Normal 0 3.2)) 12 48)
        ALT = RoundValue $alt 0
        AST = RoundValue (Clamp ($alt * 0.65 + (Normal 10 5)) 8 95) 0
        ALP = RoundValue (Clamp (Normal (72 + 0.18 * ($age - 50)) 18) 35 145) 0
        GGT = RoundValue (Clamp ([Math]::Exp((Normal ([Math]::Log([Math]::Max(3, 20 + 7 * $male + 0.4 * ($bmi - 22)))) 0.48))) 5 150) 0
        TBIL = RoundValue (Clamp (Normal (12.5 + 1.2 * $male) 4) 4 28)
        ALB = RoundValue $alb
        TP = RoundValue (Clamp ($alb + (Normal 27 2.5)) 58 84)
        GLU = RoundValue (Clamp (Normal (5.05 + 0.018 * ($age - 45) + 0.055 * ($bmi - 23)) 0.62) 3.7 8.8) 2
        TC = RoundValue $tc 2
        TG = RoundValue $tg 2
        HDL = RoundValue $hdl 2
        LDL = RoundValue (Clamp ($tc - $hdl - $tg / 2.2 + (Normal 0 0.12)) 1.0 5.2) 2
        CREA = RoundValue (Clamp (Normal (63 + 15 * $male + 0.20 * ($age - 45)) 11) 38 125) 0
        UREA = RoundValue (Clamp (Normal (4.8 + 0.025 * ($age - 45)) 1.05) 2.4 8.9) 2
        UA = RoundValue (Clamp (Normal (275 + 75 * $male + 1.2 * ($bmi - 23)) 55) 150 520) 0
        CRP = RoundValue (Clamp ([Math]::Exp((Normal ([Math]::Log([Math]::Max(0.2, 1.4 + 0.035 * ($age - 40) + 0.05 * ($bmi - 22)))) 0.72))) 0.1 18) 2
    }
}

$rows | ForEach-Object { [pscustomobject]$_ } |
    Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding UTF8

Write-Output "Wrote 100 rows and 27 columns to $OutputPath"
