# CyberAI — Flutter Cybersecurity Chatbot

This repository contains:
- Flutter app `cyber_ai_app` with a cyberpunk UI, offline KB + learnable memory, tools (Wi‑Fi scan, password, phishing), daily tips and notifications, and optional online LLM fallback via a proxy.
- Optional FastAPI proxy in `server/` to call OpenAI-compatible APIs without embedding keys in the client.

## Prerequisites

- Flutter 3.x (stable) and Android SDK, or rely on GitHub Actions to build the APK artifact.

## Running the Flutter App

```bash
flutter pub get
flutter run
```

## Building APK locally

```bash
flutter build apk --release
```

## Permissions used (Android)

- INTERNET: network calls.
- ACCESS_WIFI_STATE, CHANGE_WIFI_STATE, ACCESS_NETWORK_STATE: Wi‑Fi info and scanning.
- ACCESS_FINE_LOCATION: required for SSID on modern Android.
- POST_NOTIFICATIONS: local notifications (Android 13+).

Network security config allows cleartext only to 127.0.0.1 for local proxy testing. Remote proxy should use HTTPS.

## Configure Online Intelligence

Set proxy URL in Settings screen (e.g., `https://your-proxy.example.com`). Toggle Use Online Intelligence. The app will try KB → memory → proxy.

## Server (optional)

See `server/README.md` for setup. Environment variables: `OPENAI_API_KEY`, `OPENAI_BASE_URL`, `OPENAI_MODEL`, `ALLOWED_ORIGINS`.

Run:

```bash
cd server
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
uvicorn main:app --host 0.0.0.0 --port 8000
```

## CI

GitHub Actions workflow builds release APK and uploads artifact. See `.github/workflows/flutter-android.yml`.

## Troubleshooting

- If Wi‑Fi scan returns empty, ensure Location permission is granted and you are connected to Wi‑Fi.
- If notifications don’t appear on Android 13+, ensure POST_NOTIFICATIONS permission is granted.
- If proxy calls fail, verify HTTPS URL, CORS, and that the server is reachable.