//
//  PlaygroundView.swift
//  Childcare_crew
//
//  Created by 안혜민 on 6/15/25.
//

import Foundation
import SwiftUI
import WebKit

struct PlaygroundWebView: UIViewRepresentable {
    var onSelect: (PlaygroundModel) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "markerTapped")

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: config)

        if let url = URL(string: "http://192.168.219.100:8001/leaflet-map") {  // ✅ IP 확인
            webView.load(URLRequest(url: url))
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // 필요 시 갱신 처리
    }

    class Coordinator: NSObject, WKScriptMessageHandler {
        var parent: PlaygroundWebView

        init(_ parent: PlaygroundWebView) {
            self.parent = parent
        }

        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            print("📩 메시지 수신됨: \(message.name)")
            
            guard message.name == "markerTapped",
                  let dict = message.body as? [String: Any] else {
                print("❌ 잘못된 메시지 형식")
                return
            }

            print("📦 수신된 데이터: \(dict)")

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dict)
                let playground = try JSONDecoder().decode(PlaygroundModel.self, from: jsonData)
                print("✅ 디코딩 성공: \(playground.facility_name)")
                parent.onSelect(playground)
            } catch {
                print("❌ 디코딩 실패: \(error)")
            }
        }
    }
}
