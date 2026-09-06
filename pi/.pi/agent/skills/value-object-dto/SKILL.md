---
name: value-object-dto
description: Erstellt DTOs und Value Objects nach dem Prinzip des Negative Space Programming für PHP 8.3 / Symfony 7.3. Nutze diesen Skill immer, wenn Thomas nach DTOs, Value Objects, Request-Mapping (#[MapRequestPayload]), Validierung von Eingabedaten oder "ungültige Zustände verhindern" fragt — auch wenn er nicht explizit "Value Object" oder "Negative Space Programming" sagt, z.B. bei "wie validiere ich Email/PLZ/IBAN sauber", "DTO für Request", oder "wie strukturiere ich Eingabedaten typsicher".
---

# Value Objects für Negative Space Programming (PHP 8.3 / Symfony 7.3)

## Prinzip

Ungültige Zustände sollen nicht darstellbar sein, statt sie zur Laufzeit abzufangen.
Erreicht durch: `readonly`-Klassen + Validierung im Konstruktor + primitive Typen durch
Value Objects (VOs) ersetzen. Sobald ein Objekt existiert, ist es garantiert gültig —
kein Code danach muss das je wieder prüfen.

## Value Object — Grundstruktur

```php
final readonly class Email
{
    public function __construct(private string $value)
    {
        if (!filter_var($value, FILTER_VALIDATE_EMAIL)) {
            throw new InvalidArgumentException("Invalid email: {$value}");
        }
    }

    public function __toString(): string
    {
        return $this->value;
    }
}
```

Regeln:

- Immer `final readonly class`.
- Validierung ausschließlich im Konstruktor, nirgendwo sonst.
- Bei Vergleichbarkeit: `equals(self $other): bool` ergänzen.
- Kein Setter, keine öffentliche Mutation — sonst ist der Zustand wieder ungültig darstellbar.

## DTO, das VOs statt Primitiven nutzt

```php
final readonly class RegisterUserDto
{
    public function __construct(
        public Email $email,
        public PostalCode $postalCode,
    ) {}
}
```

Kein `?string $email = null` für Pflichtfelder. Wenn ein Zustand optional ist,
eigenen DTO-Typ pro Zustand erstellen (z.B. `DraftOrderDto` vs. `ConfirmedOrderDto`),
statt nullable Felder in einem gemeinsamen DTO zu mischen.

## Symfony-Integration: MapRequestPayload + Denormalizer

Rohe Request-Strings müssen vor der DTO-Erstellung in VOs umgewandelt werden, sonst
wirft Symfonys Standard-Denormalizer schon vor der eigentlichen Validierung Fehler.

Siehe `references/symfony-integration.md` für:

- Custom Denormalizer pro VO-Typ
- Registrierung als Service (`#[AutoconfigureTag]`)
- Verwendung mit `#[MapRequestPayload]` im Controller
- Umgang mit Validierungsfehlern (400 Response statt 500)

## Checkliste beim Erstellen eines neuen DTOs

1. Welche Felder haben eine Invariante (Format, Range, Enum-artige Werte)? → eigenes VO.
2. Gibt es unterschiedliche gültige Zustände (z.B. Draft/Confirmed)? → getrennte DTOs, keine nullable Felder.
3. Bool-Flag-Kombinationen, die sich gegenseitig ausschließen? → durch `enum` ersetzen.
4. Ist das DTO `final readonly`?
5. Wird die Validierung nur im Konstruktor durchgeführt (kein Symfony-Validator-Attribut zusätzlich nötig)?
