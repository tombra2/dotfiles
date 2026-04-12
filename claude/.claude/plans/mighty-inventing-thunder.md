# Plan: SurveyVoter – Zugriff auf Surveys einschränken

## Context
Aktuell kann jeder eingeloggte User (`ROLE_USER`) jede Survey über die URL aufrufen (z.B. `/42`, `/42/edit`). Es fehlt eine Autorisierungsprüfung, die sicherstellt, dass nur der Eigentümer der Survey oder ein Admin darauf zugreifen darf.

---

## Kritische Dateien

| Datei | Aktion |
|-------|--------|
| `src/Security/Voter/SurveyVoter.php` | **Neu erstellen** |
| `src/Controller/SurveyController.php` | `denyAccessUnlessGranted` in betroffene Actions einfügen |

---

## Schritt 1: SurveyVoter erstellen

**Datei:** `src/Security/Voter/SurveyVoter.php`

Attribute:
- `SurveyVoter::VIEW` – für show, step, resume, download, ai-summary
- `SurveyVoter::EDIT` – für edit
- `SurveyVoter::DELETE` – für delete

Logik in `voteOnAttribute()`:
```
if $user has ROLE_ADMIN → ACCESS_GRANTED
if $survey->getUser() === $user → ACCESS_GRANTED
sonst → ACCESS_DENIED
```

Symfony erkennt Voter-Klassen im `src/Security/Voter/`-Verzeichnis automatisch via Autowiring.

---

## Schritt 2: Controller absichern

**Datei:** `src/Controller/SurveyController.php`

In jede betroffene Action am Anfang einfügen:

| Action / Route | Attribut |
|----------------|----------|
| `show` (`/{id}`) | `SurveyVoter::VIEW` |
| `edit` (`/{id}/edit`) | `SurveyVoter::EDIT` |
| `delete` (`/{id}/delete`) | `SurveyVoter::DELETE` |
| `step` (`/{id}/step`) | `SurveyVoter::VIEW` |
| `resume` (`/{id}/step/resume`) | `SurveyVoter::VIEW` |
| `pdfDownload` (`/{id}/download`) | `SurveyVoter::VIEW` |
| `aiSummaryDownload` (`/{id}/ai-summary/download`) | `SurveyVoter::VIEW` |

Beispiel-Aufruf:
```php
$this->denyAccessUnlessGranted(SurveyVoter::VIEW, $survey);
```

Der `api_save_chart`-Endpunkt (`/chart/save`) lädt die Survey per ID aus dem POST-Body – dort ebenfalls prüfen, nachdem die Survey geladen wurde.

---

## Verifikation

1. Als normaler User Survey eines anderen Users direkt via URL aufrufen → erwarte 403
2. Als Admin jede Survey aufrufen → erwarte Erfolg
3. Als Eigentümer eigene Survey aufrufen → erwarte Erfolg
4. `index`-Route bleibt unverändert (zeigt nur eigene Surveys via Repository-Query)
