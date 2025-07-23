# chatbot/schedule_alert.py

from datetime import datetime, time

# 🔹 시간대 기반 보육 알림 메시지를 반환하는 함수
def schedule_reminder(current_time: time) -> str:
    """
    현재 시간(current_time)을 받아서 시간대에 맞는 챗봇 메시지를 반환합니다.
    """

    # 알림 메시지 초기화
    msg = ""

    # 1️⃣ 등원 시간대: 오전 8시 30분 ~ 9시 30분
    if time(8, 30) <= current_time <= time(9, 30):
        msg = "🧸 아이가 등원하는 시간이에요! 오늘도 좋은 하루 보내요 😊"

    # 2️⃣ 하원 시간대 (기본보육 종료): 오후 3시 30분 ~ 4시
    elif time(15, 30) <= current_time <= time(16, 0):
        msg = "🎒 지금은 하원 시간이에요! 아이를 마중 나갈 준비 되셨나요?"

    # 3️⃣ 연장 보육 시간대: 오후 4시 ~ 오후 7시 30분
    elif time(16, 0) <= current_time <= time(19, 30):
        msg = "⏰ 연장 보육 시간입니다. 아직 원에 있는 아이들도 많아요."

    # 4️⃣ 야간 보육 시간대: 오후 7시 30분 ~ 밤 12시
    elif time(19, 30) <= current_time <= time(23, 59):
        msg = "🌙 야간 보육이 진행 중일 수 있어요. 안전히 돌봄 받고 있는지 확인해보세요."

    # 5️⃣ 심야 보육 시간: 밤 12시 ~ 오전 7시 30분
    elif time(0, 0) <= current_time < time(7, 30):
        msg = "🌙 심야 보육 또는 24시간 보육 대상 아이가 있을 수 있어요."

    # 그 외 시간대
    else:
        msg = "👶 지금은 보육 시간이 아닐 수 있어요. 궁금한 점이 있다면 언제든지 물어보세요!"

    return msg

# 🔹 이 파일을 단독 실행할 경우, 현재 시간으로 테스트 가능
if __name__ == "__main__":
    now = datetime.now().time()
    print("현재 시간:", now.strftime("%H:%M"))
    print("🤖 챗봇 메시지:", schedule_reminder(now))
