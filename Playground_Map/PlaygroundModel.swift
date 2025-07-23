//
//  PlaygroundModel.swift
//  Childcare_crew
//
//  Created by 안혜민 on 6/15/25.
//

import Foundation

struct PlaygroundModel: Codable, Identifiable, Equatable {
    let id: Int
    let facility_name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let location_type: String
    let toddler_population: Int
    let safety_score: Int
    let accessibility: Int
    let density: Int
    let overall_score: Int

    enum CodingKeys: String, CodingKey {
        case id = "facility_id" // ✅ Python 필드명 대응
        case facility_name, address, latitude, longitude, location_type,
             toddler_population, safety_score, accessibility, density, overall_score
    }
}

