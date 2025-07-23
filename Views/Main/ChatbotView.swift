import Foundation
import SwiftUI
import FirebaseFirestore

struct ChatMessage: Identifiable {
    let id = UUID()
    let isUser: Bool
    let text: String
}

struct ChatbotView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var nickname: String = "사용자"
    let kakaoId: String
    
    @State private var inputText: String = ""
    @State private var messages: [ChatMessage] = []
    
    let macroKeywords = ["인근 병원", "아이가 열나요", "인근 약국", "만 3살 육아", "근처 놀이터", "예방접종 일정", "성장 그래프"]
    
    var body: some View {
        VStack(spacing: 16) {
            
            // ✅ 상단 헤더 + 인사 + 키워드
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image("todaktok_logo_horizontal")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 28)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                }
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(nickname)님")
                            .font(.title3).bold().foregroundColor(.gray)
                        
                        Text("무엇을 도와드릴까요?")
                            .font(.title3).bold().foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image("chatbot_icon")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .shadow(color: .gray.opacity(0.3), radius: 4, x: 2, y: 2)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(macroKeywords, id: \.self) { keyword in
                            Button {
                                inputText = keyword
                            } label: {
                                Text(keyword)
                                    .font(.subheadline)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color("AccentColor").opacity(0.1))
                                    .foregroundColor(Color("AccentColor"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color("AccentColor"), lineWidth: 1.2)
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.horizontal)
            
            // ✅ 메시지 영역
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(messages) { msg in
                            HStack {
                                if msg.isUser {
                                    Spacer()
                                    Text(msg.text)
                                        .padding()
                                        .background(Color("AccentColor").opacity(0.2))
                                        .foregroundColor(.black)
                                        .cornerRadius(16)
                                } else {
                                    Text(msg.text)
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(16)
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                            .id(msg.id)
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.bottom, 90)
                    .onChange(of: messages.count) { _ in
                        withAnimation {
                            proxy.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // ✅ 입력창
            HStack {
                TextField("궁금한 사항을 입력해 주세요", text: $inputText)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(30)
                
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color("AccentColor"))
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .padding(.top)
        .onAppear {
            Firestore.firestore().collection("users").document(kakaoId).getDocument { doc, _ in
                if let doc = doc, doc.exists {
                    nickname = doc.get("parent_nickname") as? String ?? "사용자"
                }
            }
        }
    }
    
    // ✅ 메시지 전송 함수
    func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        messages.append(ChatMessage(isUser: true, text: trimmed))
        inputText = ""
        
        // 📌 분기 처리
        let macroTFIDF = ["인근 병원", "인근 약국"]
        let nightCareKeywords = ["야간보육", "야간연장", "야간 어린이집"]
        
        let isMacro = macroTFIDF.contains(trimmed)
        let isNightCare = nightCareKeywords.contains { trimmed.contains($0) }
        
        let endpoint: String
        if isMacro {
            endpoint = "http://127.0.0.1:5000/tfidf"
        } else if isNightCare {
            endpoint = "http://127.0.0.1:8002/night_care"
        } else {
            endpoint = "http://127.0.0.1:5000/chat"
        }
        
        let payload: [String: String] = isNightCare ?
            ["region": trimmed] :
            ["query": trimmed]
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                
                let reply = json["answer"] as? String ??
                            (json["results"] as? [[String: Any]])?
                            .prefix(3)
                            .map {
                                "🏠 \($0["어린이집명"] ?? "")\n📍 \($0["상세주소"] ?? "")\n📞 \($0["전화번호"] ?? "")"
                            }
                            .joined(separator: "\n\n") ??
                            "⚠️ 응답 파싱 실패"
                
                DispatchQueue.main.async {
                    messages.append(ChatMessage(isUser: false, text: reply))
                }
            } else {
                DispatchQueue.main.async {
                    messages.append(ChatMessage(isUser: false, text: "⚠️ 서버 응답 오류"))
                }
            }
        }.resume()
    }
}
