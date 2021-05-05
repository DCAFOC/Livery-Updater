Write-Output "`n*** Welcome to DCAF's Livery Updater ***`n`n"




while ($firstOption -ne "1" -and $firstOption -ne "2" -and $firstOption -ne "3") {
    #Write menu and prompt user for option
    Write-Output "Please select an option"
    Write-Output "1 = New Install  |  2 = Update an Existing Install  |  3 = Remove an Existing Install"
    $firstOption = Read-Host -Prompt "Option"

    #Determine if the option was valid
    if ($firstOption -ne "1" -and $firstOption -ne "2" -and $firstOption -ne "3") {
        Write-Warning "The option you selected is not valid, please type one number from the menu and press 'Enter' `n`n"
    }
}

#Initialize folder browser dialog
Add-Type -AssemblyName System.Windows.Forms
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog

#Create New-Install function
function New-Install {
    Write-Output "Please select a location to install the liveries..."
    $folderBrowser.ShowDialog()

    #Test if the user pressed "Cancel"
    #Create empty Liveries Folder in root folder or user selected folder
    if ($folderBrowser.SelectedPath -eq "") {
        Write-Output "No directory selected, please rerun the updater and select a directory to install the liveries...exiting"
    } elseif (Test-Path -Path $folderBrowser.SelectedPath) {
        $newFolder = $folderBrowser.SelectedPath, "DCAF Liveries" -join "\"
        New-Item -Path $folderBrowser.SelectedPath -Name "DCAF Liveries" -ItemType "Directory"

        #Clone the github repository
        ./Git/bin/git clone --progress https://github.com/DCAFOC/Liveries $newFolder

        #Write out liveries path for later use by update or removal
        if (-not (Test-Path -Path .\LiveryPath.cfg)) {
            $newFolder | Out-File -FilePath .\LiveryPath.cfg
        }
        Get-Content -Path .\LiveryPath.cfg
    }
}

#Option 1: New Install
if ($firstOption -eq "1") {
    Remove-Item -Path .\LiveryPath.cfg -ErrorAction SilentlyContinue
    New-Install
}

#Option 2: Update Existing Install
if ($firstOption -eq "2") {
    #Check if the path listed in liverypath.cfg is valid or if liverypath.cfg exists
    if (Test-Path -Path .\LiveryPath.cfg) {

        #Prompt user to determine whether if the existing directory in liverypath.cfg is what they want to update
        while ($m2Option -ne "y" -and $m2Option -ne "n") {
            
            Write-Output "Is this the existing livery directory that you wish to update?"
            Get-Content -Path .\LiveryPath.cfg
            Write-Output "y = Yes  |  n = No"
            $m2Option = Read-Host -Prompt ":"

            #Determine if the option was valid
            if ($m2Option -ne "y" -and $m2Option -ne "n") {
                Write-Warning "The option you selected is not valid, please type either 'y' or 'n' and press 'Enter' `n`n"
            }
        }

        #New install if the existing liverypath.cfg IS NOT correct
        if ($m2Option -eq "n") {
            Write-Output "Please select the existing liveries folder..."
            $folderBrowser.ShowDialog()
            
            #User did not locate the directory
            if ($folderBrowser.SelectedPath -eq "") {
                Write-Output "Livery container folder was not located...exiting"
            
            #User located the directory
            } elseif (Test-Path -Path $folderBrowser.SelectedPath) {
                
                Remove-Item -Path .\LiveryPath.cfg -ErrorAction SilentlyContinue
                ./Git/bin/git -C $folderBrowser.SelectedPath pull --progress
                $folderBrowser.SelectedPath | Out-File -FilePath .\LiveryPath.cfg
            }

        #Git Pull if the existing liverypath.cfg IS correct
        } elseif ($m2Option -eq "y") {
            $liveryPath = Get-Content -Path .\LiveryPath.cfg
            ./Git/bin/git -C $liveryPath pull --progress
        }

    #LiveryCfg path was not valid
    } else {
        while ($m21Option -ne "y" -and $m21Option -ne "n") {
            
            Write-Output "The existing livery directory could not be found, would you like to locate it manually?"
            Write-Output "y = Yes  |  n = No"
            $m21Option = Read-Host -Prompt ":"

            #Determine if the option was valid
            if ($m21Option -ne "y" -and $m21Option -ne "n") {
                Write-Warning "The option you selected is not valid, please type either 'y' or 'n' and press 'Enter' `n`n"
            }
        }

        #User manually locates the directory
        if ($m21Option -eq "y") {
            Write-Output "Please select the existing liveries folder..."
            $folderBrowser.ShowDialog()
            
            #User did not locate the directory
            if ($folderBrowser.SelectedPath -eq "") {
                Write-Output "Livery container folder was not located...exiting"
            
            #User located the directory
            } elseif (Test-Path -Path $folderBrowser.SelectedPath) {
                
                Remove-Item -Path .\LiveryPath.cfg -ErrorAction SilentlyContinue
                ./Git/bin/git -C $folderBrowser.SelectedPath pull --progress
                $folderBrowser.SelectedPath | Out-File -FilePath .\LiveryPath.cfg
            }
        #User does not want to manually locate the directory
        } elseif ($m21Option -eq "n") {
            Write-Output "If you would like to install a new livery folder, please rerun the updater...exiting"
        }
    }
}

#Remove the stored livery folder
if ($firstOption -eq "3") {
    if (Test-Path -Path .\LiveryPath.cfg) {
        $liveryPath = Get-Content -Path .\LiveryPath.cfg
        if (Test-Path -Path $liveryPath) {
            Remove-Item -Path $liveryPath -Confirm -Force -Recurse
        } else {
            Write-Warning "Livery folder could not be located...exiting"
        }
    } else {
        Write-Warning "Livery folder could not be located...exiting"
    }  
}

Pause