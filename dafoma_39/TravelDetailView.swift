//
//  TravelDetailView.swift
//  TaskVenture Fortune
//
//  Created by TaskVenture on 9/6/25.
//

import SwiftUI

struct TravelDetailView: View {
    let travel: TravelInfoModel
    @ObservedObject var viewModel: TravelViewModel
    
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0
    @State private var showingEditTravel = false
    @State private var showingAddItinerary = false
    @State private var showingAddTip = false
    
    private let tabs = ["Overview", "Itinerary", "Tips"]
    
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
                    // Header
                    TravelHeaderView(travel: travel)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    
                    // Tab Picker
                    Picker("Tab", selection: $selectedTab) {
                        ForEach(0..<tabs.count, id: \.self) { index in
                            Text(tabs[index]).tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 16)
                    
                    // Content
                    switch selectedTab {
                    case 0:
                        TravelOverviewView(travel: travel)
                    case 1:
                        TravelItineraryView(
                            travel: travel,
                            viewModel: viewModel,
                            onAddItem: { showingAddItinerary = true }
                        )
                    case 2:
                        TravelTipsView(
                            travel: travel,
                            viewModel: viewModel,
                            onAddTip: { showingAddTip = true }
                        )
                    default:
                        EmptyView()
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle(travel.destination)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color(hex: "#1ed55f")),
                
                trailing: Button("Edit") {
                    showingEditTravel = true
                }
                .foregroundColor(Color(hex: "#ffc934"))
            )
        }
        .sheet(isPresented: $showingEditTravel) {
            AddEditTravelView(viewModel: viewModel, editingTravel: travel)
        }
        .sheet(isPresented: $showingAddItinerary) {
            AddItineraryItemView(travel: travel, viewModel: viewModel)
        }
        .sheet(isPresented: $showingAddTip) {
            AddLocalTipView(travel: travel, viewModel: viewModel)
        }
    }
}

struct TravelHeaderView: View {
    let travel: TravelInfoModel
    
    private var statusColor: Color {
        let now = Date()
        if travel.isActive && travel.departureDate <= now && (travel.returnDate == nil || travel.returnDate! >= now) {
            return Color(hex: "#1ed55f")
        } else if travel.departureDate > now {
            return Color(hex: "#ffc934")
        } else {
            return .secondary
        }
    }
    
    private var statusText: String {
        let now = Date()
        if travel.isActive && travel.departureDate <= now && (travel.returnDate == nil || travel.returnDate! >= now) {
            return "Currently traveling"
        } else if travel.departureDate > now {
            let days = Calendar.current.dateComponents([.day], from: now, to: travel.departureDate).day ?? 0
            return "Departing in \(days) days"
        } else {
            return "Completed"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(travel.destination)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(statusText)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(statusColor)
                }
                
                Spacer()
                
                Image(systemName: travel.isActive ? "location.fill" : "airplane")
                    .font(.title)
                    .foregroundColor(statusColor)
            }
            
            // Travel dates
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Departure")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text(DateFormatter.mediumDateTime.string(from: travel.departureDate))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                }
                
                if let returnDate = travel.returnDate {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Return")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        Text(DateFormatter.mediumDateTime.string(from: returnDate))
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
                
                // Time zone
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Local Time")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text(travel.localTimeZone.abbreviation() ?? "UTC")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct TravelOverviewView: View {
    let travel: TravelInfoModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Flight info
                if let flightNumber = travel.flightNumber, !flightNumber.isEmpty {
                    InfoCard(title: "Flight", content: flightNumber, icon: "airplane")
                }
                
                // Accommodation
                if let accommodation = travel.accommodation, !accommodation.isEmpty {
                    InfoCard(title: "Accommodation", content: accommodation, icon: "bed.double.fill")
                }
                
                // Notes
                if !travel.notes.isEmpty {
                    InfoCard(title: "Notes", content: travel.notes, icon: "note.text")
                }
                
                // Statistics
                HStack(spacing: 16) {
                    StatCard(
                        title: "Itinerary Items",
                        value: "\(travel.itineraryItems.count)",
                        icon: "list.bullet",
                        color: Color(hex: "#ffc934")
                    )
                    
                    StatCard(
                        title: "Local Tips",
                        value: "\(travel.localTips.count)",
                        icon: "lightbulb.fill",
                        color: Color(hex: "#1ed55f")
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
    }
}

struct InfoCard: View {
    let title: String
    let content: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(Color(hex: "#ffc934"))
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Text(content)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    TravelDetailView(
        travel: TravelInfoModel(
            destination: "Tokyo, Japan",
            departureDate: Date(),
            returnDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
            localTimeZone: TimeZone(identifier: "Asia/Tokyo") ?? TimeZone.current
        ),
        viewModel: TravelViewModel()
    )
}
