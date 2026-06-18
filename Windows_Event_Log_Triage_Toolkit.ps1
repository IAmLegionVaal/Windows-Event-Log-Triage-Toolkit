#requires -Version 5.1
<#
.SYNOPSIS
    Windows Event Log Triage Toolkit.
.DESCRIPTION
    Read-only event log triage script for Windows helpdesk support.
#>
[CmdletBinding()]
param([int]$Hours = 48,[string]$Keyword,[string]$OutputPath)

$RunStamp = Get-Date -Format 'yyyyMMdd_HHmmss'
if ([string]::IsNullOrWhiteSpace($OutputPath)) { $OutputPath = Join-Path ([Environment]::GetFolderPath('Desktop')) 'Event_Log_Triage_Reports' }
New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
$Start = (Get-Date).AddHours(-1 * $Hours)
function Export-Data { param($Name,$Data) $Data | Export-Csv (Join-Path $OutputPath "$Name.csv") -NoTypeInformation -Encoding UTF8; $Data | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $OutputPath "$Name.json") -Encoding UTF8 }

$all = @()
foreach($log in @('System','Application')){
    $events = Get-WinEvent -FilterHashtable @{LogName=$log;Level=1,2,3;StartTime=$Start} -ErrorAction SilentlyContinue
    if($Keyword){ $events = $events | Where-Object { $_.Message -match [regex]::Escape($Keyword) -or $_.ProviderName -match [regex]::Escape($Keyword) } }
    $rows = $events | Select-Object @{n='LogName';e={$log}},TimeCreated,Id,ProviderName,LevelDisplayName,Message
    $all += $rows
    Export-Data -Name "$($log)_events_$RunStamp" -Data $rows
}
$topIds = $all | Group-Object LogName,Id | Sort-Object Count -Descending | Select-Object Count,Name
$topProviders = $all | Group-Object ProviderName | Sort-Object Count -Descending | Select-Object Count,Name
Export-Data -Name "top_event_ids_$RunStamp" -Data $topIds
Export-Data -Name "top_event_providers_$RunStamp" -Data $topProviders
$html = "<h1>Windows Event Log Triage - $env:COMPUTERNAME</h1><p>Generated $(Get-Date). Window: last $Hours hours.</p><h2>Top Event IDs</h2>$($topIds | ConvertTo-Html -Fragment)<h2>Top Providers</h2>$($topProviders | ConvertTo-Html -Fragment)<h2>Recent Events</h2>$($all | Select-Object -First 100 | ConvertTo-Html -Fragment)"
$html | ConvertTo-Html -Title 'Event Log Triage' | Set-Content (Join-Path $OutputPath "event_log_triage_$RunStamp.html") -Encoding UTF8
$topIds | Format-Table -AutoSize
Write-Host "Reports saved to: $OutputPath" -ForegroundColor Green
Start-Process explorer.exe -ArgumentList "`"$OutputPath`"" -ErrorAction SilentlyContinue
