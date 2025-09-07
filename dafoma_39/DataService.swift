//
//  DataService.swift
//  TaskVenture Fortune
//
//  Created by TaskVenture on 9/6/25.
//

import Foundation

class DataService: ObservableObject {
    static let shared = DataService()
    
    private let tasksKey = "TaskVenture_Tasks"
    private let travelsKey = "TaskVenture_Travels"
    private let onboardingKey = "TaskVenture_OnboardingCompleted"
    
    private init() {}
    
    // MARK: - Tasks Management
    func saveTasks(_ tasks: [TaskModel]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(tasks)
            UserDefaults.standard.set(data, forKey: tasksKey)
        } catch {
            print("Failed to save tasks: \(error)")
        }
    }
    
    func loadTasks() -> [TaskModel] {
        guard let data = UserDefaults.standard.data(forKey: tasksKey) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let tasks = try decoder.decode([TaskModel].self, from: data)
            return tasks
        } catch {
            print("Failed to load tasks: \(error)")
            return []
        }
    }
    
    // MARK: - Travels Management
    func saveTravels(_ travels: [TravelInfoModel]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(travels)
            UserDefaults.standard.set(data, forKey: travelsKey)
        } catch {
            print("Failed to save travels: \(error)")
        }
    }
    
    func loadTravels() -> [TravelInfoModel] {
        guard let data = UserDefaults.standard.data(forKey: travelsKey) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let travels = try decoder.decode([TravelInfoModel].self, from: data)
            return travels
        } catch {
            print("Failed to load travels: \(error)")
            return []
        }
    }
    
    // MARK: - Onboarding Management
    func setOnboardingCompleted(_ completed: Bool) {
        UserDefaults.standard.set(completed, forKey: onboardingKey)
    }
    
    func isOnboardingCompleted() -> Bool {
        return UserDefaults.standard.bool(forKey: onboardingKey)
    }
    
    // MARK: - Data Reset (for account deletion)
    func resetAllData() {
        UserDefaults.standard.removeObject(forKey: tasksKey)
        UserDefaults.standard.removeObject(forKey: travelsKey)
        UserDefaults.standard.removeObject(forKey: onboardingKey)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Data Export/Import
    func exportData() -> [String: Any]? {
        var exportData: [String: Any] = [:]
        
        if let tasksData = UserDefaults.standard.data(forKey: tasksKey) {
            exportData["tasks"] = tasksData
        }
        
        if let travelsData = UserDefaults.standard.data(forKey: travelsKey) {
            exportData["travels"] = travelsData
        }
        
        exportData["onboarding_completed"] = isOnboardingCompleted()
        exportData["export_date"] = Date().timeIntervalSince1970
        
        return exportData.isEmpty ? nil : exportData
    }
    
    func importData(_ data: [String: Any]) -> Bool {
        do {
            if let tasksData = data["tasks"] as? Data {
                UserDefaults.standard.set(tasksData, forKey: tasksKey)
            }
            
            if let travelsData = data["travels"] as? Data {
                UserDefaults.standard.set(travelsData, forKey: travelsKey)
            }
            
            if let onboardingCompleted = data["onboarding_completed"] as? Bool {
                setOnboardingCompleted(onboardingCompleted)
            }
            
            UserDefaults.standard.synchronize()
            return true
        } catch {
            print("Failed to import data: \(error)")
            return false
        }
    }
    
    // MARK: - Statistics
    func getTaskStatistics() -> TaskStatistics {
        let tasks = loadTasks()
        let completedTasks = tasks.filter { $0.isCompleted }
        let overdueTasks = tasks.filter { !$0.isCompleted && ($0.dueDate ?? Date.distantFuture) < Date() }
        let upcomingTasks = tasks.filter { !$0.isCompleted && ($0.dueDate ?? Date.distantFuture) >= Date() }
        
        return TaskStatistics(
            totalTasks: tasks.count,
            completedTasks: completedTasks.count,
            overdueTasks: overdueTasks.count,
            upcomingTasks: upcomingTasks.count
        )
    }
    
    func getTravelStatistics() -> TravelStatistics {
        let travels = loadTravels()
        let activeTravels = travels.filter { $0.isActive }
        let upcomingTravels = travels.filter { $0.departureDate > Date() }
        let pastTravels = travels.filter { ($0.returnDate ?? Date.distantFuture) < Date() }
        
        return TravelStatistics(
            totalTravels: travels.count,
            activeTravels: activeTravels.count,
            upcomingTravels: upcomingTravels.count,
            pastTravels: pastTravels.count
        )
    }
}

struct TaskStatistics {
    let totalTasks: Int
    let completedTasks: Int
    let overdueTasks: Int
    let upcomingTasks: Int
    
    var completionRate: Double {
        guard totalTasks > 0 else { return 0.0 }
        return Double(completedTasks) / Double(totalTasks)
    }
}

struct TravelStatistics {
    let totalTravels: Int
    let activeTravels: Int
    let upcomingTravels: Int
    let pastTravels: Int
}
