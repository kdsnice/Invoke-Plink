<#
    .SYNOPSIS
    Executes a PuTTY PLink.exe SSH command using either a password or a key file.
    This is a sample that shows how to integrate with PuTTY for basic commands. You will need to extend for your specific needs.


	.DESCRIPTION
	This module has a dependency on PLink.exe available in the PuttyFiles folder. You can download this file from http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html 
	and place this in the PuttyFiles folder. You can then zip up the SSH folder and import this into System Center R2 - Orchestrator Service Management Automation.

#>
function Invoke-Plink{
    [CmdletBinding(DefaultParameterSetName='UseAgentAuthentication')]
    param(
        [Parameter(Position=0, Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]
        $HostName,

        [Parameter(Position=1, Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]
        $SSHCommand,
        
        [Parameter(Position=2, Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]
        $UserName,

        [Parameter(Position=3, Mandatory=$False)]
        [Switch]
        $AcceptHostKey,

        [Parameter(ParameterSetName='UsePasswordAuthentication',Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Password,

        [Parameter(ParameterSetName='UseKeyAuthentication', Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]
        $KeyFilePath,

        [Parameter(ParameterSetName='UseAgentAuthentication', Mandatory=$True, HelpMessage="Set either UseAgent switch, or specify Password, or specify KeyFilePath")]
        [ValidateNotNullOrEmpty()]
        [Switch]
        $UseAgent,        
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [int] $Port
    )

    # Get the path to the PLink.exe tool withing the module folder. The PLink.exe should be placed in the PuttyFiles folder.
    # You can download the tool from http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    $CMDLetPath = Split-Path $Invocation.MyCommand.Path
	$PLINK = $CMDLetPath + "\PuttyFiles\Plink.exe"

    if (!(Test-Path $PLINK)) 
    { 
	    Throw  "Plink.exe is not available in the PuttyFiles folder within the module. Please download from http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html"
    }

    # If Accept host is true then automatically accept the host key.
    # It is recommended that you do not use this setting because it can cause a runbook to accept any change in a server, 
    # including any that are for malicious purposes. By selecting this option, you are instructing the activity to connect to any server, 
    # regardless of the host key. Only use this option for testing purposes.
	if ($AcceptHostKey)
	{
        # Inovke-Expression doesn't work well with spaces in the path so copying the file to a temp directory and then removing afterwards 
        $FileGuid = [guid]::NewGuid()
        $Result = New-Item -ItemType Directory $env:SystemDrive\$FileGuid
        $Result = Copy-Item $PLINK $env:SystemDrive\$FileGuid
        $Result = Invoke-Expression "cmd.exe /c echo y | $env:SystemDrive\$FileGuid\Plink.exe $HostName -P $Port" 2>&1
        $Result = Remove-Item $env:SystemDrive\$FileGuid -Recurse -Force
 	}

    # Create temp file to capture any errors produced by plink.exe since these don't come through in SMA currently.
    $Guid = [guid]::NewGuid()
    $Result = New-Item -ItemType Directory $env:SystemDrive\"Invoke-Plink-Logs"
    $TempErrorDir = $env:SystemDrive + "\Invoke-Plink-Logs"
    $TempErrorFile = $TempErrorDir + "\$guid"

    # If a password is set then run the command using the provided password
 	if ($Password)
	{
        $args = $HostName, "-l", $UserName, "-pw", $Password, "-P", $Port, "-batch", $SSHCommand;
        & $PLINK $args 2> $TempErrorFile 
	}
    # If a key file is set then run the command using the provided key file. All Key files should be placed in the KeyFiles folder and
    # must not have a passphrase protecting them. Ensure that access to the runbook workers is restricted to protect these files.
  	elseif ($KeyFilePath)
	{
        if (Test-Path $KeyFilePath) {
            $args = $HostName, "-l", $UserName, "-i", $KeyFilePath, "-P", $Port, "-batch", $SSHCommand;
            & $PLINK $args 2> $TempErrorFile
        }
        else { Throw "Key File not found" }
	}
    #If UseAgentAuthentication
    elseif ($UseAgent)
    {
        $args = $HostName, "-l", $UserName, "-agent", "-P", $Port, "-batch", $SSHCommand;
        & $PLINK $args 2> $TempErrorFile 
    }
 
    # Check if any errors were produced and send these back as an exception
    if (Test-Path $TempErrorFile) { 
        $Err = Get-Content -Path $TempErrorFile; 
        $Result = Remove-Item $TempErrorDir -Recurse -Force; 
        If ($Err -ne $null){ Throw $Err}
    }
 
}

Export-ModuleMember Invoke-Plink