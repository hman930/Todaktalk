//
//  StarRatingView.swift
//  Childcare_crew
//
//  Created by 안혜민 on 6/15/25.
//

import Foundation
import SwiftUI

struct StarRatingView: View {
    let title: String
    let score: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
            HStack(spacing: 2) {
                ForEach(0..<5) { i in
                    Image(systemName: i < score ? "star.fill" : "star")
                        .foregroundColor(.pink)
                        .shadow(color: .pink.opacity(0.4), radius: 1, x: 1, y: 1)
                }
            }
        }
    }
}
