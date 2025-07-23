//
//  RootView.swift
//  Childcare_crew
//
//  Created by 안혜민 on 6/1/25.
//

import Foundation
import SwiftUI

struct RootView: View {
    @State private var isLoggedIn = false
    @State private var kakaoId: String = ""

    var body: some View {
        if isLoggedIn {
            MainAppView(kakaoId: kakaoId)
        } else {
            SignUpFlowView(kakaoId: $kakaoId, isLoggedIn: $isLoggedIn)
        }
    }
}
