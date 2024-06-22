﻿function New-PasswordConfigurationExternalUsers {
    <#
    .SYNOPSIS
    This function caches users from external systems to be used in the password configuration.

    .DESCRIPTION
    This function caches users from external systems to be used in the password configuration.
    It provides ability to find user by some property and get another property of the user.

    .PARAMETER Users
    Parameter description

    .PARAMETER ActiveDirectoryProperty
    Property in Active Directory to search for when comparing against SearchProperty.

    .PARAMETER SearchProperty
    Property to cache on the user object.

    .PARAMETER EmailProperty
    How the email property is called in the user object.

    .PARAMETER Global
    Tells the solution to globally overwrite email addresses for all users.

    .EXAMPLE
    New-PasswordConfigurationExternalUsers -Users $ExportDataFromHrSystem -SearchProperty '<property in the HR system>' -EmailProperty '<email property in HR system>' -ActiveDirectoryProperty 'SamAccountName'

    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory)][Array] $Users,
        [parameter(Mandatory)][string] $ActiveDirectoryProperty,
        [parameter(Mandatory)][string] $SearchProperty,
        [parameter(Mandatory)][string] $EmailProperty,
        [switch] $Global
    )

    $CachedUsers = [ordered] @{}
    try {
        foreach ($User in $Users) {
            $CachedUsers[$User.$SearchProperty] = $User | Select-Object -Property $EmailProperty
        }
    } catch {
        Write-Color -Text '[-] ', "Couldn't cache users. Please fix 'New-PasswordConfigurationExternalUsers'. Error: ", "$($_.Exception.Message)" -Color Yellow, White, Red
        return
    }
    [ordered] @{
        Type                    = 'ExternalUsers'
        ActiveDirectoryProperty = $ActiveDirectoryProperty
        SearchProperty          = $SearchProperty
        EmailProperty           = $EmailProperty
        Users                   = $CachedUsers
        Global                  = $Global.IsPresent
    }
}