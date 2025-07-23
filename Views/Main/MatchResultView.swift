//
//  MatchResultView.swift
//  Childcare_crew
//
//  Created by 안혜민 on 5/24/25.
//

import Foundation
import SwiftUI
import Firebase

struct MatchResultView: View {
    let friends: [Friend]
    let kakaoId: String  // ✅ 부모 카카오 ID 전달
    var onRequestAgain:((Int) -> Void)?

    @State private var currentIndex = 0
    @State private var recommendationCount = 1
    @State private var parentNickname: String = "사용자"

    var body: some View {
        if friends.isEmpty {
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: "person.crop.circle.badge.exclamationmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                Text("추천된 친구가 없어요 😢")
                    .font(.title3)
                    .foregroundColor(.gray)
                Text("조건을 바꿔 다시 시도해보세요.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Button("닫기") {
                    // ❗️상위 View에서 dismiss 처리 필요
                }
                .padding()
                .background(Color("AccentColor"))
                .foregroundColor(.white)
                .cornerRadius(20)
                Spacer()
            }
        } else {
            VStack(spacing: 20) {
                // MARK: - 상단 바
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
                    .foregroundColor(.black)
                }
                .padding(.horizontal)

                VStack(alignment: .leading) {
                    Text("🎉 \(parentNickname)님, 친구를 찾았습니다!")
                        .font(.title3)
                        .bold()
                        .foregroundColor(Color("AccentColor"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                Spacer()

                // MARK: - 친구 카드 (드래그 방식)
                TabView(selection: $currentIndex) {
                    ForEach(friends.indices, id: \.self) { index in
                        VStack(spacing: 12) {
                            Text(friends[index].name)
                                .font(.title2)
                                .foregroundColor(.gray)
                                .bold()

                            VStack(spacing: 8) {
                                ForEach(friends[index].tags, id: \.self) { tag in
                                    Text(tag)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(Color("AccentColor"))
                                        .foregroundColor(.white)
                                        .cornerRadius(20)
                                }
                            }
                            .padding()
                        }
                        .padding()
                        .frame(width: UIScreen.main.bounds.width * 0.75)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color("AccentColor"), lineWidth: 3)
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 400)

                // MARK: - 하단 버튼
                VStack(spacing: 16) {
                    Button("채팅 하기") {
                        print("채팅으로 이동")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("AccentColor"))
                    .foregroundColor(.white)
                    .cornerRadius(30)

                    Button("다시 추천 받기") {
                        recommendationCount += 1
                        currentIndex = 0
                        onRequestAgain?(recommendationCount)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("AccentColor"))
                    .foregroundColor(.white)
                    .cornerRadius(30)

                    if recommendationCount >= 3 {
                        Text("세번째는 매칭 점수가 낮을 수 있어요.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 40)

                Spacer()
            }
            .padding(.top)
            .onAppear {
                Firestore.firestore().collection("users").document(kakaoId).getDocument { doc, error in
                    if let doc = doc, doc.exists {
                        self.parentNickname = doc.get("parent_nickname") as? String ?? "사용자"
                    }
                }
            }
        }
    }
}
