//
//  MainAppView.swift
//  Childcare_crew
//
//  Created by 안혜민 on 4/23/25.
//

import Foundation
import SwiftUI

struct MainAppView: View {
    let kakaoId: String
    @State private var selectedTab = 2

    var body: some View {
        TabView(selection : $selectedTab) {
            CommunityView()
                .tabItem {
                    Label("커뮤니티", systemImage: "globe")
                }
                .tag(0)

            MatchView(kakaoId: kakaoId)
                .tabItem {
                    Label("친구 찾기", systemImage: "person.2")
                }
                .tag(1)

            // ✅ 홈뷰는 가운데 탭
            HomeView(kakaoId: kakaoId)
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }
                .tag(2)

            PlayView()
                .tabItem {
                    Label("놀이·체험", systemImage: "cube.box")
                }
                .tag(3)

            NavigationStack {
                    SettingsView(kakaoId: kakaoId)
                }
                .tabItem {
                    Label("설정", systemImage: "gearshape")
                }
                .tag(4)
        }
        .accentColor(Color("AccentColor"))
    }
}

