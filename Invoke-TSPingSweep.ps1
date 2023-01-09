<#
    -------------------------- EXAMPLE 1 --------------------------
   C:\PS> Invoke-PingSweep -Subnet 192.168.1.0 -Start 1 -End 254 -Count 2 -Source Multiple
   This command starts a ping sweep from 192.168.1.1 through 192.168.1.254. It sends two pings to each address. It sends each ping from a random source address.


   -------------------------- EXAMPLE 2 --------------------------
  C:\PS> Invoke-PingSweep -Subnet 192.168.1.0 -Start 192 -End 224 -Source Singular
  This command starts a ping sweep from 192.168.1.192 through 192.168.1.224. It sends one ping to each address. It sends each ping from one source address that is different from the local IP addresses.


  -------------------------- EXAMPLE 3 --------------------------
 C:\PS> Invoke-PingSweep -Subnet 192.168.1.0 -Start 64 -End 192
 This command starts a ping sweep from 192.168.1.64 through 192.168.1.192. It sends one ping to each address. It sends each ping from the local computers IPv4 address.
#>
Function Invoke-PingSweep
{
    [CmdletBinding()]
        param(
            [Parameter(
                Mandatory=$True,
                Position=0,
                HelpMessage="Enter an IPv4 subnet ending in 0. Example: 10.0.9.0")]
            [ValidatePattern("\d{1,3}\.\d{1,3}\.\d{1,3}\.0")]
            [string]$Subnet,

            [Parameter(
                Mandatory=$True,
                Position=1,
                HelpMessage="Enter the start IP of the range you want to scan.")]
            [ValidateRange(1,255)]
            [int]$Start = 1,

            [Parameter(
                Mandatory=$True,
                Position=2,
                HelpMessage="Enter the end IP of the range you want to scan.")]
            [ValidateRange(1,255)]
            [int]$End = 254,

            [Parameter(
                Mandatory=$False,
                Position=3)]
            [ValidateRange(1,10)]
            [int]$Count = 1,

            [Parameter(
                Mandatory=$False,
                Position=4)]
            [ValidateSet("Singular","Multiple")]
            [string]$Source
        ) # End param

        [array]$LocalIPAddress = Get-NetIPAddress -AddressFamily "IPv4" | Where-Object { ($_.InterfaceAlias -notmatch "Bluetooth|Loopback") -and ($_.IPAddress -notlike "169.254.*") }  | Select-Object -Property "IPAddress"
        [string]$ClassC = $Subnet.Split(".")[0..2] -Join "."
        [array]$Results = @()
        [int]$Timeout = 500

        Write-Host "The below IP Addressess are currently active." -ForegroundColor "Green"

        For ($i = 0; $i -le $End; $i++)
        {

            [string]$IP = "$ClassC.$i"

            # When Windows PowerShell is executing the command and source value is not defined
            If (($PsVersionTable.PSEdition -ne 'Core') -and ($Source -like $Null) -and ($IP -notlike $LocalIPAddress))
            {

                $Filter = 'Address="{0}" and Timeout={1}' -f $IP, $Timeout

                If ((Get-WmiObject "Win32_PingStatus" -Filter $Filter).StatusCode -eq 0)
                {

                    Write-Host $IP -ForegroundColor "Yellow"

                } # End If

            } # End If
            # When Core or Windows PowerShell is running or source is defined
            ElseIf (($PsVersionTable.PSEdition -eq 'Core') -or ($Source -ne $Null) -and ($IP -notlike $LocalIPAddress))
            {

                If ($Source -like 'Singular')
                {

                    $SourceIP = "$ClassC." + ($End - 1)

                    # Uncomment the below line if you wish to see the source address the ping is coming from
                    # Write-Host "Sending Ping from $SourceIP to $IP"

                    Try
                    {

                        Test-Connection -BufferSize 16 -ComputerName $IP -Count $Count -Source $SourceIP -Quiet

                    }  # End Try
                    Catch
                    {

                        Write-Host "Source routing may not be allowed on your device. Use ipconfig /all and check that Ip Routing Enabled is set to a value of YES. Otherwise this option will not work." -ForegroundColor 'Red'

                    }  # End Catch
                } # End If
                ElseIf ($Source -like 'Multiple')
                {

                    For ($x = ($Start - 1); $x -le ($End - $Start); $x++)
                    {

                        $SourceIP = "$ClassC.$x"

                        # Uncomment the below line if you wish to see the source ip the ping is being sent from 
                        # Write-Host "Sending ping from $SourceIP to $IP"

                        Try
                        {

                            Test-Connection -BufferSize 16 -ComputerName $IP -Count $Count -Source $SourceIP -Quiet

                        }  # End Try
                        Catch
                        {

                            Write-Host "Source routing may not be allowed on your device. Use ipconfig /all and check that Ip Routing Enabled is set to a value of YES. Otherwise this option will not work." -ForegroundColor 'Red'

                        }  # End Catch

                    } # End For

                } # End ElseIf

            }  # End ElseIf
            # When Core is running and source is not defined
            ElseIf (($PsVersionTable.PSEdition -eq 'Core') -and ($Source -eq $Null) -and ($IP -notlike $LocalIPAddress))
            {

                If (Test-Connection -BufferSize 16 -ComputerName $IP -Count $Count -Quiet)
                {

                    Write-Host $IP -ForegroundColor 'Yellow'

                }  # End If

            }  # End ElseIf

        } # End For

} # End Function Invoke-PingSweep