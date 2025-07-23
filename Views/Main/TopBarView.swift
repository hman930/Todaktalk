////
////  TopBarView.swift
////  Childcare_crew
////
////  Created by 안혜민 on 6/2/25.
////
////
//import Foundation
//import SwiftUI
//import Firebase
//
//struct TopBarView: View {
//    let kakaoId: String
//
//    @State private var nickname: String = "사용자"
//
//    var onAlertTapped: () -> Void = {}
//    var onMenuTapped: () -> Void = {}
//
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 2) {
//                HStack(spacing: 4) {
//                    Image("todaktok_logo_icon")
//                        .resizable()
//                        .frame(width: 18, height: 18)
//                    Text("토닥톡")
//                        .font(.caption)
//                        .foregroundColor(.pink)
//                }
//                Text(nickname)
//                    .font(.footnote)
//                    .foregroundColor(.pink)
//            }
//
//            Spacer()
//
//            HStack(spacing: 16) {
//                Button(action: onAlertTapped) {
//                    Image(systemName: "bell")
//                        .foregroundColor(.black)
//                }
//                Button(action: onMenuTapped) {
//                    Image(systemName: "line.3.horizontal")
//                        .foregroundColor(.black)
//                }
//            }
//        }
//        .padding(.horizontal)
//        .padding(.top, 12)
//        .padding(.bottom, 8)
//        .background(Color.white)
//        .onAppear {
//            fetchNickname()
//        }
//    }
//
//    private func fetchNickname() {
//        Firestore.firestore().collection("users").document(kakaoId).getDocument { doc, error in
//            if let doc = doc, doc.exists {
//                self.nickname = doc.get("parent_nickname") as? String ?? "사용자"
//            }
//        }
//    }
//}
