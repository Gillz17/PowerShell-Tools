#Zach McGill
#10/27/2021
#Sets the default printer in registry to work with ProLaw

# Clear any existing errors.
#
"Waiting for printers to be created"
Start-Sleep 3

#$error.clear()
$registrykey = "Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows"

# Set the location
Set-Location -Path $registrykey -ErrorAction SilentlyContinue

# Retrieve the default printer properties.
$wmiDefaultPrinter = Get-WmiObject -query "SELECT * FROM WIN32_PRINTER WHERE Default = TRUE"

# If the default printer exists then set the registry values.
if ($wmiDefaultPrinter -ne $null)
{
	"Setting the Windows default printer registry key"
	Set-ItemProperty -Path $registrykey -Name "Device" -Value ($wmiDefaultPrinter.Name+",winspool,Ne00:")
	Write-Host "Your default printer is" $wmiDefaultPrinter.Name
} else {
	Set-ItemProperty -Path $registrykey -Name "Device" -Value "Microsoft Print to PDF,winspool,Ne01:"
}