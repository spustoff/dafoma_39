//
//  TaskViewModel.swift
//  TaskVenture Fortune
//
//  Created by TaskVenture on 9/6/25.
//

import Foundation
import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var tasks: [TaskModel] = []
    @Published var filteredTasks: [TaskModel] = []
    @Published var selectedCategory: TaskCategory? = nil
    @Published var selectedPriority: TaskPriority? = nil
    @Published var searchText: String = ""
    @Published var sortOption: SortOption = .dueDate
    
    private let dataService = DataService.shared
    
    enum SortOption: String, CaseIterable {
        case dueDate = "Due Date"
        case priority = "Priority"
        case createdDate = "Created Date"
        case title = "Title"
    }
    
    init() {
        loadTasks()
        filterTasks()
    }
    
    func addTask(_ task: TaskModel) {
        tasks.append(task)
        saveTasks()
        filterTasks()
    }
    
    func updateTask(_ task: TaskModel) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
            filterTasks()
        }
    }
    
    func deleteTask(_ task: TaskModel) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
        filterTasks()
    }
    
    func toggleTaskCompletion(_ task: TaskModel) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            saveTasks()
            filterTasks()
        }
    }
    
    func filterTasks() {
        var filtered = tasks
        
        // Filter by category
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Filter by priority
        if let priority = selectedPriority {
            filtered = filtered.filter { $0.priority == priority }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort tasks
        switch sortOption {
        case .dueDate:
            filtered.sort { task1, task2 in
                guard let date1 = task1.dueDate, let date2 = task2.dueDate else {
                    return task1.dueDate != nil
                }
                return date1 < date2
            }
        case .priority:
            filtered.sort { task1, task2 in
                let priorities: [TaskPriority] = [.urgent, .high, .medium, .low]
                let index1 = priorities.firstIndex(of: task1.priority) ?? priorities.count
                let index2 = priorities.firstIndex(of: task2.priority) ?? priorities.count
                return index1 < index2
            }
        case .createdDate:
            filtered.sort { $0.createdDate > $1.createdDate }
        case .title:
            filtered.sort { $0.title < $1.title }
        }
        
        filteredTasks = filtered
    }
    
    func getTasksForTimeZone(_ timeZone: TimeZone) -> [TaskModel] {
        return tasks.filter { $0.timeZone == timeZone }
    }
    
    func getUpcomingTasks(limit: Int = 5) -> [TaskModel] {
        let now = Date()
        return tasks
            .filter { !$0.isCompleted && ($0.dueDate ?? Date.distantFuture) >= now }
            .sorted { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) }
            .prefix(limit)
            .map { $0 }
    }
    
    func getOverdueTasks() -> [TaskModel] {
        let now = Date()
        return tasks.filter { !$0.isCompleted && ($0.dueDate ?? Date.distantFuture) < now }
    }
    
    func getCompletedTasks() -> [TaskModel] {
        return tasks.filter { $0.isCompleted }
    }
    
    func clearCompletedTasks() {
        tasks.removeAll { $0.isCompleted }
        saveTasks()
        filterTasks()
    }
    
    private func loadTasks() {
        tasks = dataService.loadTasks()
    }
    
    private func saveTasks() {
        dataService.saveTasks(tasks)
    }
    
    func createSampleTasks() {
        let sampleTasks = [
            TaskModel(title: "Pack luggage for Tokyo trip", description: "Don't forget passport and chargers", priority: .high, dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()), category: .travel),
            TaskModel(title: "Book dinner reservation", description: "Try the new sushi place", priority: .medium, dueDate: Calendar.current.date(byAdding: .hour, value: 4, to: Date()), category: .personal),
            TaskModel(title: "Finish quarterly report", description: "Q3 financial analysis", priority: .urgent, dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()), category: .work),
            TaskModel(title: "Buy groceries", description: "Milk, bread, fruits", priority: .low, dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()), category: .shopping)
        ]
        
        for task in sampleTasks {
            addTask(task)
        }
    }
}
