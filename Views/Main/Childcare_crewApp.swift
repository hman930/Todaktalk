//
//  Childcare_crewApp.swift
//  Childcare_crew
//
//  Created by 안혜민 on 3/29/25.
//

import SwiftUI
import FirebaseCore
import KakaoSDKCommon

@main
struct Childcare_crewApp: App {
    @State private var kakaoId: String = ""
    @State private var isLoggedIn: Bool = false

    init() {
        FirebaseApp.configure()
        KakaoSDK.initSDK(appKey: "5e107fbe70feb9dd8e168189eed89d0c")
    }

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                MainAppView(kakaoId: kakaoId)
            } else {
                SplashView(isLoggedIn: $isLoggedIn, kakaoId: $kakaoId)
            }
        }
    }
}
