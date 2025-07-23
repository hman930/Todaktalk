import Foundation
import SwiftUI
import KakaoSDKUser
import FirebaseFirestore

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @Binding var kakaoId: String
    @State private var showSignUpForm = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // MARK: 로고
                Image("todaktok_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140)

                // MARK: 로그인 버튼 영역
                VStack(spacing: 16) {

                    // ✅ 카카오 로그인 버튼
                    Button(action: {
                        loginWithKakao()
                    }) {
                        Image("login/kakao_login")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 44)
                    }

                    // ✅ 네이버 로그인 버튼
                    Button(action: {
                        print("네이버 로그인")
                        // TODO: 네이버 로그인 로직 연결
                    }) {
                        Image("login/naver_login")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 250, height: 48)
                    }

                    // ✅ 이메일 로그인
                    NavigationLink(destination: EmailLoginView()) {
                        Text("이메일로 로그인하기")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                            .padding(.top, 6)
                    }
                }

                Spacer()

//                 ✅ 테스트 로그인 (임시)
                Button(action: {
                    kakaoId = "U0001"
                    isLoggedIn = true
                }) {
                    Text("테스트 로그인 (U0001)")
                        .frame(width: 250, height: 40)
                        .background(Color.gray.opacity(0.15))
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal)
            .navigationDestination(isPresented: $showSignUpForm) {
                SignUpFormView(kakaoId: $kakaoId, isLoggedIn: $isLoggedIn)
            }
        }
    }

    // MARK: 카카오 로그인
    func loginWithKakao() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { token, error in
                if token != nil {
                    getUserInfo()
                } else {
                    print("❌ 카카오톡 로그인 실패: \(error?.localizedDescription ?? "")")
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { token, error in
                if token != nil {
                    getUserInfo()
                } else {
                    print("❌ 카카오 계정 로그인 실패: \(error?.localizedDescription ?? "")")
                }
            }
        }
    }

    // MARK: 유저 정보 + 파이어스토어 연동
    func getUserInfo() {
        UserApi.shared.me { user, error in
            if let user = user {
                let kakaoId = "\(user.id ?? 0)"
                self.kakaoId = kakaoId

                let db = Firestore.firestore()
                let userRef = db.collection("users").document(kakaoId)

                userRef.getDocument { document, error in
                    if let document = document, document.exists {
                        DispatchQueue.main.async {
                            isLoggedIn = true
                        }
                    } else {
                        DispatchQueue.main.async {
                            showSignUpForm = true
                        }
                    }
                }
            } else {
                print("❌ 사용자 정보 가져오기 실패: \(error?.localizedDescription ?? "")")
            }
        }
    }
}
