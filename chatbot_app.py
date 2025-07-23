from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from chatbot.care_facility import get_night_care, extract_region
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# ✅ CORS 허용 (iOS 연동 시 필수)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 실제 배포 시 도메인 제한 필요
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class RegionRequest(BaseModel):
    region: str

@app.post("/night_care")
def night_care_endpoint(request: RegionRequest):
    # ✅ 문장에서 자치구명 추출
    region = extract_region(request.region)
    if not region:
        raise HTTPException(status_code=400, detail="서울의 자치구명을 포함해 주세요. 예: '강남구 야간보육'")

    try:
        results = get_night_care(region)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    if not results:
        raise HTTPException(status_code=404, detail=f"{region}에는 야간보육 어린이집이 없습니다.")

    return {
        "results": results[:3],  # 최대 3개만 반환
        "total_count": len(results),
        "region": region
    }
