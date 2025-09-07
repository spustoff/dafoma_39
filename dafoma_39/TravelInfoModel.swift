//
//  TravelInfoModel.swift
//  TaskVenture Fortune
//
//  Created by TaskVenture on 9/6/25.
//

import Foundation

struct TravelInfoModel: Identifiable, Codable {
    let id = UUID()
    var destination: String
    var departureDate: Date
    var returnDate: Date?
    var flightNumber: String?
    var accommodation: String?
    var localTimeZone: TimeZone
    var notes: String
    var itineraryItems: [ItineraryItem]
    var localTips: [LocalTip]
    var isActive: Bool
    
    init(destination: String, departureDate: Date, returnDate: Date? = nil, localTimeZone: TimeZone = TimeZone.current) {
        self.destination = destination
        self.departureDate = departureDate
        self.returnDate = returnDate
        self.flightNumber = nil
        self.accommodation = nil
        self.localTimeZone = localTimeZone
        self.notes = ""
        self.itineraryItems = []
        self.localTips = []
        self.isActive = false
    }
}

struct ItineraryItem: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var date: Date
    var location: String?
    var type: ItineraryType
    
    init(title: String, description: String = "", date: Date, location: String? = nil, type: ItineraryType = .activity) {
        self.title = title
        self.description = description
        self.date = date
        self.location = location
        self.type = type
    }
}

enum ItineraryType: String, CaseIterable, Codable {
    case flight = "Flight"
    case accommodation = "Accommodation"
    case activity = "Activity"
    case meeting = "Meeting"
    case dining = "Dining"
    case transportation = "Transportation"
    
    var icon: String {
        switch self {
        case .flight:
            return "airplane"
        case .accommodation:
            return "bed.double.fill"
        case .activity:
            return "star.fill"
        case .meeting:
            return "person.2.fill"
        case .dining:
            return "fork.knife"
        case .transportation:
            return "car.fill"
        }
    }
}

struct LocalTip: Identifiable, Codable {
    let id = UUID()
    var title: String
    var content: String
    var category: TipCategory
    var isBookmarked: Bool
    
    init(title: String, content: String, category: TipCategory = .general) {
        self.title = title
        self.content = content
        self.category = category
        self.isBookmarked = false
    }
}

enum TipCategory: String, CaseIterable, Codable {
    case general = "General"
    case food = "Food & Dining"
    case transportation = "Transportation"
    case culture = "Culture"
    case safety = "Safety"
    case shopping = "Shopping"
    
    var icon: String {
        switch self {
        case .general:
            return "info.circle.fill"
        case .food:
            return "fork.knife.circle.fill"
        case .transportation:
            return "car.circle.fill"
        case .culture:
            return "building.columns.fill"
        case .safety:
            return "shield.fill"
        case .shopping:
            return "bag.fill"
        }
    }
}
