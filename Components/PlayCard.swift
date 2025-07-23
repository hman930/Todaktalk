//
//  PlayCard.swift
//  Childcare_crew
//
//  Created by 안혜민 on 5/23/25.
//

import Foundation
import SwiftUI

struct PlayCard: View {
    let title: String

    var body: some View {
        VStack {
            Text(title)
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .padding()
            Image(systemName: "arrow.right")
                .resizable()
                .frame(width: 40, height: 20)
                .padding(.bottom, 8)
        }
        .frame(width: 160)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.pink, lineWidth: 2))
    }
}
