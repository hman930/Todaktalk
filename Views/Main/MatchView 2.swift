//
//  MatchView 2.swift
//  Childcare_crew
//
//  Created by 안혜민 on 5/28/25.

import Foundation
import SwiftUI
import FirebaseFirestore

struct MatchView: View {
    @State private var parentNickname: String = "Loading..."
    let kakaoId: String

    var body: some View {
        VStack(spacing: 20) {
            // 상단 바
            HStack {
                Image("todaktok_logo_vertical")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 32)

                Spacer()

                HStack(spacing: 16) {
                    Image(systemName: "bell")
                    Image(systemName: "line.3.horizontal")
                }
                .font(.title3)
                .foregroundColor(.black)
            }
            .padding(.horizontal)

            // 유저 이름
            VStack(alignment: .leading, spacing: 4) {
                Text(parentNickname)
                    .font(.title3)
                    .bold()
                    .foregroundColor(Color("AccentColor"))

                Text("친구 찾기")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            Spacer()

            Image("matching_child_image")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)

            Text("선택한 자녀의 프로필을 기반으로 친구를 추천해드립니다.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: {
                print("친구 추천 알고리즘 실행!")
            }) {
                Text("친구 찾기")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(Color("AccentColor"))
                    .cornerRadius(30)
                    .padding(.horizontal, 40)
            }

            Spacer()
        }
        .onAppear {
            fetchNickname(for: kakaoId)
        }
    }

    // Firestore에서 닉네임 불러오기
    func fetchNickname(for userId: String) {
        let db = Firestore.firestore()
        let docRef = db.collection("parents").document(userId)

        docRef.getDocument { document, error in
            if let document = document, document.exists {
                self.parentNickname = document.get("parent_nickname") as? String ?? "알 수 없음"
            } else {
                print("❌ 사용자 정보 불러오기 실패")
            }
        }
    }
}
