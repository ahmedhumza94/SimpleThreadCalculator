//
//  Project.swift
//  SimpleThreadCalculator
//
//  Created by Humza Ahmed on 8/14/25.
//

import Foundation

struct Project: Codable {
    let name: String
    let cityType: CityType
    let startDate: Date
    let endDate: Date
    
    enum CityType: String, Codable {
        case low = "low"
        case high = "high"
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case cityType = "city_type"
        case startDate = "start_date"
        case endDate = "end_date"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        cityType = try container.decode(CityType.self, forKey: .cityType)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date.self, forKey: .endDate)
        
        // Validate that end date is not before start date
        if endDate < startDate {
            let context = DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "End date (\(endDate)) cannot be before start date (\(startDate))"
            )
            throw DecodingError.dataCorrupted(context)
        }
    }

}

struct ProjectSet: Codable {
    let id: Int
    let projects: [Project]
}
