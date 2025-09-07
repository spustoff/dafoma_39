//
//  SettingsView.swift
//  TaskVenture Fortune
//
//  Created by TaskVenture on 9/6/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var notificationService = NotificationService.shared
    @State private var showingDeleteConfirmation = false
    @State private var showingExportData = false
    @State private var showingImportData = false
    @State private var exportedData: [String: Any]?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#ae2d27").opacity(0.1),
                        Color(hex: "#dfb492").opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                Form {
                    // App Info Section
                    Section {
                        AppInfoRow()
                    }
                    
                    // Notifications Section
                    Section(header: Text("Notifications")) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(Color(hex: "#ffc934"))
                                .frame(width: 24)
                            
                            Text("Enable Notifications")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                            
                            Spacer()
                            
                            Button(notificationService.isAuthorized ? "Enabled" : "Enable") {
                                if !notificationService.isAuthorized {
                                    notificationService.requestAuthorization()
                                }
                            }
                            .foregroundColor(notificationService.isAuthorized ? Color(hex: "#1ed55f") : Color(hex: "#ffc934"))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                        }
                        
                        if notificationService.isAuthorized {
                            HStack {
                                Image(systemName: "bell.badge")
                                    .foregroundColor(.secondary)
                                    .frame(width: 24)
                                
                                Text("Notifications are enabled for task reminders and travel alerts")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Data Management Section
                    Section(header: Text("Data Management")) {
                        // Statistics
                        StatisticsView()
                        
                        // Export Data
                        Button(action: {
                            exportData()
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(Color(hex: "#1ed55f"))
                                    .frame(width: 24)
                                
                                Text("Export Data")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Clear Completed Tasks
                        Button(action: {
                            clearCompletedTasks()
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(Color(hex: "#ffff03"))
                                    .frame(width: 24)
                                
                                Text("Clear Completed Tasks")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                        }
                    }
                    
                    // Account Section
                    Section(header: Text("Account")) {
                        Button(action: {
                            showingDeleteConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "person.crop.circle.badge.minus")
                                    .foregroundColor(Color(hex: "#eb262f"))
                                    .frame(width: 24)
                                
                                Text("Delete Account")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "#eb262f"))
                                
                                Spacer()
                            }
                        }
                    }
                    
                    // App Info Section
                    Section(header: Text("About")) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.secondary)
                                .frame(width: 24)
                            
                            Text("Version")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                            
                            Spacer()
                            
                            Text("1.0.0")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Image(systemName: "building.2")
                                .foregroundColor(.secondary)
                                .frame(width: 24)
                            
                            Text("Session ID")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                            
                            Spacer()
                            
                            Text("6587")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Delete Account", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("This will reset the app to its initial state. All your tasks and travel data will be removed. This action cannot be undone.")
        }
        .sheet(isPresented: $showingExportData) {
            if let data = exportedData {
                ExportDataView(data: data)
            }
        }
        .onAppear {
            notificationService.checkAuthorizationStatus()
        }
    }
    
    private func exportData() {
        exportedData = DataService.shared.exportData()
        showingExportData = true
    }
    
    private func clearCompletedTasks() {
        let taskViewModel = TaskViewModel()
        taskViewModel.clearCompletedTasks()
    }
    
    private func deleteAccount() {
        // Reset all data
        DataService.shared.resetAllData()
        
        // Cancel all notifications
        NotificationService.shared.cancelAllNotifications()
        
        // Reset onboarding
        UserDefaults.standard.removeObject(forKey: "onboarding_completed")
        
        // Force app restart by exiting (in a real app, you might want to navigate to onboarding)
        exit(0)
    }
}

struct AppInfoRow: View {
    var body: some View {
        HStack(spacing: 16) {
            // App Icon
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#1ed55f"),
                            Color(hex: "#ffc934")
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "airplane.departure")
                        .font(.title)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("TaskVenture Fortune")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Productivity & Travel Companion")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text("Session ID: 6587")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct StatisticsView: View {
    @State private var taskStats: TaskStatistics?
    @State private var travelStats: TravelStatistics?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(Color(hex: "#ffc934"))
                    .frame(width: 24)
                
                Text("Statistics")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            if let taskStats = taskStats {
                HStack(spacing: 20) {
                    StatItem(title: "Tasks", value: "\(taskStats.totalTasks)", color: Color(hex: "#dfb492"))
                    StatItem(title: "Completed", value: "\(taskStats.completedTasks)", color: Color(hex: "#1ed55f"))
                    StatItem(title: "Progress", value: "\(Int(taskStats.completionRate * 100))%", color: Color(hex: "#ffc934"))
                }
            }
            
            if let travelStats = travelStats {
                HStack(spacing: 20) {
                    StatItem(title: "Travels", value: "\(travelStats.totalTravels)", color: Color(hex: "#dfb492"))
                    StatItem(title: "Active", value: "\(travelStats.activeTravels)", color: Color(hex: "#1ed55f"))
                    StatItem(title: "Upcoming", value: "\(travelStats.upcomingTravels)", color: Color(hex: "#ffc934"))
                }
            }
        }
        .onAppear {
            loadStatistics()
        }
    }
    
    private func loadStatistics() {
        taskStats = DataService.shared.getTaskStatistics()
        travelStats = DataService.shared.getTravelStatistics()
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ExportDataView: View {
    let data: [String: Any]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "square.and.arrow.up.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: "#1ed55f"))
                
                Text("Data Export Ready")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Your TaskVenture data has been prepared for export. This includes all your tasks, travel information, and settings.")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                VStack(spacing: 8) {
                    if let exportDate = data["export_date"] as? TimeInterval {
                        Text("Export Date: \(Date(timeIntervalSince1970: exportDate).formatted())")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Data is ready for backup or transfer")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color(hex: "#1ed55f"))
            )
        }
    }
}

#Preview {
    SettingsView()
}
