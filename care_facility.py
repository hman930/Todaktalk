#-------야간보육 시설-------#

# chatbot/care_facility.py

import pandas as pd
import re
import os
from chatbot.hybrid_bot import HybridBot


# 서울 지역 리스트
SEOUL_REGIONS = [
    "강남구", "강동구", "강북구", "강서구", "관악구", "광진구", "구로구", "금천구",
    "노원구", "도봉구", "동대문구", "동작구", "마포구", "서대문구", "서초구",
    "성동구", "성북구", "송파구", "양천구", "영등포구", "용산구", "은평구", "종로구", "중구", "중랑구"
]

# 🔹 지역명 추출 함수
def extract_region(text: str):
    for region in SEOUL_REGIONS:
        if region in text:
            return region
    return None

# 🔹 야간보육 시설 필터링 함수
def get_night_care(region: str) -> list:
    # 현재 파일 기준 절대 경로 지정
    base_dir = os.path.dirname(os.path.abspath(__file__))
    file_path = os.path.join(base_dir, "data", "서울시 어린이집 정보.csv")

    df = pd.read_csv(file_path, encoding="utf-8")
    df_night = df[df['제공서비스'].fillna('').str.contains("야간연장형")]
    result = df_night[df_night['시군구명'] == region]

    return result[['어린이집명', '상세주소', '전화번호', '제공서비스']].to_dict(orient="records")

# 🔹 자연어 입력 → 챗봇 응답
def chatbot_response(user_input: str):
    region = extract_region(user_input)
    if not region:
        return "죄송해요. 말씀하신 지역을 찾을 수 없어요. '강남구'처럼 입력해 주세요 😊"

    try:
        results = get_night_care(region)
    except Exception as e:
        return f"⚠️ 오류가 발생했어요: {str(e)}"

    if not results:
        return f"{region}에는 현재 운영 중인 야간보육 어린이집이 없어요."

    reply = f"✅ {region}의 야간보육 어린이집 정보예요!\n"
    for item in results[:3]:
        reply += f"\n🏠 {item['어린이집명']}\n📍 {item['상세주소']}\n📞 {item['전화번호']}\n"

    if len(results) > 3:
        reply += f"\n총 {len(results)}곳 중 일부만 보여드렸어요 😊"

    return reply

# 🧪 콘솔에서 테스트할 수 있도록 유지 (선택)
if __name__ == "__main__":
    print("\n👶 육아 챗봇 테스트")
    while True:
        user = input("👩 사용자 질문: ")
        if user.lower() in ['exit', 'quit']:
            break
        bot = chatbot_response(user)
        print(f"🤖 챗봇: {bot}\n")
