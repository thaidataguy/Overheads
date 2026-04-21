//
//  Frequency.swift
//  Overheads
//
//  Created by Tanagarn Ploychinda on 4/22/26.
//

enum Frequency: String, CaseIterable, Identifiable, Codable {
    case weekly
    case monthly
    case quarterly
    case annually

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        case .quarterly:
            return "Quarterly"
        case .annually:
            return "Annually"
        }
    }
}
