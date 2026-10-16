---
name: commit
description: Gruppiere die aktuellen, noch nicht committeten Git-Änderungen in logisch zusammengehörige Commits und pushe sie. Verwende diesen Skill immer, wenn der Benutzer „commit“, „commit my changes“ sagt, darum bittet, Änderungen auf mehrere Commits aufzuteilen, oder möchte, dass die Änderungen im Working Tree sinnvoll gruppiert statt in einem einzigen großen Commit committed werden. Trigger auch dann, wenn der Benutzer lediglich „commit“ ohne weitere Details sagt.
---

---

# Commit

Teilt die aktuellen Änderungen im Working Tree in logisch gruppierte Commits im Conventional-Commits-Stil auf, schlägt dem Benutzer zunächst die Gruppierung vor und führt die Commits sowie den Push erst nach seiner Bestätigung aus.

## ZIEL

Die aktuellen Git-Änderungen sollen anhand ihrer fachlichen und technischen Zusammengehörigkeit in sinnvolle, kleine Commits aufgeteilt werden. Jeder Commit soll genau eine nachvollziehbare Änderung enthalten und dem Conventional-Commits-Standard entsprechen.

## Workflow

1. **Aktuellen Zustand und Branch prüfen**

   - Prüfe den aktuellen Branch mit `git branch --show-current` und den Working Tree mit `git status --porcelain`.
   - Prüfe `git diff` sowie `git diff --staged`, falls bereits Änderungen gestaged wurden, um die tatsächlichen Änderungen und nicht nur die Dateinamen zu sehen.
   - Wenn keine Änderungen vorhanden sind, teile dies dem Benutzer mit und beende den Vorgang.
   - Wenn bereits ein passender Feature-Branch ausgecheckt ist, arbeite auf diesem weiter und erstelle keinen zusätzlichen Branch.
   - Wenn du auf einem Basis-Branch wie `main` oder `master` bist, schlage einen passenden neuen Branch-Namen vor und bitte um Bestätigung, bevor du ihn erstellst. Erstelle und pushe keinen Branch ohne Zustimmung.
   - Kläre vor dem Branch-Wechsel, ob alle uncommitteten Änderungen auf denselben Branch gehören. Wenn Änderungen unabhängig sind oder die Zuordnung unklar ist, frage den Benutzer und fahre erst nach seiner Entscheidung fort.
   - Erstelle den bestätigten Branch vom aktuellen Ausgangspunkt, bevor du Commits erstellst. Bewahre dabei alle bestätigten Änderungen im Working Tree. Verwende keinen destruktiven Befehl und überschreibe oder verwerfe keine Änderungen.

2. **Nach Logik gruppieren, nicht nach Datei oder Verzeichnis**

   - Lies die Diffs und gruppiere Änderungen, die zur selben logischen Arbeitseinheit gehören, z. B. „neuer Endpoint + zugehöriger Test“, „Refactoring von Service X“, „Konfigurationsänderung“ oder „unabhängiger Bugfix“.
   - Eine Gruppe kann mehrere Dateien umfassen. Eine einzelne Datei kann bei Bedarf sogar mit `git add -p` auf mehrere Commits aufgeteilt werden, wenn sie voneinander unabhängige Änderungen enthält.
   - Gruppiere Änderungen nicht ausschließlich anhand des Verzeichnisses oder Dateityps, sondern danach, **was die Änderung bewirkt**.

3. **Gruppierung vorschlagen**

   - Präsentiere dem Benutzer jede vorgeschlagene Gruppe nur mit einer vorgeschlagenen Conventional-Commit-Message im Format `type(scope): summary`, z. B. `feat(auth): add password reset endpoint`.
   - Nenne keine enthaltenen Dateien, Hunks oder Listen mit Dateipfaden, außer der Benutzer fragt ausdrücklich danach.

   - Verwende folgende Commit-Typen:

     - `feat`
     - `fix`
     - `refactor`
     - `test`
     - `docs`
     - `chore`
     - `style`
     - `perf`
     - `build`
     - `ci`

   - Frage nach Ticket Nummer, sollte es eine Ticketnummer geben bitte vor type(scope) einfügen z.B #006849 feat(auth): add password reset endpoint
   - Warte auf die Bestätigung oder Änderungswünsche des Benutzers, bevor etwas committed wird.
   - Halte den Vorschlag kompakt: Hat es ein Ticket zu dieser Änderung gegeben, wenn du es nicht weißt frage nach der Ticke Beschreibung? Welches Problem löst dieser Commit. Kurz und Aussagekräftig.

4. **Jede Gruppe committen**

   - Stage ausschließlich die Dateien bzw. Hunks der jeweiligen Gruppe mit `git add <bestimmte Dateien/Hunks>`.
   - Erstelle anschließend den Commit mit:
     `git commit -m "<conventional commit message>"`
   - Verwende niemals `git commit --no-verify`. Wirklich niemals. Wenn ein Hook fehlschlägt, brich den Vorgang ab, informiere den Benutzer und behebe das Problem nur nach ausdrücklicher Anweisung.
   - Wiederhole diesen Vorgang für jede Gruppe.
   - Verwende eine sinnvolle Reihenfolge, z. B. grundlegende Änderungen oder Refactorings vor Features, die davon abhängig sind.

5. **Push durchführen**

   - Nachdem alle Gruppen committed wurden, pushe den aktuellen Branch.
   - Falls der aktuelle Branch noch keinen Upstream besitzt, verwende:
     `git push -u origin <branch>`
   - Pushe niemals den Basis-Branch, wenn der Workflow einen neuen Feature-Branch erstellt hat.
   - Gib anschließend die endgültige Liste der erstellten Commits aus:
     `git log --oneline -n <count>`

## Hinweise

- Erfinde keine Gruppierungen, die durch den Diff nicht gerechtfertigt sind. Wenn die Änderungen tatsächlich eine einzige logische Einheit bilden, ist ein einzelner Commit korrekt. Erzwinge keine künstliche Aufteilung.
- Wenn einzelne Hunks einer Datei getrennt werden müssen, verwende `git add -p` oder `git diff` mit gezieltem Staging, anstatt die gesamte Datei dem falschen Commit zuzuordnen.
- Wenn unklar ist, ob zwei Änderungen zusammengehören, frage den Benutzer, anstatt eine Annahme zu treffen.
