//
//  AddEditTravelView.swift
//  TaskVenture Fortune
//
//  Created by TaskVenture on 9/6/25.
//

import SwiftUI

struct AddEditTravelView: View {
    @ObservedObject var viewModel: TravelViewModel
    let editingTravel: TravelInfoModel?
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var destination = ""
    @State private var departureDate = Date()
    @State private var returnDate = Date()
    @State private var hasReturnDate = false
    @State private var flightNumber = ""
    @State private var accommodation = ""
    @State private var notes = ""
    @State private var selectedTimeZone = TimeZone.current
    @State private var isActive = false
    
    init(viewModel: TravelViewModel, editingTravel: TravelInfoModel? = nil) {
        self.viewModel = viewModel
        self.editingTravel = editingTravel
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Destination")) {
                    TextField("Where are you going?", text: $destination)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                }
                
                Section(header: Text("Travel Dates")) {
                    DatePicker("Departure", selection: $departureDate, displayedComponents: [.date, .hourAndMinute])
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                    
                    Toggle("Set return date", isOn: $hasReturnDate)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                    
                    if hasReturnDate {
                        DatePicker("Return", selection: $returnDate, displayedComponents: [.date, .hourAndMinute])
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                    }
                    
                    Picker("Local Time Zone", selection: $selectedTimeZone) {
                        ForEach(worldTimeZones, id: \.identifier) { timeZone in
                            Text(timeZone.localizedName(for: .standard, locale: .current) ?? timeZone.identifier)
                                .tag(timeZone)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Travel Details")) {
                    TextField("Flight number (optional)", text: $flightNumber)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                    
                    TextField("Accommodation (optional)", text: $accommodation)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                    
                    TextField("Notes", text: $notes)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .lineLimit(3)
                }
                
                Section(header: Text("Status")) {
                    Toggle("Mark as active travel", isOn: $isActive)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                }
            }
            .navigationTitle(editingTravel == nil ? "New Travel" : "Edit Travel")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color(hex: "#eb262f")),
                
                trailing: Button("Save") {
                    saveTravel()
                }
                .foregroundColor(Color(hex: "#1ed55f"))
                .disabled(destination.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
        }
        .onAppear {
            setupInitialValues()
        }
    }
    
    private var worldTimeZones: [TimeZone] {
        let identifiers = [
            "America/New_York",
            "America/Chicago",
            "America/Denver",
            "America/Los_Angeles",
            "America/Anchorage",
            "Pacific/Honolulu",
            "Europe/London",
            "Europe/Paris",
            "Europe/Berlin",
            "Europe/Rome",
            "Europe/Madrid",
            "Europe/Amsterdam",
            "Europe/Stockholm",
            "Europe/Moscow",
            "Asia/Tokyo",
            "Asia/Seoul",
            "Asia/Shanghai",
            "Asia/Hong_Kong",
            "Asia/Singapore",
            "Asia/Bangkok",
            "Asia/Dubai",
            "Asia/Kolkata",
            "Australia/Sydney",
            "Australia/Melbourne",
            "Australia/Perth",
            "Pacific/Auckland",
            "Africa/Cairo",
            "Africa/Johannesburg",
            "America/Sao_Paulo",
            "America/Mexico_City",
            "America/Toronto"
        ]
        
        var timeZones = identifiers.compactMap { TimeZone(identifier: $0) }
        
        // Add current time zone if not already included
        if !timeZones.contains(TimeZone.current) {
            timeZones.insert(TimeZone.current, at: 0)
        }
        
        return timeZones.sorted { tz1, tz2 in
            let name1 = tz1.localizedName(for: .standard, locale: .current) ?? tz1.identifier
            let name2 = tz2.localizedName(for: .standard, locale: .current) ?? tz2.identifier
            return name1 < name2
        }
    }
    
    private func setupInitialValues() {
        if let travel = editingTravel {
            destination = travel.destination
            departureDate = travel.departureDate
            selectedTimeZone = travel.localTimeZone
            flightNumber = travel.flightNumber ?? ""
            accommodation = travel.accommodation ?? ""
            notes = travel.notes
            isActive = travel.isActive
            
            if let returnDate = travel.returnDate {
                self.returnDate = returnDate
                hasReturnDate = true
            }
        } else {
            // Set default return date to 7 days after departure
            returnDate = Calendar.current.date(byAdding: .day, value: 7, to: departureDate) ?? departureDate
        }
    }
    
    private func saveTravel() {
        let trimmedDestination = destination.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedDestination.isEmpty else { return }
        
        if let existingTravel = editingTravel {
            var updatedTravel = existingTravel
            updatedTravel.destination = trimmedDestination
            updatedTravel.departureDate = departureDate
            updatedTravel.returnDate = hasReturnDate ? returnDate : nil
            updatedTravel.flightNumber = flightNumber.isEmpty ? nil : flightNumber
            updatedTravel.accommodation = accommodation.isEmpty ? nil : accommodation
            updatedTravel.notes = notes
            updatedTravel.localTimeZone = selectedTimeZone
            updatedTravel.isActive = isActive
            
            viewModel.updateTravel(updatedTravel)
            
            // Update notifications
            NotificationService.shared.cancelTravelReminders(for: existingTravel)
            NotificationService.shared.scheduleTravelReminders(for: updatedTravel)
        } else {
            let newTravel = TravelInfoModel(
                destination: trimmedDestination,
                departureDate: departureDate,
                returnDate: hasReturnDate ? returnDate : nil,
                localTimeZone: selectedTimeZone
            )
            
            var travelWithDetails = newTravel
            travelWithDetails.flightNumber = flightNumber.isEmpty ? nil : flightNumber
            travelWithDetails.accommodation = accommodation.isEmpty ? nil : accommodation
            travelWithDetails.notes = notes
            travelWithDetails.isActive = isActive
            
            viewModel.addTravel(travelWithDetails)
            NotificationService.shared.scheduleTravelReminders(for: travelWithDetails)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    AddEditTravelView(viewModel: TravelViewModel())
}
