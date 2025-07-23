//
//  SettingsView.swift
//  Childcare_crew
//
//  Created by 안혜민 on 2025/06/05.
//

import SwiftUI
import Firebase

struct SettingsView: View {
    let kakaoId: String
    @State private var parentNickname: String = ""

    var body: some View {
        VStack(spacing: 20) {
            // MARK: - 상단바
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image("todaktok_logo_vertical")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 32)
                    Spacer()
                    Image(systemName: "bell")
                    Image(systemName: "line.3.horizontal")
                }
                .foregroundColor(.black)

                Text("\(parentNickname) 프로필")
                    .font(.headline)
                    .foregroundColor(Color("AccentColor"))
                    .padding(.top, 4)
            }
            .padding(.horizontal)

            // MARK: - 일반 설정
            VStack(spacing: 0) {
                NavigationLink(destination: EditProfileView()) {
                    HStack {
                        Text("프로필 편집")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                }

                Divider()

                NavigationLink(destination: AppSettingsView()) {
                    HStack {
                        Text("앱 설정")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                }
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal)

            // MARK: - 아이 설정
            VStack(alignment: .leading, spacing: 12) {
                Text("아이 설정")
                    .font(.headline)
                    .padding(.horizontal)

                LazyVGrid(columns: [GridItem(), GridItem()], spacing: 16) {
                    NavigationLink(destination: DismissalSettingsView()) {
                        SettingTile(icon: "figure.and.child.holdinghands", title: "하원시간", color: Color.purple.opacity(0.2))
                    }

                    NavigationLink(destination: VaccineAlertView(kakaoId: kakaoId)) {
                        SettingTile(icon: "calendar.badge.plus", title: "백신알림", color: Color.cyan.opacity(0.2))
                    }

                    NavigationLink(destination: MembershipView()) {
                        SettingTile(icon: "person.3.fill", title: "멤버십 설정", color: Color.orange.opacity(0.2))
                    }

                    NavigationLink(destination: DevelopmentLogView()) {
                        SettingTile(icon: "figure.child.circle.fill", title: "아이 발달 기록", color: Color.pink.opacity(0.2))
                    }
                }
                .padding(.horizontal)
            }

            // MARK: - 소개
            Text("토닥톡 소개")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.horizontal)
                .padding(.top, 8)

           

            VStack(spacing: 8) {
                Text("또닥톡은 우리 아이의 성격과 관심사를 기반으로")
                Text("가장 잘 어울릴 친구를 찾아주는 맞춤형 친구 매칭 플랫폼입니다.")
                Text("AI 추천, 챗봇 상담, 지도 기반 기능으로")
                Text("부모와 아이 모두에게 따뜻한 연결을 전합니다.")
                Text(" ")
                Text("ⓒ 2025 Todaktalk")
                Text("모든 콘텐츠의 저작권은 또닥톡에 있으며, 무단 복제를 금합니다.")
            }
            .font(.caption)
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
            .padding(.horizontal)
            .padding(.bottom, 32) // 하단 여백
        }
        .padding(.top)
        .onAppear {
            Firestore.firestore().collection("users").document(kakaoId).getDocument { doc, error in
                if let doc = doc, doc.exists {
                    self.parentNickname = doc.get("parent_nickname") as? String ?? ""
                }
            }
        }
    }
}

// MARK: - 공통 아이템 타일
struct SettingTile: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width : 30, height: 30)
                .foregroundColor(.white)
                .padding(16)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
