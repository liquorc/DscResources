data LocalizedData
{
	# culture="en-US"
	ConvertFrom-StringData -StringData @'
        VerboseNoxHiiWebBinding			 = Please ensure that WebAdministration is installed.
		VerboseAddingWebBinding 		 = Adding WebBinding {0}.
		VerboseRemovingWebBinding		 = Removing WebBinding {0}.
		VerboseTestTargetResource		 = Get-TargetResource has been run.
		VerboseGetTargetAbsent			 = WebBinding is absent.
		VerboseGetTargetPresent			 = WebBinding is present.
		VerboseSetTargetError			 = Cannot add web binding.
		BindingNotPresent				 = Binding does not exist on the current website.
		BindingUnknown					 = Binding has an error or is unknown.
'@
}

function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$Name,
		[Parameter(Mandatory = $false)]
		[string]$Protocol,
		[Parameter(Mandatory = $false)]
		[string]$Port,
		[Parameter(Mandatory = $true)]
		[string]$IPAddress,
		[Parameter(Mandatory = $true)]
		[string]$HostHeader,
		[Parameter(Mandatory = $false)]
		[ValidateSet('0', '1', '2', '3')]
		[string]$SslFlags
	)
	
	$Ensure = 'Absent'
	
	$params = @{
		Name = $Name
		Protocol = $Protocol
		Port = $Port
		IPAddress = $IPAddress
		HostHeader = $HostHeader
	}
	
	$WebBindingCheck = Get-WebBinding @params
	
	if ($null -eq $WebBindingCheck)
	{
		Write-Verbose -Message $LocalizedData.VerboseGetTargetAbsent
		return @{
			Ensure = 'Absent'
			Name = $null
			Protocol = $null
			Port = $null
			IPAddress = $null
			HostHeader = $null
		}
	}
	
	else
	{
		Write-Verbose -Message $LocalizedData.VerboseGetTargetPresent
		return = @{
			Name = $Name
			Protocol = $Protocol
			Port = $Port
			IPAddress = $IPAddress
			HostHeader = $HostHeader
			Ensure = $Ensure
		}
	}
}


function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$Name,
		[Parameter(Mandatory = $false)]
		[string]$Protocol = 'http',
		[Parameter(Mandatory = $false)]
		[string]$Port = '80',
		[Parameter(Mandatory = $true)]
		[string]$IPAddress,
		[Parameter(Mandatory = $true)]
		[string]$HostHeader,
		[Parameter(Mandatory = $false)]
		[ValidateSet('0', '1', '2', '3')]
		[string]$SslFlags,
		[Parameter(Mandatory = $true)]
		[ValidateSet('Present', 'Absent')]
		[string]$Ensure
	)
	
	$params = @{
		Name = $Name
		Protocol = $Protocol
		Port = $Port
		IPAddress = $IPAddress
		HostHeader = $HostHeader
		SslFlags = $SslFlags
	}
	
	$WebBindingCheck = Get-WebBinding -Name $Name -Protocol $Protocol -Port $Port -IPAddress $IPAddress -HostHeader $HostHeader
	
	if ($WebBindingCheck -eq $null -and $Ensure -eq 'Present')
	{
		New-WebBinding @params
		Write-Verbose -Message ($LocalizedData.VerboseAddingWebBinding -f $HostHeader)
	}
	
	elseif ($WebBindingCheck -ne $null -and $Ensure -eq 'Absent')
	{
		Remove-WebBinding -Name $Name -Protocol $Protocol -Port $Port -IPAddress $IPAddress -HostHeader $HostHeader
		Write-Verbose -Message ($LocalizedData.VerboseRemovingWebBinding -f $Name, $Protocol, $Port, $IPAddress, $HostHeader)
	}
	
	else
	{
		Write-Verbose -Message $LocalizedData.VerboseGetTargetPresent
	}
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
		[string]$Name,
		[Parameter(Mandatory = $false)]
		[string]$Protocol = 'http',
		[Parameter(Mandatory = $false)]
		[string]$Port = '80',
		[Parameter(Mandatory = $true)]
		[string]$IPAddress,
		[Parameter(Mandatory = $true)]
		[string]$HostHeader,
		[Parameter(Mandatory = $false)]
		[ValidateSet('0', '1', '2', '3')]
		[string]$SslFlags,
		[Parameter(Mandatory = $true)]
		[ValidateSet('Present', 'Absent')]
		[string]$Ensure
    )
	
	$params = @{
		Name = $Name
		Protocol = $Protocol
		Port = $Port
		IPAddress = $IPAddress
		HostHeader = $HostHeader
	}
	
	$WebBindingCheck = Get-WebBinding @params
	
	if (($null -ne $WebBindingCheck -and $Ensure -eq 'Present') -or ($null -ne $WebBindingCheck -and $Ensure -eq 'Absent'))
	{
		$DesiredConfigurationMatch = $false;
	}
	
	elseif ($null -eq $WebBindingCheck -and $Ensure -eq 'Absent')
	{
		$DesiredConfigurationMatch = $false;
	}
	
	else
	{
		$DesiredConfigurationMatch = $false;
	}
	return $DesiredConfigurationMatch
}


Export-ModuleMember -Function *-TargetResource

