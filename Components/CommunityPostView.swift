//
//  CommunityPostView.swift
//  Childcare_crew
//
//  Created by 안혜민 on 5/23/25.
//

import Foundation
import SwiftUI

struct CommunityPostView: View {
    var text: String
    var likes: Int
    var comments: Int
    var views: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(text)
                .font(.body)
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)

            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "heart")
                    Text("\(likes)")
                }

                HStack(spacing: 4) {
                    Image(systemName: "bubble.right")
                    Text("\(comments)")
                }

                HStack(spacing: 4) {
                    Image(systemName: "eye")
                    Text("\(views)")
                }
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading) // ✅ 가로 폭 꽉 채우기
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color("AccentColor"), lineWidth: 2)
        )
        .cornerRadius(10)
    }
}
