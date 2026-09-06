---
name: dto-response-error-handling
description: Use when PHP code receives data from HTTP APIs, webhooks, Messenger messages, JSON files, forms, database JSON, or configuration. Map untyped boundary data into typed DTOs immediately and preserve the original exception on mapping failures.
---

# DTO boundary validation

Use a typed DTO at every boundary where data enters the application. The DTO is the validation boundary. After it, application code works with typed properties instead of `array`, `mixed`, or unvalidated strings.

Apply this to HTTP responses, webhook payloads, Messenger messages, JSON files, form input, database JSON, and configuration data.

## Pattern

1. Read data from the external or untyped source.
2. Inside one `try` block, map it immediately to a typed DTO.
3. Catch `\Throwable` and throw a domain-specific `\RuntimeException` with `previous: $exception`.
4. Return or pass on the DTO. Callers use its typed properties.

```php
try {
    return FileUploadResponse::fromArray($response->toArray());
} catch (\Throwable $exception) {
    throw new \RuntimeException(
        'OpenWebUI returned an invalid file upload response.',
        previous: $exception,
    );
}
```

## DTO shape

Keep boundary DTOs small and typed. Map source data directly.

```php
final class FileUploadResponse
{
    public function __construct(public readonly string $id)
    {
    }

    /** @param array{id: string} $data */
    public static function fromArray(array $data): self
    {
        return new self($data['id']);
    }
}
```

## Rules

- Map data at the boundary, not later in business logic.
- Do not pass raw arrays or `mixed` beyond the boundary.
- Do not add manual `isset`, `is_null`, `is_string`, empty-string, or status-code checks before DTO mapping.
- Let DTO construction and source parsing fail inside the shared `try/catch`.
- Keep the original exception as `previous` so logs retain the parsing, transport, or type failure.
- Use an error message that names the source and failed operation.
- Do not use this pattern to hide application logic errors. It is for untyped input at system boundaries.
