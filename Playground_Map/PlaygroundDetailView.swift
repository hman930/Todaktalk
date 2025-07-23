//
//  PlaygroundDetailView.swift
//  Childcare_crew
//
//  Created by 안혜민 on 6/16/25.
//

import Foundation
import SwiftUI

struct PlaygroundDetailView: View {
    let playground: PlaygroundModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Capsule()
                .frame(width: 40, height: 4)
                .foregroundColor(.gray)
                .opacity(0.4)
                .padding(.top, 8)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(playground.facility_name)
                .font(.headline)
                .foregroundColor(.black)

            Text(playground.address)
                .font(.subheadline)
                .foregroundColor(.gray)

            HStack(spacing: 15) {
                statItem("유형", value: playground.location_type)
                statItem("유아 수", value: "\(playground.toddler_population)명")
                statItem("혼잡도", value: "\(playground.density)")
            }

            HStack(spacing: 15) {
                statItem("접근성", value: "\(playground.accessibility)")
                statItem("안전도", value: "\(playground.safety_score)")
                statItem("종합 점수", value: "\(playground.overall_score)")
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(radius: 5)
        .padding(.horizontal)
    }

    private func statItem(_ title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
    }
}
