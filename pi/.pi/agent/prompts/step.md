---
name: step
description: Erstelle eine neue Version der aktuellen Step-by-Step-Anleitung.
  Berücksichtige den bisherigen Gesprächsverlauf und alle neuen Anweisungen.
---

- Nummeriere Hauptschritte fortlaufend: 1, 2, 3, ...
- Nummeriere Unterschritte alphabetisch: 1.a, 1.b, 2.a, ...
- Nenne vor jedem Codeblock den vollständigen projektbezogenen Dateipfad.
- Erkläre kurz, wozu die jeweilige Änderung dient.

## Vollständiger Implementierungscode ist Pflicht

- Gib nicht nur einen konzeptionellen Plan aus.
- Zeige für jeden Implementierungsschritt unmittelbar den benötigten Code.
- Neue Dateien müssen vollständig und kopierbar enthalten sein.
- Bei bestehenden Dateien zeige vollständige Ersatzmethoden oder
  eindeutig abgegrenzte Änderungen einschließlich nötiger Imports.
- Zeige auch erforderliche Konfiguration und Konsolenbefehle.
- Keine Platzhalter, kein Pseudocode, keine ausgelassenen Methoden.
- Verschiebe den Code nicht mit Aussagen wie
  „Das implementieren wir im nächsten Schritt“ auf eine spätere Antwort.
- Wenn der Umfang zu groß ist, liefere einen kleineren, vollständig
  umsetzbaren Teilschritt statt eines großen Plans ohne Code.

## Technische Regeln

- Prüfe vorhandenen Projektcode, bevor du darauf aufbauenden Code zeigst.
- Verwende die installierten Framework- und Sprachversionen.
- Befolge typische Symfony-Konventionen und Constructor Injection.
- Nutze passende Patterns, aber keine unnötigen Abstraktionen.
- Bevorzuge Array-Funktionen gegenüber Schleifen, wenn sie die Lösung
  verständlicher machen. Begründe notwendige zustandsabhängige Schleifen kurz.
- Erfinde keine APIs, Endpunkte oder Fähigkeiten von Bibliotheken.
- Kläre fehlende Informationen gezielt, bevor du davon abhängigen Code erzeugst.
- Berücksichtige meine bisherigen Vorgaben zum Umfang und zu Tests.

## Planmodus

- Auch im Planmodus muss die Antwort vollständigen Implementierungscode enthalten.
- Zeige Code und Befehle ausschließlich als Anleitung.
- Ändere keine Dateien und führe keine zustandsverändernden Befehle aus.
- Unterscheide klar zwischen vorgeschlagenem und tatsächlich geprüftem Code.

## Abschluss

- Nenne die erwartete Ausgabe oder das erkennbare Erfolgskriterium.
- Nenne bekannte Grenzen des vorgeschlagenen Codes.
- Liefere nach jedem Aufruf dieses Prompts die aktualisierte Anleitung,
  nicht lediglich eine Bestätigung der Regeln.
