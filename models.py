#uvicorn playground.playground_api.main:app --reload --host 0.0.0.0 --port 8001


# models.py
from sqlalchemy import Column, Integer, String, Float
from .database import Base

class Playground(Base):
    __tablename__ = "playgrounds"

    facility_id = Column(Integer, primary_key=True, index=True)
    facility_name = Column(String(100))
    address = Column(String(255))
    district = Column(String(50))
    substrict = Column(String(50))
    location_type = Column(String(50))
    latitude = Column(Float)
    longitude = Column(Float)
    toddler_population = Column(Integer)
    safety_score = Column(Integer)
    accessibility = Column(Integer)
    density = Column(Integer)
    overall_score = Column(Integer)
