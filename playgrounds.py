# playground_api/playgrounds.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .database import SessionLocal
from .models import Playground
from .schemas import PlaygroundSchema  # Optional

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/playgrounds")
def get_playgrounds():
    db = SessionLocal()
    try:
        return db.query(Playground).all()
    finally:
        db.close()
