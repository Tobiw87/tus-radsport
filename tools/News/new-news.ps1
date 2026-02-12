Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Slugify([string]$text) {
    $text = $text.Trim().ToLower()
    $text = $text -replace 'ä','ae' -replace 'ö','oe' -replace 'ü','ue' -replace 'ß','ss'
    $text = $text -replace '[^a-z0-9\s-]', ''
    $text = $text -replace '\s+', '-'
    $text = $text -replace '-+', '-'
    return $text.Trim('-')
}

function Confirm-YesNo([string]$prompt, [bool]$defaultYes = $false) {
    $suffix = if ($defaultYes) { "[J/n]" } else { "[j/N]" }
    $answer = Read-Host "$prompt $suffix"
    $answer = $answer.Trim().ToLower()
    if ([string]::IsNullOrWhiteSpace($answer)) { return $defaultYes }
    return ($answer -eq "j" -or $answer -eq "ja" -or $answer -eq "y" -or $answer -eq "yes")
}

function Is-ValidIsoDate([string]$date) {
    return [datetime]::TryParseExact(
        $date, "yyyy-MM-dd", $null,
        [System.Globalization.DateTimeStyles]::None,
        [ref]([datetime]::MinValue)
    )
}

function Get-GitBranch {
    try {
        $b = (& git rev-parse --abbrev-ref HEAD 2>$null).Trim()
        if ($b) { return $b }
    } catch {}
    return ""
}

Write-Host ""
Write-Host "Neue News anlegen"
Write-Host "-----------------"

# Datum (default: heute)
$today = (Get-Date).ToString("yyyy-MM-dd")
$newsDate = Read-Host "Datum (YYYY-MM-DD) [Enter = $today]"
if ([string]::IsNullOrWhiteSpace($newsDate)) { $newsDate = $today }
if (!(Is-ValidIsoDate $newsDate)) {
    Write-Host "Ungültiges Datum. Bitte im Format YYYY-MM-DD eingeben (z.B. 2026-02-12)."
    exit 1
}

# Titel
$newsTitle = Read-Host "Titel"
$newsTitle = $newsTitle.Trim()
if ([string]::IsNullOrWhiteSpace($newsTitle)) {
    Write-Host "Titel darf nicht leer sein."
    exit 1
}

$slug = Slugify $newsTitle
if ([string]::IsNullOrWhiteSpace($slug)) {
    Write-Host "Konnte aus dem Titel keinen gültigen Slug erzeugen."
    exit 1
}

$doGit = Confirm-YesNo "Git add + commit durchführen?" $true
$doPush = $false
if ($doGit) { $doPush = Confirm-YesNo "Danach auch git push?" $false }

# Repo root robust über git
$repoRoot = (& git rev-parse --show-toplevel).Trim()
if ([string]::IsNullOrWhiteSpace($repoRoot) -or !(Test-Path $repoRoot)) {
    Write-Host "Konnte Repo-Root nicht ermitteln. Bist du in einem Git-Repo?"
    exit 1
}

$newsDir = Join-Path $repoRoot "_news"
New-Item -ItemType Directory -Force -Path $newsDir | Out-Null

$newsFile = Join-Path $newsDir "$newsDate-$slug.md"

if (Test-Path $newsFile) {
    Write-Host "News-Datei existiert schon: $newsFile"
    $overwrite = Confirm-YesNo "Überschreiben?" $false
    if (!$overwrite) { exit 1 }
}

# Grundgerüst schreiben (mit <!--more--> für Vorschau/Mehr)
$template = @"
---
layout: default
title: "$newsTitle"
date: $newsDate
---

Schreibe hier deine News.

<!--more-->

Mehr Inhalt hier. (Alles unterhalb von <!--more--> erscheint nach Klick auf „Mehr“.)
"@

New-Item -ItemType File -Force -Path $newsFile -Value $template | Out-Null

# Datei in VS Code öffnen (und danach beenden)
$codeCmd = Get-Command code -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Fertig!"
Write-Host " - News-Datei: $newsFile"
Write-Host ""

if ($codeCmd) {
    Start-Process -FilePath $codeCmd.Source -ArgumentList @("-r", "$newsFile")
    Write-Host "Geöffnet in VS Code."
} else {
    Write-Host "VS Code (Befehl 'code') wurde nicht gefunden."
    Write-Host "In VS Code (Command Palette): Shell Command: Install 'code' command in PATH"
}