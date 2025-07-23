//
//  PlaygroundContainerView.swift
//  Childcare_crew
//
//  Created by 안혜민 on 6/15/25.
//

import Foundation
import SwiftUI

struct PlaygroundContainerView: View {
    @State private var selectedPlayground: PlaygroundModel?

    var body: some View {
        ZStack(alignment: .bottom) {
            PlaygroundWebView(onSelect: { selected in
                print("🎯 선택된 놀이터: \(selected.facility_name)")
                withAnimation {
                    selectedPlayground = selected
                }
            })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)

            if let selected = selectedPlayground {
                PlaygroundDetailView(playground: selected)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: selectedPlayground)
            } else {
                // 안내 박스 구성
                VStack(alignment: .leading, spacing: 12) {
                    Text("놀이터 이렇게 구성되어 있어요!")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.pink)
                        .frame(maxWidth: .infinity, alignment: .center)

                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(Color.purple)
                            .frame(width: 8, height: 8)
                        Text("접근성: 들어가기 어려운 곳은 점수가 낮아요.")
                    }

                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("유아 밀집도: 아이 유동인구가 많아요.")
                    }

                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "shield.lefthalf.filled")
                            .foregroundColor(.pink)
                            .frame(width: 10)
                        Text("안전도: 주변 CCTV, 경찰서가 가까이에 있어요.")
                    }
                }
                .font(.caption)
                .foregroundColor(.gray)
                .padding(16)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .gray.opacity(0.2), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }
        }
    }
}
