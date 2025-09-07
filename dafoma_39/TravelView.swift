//
//  TravelView.swift
//  TaskVenture Fortune
//
//  Created by TaskVenture on 9/6/25.
//

import SwiftUI

struct TravelView: View {
    @StateObject private var travelViewModel = TravelViewModel()
    @State private var showingAddTravel = false
    @State private var selectedTravel: TravelInfoModel?
    @State private var selectedSegment = 0
    
    private let segments = ["Active", "Upcoming", "Past"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#ffc934").opacity(0.1),
                        Color(hex: "#dfb492").opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Segmented Control
                    Picker("Travel Status", selection: $selectedSegment) {
                        ForEach(0..<segments.count, id: \.self) { index in
                            Text(segments[index]).tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // Content based on selected segment
                    switch selectedSegment {
                    case 0:
                        ActiveTravelsView(travels: travelViewModel.activeTravels, onTravelTap: { travel in
                            selectedTravel = travel
                        })
                    case 1:
                        UpcomingTravelsView(travels: travelViewModel.upcomingTravels, onTravelTap: { travel in
                            selectedTravel = travel
                        })
                    case 2:
                        PastTravelsView(travels: travelViewModel.pastTravels, onTravelTap: { travel in
                            selectedTravel = travel
                        })
                    default:
                        EmptyView()
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Travel")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                trailing: Button(action: {
                    showingAddTravel = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color(hex: "#1ed55f"))
                }
            )
        }
        .sheet(isPresented: $showingAddTravel) {
            AddEditTravelView(viewModel: travelViewModel)
        }
        .sheet(item: $selectedTravel) { travel in
            TravelDetailView(travel: travel, viewModel: travelViewModel)
        }
        .onAppear {
            if travelViewModel.travels.isEmpty {
                travelViewModel.createSampleTravels()
            }
        }
    }
}

struct ActiveTravelsView: View {
    let travels: [TravelInfoModel]
    let onTravelTap: (TravelInfoModel) -> Void
    
    var body: some View {
        if travels.isEmpty {
            EmptyTravelView(
                title: "No Active Travels",
                subtitle: "Your current trips will appear here",
                icon: "airplane.departure"
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(travels) { travel in
                        ActiveTravelCard(travel: travel) {
                            onTravelTap(travel)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
    }
}

struct UpcomingTravelsView: View {
    let travels: [TravelInfoModel]
    let onTravelTap: (TravelInfoModel) -> Void
    
    var body: some View {
        if travels.isEmpty {
            EmptyTravelView(
                title: "No Upcoming Travels",
                subtitle: "Plan your next adventure!",
                icon: "calendar.badge.plus"
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(travels) { travel in
                        UpcomingTravelCard(travel: travel) {
                            onTravelTap(travel)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
    }
}

struct PastTravelsView: View {
    let travels: [TravelInfoModel]
    let onTravelTap: (TravelInfoModel) -> Void
    
    var body: some View {
        if travels.isEmpty {
            EmptyTravelView(
                title: "No Past Travels",
                subtitle: "Your travel history will appear here",
                icon: "clock.arrow.circlepath"
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(travels) { travel in
                        PastTravelCard(travel: travel) {
                            onTravelTap(travel)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
    }
}

struct ActiveTravelCard: View {
    let travel: TravelInfoModel
    let onTap: () -> Void
    
    private var daysRemaining: Int {
        guard let returnDate = travel.returnDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: Date(), to: returnDate).day ?? 0
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(travel.destination)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Currently traveling")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hex: "#1ed55f"))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .foregroundColor(Color(hex: "#1ed55f"))
                        
                        if daysRemaining > 0 {
                            Text("\(daysRemaining) days left")
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Quick stats
                HStack(spacing: 16) {
                    TravelStatItem(
                        icon: "calendar",
                        value: DateFormatter.shortDate.string(from: travel.departureDate),
                        label: "Departure"
                    )
                    
                    if !travel.itineraryItems.isEmpty {
                        TravelStatItem(
                            icon: "list.bullet",
                            value: "\(travel.itineraryItems.count)",
                            label: "Items"
                        )
                    }
                    
                    if !travel.localTips.isEmpty {
                        TravelStatItem(
                            icon: "lightbulb.fill",
                            value: "\(travel.localTips.count)",
                            label: "Tips"
                        )
                    }
                }
            }
            .padding(16)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct UpcomingTravelCard: View {
    let travel: TravelInfoModel
    let onTap: () -> Void
    
    private var daysUntilDeparture: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: travel.departureDate).day ?? 0
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(travel.destination)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("in \(daysUntilDeparture) days")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hex: "#ffc934"))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "airplane")
                        .font(.title2)
                        .foregroundColor(Color(hex: "#ffc934"))
                }
                
                // Departure info
                HStack {
                    Label(DateFormatter.mediumDateTime.string(from: travel.departureDate), systemImage: "calendar")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PastTravelCard: View {
    let travel: TravelInfoModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(travel.destination)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        if let returnDate = travel.returnDate {
                            Text("Returned \(DateFormatter.shortDate.string(from: returnDate))")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color(hex: "#1ed55f"))
                }
                
                // Duration
                if let returnDate = travel.returnDate {
                    let duration = Calendar.current.dateComponents([.day], from: travel.departureDate, to: returnDate).day ?? 0
                    Text("\(duration) days")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TravelStatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(label)
                    .font(.system(size: 9, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct EmptyTravelView: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(title)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            
            Text(subtitle)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.top, 60)
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    static let mediumDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    TravelView()
}
