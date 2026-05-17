# Plan: OpenAPI (Swagger) Einführung — Dummy-Ressource Product

## Kontext

Das Projekt nutzt bereits `nelmio/api-doc-bundle ^5.10`, das Bundle ist aber weder in `bundles.php` registriert noch konfiguriert. Ziel ist ein didaktisch sauberer Einstieg: eine minimale `Product`-Ressource mit vier CRUD-Endpunkten, vollständig dokumentiert via OpenAPI-Attribute, sichtbar in Swagger UI unter `/api/doc`.

---

## Schritt 1 — Bundle registrieren

**Datei:** `config/bundles.php`

Zeile hinzufügen (nach `GesdinetJWTRefreshTokenBundle`):

```php
Nelmio\ApiDocBundle\NelmioApiDocBundle::class => ['all' => true],
```

**Konzept:** Symfony lädt nur explizit registrierte Bundles. Das Bundle stellt den Spec-Generator-Service und die Swagger-UI-Controller bereit.

---

## Schritt 2 — Bundle konfigurieren

**Datei (neu):** `config/packages/nelmio_api_doc.yaml`

```yaml
nelmio_api_doc:
    documentation:
        info:
            title: 'Chat Backend API'
            description: 'Educational OpenAPI demo with a Product resource'
            version: '1.0.0'
    areas:
        default:
            path_patterns:
                - ^/api(?!/doc)  # /api/... aber NICHT /api/doc selbst
```

**Konzept:** `areas` filtert per Regex, welche Routen in die Spec aufgenommen werden. Der negative Lookahead `(?!/doc)` verhindert, dass die Doku-Route sich selbst dokumentiert.

---

## Schritt 3 — Swagger-UI-Routen registrieren

**Datei (neu):** `config/routes/nelmio_api_doc.yaml`

```yaml
nelmio_api_doc.swagger_ui:
    resource: '@NelmioApiDocBundle/config/routing/swaggerui.php'
    prefix: /api/doc

nelmio_api_doc.json:
    path: /api/doc.json
    controller: nelmio_api_doc.controller.documentation
    methods: [GET]
```

**Konzept:** Zwei Endpunkte entstehen:
- `/api/doc` → HTML-Seite mit Swagger UI (lädt die JS-App aus `vendor/`)
- `/api/doc.json` → roher OpenAPI-3.0-JSON-Spec (für Postman, Code-Generatoren etc.)

---

## Schritt 4 — Security für /api/doc öffnen

**Datei:** `config/packages/security.yaml`

Neuen Firewall-Eintrag **vor** dem `api`-Firewall einfügen (Reihenfolge zählt — erste Übereinstimmung gewinnt):

```yaml
firewalls:
    dev:
        pattern: ^/(_profiler|_wdt|assets|build)/
        security: false
    api_doc:                        # NEU
        pattern: ^/api/doc
        security: false
    login:
        ...
```

**Konzept:** Der `api`-Firewall hat das Muster `^/api` und erzwingt JWT. Ohne `api_doc` davor würde `/api/doc` mit 401 beantwortet.

---

## Schritt 5 — Product Entity mit `#[OA\Schema]`

**Datei (neu):** `src/Entity/Product.php`

```php
<?php

namespace App\Entity;

use App\Repository\ProductRepository;
use Doctrine\ORM\Mapping as ORM;
use OpenApi\Attributes as OA;

#[ORM\Entity(repositoryClass: ProductRepository::class)]
#[ORM\Table(name: 'product')]
#[OA\Schema(
    schema: 'Product',
    description: 'A simple product entity',
    required: ['name', 'price'],
)]
class Product
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[OA\Property(property: 'id', type: 'integer', readOnly: true, example: 1)]
    private ?int $id = null;

    #[ORM\Column(length: 255)]
    #[OA\Property(property: 'name', type: 'string', example: 'Laptop')]
    private ?string $name = null;

    #[ORM\Column]
    #[OA\Property(property: 'price', type: 'number', format: 'float', example: 999.99)]
    private ?float $price = null;

    #[ORM\Column(type: 'text', nullable: true)]
    #[OA\Property(property: 'description', type: 'string', nullable: true, example: 'A powerful laptop')]
    private ?string $description = null;

    #[ORM\Column]
    #[OA\Property(property: 'createdAt', type: 'string', format: 'date-time', readOnly: true)]
    private ?\DateTimeImmutable $createdAt = null;

    public function __construct()
    {
        $this->createdAt = new \DateTimeImmutable();
    }

    // Getters + Setters für alle Felder
}
```

**Konzept:** `#[OA\Schema]` registriert die Klasse als wiederverwendbares Schema unter `components.schemas.Product`. Jedes `#[OA\Property]` beschreibt ein JSON-Feld (Typ, Format, Beispiel). Controller-Responses können via `ref: '#/components/schemas/Product'` darauf zeigen.

---

## Schritt 6 — ProductRepository

**Datei (neu):** `src/Repository/ProductRepository.php`

Standard ServiceEntityRepository für `Product`. Wird vom Controller per Autowiring injiziert.

---

## Schritt 7 — ProductController mit vollen OpenAPI-Attributen

**Datei (neu):** `src/Controller/api/ProductController.php`

Vier Endpunkte, alle mit vollständigen OA-Attributen, alle public (kein JWT für dieses Demo):

| Methode | Pfad | OA-Attribut | Status-Codes |
|---|---|---|---|
| GET | `/api/products` | `#[OA\Get]` | 200 |
| GET | `/api/products/{id}` | `#[OA\Get]` | 200, 404 |
| POST | `/api/products` | `#[OA\Post]` | 201, 422 |
| DELETE | `/api/products/{id}` | `#[OA\Delete]` | 200, 404 |

Wichtige OA-Attribute:
- `#[OA\Tag(name: 'Products')]` auf der Klasse → gruppiert alle Endpunkte in Swagger UI
- `#[OA\PathParameter]` für `{id}` → zeigt es als Pflichtparameter in der UI
- `#[OA\RequestBody]` mit `#[OA\JsonContent]` für POST → zeigt ein ausfüllbares Body-Schema
- `#[OA\Response(..., content: new OA\JsonContent(ref: '#/components/schemas/Product'))]` → verlinkt auf die Entity-Schema-Definition

Controller nutzt `BaseController::success()`, `error()`, `message()` für JSON-Antworten (bestehende Methoden in `src/Controller/api/BaseController.php`).

---

## Schritt 8 — Migration erzeugen und ausführen

```bash
# Im backend/-Verzeichnis:
bin/console make:migration
bin/console doctrine:migrations:migrate
```

Erzeugt `CREATE TABLE product (id, name, price, description, created_at)` in der DB.

---

## Schritt 9 — Cache leeren und verifizieren

```bash
bin/console cache:clear
bin/console debug:router | grep -E 'product|api_doc'
```

Erwartete Ausgabe:
```
product_list      GET    /api/products
product_show      GET    /api/products/{id}
product_create    POST   /api/products
product_delete    DELETE /api/products/{id}
nelmio_api_doc.*         /api/doc
nelmio_api_doc.*         /api/doc.json
```

Dann im Browser: `http://localhost:8000/api/doc`

---

## Kritische Dateien

| Datei | Aktion |
|---|---|
| `config/bundles.php` | 1 Zeile hinzufügen |
| `config/packages/nelmio_api_doc.yaml` | neu erstellen |
| `config/routes/nelmio_api_doc.yaml` | neu erstellen |
| `config/packages/security.yaml` | `api_doc` Firewall einfügen |
| `src/Entity/Product.php` | neu erstellen |
| `src/Repository/ProductRepository.php` | neu erstellen |
| `src/Controller/api/ProductController.php` | neu erstellen |

---

## OpenAPI-Attribut-Kurzreferenz

| Attribut | Ort | Ergebnis in der Spec |
|---|---|---|
| `#[OA\Schema]` | Entity-Klasse | Eintrag unter `components.schemas` |
| `#[OA\Property]` | Entity-Feld | Feld innerhalb einer Schema-Definition |
| `#[OA\Tag]` | Controller-Klasse | Gruppierung in Swagger UI |
| `#[OA\Get/Post/Delete]` | Controller-Methode | Operation unter einem Pfad |
| `#[OA\PathParameter]` | Innerhalb einer Operation | `parameters` Eintrag mit `in: path` |
| `#[OA\RequestBody]` | Innerhalb einer Operation | `requestBody` Block |
| `#[OA\Response]` | Innerhalb einer Operation | Eintrag in `responses` |
| `#[OA\JsonContent]` | In Response oder Body | Content-Type `application/json` mit Schema |

---

## Verifikation

1. `bin/console debug:router` zeigt alle 4 Product-Routen + 2 Doc-Routen
2. `http://localhost:8000/api/doc` → Swagger UI mit "Products"-Gruppe und 4 Endpunkten
3. `http://localhost:8000/api/doc.json` → raw JSON mit `paths`, `components.schemas.Product`
4. In Swagger UI "Try it out" → POST `/api/products` mit `{"name":"Test","price":9.99}` → 201
5. GET `/api/products` → Array mit dem neuen Produkt
6. DELETE `/api/products/1` → 200 mit Bestätigungsmeldung
