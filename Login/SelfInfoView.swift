import Foundation
import SwiftUI
import FirebaseFirestore

struct SelfInfoView: View {
    let kakaoId: String  // 🔸 부모 뷰에서 전달받음
    @Binding var isLoggedIn: Bool

    @State private var selfIntro: String = ""
    @State private var characterLimit = 100
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 상단 진행 바
                ProgressView(value: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color.softPink))
                    .padding(.horizontal)

                // 제목
                VStack(alignment: .leading, spacing: 4) {
                    Text("간단한 자기소개를 입력해주세요.")
                        .font(.title2).bold()
                    Text("입력은 선택사항이에요. 자유롭게 작성해주세요. :)")
                        .font(.subheadline).foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                // 텍스트 박스
                VStack(alignment: .leading, spacing: 8) {
                    Text("자기소개").foregroundColor(Color.softPink)

                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.softPink, lineWidth: 1)
                            .background(Color.white)

                        TextEditor(text: $selfIntro)
                            .frame(height: 150)
                            .padding(8)
                            .onChange(of: selfIntro) { newValue in
                                if newValue.count > characterLimit {
                                    selfIntro = String(newValue.prefix(characterLimit))
                                }
                            }
                    }

                    Text("(\(selfIntro.count)/\(characterLimit)자)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal)

                // ✅ 완료 버튼 → Firestore 저장 & 로그인 완료 처리
                Button("완 료") {
                    print("✅ [SelfInfoView] 완료 버튼 눌림")

                    let db = Firestore.firestore()
                    print("✅ [Firestore] 인스턴스 생성됨")

                    db.collection("users").document(kakaoId).setData([
                        "self_intro": selfIntro
                    ], merge: true) { error in
                        if let error = error {
                            print("❌ [Firestore] 저장 실패: \(error.localizedDescription)")
                        } else {
                            print("✅ [Firestore] 저장 성공, ID: \(kakaoId)")
                            DispatchQueue.main.async {
                                isLoggedIn = true
                                print("✅ [Navigation] isLoggedIn = true → MainAppView 진입 조건 만족")
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.softPink)
                .foregroundColor(.white)
                .cornerRadius(20)
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Text("뒤로")
                        .foregroundColor(Color.softPink)
                        .bold()
                }
            }
        }
    }
}

