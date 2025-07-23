import Foundation
import SwiftUI
import MapKit
import UIKit
import FirebaseFirestore

struct HomeView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5, longitude: 127.0),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )

    @State private var showChatbot = false
    let kakaoId: String
    @State private var parentNickname: String = "사용자"

    @State private var nextVaccineDays: Int? = 3
    @State private var nextVaccineName: String? = "DTaP"
    @State private var randomNotice: String? = nil

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        // MARK: 상단 유저 인사 및 아이콘
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

                        // ✅ 추가: 인사 텍스트
                        Text("\(parentNickname)님 안녕하세요!")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color("AccentColor"))
                            .padding(.horizontal)

                        // MARK: 커뮤니티 인기글
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("커뮤니티 인기글")
                                    .font(.headline)
                                Spacer()
                                NavigationLink(destination: CommunityView()) {
                                    Text("전체보기 >")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }

                            VStack(spacing: 10) {
                                CommunityPostView(
                                    text: "최근에 아이랑 다녀온 키즈카페 추천해요~!",
                                    likes: 100,
                                    comments: 16,
                                    views: 212
                                )
                                CommunityPostView(
                                    text: "아이 장난감 너무 비싸네요ㅠㅠ",
                                    likes: 58,
                                    comments: 20,
                                    views: 158
                                )
                                CommunityPostView(
                                    text: "아이가 너무 편식하네요. 선배님들 조언 구합니다..",
                                    likes: 342,
                                    comments: 56,
                                    views: 532
                                )
                            }
                        }
                        .padding(.horizontal)

                        // MARK: 놀이터 알아보기
                        VStack(alignment: .leading, spacing: 12) {
                            Text("오늘은 어디서 놀까?")
                                .font(.headline)

                            NavigationLink(destination: PlaygroundContainerView()) {
                                VStack(spacing: 0) {
                                    ZStack(alignment: .bottomLeading) {
                                        Map(coordinateRegion: .constant(MKCoordinateRegion(
                                            center: CLLocationCoordinate2D(latitude: 37.5056, longitude: 127.1166), // 예: 송파구
                                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                        )))
                                        .frame(height: 160)
                                        .cornerRadius(12)
                                        .disabled(true) // 👉 확대/클릭 방지
                                        .allowsHitTesting(false)

                                        Text("어느 놀이터로 가볼까요? 👉")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.black.opacity(0.5))
                                            .cornerRadius(8)
                                            .padding(12)
                                    }
                                }
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                            }
                        }
                        .padding(.horizontal)

                        // MARK: 놀이 추천
                        VStack(alignment: .leading, spacing: 12) {
                            Text("놀이 추천")
                                .font(.headline)

                            VStack(spacing: 16) {
                                PlayCardHorizontal(title: "송파구 놀이체험실")
                                PlayCardHorizontal(title: "강남구 놀이체험실")
                                PlayCardHorizontal(title: "송파 어린이 문화회관")
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }

                // MARK: 플로팅 챗봇 버튼 + 말풍선
                ZStack(alignment: .topTrailing) {
                    Button(action: {
                        showChatbot = true
                    }) {
                        Image("chatbot_icon")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }

                    if let message = alertBubbleMessage() {
                        Text(message)
                            .font(.caption2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.pink.opacity(0.85))
                            .cornerRadius(12)
                            .offset(x: 8, y: -12)
                            .transition(.scale)
                    }
                }
                .padding(.bottom, 30)
                .padding(.trailing, 20)
                .sheet(isPresented: $showChatbot) {
                    ChatbotView(kakaoId: kakaoId)
                }
                .onAppear {
                    fetchNickname()
                    pickRandomNotice()
                }
            }
        }
    }

    private func alertBubbleMessage() -> String? {
        if let days = nextVaccineDays, let name = nextVaccineName, days <= 7 {
            return balloonText(for: days, name: name)
        } else if let random = randomNotice {
            return random
        } else {
            return nil
        }
    }

    private func balloonText(for days: Int, name: String) -> String {
        switch days {
        case 0: return "오늘! \(name) 접종 🩹"
        case 1: return "내일 \(name) 접종 예정"
        default: return "\(days)일 뒤 \(name) 접종!"
        }
    }

    private func pickRandomNotice() {
        let messages = [
            "오늘은 어린이날이에요 🎈",
            "근처에 새 놀이터가 생겼어요!",
            "챗봇에게 궁금한 걸 물어보세요 🤖",
            "아이의 성장 기록도 입력해보세요!",
            "🎉 무료 체험 이벤트가 있어요!"
        ]
        randomNotice = messages.randomElement()
    }

    private func fetchNickname() {
        Firestore.firestore().collection("users").document(kakaoId).getDocument { doc, error in
            if let doc = doc, doc.exists {
                self.parentNickname = doc.get("parent_nickname") as? String ?? "사용자"
            }
        }
    }
}

// MARK: - 카드형 플레이 아이템
struct PlayCardHorizontal: View {
    var title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(Color("AccentColor"))
                .multilineTextAlignment(.leading)

            Spacer()

            Image(systemName: "arrow.right")
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .foregroundColor(.black)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("AccentColor"), lineWidth: 2)
        )
        .cornerRadius(12)
    }
}
