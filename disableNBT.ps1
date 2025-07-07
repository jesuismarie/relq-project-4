$adapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled }

foreach ($adapter in $adapters) {
	$adapter.SetTcpipNetbios(2)  # 0=Default, 1=Enable, 2=Disable
}

