import pandas as pd
import numpy as np
from sklearn.preprocessing import OneHotEncoder, MultiLabelBinarizer
from sklearn.metrics.pairwise import euclidean_distances
from collections import defaultdict
from math import radians, sin, cos, sqrt, atan2
from datetime import datetime

# 🔹 날짜 계산 함수 — 문자열 또는 Firestore datetime 모두 지원
def calculate_age_in_months(birthdate_input):
    if birthdate_input is None:
        return 0
    if isinstance(birthdate_input, str):
        try:
            birthdate = datetime.strptime(birthdate_input, "%Y-%m-%d")
        except ValueError:
            return 0
    else:
        try:
            birthdate = birthdate_input.replace(tzinfo=None)
        except:
            return 0
    today = datetime.today()
    return (today.year - birthdate.year) * 12 + (today.month - birthdate.month)

# 🔹 거리 계산 함수
def haversine(lat1, lon1, lat2, lon2):
    R = 6371
    dlat = radians(lat2 - lat1)
    dlon = radians(lon2 - lon1)
    a = sin(dlat/2)**2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon/2)**2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))
    return R * c

# 🔸 추천 알고리즘
def run_recommendation(static_df, user_logs, target_user, target_info, target_lat, target_lng, offset=0, top_k=5):
    static_df = static_df.dropna(subset=["region_lat", "region_lng", "child_birthdate", "child_gender"])
    static_df["child_age_months"] = static_df["child_birthdate"].apply(calculate_age_in_months)
    static_df["preferred_activities"] = static_df["preferred_activities"].apply(
        lambda x: x.split(",") if isinstance(x, str) and x.strip() != "" else ["기타"]
    )
    static_df["child_personality"] = static_df["child_personality"].fillna("기타")

    # ✅ 본인 제거 먼저
    static_df = static_df[static_df["user_id"] != target_user].copy()

    # ✅ 거리 계산
    static_df["geo_distance_km"] = static_df.apply(
        lambda row: haversine(target_lat, target_lng, row["region_lat"], row["region_lng"]), axis=1
    )

    # ✅ 거리 필터링 (3km 이하 등)
    filtered_df = static_df[static_df["geo_distance_km"] <= 5.0].copy()

    def score_by_distance(km):
        if km <= 3.0:
            return 5
        elif km <= 4.0:
            return 3
        elif km <= 5.0:
            return 1
        else:
            return 0

    filtered_df["distance_score"] = filtered_df["geo_distance_km"].apply(score_by_distance)

    def prepare_feature_matrix(df):
        base = pd.DataFrame()
        base["age"] = df["child_age_months"]
        base["gender"] = df["child_gender"].apply(lambda g: 0 if g == "M" else 1 if g == "F" else np.nan)
        base["personality"] = df["child_personality"]

        ohe = OneHotEncoder(handle_unknown="ignore")
        personality_encoded = ohe.fit_transform(base[["personality"]]).toarray()
        personality_df = pd.DataFrame(personality_encoded, columns=ohe.get_feature_names_out(["personality"]))

        mlb = MultiLabelBinarizer()
        activities_encoded = mlb.fit_transform(df["preferred_activities"])
        activities_df = pd.DataFrame(activities_encoded, columns=mlb.classes_)

        feature_matrix = pd.concat(
            [base[["age", "gender"]].reset_index(drop=True),
             personality_df.reset_index(drop=True),
             activities_df.reset_index(drop=True)],
            axis=1
        ).dropna()

        return feature_matrix, ohe, mlb

    def encode_single_user(row, ohe, mlb):
        age = calculate_age_in_months(row.get("child_birthdate", "2020-01-01"))
        gender = row.get("child_gender", "M")
        gender_val = 0 if gender == "M" else 1
        personality = row.get("child_personality") or "기타"
        activities = row.get("preferred_activities") or ["기타"]
        if isinstance(activities, str):
            activities = activities.split(",")

        personality_encoded = ohe.transform(pd.DataFrame([[personality]], columns=["personality"])).toarray()
        activities_encoded = mlb.transform([activities])

        return pd.DataFrame([[age, gender_val]], columns=["age", "gender"]).join(
            pd.DataFrame(personality_encoded, columns=ohe.get_feature_names_out(["personality"]))
        ).join(
            pd.DataFrame(activities_encoded, columns=mlb.classes_)
        )

    feature_matrix, ohe, mlb = prepare_feature_matrix(filtered_df)
    if feature_matrix.empty:
        return pd.DataFrame()

    target_vector = encode_single_user(target_info, ohe, mlb).values.reshape(1, -1)
    distances = euclidean_distances(target_vector, feature_matrix).flatten()
    filtered_df["knn_distance"] = distances
    filtered_df["knn_score"] = -filtered_df["knn_distance"]

    if "action_type" in user_logs.columns and "action_result" in user_logs.columns:
        exclude_ids = set(
            user_logs[
                (user_logs["action_type"] == "like") &
                (user_logs["action_result"] == "accepted")
            ]["target_user_id"]
        )
    else:
        exclude_ids = set()

    filtered_df = filtered_df[~filtered_df["user_id"].isin(exclude_ids)].copy()

    action_score = {
        ("click_profile", ""): 0.5,
        ("like", "rejected"): 1.0,
        ("reject", "rejected"): -3.0,
        ("skip", ""): -1.5,
        ("no_action", ""): -0.5,
    }

    score_map = defaultdict(float)
    if all(col in user_logs.columns for col in ["action_type", "action_result", "target_user_id"]):
        for _, row in user_logs.iterrows():
            result = row["action_result"] if pd.notna(row["action_result"]) else ""
            key = (row["action_type"], result)
            score = action_score.get(key, 0.0)
            score_map[row["target_user_id"]] += score

    filtered_df["dynamic_score"] = filtered_df["user_id"].apply(lambda uid: score_map.get(uid, 0.0))
    # 점수 계산
    filtered_df["total_score"] = (
            filtered_df["distance_score"] +
            filtered_df["knn_score"] +
            filtered_df["dynamic_score"]
    )

    # 🔽 성능 개선을 위한 사전 필터링
    pre_top = filtered_df.nlargest(50, "total_score")

    # ✅ offset과 top_k를 활용해 원하는 순위 범위 추천
    top_n = pre_top.iloc[offset:offset + top_k].copy()

    return top_n
