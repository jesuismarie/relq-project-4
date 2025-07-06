$date = Get-Date -Format "yyyy-MM-dd"

$logPath = "C:\Logs"
if (-not (Test-Path -Path $logPath)) {
	New-Item -Path $logPath -ItemType Directory | Out-Null
}

Get-ComputerInfo | Out-File -FilePath "C:\Logs\systemdata_$date.txt"
