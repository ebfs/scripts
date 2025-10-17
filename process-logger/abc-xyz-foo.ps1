# last edited by Elias Bergroth @ 17/10/2025 19:54

param(
    [int]$Interval = 30,
    [int]$Duration = 3600,
    [string]$OutputFile = "C:\Program Files\process_log.csv"
)

$Iterations = [math]::Floor($Duration / $Interval)
$processCatalog = @{}


Write-Host "Welcome!"
Write-Host "This is a nifty little program to see what programs appear most often in the background."
Write-Host "The program runs for an hour and will log results every 30 seconds."
Write-Host "For a more accurate measurement, consider 24 hours."
Write-Host "in the abc-xyz-foo.ps1 file, change parameter on line 5:"
Write-Host "from 3600 to 3600*24"
Write-Host "I hope this program serves its little purpose."
Write-Host "---"
Write-Host "Last version update from Elias Bergroth on 17/10/2025"
Write-Host "---"
Write-Host "Monitor info:"
Write-Host "Sample every $Interval seconds for $($Duration / 60) minutes"
Write-Host "Output file: $OutputFile"

# look at log
if (Test-Path $OutputFile) {
    Write-Host "Overwriting existing log at $OutputFile"
    $existingData = Import-Csv -Path $OutputFile
    foreach ($row in $existingData) {
        $processCatalog[$row.ProcessName] = [PSCustomObject]@{
            Count     = [int]$row.Appearances
            TotalCPU  = [double]$row.AvgCPU * [int]$row.Appearances
            TotalMem  = [double]$row.AvgMemoryMB * [int]$row.Appearances
        }
    }
}

# the shmeat
for ($i = 0; $i -lt $Iterations; $i++) {
    $snapshot = Get-Process | Select-Object Name, CPU,
        @{Name='MemoryMB'; Expression = { "{0:N2}" -f ($_.WorkingSet64 / 1MB) }}

    foreach ($proc in $snapshot) {
        if (-not $processCatalog.ContainsKey($proc.Name)) {
            $processCatalog[$proc.Name] = [PSCustomObject]@{
                Count    = 0
                TotalCPU = 0
                TotalMem = 0
            }
        }
        $entry = $processCatalog[$proc.Name]
        $entry.Count++
        $entry.TotalCPU += [double]($proc.CPU)
        $entry.TotalMem += [double]($proc.MemoryMB)
    }

    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Snapshot $($i + 1)/$Iterations"
    Start-Sleep -Seconds $Interval
}

# results go here
$results = foreach ($name in $processCatalog.Keys) {
    $entry = $processCatalog[$name]
    [PSCustomObject]@{
        ProcessName  = $name
        Appearances  = $entry.Count
        AvgCPU       = [Math]::Round($entry.TotalCPU / $entry.Count, 2)
        AvgMemoryMB  = [Math]::Round($entry.TotalMem / $entry.Count, 2)
    }
}

$results | Sort-Object -Property Appearances -Ascending |
    Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8

Write-Host "`n[Done] Output saved to $OutputFile"