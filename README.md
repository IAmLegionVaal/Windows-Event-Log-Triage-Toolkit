# Windows Event Log Triage Toolkit

A read-only PowerShell toolkit for L1/L2 Windows event log triage.

## Features

- System and Application error summary
- Critical event summary
- Top event IDs and providers
- Time-window filtering
- Optional keyword filtering
- CSV, JSON, and HTML reports

## How to run

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Windows_Event_Log_Triage_Toolkit.ps1
```

Check the last 72 hours:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Windows_Event_Log_Triage_Toolkit.ps1 -Hours 72
```

## Safety

Diagnostic-only. It reads event logs and creates report exports.

## Suggested topics

```text
powershell
windows
eventlog
helpdesk
it-support
troubleshooting
sysadmin
```
