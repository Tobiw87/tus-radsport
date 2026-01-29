# TuS Jahn Werdohl – Abteilung Radsport (GitHub Pages / Jekyll)

## Ziel
Sportlich-aktiv, aber gemeinschaftlich. Informieren und neue Mitfahrer gewinnen.

---

## Repo-Struktur (wichtig: wo gehört was hin)

- `_config.yml`
  - Zentrale Daten & Einstellungen: Titel, Navigation, Links, Kontakt, Sidebar-Inhalte
  - Regel: Wenn du etwas „überall“ ändern willst → hier.

- `_layouts/default.html`
  - Rahmen der Website: Header / Main / Footer
  - Regel: Kein Seiteninhalt hier, nur Struktur.

- `_includes/sidebar.html`
  - Wiederverwendbarer Baustein (Sidebar)
  - Regel: Zeigt Daten aus `_config.yml` an. Inhalte NICHT hart codieren.

- `index.md` und weitere `*.md`
  - Seiteninhalt (Text, Bilder, Karten, Markdown)
  - Regel: Alles was inhaltlich ist → hier.

- `assets/css/style.css`
  - Design (Farben, Abstände, Layout, Responsive)
  - Regel: Keine HTML-Änderungen für Optik.

- `assets/images/*`
  - Bilder (logo, hero, background)

---

## Was ändere ich wann? (ohne Suchen)

### Navigation (Header)
→ `_config.yml` → `navigation:` bearbeiten

### Sidebar-Inhalte
→ `_config.yml` → `sidebar:` und `contact:` bearbeiten

### Footer (Impressum/Datenschutz/Note)
→ `_config.yml` → `links:` und `footer:` bearbeiten

### Design / Abstände / Mobile
→ `assets/css/style.css`

### Seiteninhalte
→ jeweilige `.md` Seite

---

## Regeln, damit es nicht wieder chaotisch wird

1. Inhalte stehen NICHT im Layout.
2. Wiederverwendbare Inhalte (Kontakt/Navigation/Sidebar) stehen in `_config.yml`.
3. CSS wird nur in den passenden Abschnitten gepflegt (Tokens, Layout, Components, Typography).
4. Keine „Quick Fixes“ irgendwo in der Datei – lieber sauber im passenden Block ergänzen.

---

## Tipp: Titel auf einer Seite ausblenden
Wenn eine Seite selbst eine große Überschrift im Inhalt hat:

```yml
---
layout: default
title: "Training"
hide_title: true
---
