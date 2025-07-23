//
//  SplashView.swift
//  Childcare_crew
//
//  Created by 안혜민 on 5/23/25.
//

import Foundation
import SwiftUI

struct SplashView: View {
    @Binding var isLoggedIn: Bool
    @Binding var kakaoId : String
    @State private var showLogo = false
    @State private var navigateToLogin = false

    var body: some View {
        ZStack {
            if navigateToLogin {
                LoginView(isLoggedIn: $isLoggedIn, kakaoId: $kakaoId)  // ✅ 여기서 로그인 상태 전달
            } else {
                Color.white.ignoresSafeArea()
                VStack {
                    if showLogo {
                        Image("todaktok_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160)
                    }
                }
                .onAppear {
                    withAnimation(.easeIn(duration: 1.5)) {
                        showLogo = true
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation(.easeOut(duration: 1.0)) {
                            showLogo = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            navigateToLogin = true
                        }
                    }
                }
            }
        }
    }
}
