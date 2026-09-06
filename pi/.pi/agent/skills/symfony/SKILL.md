---
name: symfony
description: >
  A Symfony coding skill for clean, maintainable, and testable code. It follows Symfony
  conventions, keeps controllers thin, moves business logic into services, uses dependency
  injection, DTOs, enums, repositories, PHPUnit tests, and Symfony Translation.
---

# Symfony

## Strings, translations, and exceptions

- Treat every error message as potentially user-facing.
- Never hardcode or build error messages with `sprintf()` in services or exception classes.
- Do not inject `TranslatorInterface` into services or exception classes.
- Domain exceptions must contain relevant structured context as typed readonly properties.
- Domain exceptions must preserve the original exception with `$previous`.
- Translate domain exceptions at the HTTP boundary, preferably in an exception listener. A controller may translate them when no listener exists.
- Before implementing an error response, inspect `translations/`, the relevant controller, and existing exception handling.
- Return translated API errors with an appropriate HTTP status code.

Example:

```php
final class ExternalServiceException extends \RuntimeException
{
    public function __construct(
        public readonly string $resourceId,
        ?\Throwable $previous = null,
    ) {
        parent::__construct(previous: $previous);
    }
}
```

```php
catch (ExternalServiceException $exception) {
    return $this->json([
        'error' => $translator->trans('external_service.error.request_failed', [
            '%resource_id%' => $exception->resourceId,
        ]),
    ], Response::HTTP_BAD_GATEWAY);
}
```
