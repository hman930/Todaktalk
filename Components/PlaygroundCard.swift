//
//  PlaygroundCard.swift
//  Childcare_crew
//
//  Created by 안혜민 on 6/16/25.
//

import Foundation
import SwiftUI

struct PlaygroundCard: View {
    let playground: PlaygroundModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(playground.facility_name)
                .font(.headline)

            Text(playground.address)
                .font(.subheadline)
                .foregroundColor(.gray)

            HStack {
                Label("접근성: \(playground.accessibility)", systemImage: "figure.walk")
                Spacer()
                Label("안전도: \(playground.safety_score)", systemImage: "shield")
            }
            .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}
