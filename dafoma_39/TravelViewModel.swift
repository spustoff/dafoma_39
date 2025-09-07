//
//  TravelViewModel.swift
//  TaskVenture Fortune
//
//  Created by TaskVenture on 9/6/25.
//

import Foundation
import SwiftUI

class TravelViewModel: ObservableObject {
    @Published var travels: [TravelInfoModel] = []
    @Published var activeTravels: [TravelInfoModel] = []
    @Published var upcomingTravels: [TravelInfoModel] = []
    @Published var pastTravels: [TravelInfoModel] = []
    
    private let dataService = DataService.shared
    
    init() {
        loadTravels()
        organizeTravels()
    }
    
    func addTravel(_ travel: TravelInfoModel) {
        travels.append(travel)
        saveTravels()
        organizeTravels()
    }
    
    func updateTravel(_ travel: TravelInfoModel) {
        if let index = travels.firstIndex(where: { $0.id == travel.id }) {
            travels[index] = travel
            saveTravels()
            organizeTravels()
        }
    }
    
    func deleteTravel(_ travel: TravelInfoModel) {
        travels.removeAll { $0.id == travel.id }
        saveTravels()
        organizeTravels()
    }
    
    func toggleTravelActive(_ travel: TravelInfoModel) {
        if let index = travels.firstIndex(where: { $0.id == travel.id }) {
            travels[index].isActive.toggle()
            saveTravels()
            organizeTravels()
        }
    }
    
    func addItineraryItem(_ item: ItineraryItem, to travelId: UUID) {
        if let index = travels.firstIndex(where: { $0.id == travelId }) {
            travels[index].itineraryItems.append(item)
            saveTravels()
            organizeTravels()
        }
    }
    
    func updateItineraryItem(_ item: ItineraryItem, in travelId: UUID) {
        if let travelIndex = travels.firstIndex(where: { $0.id == travelId }),
           let itemIndex = travels[travelIndex].itineraryItems.firstIndex(where: { $0.id == item.id }) {
            travels[travelIndex].itineraryItems[itemIndex] = item
            saveTravels()
        }
    }
    
    func deleteItineraryItem(_ item: ItineraryItem, from travelId: UUID) {
        if let index = travels.firstIndex(where: { $0.id == travelId }) {
            travels[index].itineraryItems.removeAll { $0.id == item.id }
            saveTravels()
        }
    }
    
    func addLocalTip(_ tip: LocalTip, to travelId: UUID) {
        if let index = travels.firstIndex(where: { $0.id == travelId }) {
            travels[index].localTips.append(tip)
            saveTravels()
        }
    }
    
    func toggleTipBookmark(_ tip: LocalTip, in travelId: UUID) {
        if let travelIndex = travels.firstIndex(where: { $0.id == travelId }),
           let tipIndex = travels[travelIndex].localTips.firstIndex(where: { $0.id == tip.id }) {
            travels[travelIndex].localTips[tipIndex].isBookmarked.toggle()
            saveTravels()
        }
    }
    
    func getCurrentTravel() -> TravelInfoModel? {
        let now = Date()
        return travels.first { travel in
            travel.isActive &&
            travel.departureDate <= now &&
            (travel.returnDate == nil || travel.returnDate! >= now)
        }
    }
    
    func getUpcomingItinerary(for travelId: UUID, limit: Int = 5) -> [ItineraryItem] {
        guard let travel = travels.first(where: { $0.id == travelId }) else { return [] }
        let now = Date()
        return travel.itineraryItems
            .filter { $0.date >= now }
            .sorted { $0.date < $1.date }
            .prefix(limit)
            .map { $0 }
    }
    
    func getBookmarkedTips(for travelId: UUID) -> [LocalTip] {
        guard let travel = travels.first(where: { $0.id == travelId }) else { return [] }
        return travel.localTips.filter { $0.isBookmarked }
    }
    
    func getTravelTimeZone(for travelId: UUID) -> TimeZone? {
        return travels.first(where: { $0.id == travelId })?.localTimeZone
    }
    
    private func organizeTravels() {
        let now = Date()
        
        activeTravels = travels.filter { travel in
            travel.isActive &&
            travel.departureDate <= now &&
            (travel.returnDate == nil || travel.returnDate! >= now)
        }
        
        upcomingTravels = travels.filter { travel in
            travel.departureDate > now
        }.sorted { $0.departureDate < $1.departureDate }
        
        pastTravels = travels.filter { travel in
            if let returnDate = travel.returnDate {
                return returnDate < now
            }
            return false
        }.sorted { $0.departureDate > $1.departureDate }
    }
    
    private func loadTravels() {
        travels = dataService.loadTravels()
    }
    
    private func saveTravels() {
        dataService.saveTravels(travels)
    }
    
    func createSampleTravels() {
        let tokyo = TravelInfoModel(
            destination: "Tokyo, Japan",
            departureDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            returnDate: Calendar.current.date(byAdding: .day, value: 14, to: Date()),
            localTimeZone: TimeZone(identifier: "Asia/Tokyo") ?? TimeZone.current
        )
        
        let paris = TravelInfoModel(
            destination: "Paris, France",
            departureDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date(),
            returnDate: Calendar.current.date(byAdding: .day, value: 37, to: Date()),
            localTimeZone: TimeZone(identifier: "Europe/Paris") ?? TimeZone.current
        )
        
        // Add sample itinerary items
        var tokyoWithItems = tokyo
        tokyoWithItems.itineraryItems = [
            ItineraryItem(title: "Arrival at Narita Airport", date: tokyo.departureDate, location: "Narita Airport", type: .flight),
            ItineraryItem(title: "Check-in at Hotel", date: Calendar.current.date(byAdding: .hour, value: 3, to: tokyo.departureDate) ?? Date(), location: "Shibuya", type: .accommodation),
            ItineraryItem(title: "Visit Senso-ji Temple", date: Calendar.current.date(byAdding: .day, value: 1, to: tokyo.departureDate) ?? Date(), location: "Asakusa", type: .activity)
        ]
        
        // Add sample local tips
        tokyoWithItems.localTips = [
            LocalTip(title: "Transportation", content: "Get a JR Pass for unlimited train rides", category: .transportation),
            LocalTip(title: "Dining Etiquette", content: "Don't tip at restaurants - it's not customary in Japan", category: .food),
            LocalTip(title: "Language", content: "Download Google Translate app with camera feature", category: .general)
        ]
        
        addTravel(tokyoWithItems)
        addTravel(paris)
    }
}
