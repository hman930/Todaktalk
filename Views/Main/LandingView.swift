//
//  LandingView.swift
//  Childcare_crew
//
//  Created by 안혜민 on 4/22/25.
//

import Foundation
import SwiftUI

struct LandingView: View {
    @Binding var isLoggedIn: Bool
    @Binding var kakaoId: String
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Image("todaktok_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160)

                // 카카오 로그인 버튼
                NavigationLink(destination: LoginView(isLoggedIn: $isLoggedIn, kakaoId: $kakaoId)) {
                    Text("카카오로 시작하기")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }

                Spacer()
            }
            .padding()
        }
    }
}
