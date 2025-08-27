import os
import re
import asyncio
from typing import List
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
import httpx
from models import ChatRequest, ChatResponse

load_dotenv()

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
OPENAI_BASE_URL = os.getenv("OPENAI_BASE_URL", "https://api.openai.com/v1")
OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
ALLOWED_ORIGINS = os.getenv("ALLOWED_ORIGINS", "*")

app = FastAPI(title="CyberAI Proxy", version="1.0.0")

origins = [o.strip() for o in ALLOWED_ORIGINS.split(',') if o.strip()]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins or ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def sanitize(text: str) -> str:
    text = text.strip()
    text = re.sub(r"[\x00-\x08\x0B\x0C\x0E-\x1F]", " ", text)
    return text[:4096]


@app.post("/chat", response_model=ChatResponse)
async def chat(req: ChatRequest):
    if not OPENAI_API_KEY:
        raise HTTPException(status_code=500, detail="Server is not configured with an API key")
    message = sanitize(req.message)
    try:
        async with httpx.AsyncClient(timeout=httpx.Timeout(15.0, read=30.0)) as client:
            url = f"{OPENAI_BASE_URL.rstrip('/')}/chat/completions"
            payload = {
                "model": OPENAI_MODEL,
                "messages": [
                    {"role": "system", "content": "You are CyberAI, a concise cybersecurity assistant."},
                    {"role": "user", "content": message},
                ],
                "temperature": 0.2,
                "max_tokens": 400,
            }
            headers = {"Authorization": f"Bearer {OPENAI_API_KEY}"}
            r = await client.post(url, json=payload, headers=headers)
            if r.status_code >= 400:
                raise HTTPException(status_code=502, detail=f"Upstream error: {r.text}")
            data = r.json()
            answer = (
                data.get("choices", [{}])[0]
                .get("message", {})
                .get("content", "Sorry, no response.")
            )
            return ChatResponse(answer=answer)
    except asyncio.TimeoutError:
        raise HTTPException(status_code=504, detail="Timeout talking to model")
    except httpx.HTTPError as e:
        raise HTTPException(status_code=502, detail=f"Network error: {str(e)}")
