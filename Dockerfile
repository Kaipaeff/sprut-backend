# syntax=docker/dockerfile:1

FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# System deps (pandas/openpyxl are pure python, but keep minimal build tooling)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        gcc \
    && rm -rf /var/lib/apt/lists/*

# Install python deps
COPY requirements.txt /app/requirements.txt

# requirements.txt is UTF-16LE in this project; convert to UTF-8 for pip
RUN python - <<'PY'
import pathlib
p = pathlib.Path('requirements.txt')
data = p.read_bytes()
# naive but reliable: detect BOM/utf-16 and decode
for enc in ('utf-16', 'utf-16le', 'utf-16be'):
    try:
        txt = data.decode(enc)
        break
    except Exception:
        txt = None
if txt is None:
    txt = data.decode('utf-8')
pathlib.Path('requirements.utf8.txt').write_text(txt, encoding='utf-8')
print('Converted requirements.txt -> requirements.utf8.txt')
PY

RUN pip install --no-cache-dir -r /app/requirements.utf8.txt \
    && pip install --no-cache-dir gunicorn

# Copy app
COPY . /app

# Ensure runtime dirs exist
RUN mkdir -p /app/uploads

EXPOSE 8000

# Production-ish server (works for local too)
CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:8000", "app:app"]
