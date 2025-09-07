//
//  AddItineraryItemView.swift
//  TaskVenture Fortune
//
//  Created by TaskVenture on 9/6/25.
//

import SwiftUI

struct AddItineraryItemView: View {
    let travel: TravelInfoModel
    @ObservedObject var viewModel: TravelViewModel
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    @State private var date = Date()
    @State private var location = ""
    @State private var type = ItineraryType.activity
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Title", text: $title)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                    
                    TextField("Description (optional)", text: $description)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .lineLimit(3)
                    
                    TextField("Location (optional)", text: $location)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                }
                
                Section(header: Text("Type")) {
                    Picker("Type", selection: $type) {
                        ForEach(ItineraryType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Date & Time")) {
                    DatePicker("Date and Time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .environment(\.timeZone, travel.localTimeZone)
                    
                    Text("Time zone: \(travel.localTimeZone.localizedName(for: .standard, locale: .current) ?? travel.localTimeZone.identifier)")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("New Itinerary Item")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color(hex: "#eb262f")),
                
                trailing: Button("Save") {
                    saveItem()
                }
                .foregroundColor(Color(hex: "#1ed55f"))
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
        }
        .onAppear {
            // Set default date to travel departure date
            date = travel.departureDate
        }
    }
    
    private func saveItem() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        let newItem = ItineraryItem(
            title: trimmedTitle,
            description: description,
            date: date,
            location: location.isEmpty ? nil : location,
            type: type
        )
        
        viewModel.addItineraryItem(newItem, to: travel.id)
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddLocalTipView: View {
    let travel: TravelInfoModel
    @ObservedObject var viewModel: TravelViewModel
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var content = ""
    @State private var category = TipCategory.general
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Tip Details")) {
                    TextField("Title", text: $title)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                    
                    TextField("Content", text: $content)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .lineLimit(4)
                }
                
                Section(header: Text("Category")) {
                    Picker("Category", selection: $category) {
                        ForEach(TipCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            .navigationTitle("New Local Tip")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color(hex: "#eb262f")),
                
                trailing: Button("Save") {
                    saveTip()
                }
                .foregroundColor(Color(hex: "#1ed55f"))
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
        }
    }
    
    private func saveTip() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty && !trimmedContent.isEmpty else { return }
        
        let newTip = LocalTip(
            title: trimmedTitle,
            content: trimmedContent,
            category: category
        )
        
        viewModel.addLocalTip(newTip, to: travel.id)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    AddItineraryItemView(
        travel: TravelInfoModel(
            destination: "Tokyo, Japan",
            departureDate: Date(),
            localTimeZone: TimeZone(identifier: "Asia/Tokyo") ?? TimeZone.current
        ),
        viewModel: TravelViewModel()
    )
}
