# chatbot/main.py

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from .vaccine_scheduler import calculate_vaccine_schedule

app = FastAPI()

# 요청 형식 정의
class VaccineRequest(BaseModel):
    birthdate: str         # 생년월일 (형식: "YYYY-MM-DD")
    only_next: bool = True # True면 다음 일정만, False면 전체 일정

# 통합 API 엔드포인트
@app.post("/vaccine_schedule")
def vaccine_schedule(req: VaccineRequest):
    try:
        result = calculate_vaccine_schedule(req.birthdate, only_next=req.only_next)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"예방접종 계산 중 오류: {str(e)}")

