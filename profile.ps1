###############################################################################
# Profile PS1 based on this samples:
# http://stackoverflow.com/questions/138144/whats-in-your-powershell-profile-ps1file
# http://www.tavaresstudios.com/Blog/post/The-last-vsvars32ps1-Ill-ever-need.aspx
# Place this file in: C:\Users\ACCNAME\Documents\WindowsPowerShell\profile.ps1
# https://gist.github.com/thoemmi/3720721
###############################################################################
# red background if running elevated
###############################################################################

& {
 $wid=[System.Security.Principal.WindowsIdentity]::GetCurrent()
 $prp=new-object System.Security.Principal.WindowsPrincipal($wid)
 $adm=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 $IsAdmin=$prp.IsInRole($adm)
 if ($IsAdmin)
 {
  (get-host).UI.RawUI.Backgroundcolor="DarkRed"
  clear-host
 }
}

###############################################################################
# Exposes the environment vars in a batch and sets them in this PS session
###############################################################################
function Get-Batchfile($file) 
{
    $theCmd = "`"$file`" & set" 
    cmd /c $theCmd | Foreach-Object {
        $thePath, $theValue = $_.split('=')
        Set-Item -path env:$thePath -value $theValue
    }
}


###############################################################################
# Sets the VS variables for this PS session to use (for VS 2013)
###############################################################################
function VsVars32($version = "12.0")
{
	# 64bit Key in Registry
    $theKey = "HKLM:SOFTWARE\Wow6432Node\Microsoft\VisualStudio\" + $version
    $theVsKey = get-ItemProperty $theKey
    $theVsInstallPath = [System.IO.Path]::GetDirectoryName($theVsKey.InstallDir)
    $theVsToolsDir = [System.IO.Path]::GetDirectoryName($theVsInstallPath)
    $theVsToolsDir = [System.IO.Path]::Combine($theVsToolsDir, "Tools")
    $theBatchFile = [System.IO.Path]::Combine($theVsToolsDir, "vsvars32.bat")
    Get-Batchfile $theBatchFile
    [System.Console]::Title = "Visual Studio " + $version + " Windows Powershell"
	
	Write-Host "[Profile.ps1] Visual Studio 2013 CMD Commands set" -Foreground Green
}

function SetupPowershellHistory() {
	$profileFolder = split-path $profile
	 
	# save last 100 history items on exit
	$historyPath = Join-Path $profileFolder history.clixml
	 
	# hook powershell's exiting event & hide the registration with -supportevent.
	Register-EngineEvent -SourceIdentifier powershell.exiting -SupportEvent -Action {
		Get-History -Count 100 | Export-Clixml (Join-Path (split-path $profile) history.clixml) }
	 
	# load previous history, if it exists
	if ((Test-Path $historyPath)) {
		Import-Clixml $historyPath | ? {$count++;$true} | Add-History
		Write-Host "[Profile.ps1] Loaded $count history item(s)" -Foreground Green
	}
}

###############################################################################
# Execute
###############################################################################
Write-Host "[Custom Profile.ps1 invoked]"

# VS
VsVars32

# History
SetupPowershellHistory

Write-Host "[Custom Profile.ps1 finished]"