# Define the required folders
$reportingFolder = "$PSScriptRoot\Reporting"
$logsFolder = "$PSScriptRoot\Logs"

# Function to create a folder if it doesn't exist
function Ensure-FolderExists {
    param (
        [string]$FolderPath
    )
    if (-not (Test-Path -Path $FolderPath)) {
        try {
            New-Item -Path $FolderPath -ItemType Directory -Force | Out-Null
            Write-Verbose "Created folder: $FolderPath"
        } catch {
            Write-Error "Failed to create folder: $FolderPath. Error: $_"
            throw
        }
    } else {
        Write-Verbose "Folder already exists: $FolderPath"
    }
}

# Ensure the necessary folders exist
Ensure-FolderExists -FolderPath $reportingFolder
Ensure-FolderExists -FolderPath $logsFolder

# Predefined month list in multiple languages
$Months = @(
    # english
    "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
    # german
    "Januar", "Februar", "M�rz", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"
    # french
    'Janvier', 'Fevrier', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Aout', 'Septembre', 'Octobre', 'Novembre', 'Decembre'
    # danish
    'Januar', 'Februar', 'Marts', 'April', 'Maj', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'December'
    # norwegian
    'Januar', 'Februar', 'Mars', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Desember'
    # swedish
    'Januari', 'Februari', 'Mars', 'April', 'Maj', 'Juni', 'Juli', 'Augusti', 'September', 'Oktober', 'November', 'December'
) | Sort-Object -Unique

# Custom word list
$CustomWords = @("CompanyXYZ")  # Replace with your custom words

# Common word list
$CommonWords = @("Test","Qwerty","Qwert","Qwer","Password","Passw0rd","Pa`$`$word","Pa`$`$w0rd","Pa`$`$W0rd","P@ssword","P@ssw0rd","Welcome","Start","End","Velkommen","Farvel","Vinter",[Regex]::Unescape("For\u00e5r"),"Foraar","Sommer",[Regex]::Unescape("Efter\u00e5r"),"Efteraar","Mandag","Tirsdag","Onsdag","Torsdag","Fredag",[Regex]::Unescape("L\u00f8rdag"),"Loerdag",[Regex]::Unescape("S\u00f8ndag"),"Soendag","Welcome","Goodbye","Winter","Spring","Summer","Autumn","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")

# Combined word list (months + custom words)
$CombinedWords = $Months + $CustomWords + $CommonWords

# Other variables
$Numbers = 0..9
$Years = 2020..2024
$SpecialChar = @("!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "_", "-", "+", "=", "[", "]", "{", "}", "|", "\")

# Generate passwords
$Passwords = foreach ($Year in $Years) {
    $YearPasswords = foreach ($word in $CombinedWords) {
        foreach ($number in $Numbers) {
            foreach ($special in $SpecialChar) {
                $word + $Year.ToString() + $number.ToString() + $special
                $Year.ToString() + $word + $number.ToString() + $special
                $word + $Year.ToString() + $special
            }
        }
    }
    $YearPasswords
}

# Output the count of generated passwords
#$Passwords.Count

# Now that the folders are ensured, define the hashtable for Show-PasswordQuality
$showPasswordQualitySplat = @{
    FilePath                = "$reportingFolder\PasswordQuality_$(Get-Date -f yyyy-MM-dd_HHmmss).html"
    WeakPasswords           = $Passwords | ForEach-Object { $_ }
    SeparateDuplicateGroups = $true
    PassThru                = $true
    AddWorldMap             = $false
    LogPath                 = "$logsFolder\PasswordQuality_$(Get-Date -f yyyy-MM-dd_HHmmss).log"
    Online                  = $true
    LogMaximum              = 5
}

# Execute the Show-PasswordQuality function with the specified parameters
Show-PasswordQuality @showPasswordQualitySplat -Verbose
