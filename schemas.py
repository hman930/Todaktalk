from pydantic import BaseModel
from typing import Optional

class PlaygroundSchema(BaseModel):
    facility_id: int
    facility_name: str
    address: str
    district: str
    substrict: str
    location_type: str
    latitude: float
    longitude: float
    toddler_population: Optional[int]
    safety_score: Optional[int]
    accessibility: Optional[int]
    density: Optional[int]
    overall_score: Optional[int]

    class Config:
        from_attributes = True

