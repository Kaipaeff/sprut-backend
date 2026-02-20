# Flask backend (Docker)

## Запуск

```bash
docker compose up --build
```

API будет доступен на: `http://localhost:8000`

## Документация для фронта

См. файл: `документация апи.docx`

## Примечание

- SQLite база хранится в `data.db` и примонтирована как volume в `docker-compose.yml`.
- Загруженные `.xlsx` сохраняются в папку `uploads/` (тоже volume).
