//
//  TaskModel.swift
//  TaskVenture Fortune
//
//  Created by TaskVenture on 9/6/25.
//

import Foundation

struct TaskModel: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var isCompleted: Bool
    var priority: TaskPriority
    var dueDate: Date?
    var timeZone: TimeZone
    var createdDate: Date
    var category: TaskCategory
    var reminderTime: Date?
    
    init(title: String, description: String = "", priority: TaskPriority = .medium, dueDate: Date? = nil, timeZone: TimeZone = TimeZone.current, category: TaskCategory = .personal) {
        self.title = title
        self.description = description
        self.isCompleted = false
        self.priority = priority
        self.dueDate = dueDate
        self.timeZone = timeZone
        self.createdDate = Date()
        self.category = category
        self.reminderTime = dueDate
    }
}

enum TaskPriority: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
    
    var color: String {
        switch self {
        case .low:
            return "#1ed55f"
        case .medium:
            return "#ffc934"
        case .high:
            return "#ffff03"
        case .urgent:
            return "#eb262f"
        }
    }
}

enum TaskCategory: String, CaseIterable, Codable {
    case personal = "Personal"
    case work = "Work"
    case travel = "Travel"
    case health = "Health"
    case shopping = "Shopping"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .personal:
            return "person.fill"
        case .work:
            return "briefcase.fill"
        case .travel:
            return "airplane"
        case .health:
            return "heart.fill"
        case .shopping:
            return "cart.fill"
        case .other:
            return "folder.fill"
        }
    }
}
