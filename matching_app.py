# app.py
#python -m matching.matching_app

from flask import Flask, request, jsonify
from flask_cors import CORS
from .matching_engine import run_recommendation
from .matching_main import get_all_user_children, get_target_child_info, get_user_logs

app = Flask(__name__)
CORS(app)  # ✅ iOS 등 외부 요청 허용

@app.route("/match", methods=["POST"])
def match():
    try:
        data = request.get_json()
        user_id = data.get("user_id")
        offset = int(data.get("offset", 0))

        if not user_id:
            return jsonify({"error": "user_id is required"}), 400

        # 🔍 Firebase에서 데이터 가져오기
        static_df = get_all_user_children()
        target_info = get_target_child_info(user_id)
        user_logs = get_user_logs(user_id)

        if not target_info:
            return jsonify({"error": "User info not found"}), 404

        # ✅ None 방지 및 float 변환
        try:
            target_lat = float(target_info.get("region_lat") or 0.0)
            target_lng = float(target_info.get("region_lng") or 0.0)
        except Exception as e:
            print("❌ 위도/경도 변환 실패:", e)
            return jsonify({"error": "Invalid region coordinates"}), 500

        # 🧠 추천 알고리즘 실행
        top_matches = run_recommendation(
            static_df,
            user_logs,
            user_id,
            target_info,
            target_lat,
            target_lng,
            offset = offset,
            top_k=5
        )

        # 📦 응답 구성
        matched = []
        for _, row in top_matches.iterrows():
            tags = [
                row.get("child_personality", ""),
                *row.get("preferred_activities", []),
                row.get("region_address", ""),
                f"{int(row.get('child_age_months') or 0)}개월"
            ]

            matched.append({
                "name": row.get("parent_nickname", "알 수 없음"),
                "tags": tags
            })

        return jsonify({"results": matched})


    except Exception as e:
        print("❌ 오류 발생:", e)  # ← 이 부분 꼭 추가!
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(debug=True, port=5000)
