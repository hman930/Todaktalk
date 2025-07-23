//
//  SignUpFlowView.swift
//  Childcare_crew
//
//  Created by 안혜민 on 6/1/25.
//

import Foundation
import SwiftUI

struct SignUpFlowView: View {
    @Binding var kakaoId: String
    @Binding var isLoggedIn: Bool

    var body: some View {
        NavigationStack {
            SignUpFormView(kakaoId: $kakaoId, isLoggedIn: $isLoggedIn)
        }
    }
}
