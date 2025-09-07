//
//  TravelItineraryView.swift
//  TaskVenture Fortune
//
//  Created by TaskVenture on 9/6/25.
//

import SwiftUI

struct TravelItineraryView: View {
    let travel: TravelInfoModel
    @ObservedObject var viewModel: TravelViewModel
    let onAddItem: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Add button
            HStack {
                Spacer()
                
                Button(action: onAddItem) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.caption)
                        Text("Add Item")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(hex: "#1ed55f"))
                    .cornerRadius(20)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // Itinerary list
            if travel.itineraryItems.isEmpty {
                EmptyItineraryView()
            } else {
                List {
                    ForEach(travel.itineraryItems.sorted { $0.date < $1.date }) { item in
                        ItineraryItemRow(item: item, timeZone: travel.localTimeZone)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                    .onDelete { indexSet in
                        deleteItineraryItems(at: indexSet)
                    }
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    // Refresh functionality can be added here
                }
            }
        }
    }
    
    private func deleteItineraryItems(at offsets: IndexSet) {
        let sortedItems = travel.itineraryItems.sorted { $0.date < $1.date }
        for index in offsets {
            let item = sortedItems[index]
            viewModel.deleteItineraryItem(item, from: travel.id)
        }
    }
}

struct ItineraryItemRow: View {
    let item: ItineraryItem
    let timeZone: TimeZone
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = timeZone
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.timeZone = timeZone
        return formatter
    }
    
    private var isUpcoming: Bool {
        item.date >= Date()
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Type icon
            VStack {
                Image(systemName: item.type.icon)
                    .font(.title3)
                    .foregroundColor(isUpcoming ? Color(hex: "#1ed55f") : .secondary)
                
                Spacer()
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(item.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(isUpcoming ? .primary : .secondary)
                
                // Description
                if !item.description.isEmpty {
                    Text(item.description)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Date and time
                Text(dateFormatter.string(from: item.date))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(isUpcoming ? Color(hex: "#ffc934") : .secondary)
                
                // Location
                if let location = item.location, !location.isEmpty {
                    Label(location, systemImage: "location")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                // Type
                HStack(spacing: 4) {
                    Text(item.type.rawValue)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            // Time
            Text(timeFormatter.string(from: item.date))
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(isUpcoming ? Color(hex: "#1ed55f") : .secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .opacity(isUpcoming ? 1.0 : 0.7)
    }
}

struct EmptyItineraryView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No itinerary items")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            
            Text("Add activities, flights, and meetings to organize your trip")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 60)
    }
}

struct TravelTipsView: View {
    let travel: TravelInfoModel
    @ObservedObject var viewModel: TravelViewModel
    let onAddTip: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Add button
            HStack {
                Spacer()
                
                Button(action: onAddTip) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.caption)
                        Text("Add Tip")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(hex: "#ffc934"))
                    .cornerRadius(20)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // Tips list
            if travel.localTips.isEmpty {
                EmptyTipsView()
            } else {
                List {
                    ForEach(TipCategory.allCases, id: \.self) { category in
                        let categoryTips = travel.localTips.filter { $0.category == category }
                        if !categoryTips.isEmpty {
                            Section(header: TipCategoryHeader(category: category)) {
                                ForEach(categoryTips) { tip in
                                    TipItemRow(
                                        tip: tip,
                                        onBookmarkToggle: {
                                            viewModel.toggleTipBookmark(tip, in: travel.id)
                                        }
                                    )
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
}

struct TipCategoryHeader: View {
    let category: TipCategory
    
    var body: some View {
        HStack {
            Image(systemName: category.icon)
                .font(.caption)
                .foregroundColor(Color(hex: "#ffc934"))
            
            Text(category.rawValue)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct TipItemRow: View {
    let tip: LocalTip
    let onBookmarkToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(tip.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: onBookmarkToggle) {
                    Image(systemName: tip.isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.title3)
                        .foregroundColor(tip.isBookmarked ? Color(hex: "#ffc934") : .secondary)
                }
            }
            
            Text(tip.content)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct EmptyTipsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lightbulb")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No local tips")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            
            Text("Add helpful tips about local culture, food, and transportation")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 60)
    }
}

#Preview {
    TravelItineraryView(
        travel: TravelInfoModel(
            destination: "Tokyo, Japan",
            departureDate: Date(),
            localTimeZone: TimeZone(identifier: "Asia/Tokyo") ?? TimeZone.current
        ),
        viewModel: TravelViewModel(),
        onAddItem: {}
    )
}
