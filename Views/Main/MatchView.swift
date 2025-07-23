import Foundation
import SwiftUI
import UIKit
import FirebaseFirestore

struct MatchView: View {
    let kakaoId: String

    @State private var matchedFriends: [Friend] = []
    @State private var isLoading = false
    @State private var showResult = false
    @State private var showHelp = false
    @State private var noMatches = false
    @State private var parentNickname: String = "사용자"
    @State private var recommendationCount = 1

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // MARK: - 상단 바
                HStack {
                    Image("todaktok_logo_vertical")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 32)

                    Spacer()

                    HStack(spacing: 16) {
                        Button(action: { showHelp = true }) {
                            Image(systemName: "questionmark.circle")
                        }

                        Image(systemName: "bell")
                        Image(systemName: "line.3.horizontal")
                    }
                    .font(.title3)
                    .foregroundColor(.black)
                }
                .padding(.horizontal)

                // MARK: - 유저 이름
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

                // MARK: - 가운데 아이 이미지
                Image("matching_child_image")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)

                // MARK: - 안내 텍스트
                Text("선택한 자녀의 프로필을 기반으로 친구를 추천해드립니다.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // MARK: - 친구 찾기 버튼
                Button(action: {
                    fetchMatches()
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

            // MARK: - 로딩 오버레이
            if isLoading {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 16) {
                    ProgressView("친구 추천 중이에요…")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(16)
                }
            }
        }
        // ✅ 결과 시트
        .sheet(isPresented: $showResult) {
            MatchResultView(
                friends: matchedFriends,
                kakaoId: kakaoId,
                onRequestAgain: {
                    count in
                    let offset = (count-1)*5
                    self.fetchMatches(offset: offset)
                })
        }
        // ✅ 친구 없음 알림
        .alert("친구가 없어요 😢", isPresented: $noMatches) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("현재 조건에 맞는 친구가 없어요.\n지역·정보를 다시 확인해보세요.")
        }
        // ✅ 부모 닉네임 로딩
        .onAppear {
            Firestore.firestore().collection("users").document(kakaoId).getDocument { doc, error in
                if let doc = doc, doc.exists {
                    self.parentNickname = doc.get("parent_nickname") as? String ?? "사용자"
                }
            }
        }
    }

    // MARK: - 서버 연동 함수
    func fetchMatches(offset: Int=0) {
        isLoading = true
        guard let url = URL(string: "http://127.0.0.1:5000/match") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body:[String:Any] = ["user_id": kakaoId, "offset": offset]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let results = json["results"] as? [[String: Any]] else {
                print("❌ 서버 응답 오류")
                return
            }

            DispatchQueue.main.async {
                if results.isEmpty {
                    self.noMatches = true
                    return
                }

                self.matchedFriends = results.map { dict in
                    Friend(
                        name: dict["name"] as? String ?? "알 수 없음",
                        tags: dict["tags"] as? [String] ?? []
                    )
                }
                self.showResult = true
            }
        }.resume()
    }
}

struct Friend {
    let name: String
    let tags: [String] // 성향, 놀이, 지역, 나이 등
}
