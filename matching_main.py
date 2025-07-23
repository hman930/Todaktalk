from .matching_engine import run_recommendation
import pandas as pd
import json
from datetime import datetime
import firebase_admin
from firebase_admin import credentials, firestore

# 🔐 Firebase 연결
import os
cred_path = os.path.join(os.path.dirname(__file__), "your.json")
cred = credentials.Certificate(cred_path)
firebase_admin.initialize_app(cred)
db = firestore.client()

# ✅ 모든 유저 데이터 불러오기 (자녀 수만큼 펼침)
def get_all_user_children():
    docs = db.collection("users").stream()
    rows = []
    for doc in docs:
        user_id = doc.id
        data = doc.to_dict()
        parent_nickname = data.get("parent_nickname", "알 수 없음")
        children = data.get("children", [])
        for child in children:
            row = {
                "user_id": user_id,
                "region_address": child.get("region_address", "unknown"),
                "region_lat": child.get("region_lat", 0.0),
                "region_lng": child.get("region_lng", 0.0),
                "child_birthdate": child.get("child_birthdate", "2020-01-01"),
                "child_gender": child.get("gender", "M"),
                "child_personality": child.get("personality", "기타"),
                "preferred_activities": ",".join(child.get("preferred_activities", [])),
                "parent_nickname": parent_nickname  # ✅ 여기에 추가
            }
            rows.append(row)
    return pd.DataFrame(rows)


# ✅ 유저 1명 정보 가져오기
def get_target_child_info(user_id):
    doc = db.collection("users").document(user_id).get()
    if doc.exists:
        data = doc.to_dict()
        idx = data.get("matching_target_index", 0)
        children = data.get("children", [])
        if 0 <= idx < len(children):
            child = children[idx]
            return {
                "user_id": user_id,
                "child_birthdate": child.get("child_birthdate"),
                "child_gender": child.get("gender"),  # ✅ 여기!
                "child_personality": child.get("personality"),
                "preferred_activities": child.get("preferred_activities", []),
                "region_lat": child.get("region_lat"),
                "region_lng": child.get("region_lng"),
            }
    return None

# ✅ 로그 가져오기
def get_user_logs(user_id):
    from google.cloud.firestore_v1.base_query import FieldFilter
    docs = db.collection("logs").where(filter=FieldFilter("user_id", "==", user_id)).stream()
    return pd.DataFrame([doc.to_dict() for doc in docs])

# ✅ 디버깅 포함 전체 실행
if __name__ == "__main__":
    target_user = "U0001"

    static_df = get_all_user_children()
    target_info = get_target_child_info(target_user)
    user_logs = get_user_logs(target_user)

    # 🔍 디버깅 print
    print("🎯 Target Info:")
    print(target_info)
    print("\n📦 Static DF (head):")
    print(static_df.head())
    print("\n📘 User Logs:")
    print(user_logs.head())

    if not target_info:
        print("❌ Target user info not found.")
    else:
        top_5 = run_recommendation(
            static_df,
            user_logs,
            target_user,
            target_info,
            target_info.get("region_lat", 0.0),
            target_info.get("region_lng", 0.0)
        )
        print("\n✅ TOP 5 Recommendations:")
        print(top_5[["user_id", "dynamic_score"]])
