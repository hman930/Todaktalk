#-------접종 스케줄 계산 로직-------#
# vaccine_scheduler.py
#uvicorn chatbot.vaccine_main:app --reload

from datetime import datetime, timedelta

# 접종 스케줄 정의
vaccine_schedule = [
    {"vaccine": "HepB", "doses": [0, 1, 6]},
    {"vaccine": "DTaP", "doses": [2, 4, 6, 15, 48]},
    {"vaccine": "MMR", "doses": [12, 48]},
]

def calculate_vaccine_schedule(birthdate_str, only_next=False):
    birthdate = datetime.strptime(birthdate_str, "%Y-%m-%d").date()
    today = datetime.today().date()

    # 생후 개월 수 계산
    age_in_months = (today.year - birthdate.year) * 12 + (today.month - birthdate.month)
    if today.day < birthdate.day:
        age_in_months -= 1

    result = []

    for vac in vaccine_schedule:
        vaccine_results = []
        found_next = False

        for month in vac["doses"]:
            due_date = birthdate + timedelta(weeks=month * 4.345)
            overdue = age_in_months >= month

            vaccine_info = {
                "백신": vac["vaccine"],
                "예정 접종월령": f"{month}개월",
                "예상 접종일": due_date.strftime("%Y-%m-%d"),
                "지남 여부": overdue
            }
            vaccine_results.append(vaccine_info)

            # only_next가 True면 아직 지나지 않은 첫 번째만 유지
            if only_next and not overdue and not found_next:
                result.append(vaccine_info)
                found_next = True

        if only_next and not found_next:
            # 모두 지난 경우 마지막 하나만
            result.append(vaccine_results[-1])

        if not only_next:
            result.extend(vaccine_results)

    return result
