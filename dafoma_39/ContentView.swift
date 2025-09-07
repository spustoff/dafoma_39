//
//  ContentView.swift
//  TaskVenture Fortune
//
//  Created by TaskVenture on 9/6/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tasks Tab
            TaskView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "checkmark.circle.fill" : "checkmark.circle")
                    Text("Tasks")
                }
                .tag(0)
            
            // Travel Tab
            TravelView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "airplane.departure" : "airplane")
                    Text("Travel")
                }
                .tag(1)
            
            // Dashboard Tab
            DashboardView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "chart.pie.fill" : "chart.pie")
                    Text("Dashboard")
                }
                .tag(2)
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "gear.circle.fill" : "gear.circle")
                    Text("Settings")
                }
                .tag(3)
        }
        .accentColor(Color(hex: "#1ed55f"))
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        
        // Selected item color
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color(hex: "#1ed55f"))
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color(hex: "#1ed55f"))
        ]
        
        // Normal item color
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

struct DashboardView: View {
    @StateObject private var taskViewModel = TaskViewModel()
    @StateObject private var travelViewModel = TravelViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#ffc934").opacity(0.1),
                        Color(hex: "#1ed55f").opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Welcome Section
                        WelcomeCard()
                        
                        // Quick Stats
                        QuickStatsView(
                            taskViewModel: taskViewModel,
                            travelViewModel: travelViewModel
                        )
                        
                        // Upcoming Tasks
                        UpcomingTasksCard(taskViewModel: taskViewModel)
                        
                        // Active Travel
                        if let activeTravel = travelViewModel.getCurrentTravel() {
                            ActiveTravelCard(travel: activeTravel) {
                                // Handle active travel tap - could navigate to travel detail
                            }
                        }
                        
                        // Quick Actions
                        QuickActionsView()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            if taskViewModel.tasks.isEmpty {
                taskViewModel.createSampleTasks()
            }
            if travelViewModel.travels.isEmpty {
                travelViewModel.createSampleTravels()
            }
        }
    }
}

struct WelcomeCard: View {
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        case 17..<21:
            return "Good Evening"
        default:
            return "Good Night"
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(greeting)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Welcome to TaskVenture Fortune")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "sun.max.fill")
                .font(.system(size: 40))
                .foregroundColor(Color(hex: "#ffc934"))
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct QuickStatsView: View {
    @ObservedObject var taskViewModel: TaskViewModel
    @ObservedObject var travelViewModel: TravelViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            QuickStatCard(
                title: "Tasks",
                value: "\(taskViewModel.tasks.count)",
                subtitle: "\(taskViewModel.getCompletedTasks().count) completed",
                color: Color(hex: "#dfb492"),
                icon: "checkmark.circle.fill"
            )
            
            QuickStatCard(
                title: "Travels",
                value: "\(travelViewModel.travels.count)",
                subtitle: "\(travelViewModel.activeTravels.count) active",
                color: Color(hex: "#ffc934"),
                icon: "airplane.departure"
            )
        }
    }
}

struct QuickStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.system(size: 11, weight: .regular, design: .rounded))
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

struct UpcomingTasksCard: View {
    @ObservedObject var taskViewModel: TaskViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Upcoming Tasks")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "arrow.right.circle")
                    .font(.title3)
                    .foregroundColor(Color(hex: "#1ed55f"))
            }
            
            let upcomingTasks = taskViewModel.getUpcomingTasks(limit: 3)
            
            if upcomingTasks.isEmpty {
                Text("No upcoming tasks")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 8) {
                    ForEach(upcomingTasks) { task in
                        HStack {
                            Circle()
                                .fill(Color(hex: task.priority.color))
                                .frame(width: 8, height: 8)
                            
                            Text(task.title)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            if let dueDate = task.dueDate {
                                Text(dueDate, style: .relative)
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct QuickActionsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    title: "Add Task",
                    icon: "plus.circle.fill",
                    color: Color(hex: "#1ed55f")
                ) {
                    // Action handled by parent view
                }
                
                QuickActionButton(
                    title: "Plan Travel",
                    icon: "airplane.circle.fill",
                    color: Color(hex: "#ffc934")
                ) {
                    // Action handled by parent view
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContentView()
}
