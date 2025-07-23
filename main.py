from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from fastapi.middleware.cors import CORSMiddleware
from .database import SessionLocal
from .models import Playground
from fastapi.staticfiles import StaticFiles
import os

app = FastAPI()

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

app.mount(
    "/images",
    StaticFiles(directory=os.path.join(BASE_DIR, "map_image")),
    name="images"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], allow_credentials=True,
    allow_methods=["*"], allow_headers=["*"],
)

@app.get("/leaflet-map", response_class=HTMLResponse)
def serve_leaflet_map():
    with open(os.path.join(os.path.dirname(__file__), "LeafletMap.html"), encoding="utf-8") as f:
        return f.read()

@app.get("/playgrounds")
def get_playgrounds():
    db = SessionLocal()
    try:
        return db.query(Playground).all()
    finally:
        db.close()
