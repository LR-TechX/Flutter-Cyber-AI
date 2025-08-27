# CyberAI FastAPI Proxy

Minimal proxy to call an OpenAI-compatible API so the Flutter client does not embed API keys.

## Quickstart

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# edit .env with your key and base/model
uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}
```

## Environment

- OPENAI_API_KEY: secret key
- OPENAI_BASE_URL: e.g. https://api.openai.com/v1 or custom
- OPENAI_MODEL: e.g. gpt-4o-mini
- ALLOWED_ORIGINS: comma-separated CORS origins (default *)

## Endpoint

- POST /chat
  - Body: `{ "message": "..." }`
  - Returns: `{ "answer": "..." }`

## Docker

```bash
docker build -t cyberai-proxy .
docker run -p 8000:8000 --env-file .env cyberai-proxy
```
