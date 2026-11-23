#Requires -Version 5.0

<#
.SYNOPSIS
    Optimized Python versions cache updater for pyenv-win (Windows 11 compatible)
.DESCRIPTION
    This script checks for existing cache and only updates with new versions, making updates much faster.
    Also fixes architecture detection issues.
.PARAMETER Ignore
    Ignores any HTTP errors that occur during downloads
.PARAMETER Force
    Forces a complete rebuild of the cache (ignores existing cache)
.PARAMETER Help
    Shows help information
#>

param(
    [switch]$Ignore,
    [switch]$Force,
    [switch]$Help
)

if ($Help) {
    Write-Host "Usage: pyenv-update-optimized.ps1 [-Ignore] [-Force] [-Help]"
    Write-Host ""
    Write-Host "  -Ignore   Ignores any HTTP errors that occur during downloads."
    Write-Host "  -Force    Forces a complete rebuild (ignores existing cache)."
    Write-Host "  -Help     Shows this help message."
    Write-Host ""
    Write-Host "Optimized update that only adds new Python versions to existing cache."
    exit 0
}

# Import required modules
Add-Type -AssemblyName System.Web

# Configuration
$mirrors = @(
    "https://www.python.org/ftp/python/",
    "https://downloads.python.org/pypy/versions.json",
    "https://api.github.com/repos/oracle/graalpython/releases"
)

$cacheFile = Join-Path $PSScriptRoot "..\.versions_cache.xml"
# Note: pyenv only reads from .versions_cache.xml, share/pyenv-win/versions.xml is optional/legacy

# Regex patterns
$regexVer = [regex]'(\d+)\.(\d+)(?:\.(\d+))?'
$regexFile = [regex]'python-(\d+)\.(\d+)(?:\.(\d+))?(?:([a-z]+)(\d+))?(?:-(amd64|win32|arm64))?(?:-(web)installer)?\.(.+)'

Write-Host ":: [Info] :: Starting optimized Python version cache update..." -ForegroundColor Green

function Get-WebContent {
    param(
        [string]$Url,
        [bool]$IgnoreErrors = $false
    )
    
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -ErrorAction Stop
        return $response.Content
    }
    catch {
        $errorMsg = "HTTP Error downloading from $Url : $($_.Exception.Message)"
        Write-Host "   -> $errorMsg" -ForegroundColor Red
        if (-not $IgnoreErrors) {
            exit 1
        }
        return $null
    }
}

function Parse-ExistingCache {
    param([string]$CacheFilePath)
    
    $existingVersions = @{}
    
    if (-not (Test-Path $CacheFilePath)) {
        Write-Host "   -> No existing cache found, will create new one" -ForegroundColor Yellow
        return $existingVersions
    }
    
    try {
        Write-Host "   -> Parsing existing cache..." -ForegroundColor Cyan
        [xml]$xml = Get-Content $CacheFilePath -Raw
        
        foreach ($version in $xml.versions.version) {
            $key = $version.file
            $existingVersions[$key] = @{
                code = $version.code
                file = $version.file
                url = $version.URL
                x64 = $version.x64
                webInstall = $version.webInstall
                msi = $version.msi
            }
        }
        
        Write-Host "   -> Found $($existingVersions.Count) existing versions in cache" -ForegroundColor Green
    }
    catch {
        Write-Host "   -> Error parsing existing cache: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "   -> Will rebuild cache from scratch" -ForegroundColor Yellow
        return @{}
    }
    
    return $existingVersions
}

function Get-VersionCode {
    param(
        [string]$Major,
        [string]$Minor,
        [string]$Patch,
        [string]$Release,
        [string]$RelNum,
        [string]$Arch
    )
    
    $code = "$Major.$Minor"
    if ($Patch) { $code += ".$Patch" }
    if ($Release -and $RelNum) { $code += "$Release$RelNum" }
    elseif ($Release) { $code += $Release }
    
    # Add architecture suffix - be more specific about architecture handling
    if ($Arch -eq "win32") {
        $code += "-win32"
    }
    # For amd64, we don't add suffix (it's the default x64)
    # For arm64, we add suffix
    elseif ($Arch -eq "arm64") {
        $code += "-arm64"
    }
    # If no architecture specified and we want to mark as win32
    elseif (-not $Arch) {
        # Default behavior - we'll determine this based on the filename analysis
    }
    
    return $code
}

function Parse-PythonInstaller {
    param(
        [string]$FileName,
        [string]$Url
    )
    
    # Check if filename matches installer pattern
    $fileMatch = $regexFile.Match($FileName)
    if (-not $fileMatch.Success) {
        return $null
    }
    
    # Extract version components
    $major = $fileMatch.Groups[1].Value
    $minor = $fileMatch.Groups[2].Value
    $patch = $fileMatch.Groups[3].Value
    $release = $fileMatch.Groups[4].Value
    $relnum = $fileMatch.Groups[5].Value
    $arch = $fileMatch.Groups[6].Value
    $webInstall = $fileMatch.Groups[7].Value
    $ext = $fileMatch.Groups[8].Value
    
    # Skip non-installer files (signatures, checksums, etc.)
    if ($ext -match '\.(asc|sig|crt|sigstore|spdx\.json)$') {
        return $null
    }
    
    # Skip non-Windows files
    if ($FileName -match '\.(dmg|pkg|tgz|tar\.gz)$') {
        return $null
    }
    
    # Skip test and embed packages for main installers (keep only .exe and .msi)
    if ($ext -notmatch '^(exe|msi|zip)$') {
        return $null
    }
    
    # For .zip files, only keep specific types
    if ($ext -eq "zip" -and $FileName -notmatch '(embeddable|embed|win32|amd64|arm64)\.zip$') {
        return $null
    }
    
    # Determine architecture more precisely
    $detectedArch = $arch
    if (-not $detectedArch) {
        if ($FileName -match 'amd64') {
            $detectedArch = "amd64"
        } elseif ($FileName -match 'arm64') {
            $detectedArch = "arm64"
        } elseif ($FileName -match 'win32') {
            $detectedArch = "win32"
        } else {
            # Default for .exe without arch suffix is usually win32
            $detectedArch = if ($ext -eq "exe") { "win32" } else { "" }
        }
    }
    
    # Determine attributes
    $x64 = if ($detectedArch -eq "amd64") { "true" } else { "false" }
    $isWebInstall = if ($webInstall -eq "web") { "true" } else { "false" }
    $isMsi = if ($ext -eq "msi") { "true" } else { "false" }
    
    # Build version code
    $code = Get-VersionCode -Major $major -Minor $minor -Patch $patch -Release $release -RelNum $relnum -Arch $detectedArch
    
    return @{
        file = $FileName
        url = $Url
        code = $code
        x64 = $x64
        webInstall = $isWebInstall
        msi = $isMsi
        major = $major
        minor = $minor
        sortKey = "$major.$minor.$($patch -replace '^$','0')"
    }
}

function Scan-PythonVersions {
    param(
        [string]$BaseUrl,
        [hashtable]$ExistingVersions,
        [bool]$IgnoreErrors
    )
    
    $newVersions = @{}
    $checkedCount = 0
    
    Write-Host "`r   -> Downloading Python.org index...                                                          " -NoNewline -ForegroundColor Yellow
    $content = Get-WebContent -Url $BaseUrl -IgnoreErrors $IgnoreErrors
    if (-not $content) { 
        Write-Host "`r   -> Failed to download Python.org index                                                      " -ForegroundColor Red
        return $newVersions 
    }
    Write-Host "`r   -> Downloaded Python.org index, parsing versions...                                           " -NoNewline -ForegroundColor Green
    
    # Extract version links from HTML
    $linkPattern = @'
<a\s+[^>]*href\s*=\s*["']([^"']+)["'][^>]*>([^<>]+)</a>
'@
    $matches = [regex]::Matches($content, $linkPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    
    $versionDirs = @()
    foreach ($match in $matches) {
        $href = $match.Groups[1].Value
        $linkText = $match.Groups[2].Value.Trim()
        
        # Skip parent directory links
        if ($linkText -eq "../" -or $linkText -eq "..") { continue }
        
        # Clean version name
        $versionName = $linkText.TrimEnd('/')
        
        # Check if it matches version pattern
        $versionMatch = $regexVer.Match($versionName)
        if ($versionMatch.Success) {
            $major = [int]$versionMatch.Groups[1].Value
            $minor = [int]$versionMatch.Groups[2].Value
            
            # Only process Python >= 2.4
            if ($major -gt 2 -or ($major -eq 2 -and $minor -ge 4)) {
                $versionDirs += @{
                    name = $versionName
                    href = if ($href.StartsWith("http")) { $href } else { $BaseUrl.TrimEnd('/') + '/' + $href.TrimStart('./') }
                    major = $major
                    minor = $minor
                }
            }
        }
    }
    
    # Sort versions and process newest first (to detect new versions faster)
    $versionDirs = $versionDirs | Sort-Object { [version]"$($_.major).$($_.minor).0" } -Descending
    
    foreach ($versionDir in $versionDirs) {
        $checkedCount++
        $percentComplete = [int](($checkedCount / $versionDirs.Count) * 100)
        $progressBar = "=" * [int](($percentComplete / 100) * 30)
        $progressBar = $progressBar.PadRight(30, " ")
        
        # Update same line with progress
        Write-Host "`r     -> [$progressBar] $percentComplete% | Checking Python $($versionDir.name) [$checkedCount/$($versionDirs.Count)]..." -NoNewline -ForegroundColor Cyan
        
        # Quick check: if we already have several files from this version, it might be complete
        $existingFromThisVersion = $ExistingVersions.Keys | Where-Object { $_ -match "python-$($versionDir.name)" }
        
        $subContent = Get-WebContent -Url $versionDir.href -IgnoreErrors $IgnoreErrors
        if (-not $subContent) {
            Write-Host "`r     -> [$progressBar] $percentComplete% | Python $($versionDir.name): FAILED                                     " -NoNewline -ForegroundColor Red
            continue
        }
        
        $subMatches = [regex]::Matches($subContent, $linkPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        $versionNewCount = 0
        $versionExistingCount = 0
        
        foreach ($subMatch in $subMatches) {
            $subHref = $subMatch.Groups[1].Value
            $fileName = $subMatch.Groups[2].Value.Trim()
            
            # Skip directories and non-files
            if ($fileName.EndsWith('/') -or $fileName -eq "../" -or $fileName -eq "..") { continue }
            
            # Build full URL
            $fullUrl = if ($subHref.StartsWith("http")) { $subHref } else { $versionDir.href.TrimEnd('/') + '/' + $subHref.TrimStart('./') }
            
            # Check if this file already exists in cache
            if ($ExistingVersions.ContainsKey($fileName)) {
                $versionExistingCount++
                continue
            }
            
            # Parse the installer
            $installer = Parse-PythonInstaller -FileName $fileName -Url $fullUrl
            if ($installer) {
                $newVersions[$fileName] = $installer
                $versionNewCount++
            }
        }
        
        # Update with final result for this version
        if ($versionNewCount -gt 0) {
            Write-Host "`r     -> [$progressBar] $percentComplete% | Python $($versionDir.name): +$versionNewCount new ($versionExistingCount cached)      " -NoNewline -ForegroundColor Green
        } else {
            Write-Host "`r     -> [$progressBar] $percentComplete% | Python $($versionDir.name): No new ($versionExistingCount cached)           " -NoNewline -ForegroundColor DarkGray
        }
    }
    
    # Final newline after progress is complete
    Write-Host ""
    
    return $newVersions
}

function Save-CacheXml {
    param(
        [string]$FilePath,
        [hashtable]$AllVersions
    )
    
    Write-Host "`r   -> Building XML cache...                                                                    " -NoNewline -ForegroundColor Yellow
    
    # Sort all versions
    $sortedVersions = $AllVersions.Values | Sort-Object { 
        try {
            if ($_.sortKey) {
                [version]$_.sortKey
            } else {
                $_.file
            }
        } catch {
            $_.file
        }
    }
    
    $xml = '<?xml version="1.0" encoding="utf-8" standalone="no"?>' + "`n"
    $xml += '<versions>' + "`n"
    
    $count = 0
    foreach ($version in $sortedVersions) {
        $count++
        if ($count % 50 -eq 0) {
            $percent = [int](($count / $sortedVersions.Count) * 100)
            Write-Host "`r   -> Building XML cache... $percent% ($count/$($sortedVersions.Count))                    " -NoNewline -ForegroundColor Yellow
        }
        
        $xml += "`t<version x64=`"$($version.x64)`" webInstall=`"$($version.webInstall)`" msi=`"$($version.msi)`">`n"
        $xml += "`t`t<code>$($version.code)</code>`n"
        $xml += "`t`t<file>$($version.file)</file>`n"
        $xml += "`t`t<URL>$([System.Web.HttpUtility]::HtmlEncode($version.url))</URL>`n"
        $xml += "`t</version>`n"
    }
    
    $xml += '</versions>'
    
    Write-Host "`r   -> Saving XML cache file...                                                               " -NoNewline -ForegroundColor Yellow
    
    # Save to the main cache file (this is the only file pyenv actually reads)
    $dir = Split-Path $FilePath -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $xml | Set-Content -Path $FilePath -Encoding UTF8
    
    Write-Host "`r   -> XML cache file saved successfully!                                                       " -ForegroundColor Green
}

# Main execution
try {
    # Check existing cache unless force rebuild
    $existingVersions = if ($Force) { @{} } else { Parse-ExistingCache -CacheFilePath $cacheFile }
    
    if ($existingVersions.Count -gt 0 -and -not $Force) {
        Write-Host ":: [Info] :: Found existing cache with $($existingVersions.Count) versions" -ForegroundColor Green
        Write-Host ":: [Info] :: Checking for new versions only..." -ForegroundColor Green
    } else {
        Write-Host ":: [Info] :: Building complete cache..." -ForegroundColor Green
    }
    
    $allVersions = @{}
    
    # Add existing versions to the collection
    foreach ($key in $existingVersions.Keys) {
        $existing = $existingVersions[$key]
        $allVersions[$key] = @{
            file = $existing.file
            url = $existing.url
            code = $existing.code
            x64 = $existing.x64
            webInstall = $existing.webInstall
            msi = $existing.msi
            sortKey = try { 
                $parts = $existing.code -split '[-.]'
                "$($parts[0]).$($parts[1]).$($parts[2] -replace '^$','0')"
            } catch { $existing.file }
        }
    }
    
    $pageCount = 0
    
    # Process Python.org
    Write-Host ":: [Info] :: Processing Python.org..." -ForegroundColor Green
    $newVersions = Scan-PythonVersions -BaseUrl $mirrors[0] -ExistingVersions $existingVersions -IgnoreErrors $Ignore
    $pageCount++
    
    # Add new versions
    foreach ($key in $newVersions.Keys) {
        $allVersions[$key] = $newVersions[$key]
    }
    
    Write-Host ":: [Info] :: Found $($newVersions.Count) new Python installers" -ForegroundColor Green
    
    # TODO: Add PyPy and GraalPy processing here if needed (keeping it simple for now)
    
    # Save cache
    Write-Host ":: [Info] :: Saving cache files..." -ForegroundColor Green
    Save-CacheXml -FilePath $cacheFile -AllVersions $allVersions
    
    Write-Host ""
    Write-Host ":: [Info] :: Cache update completed successfully!" -ForegroundColor Green
    Write-Host "   -> Total versions: $($allVersions.Count)" -ForegroundColor Cyan
    Write-Host "   -> New versions added: $($newVersions.Count)" -ForegroundColor Cyan
    Write-Host "   -> Cache file: $cacheFile" -ForegroundColor Cyan
    
} catch {
    Write-Host ""
    Write-Host ":: [Error] :: $($_.Exception.Message)" -ForegroundColor Red
    if (-not $Ignore) {
        exit 1
    }
}
