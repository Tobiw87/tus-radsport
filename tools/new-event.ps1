# ==============================
# new-event.ps1
# Annahmen:
# - Repo-Struktur:
#   - _event/                         (Collection für Events)
#   - assets/images/events/           (Event-Bilder)
#   - tools/work/                     (fixer Arbeitsordner für ausgewählte Bilder)
# - Ordnername für Bilder: YYYY-MM-DD-slug
# - Event-MD: _event/YYYY-MM-DD-slug.md
# - Frontmatter-Felder: layout, title, event_date, image_folder, permalink
# - Optional: git add/commit/push mit Message: "Event: <Titel> (<Datum>)"
# - Optional: ImageMagick (magick) für Resize
# ==============================

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

    if ([string]::IsNullOrWhiteSpace($answer)) {
        return $defaultYes
    }
    return ($answer -eq "j" -or $answer -eq "ja" -or $answer -eq "y" -or $answer -eq "yes")
}

function Is-ValidIsoDate([string]$date) {
    # yyyy-MM-dd strict check
    return [datetime]::TryParseExact($date, "yyyy-MM-dd", $null, [System.Globalization.DateTimeStyles]::None, [ref]([datetime]::MinValue))
}

function Get-GitBranch {
    try {
        $b = (& git rev-parse --abbrev-ref HEAD 2>$null).Trim()
        if ($b) { return $b }
    } catch {}
    return ""
}

Write-Host ""
Write-Host "Neues Event anlegen"
Write-Host "-------------------"

$eventDate = Read-Host "Datum der Veranstaltung (YYYY-MM-DD)"
if (!(Is-ValidIsoDate $eventDate)) {
    Write-Host "Ungültiges Datum. Bitte im Format YYYY-MM-DD eingeben (z.B. 2026-02-21)."
    exit 1
}

$eventTitle = Read-Host "Titel der Veranstaltung"
$eventTitle = $eventTitle.Trim()
if ([string]::IsNullOrWhiteSpace($eventTitle)) {
    Write-Host "Titel darf nicht leer sein."
    exit 1
}

$doResize = Confirm-YesNo "Bilder automatisch resizen (ImageMagick)?" $true
$maxSize  = "1600x1600>"
$quality  = 82

$doGit = Confirm-YesNo "Git add + commit durchführen?" $true
$doPush = $false
if ($doGit) {
    $doPush = Confirm-YesNo "Danach auch git push?" $false
}

$slug = Slugify $eventTitle
if ([string]::IsNullOrWhiteSpace($slug)) {
    Write-Host "Konnte aus dem Titel keinen gültigen Slug erzeugen."
    exit 1
}

$eventKey = "$eventDate-$slug"

$repoRoot = (Resolve-Path "$PSScriptRoot\..").Path
$workFolder = Join-Path $PSScriptRoot "work"
$targetImageFolder = Join-Path $repoRoot "assets\images\events\$eventKey"
$eventFilePath = Join-Path $repoRoot "_event\$eventKey.md"

# sanity checks
if (!(Test-Path $workFolder)) {
    Write-Host "Arbeitsordner fehlt: $workFolder"
    Write-Host "Lege bitte tools/work/ an."
    exit 1
}

$workImages = Get-ChildItem $workFolder -File | Where-Object { $_.Extension -match '\.(jpg|jpeg|png)$' }
if ($workImages.Count -eq 0) {
    Write-Host "Keine Bilder in tools/work gefunden."
    exit 1
}

$overwrite = $false
if ((Test-Path $eventFilePath) -or (Test-Path $targetImageFolder)) {
    Write-Host ""
    Write-Host "Achtung: Event existiert scheinbar schon."
    if (Test-Path $eventFilePath) { Write-Host " - Event-Datei existiert: $eventFilePath" }
    if (Test-Path $targetImageFolder) { Write-Host " - Zielordner existiert:   $targetImageFolder" }
    $overwrite = Confirm-YesNo "Überschreiben (bestehende Dateien können ersetzt werden)?" $false
    if (!$overwrite) { exit 1 }
    New-Item -ItemType Directory -Force -Path $targetImageFolder | Out-Null
} else {
    New-Item -ItemType Directory -Force -Path $targetImageFolder | Out-Null
}

# check magick availability if resize enabled
$magickOk = $false
if ($doResize) {
    try {
        $null = & magick -version 2>$null
        $magickOk = $true
    } catch {
        $magickOk = $false
    }
    if (!$magickOk) {
        Write-Host "ImageMagick (magick) nicht gefunden. Resize wird übersprungen."
        $doResize = $false
    }
}

# Move + optional resize
Write-Host ""
Write-Host "Verarbeite Bilder..."
$processed = 0

# move files first (preserve names), then resize, then renumber
foreach ($img in ($workImages | Sort-Object Name)) {
    $dest = Join-Path $targetImageFolder $img.Name
    Move-Item $img.FullName $dest -Force

    if ($doResize) {
        & magick $dest -resize $maxSize -strip -quality $quality $dest
    }

    $processed++
}

# Renumber ALL images in target folder (simple first version)
$i = 1
Get-ChildItem $targetImageFolder -File |
    Where-Object { $_.Extension -match '\.(jpg|jpeg|png)$' } |
    Sort-Object Name |
    ForEach-Object {
        $ext = $_.Extension.ToLower()
        $newName = "{0:D3}{1}" -f $i, $ext
        Rename-Item $_.FullName (Join-Path $targetImageFolder $newName) -Force
        $i++
    }

# Create/overwrite event md
$frontmatter = @"
---
layout: event
title: "$eventTitle"
event_date: $eventDate
image_folder: "/assets/images/events/$eventKey"
permalink: /events/$eventKey/
---
"@

New-Item -ItemType File -Force -Path $eventFilePath -Value $frontmatter | Out-Null

Write-Host ""
Write-Host "Fertig!"
Write-Host " - Event-Datei: $eventFilePath"
Write-Host " - Bilderordner: $targetImageFolder"
Write-Host " - Bilder verarbeitet: $processed"
Write-Host ""

# Optional git add/commit/push (only for event paths)
if ($doGit) {
    Write-Host "Git: stage + commit..."

    Push-Location $repoRoot
    try {
        # Ensure git repo
        & git rev-parse --is-inside-work-tree | Out-Null

        $eventRel = "_event/$eventKey.md"
        $imagesRel = "assets/images/events/$eventKey"

        & git add $eventRel $imagesRel

        $msg = "Event: $eventTitle ($eventDate)"
        & git commit -m "$msg"

        if ($doPush) {
            $branch = Get-GitBranch
            if ([string]::IsNullOrWhiteSpace($branch)) {
                Write-Host "Konnte Branch nicht ermitteln. Push abgebrochen."
            } else {
                Write-Host "Git: push origin $branch ..."
                & git push origin $branch
            }
        }
    } catch {
        Write-Host "Git-Fehler: $($_.Exception.Message)"
        Write-Host "Hinweis: Prüfe, ob Git installiert ist und das Repo korrekt eingerichtet ist."
    } finally {
        Pop-Location
    }

    Write-Host ""
}
