//
//  NotificationService.swift
//  TaskVenture Fortune
//
//  Created by TaskVenture on 9/6/25.
//

import Foundation
import UserNotifications

class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()
    
    @Published var isAuthorized = false
    
    override init() {
        super.init()
        checkAuthorizationStatus()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
            
            if let error = error {
                print("Notification authorization error: \(error)")
            }
        }
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Task Notifications
    func scheduleTaskReminder(for task: TaskModel) {
        guard isAuthorized, let reminderTime = task.reminderTime else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title
        content.sound = .default
        content.badge = 1
        
        // Add task priority to the notification
        content.subtitle = "Priority: \(task.priority.rawValue)"
        
        // Create trigger based on reminder time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "task_\(task.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule task reminder: \(error)")
            }
        }
    }
    
    func cancelTaskReminder(for task: TaskModel) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["task_\(task.id.uuidString)"]
        )
    }
    
    // MARK: - Travel Notifications
    func scheduleTravelReminders(for travel: TravelInfoModel) {
        guard isAuthorized else { return }
        
        // Schedule departure reminder (24 hours before)
        scheduleDepartureReminder(for: travel)
        
        // Schedule itinerary reminders
        for item in travel.itineraryItems {
            scheduleItineraryReminder(for: item, travel: travel)
        }
    }
    
    private func scheduleDepartureReminder(for travel: TravelInfoModel) {
        let reminderDate = Calendar.current.date(byAdding: .day, value: -1, to: travel.departureDate) ?? travel.departureDate
        
        let content = UNMutableNotificationContent()
        content.title = "Travel Reminder"
        content.body = "Don't forget your trip to \(travel.destination) tomorrow!"
        content.sound = .default
        content.badge = 1
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "travel_departure_\(travel.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule travel departure reminder: \(error)")
            }
        }
    }
    
    private func scheduleItineraryReminder(for item: ItineraryItem, travel: TravelInfoModel) {
        // Schedule reminder 1 hour before itinerary item
        let reminderDate = Calendar.current.date(byAdding: .hour, value: -1, to: item.date) ?? item.date
        
        let content = UNMutableNotificationContent()
        content.title = "Itinerary Reminder"
        content.body = "\(item.title) in 1 hour"
        content.sound = .default
        
        if let location = item.location {
            content.subtitle = "Location: \(location)"
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "itinerary_\(item.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule itinerary reminder: \(error)")
            }
        }
    }
    
    func cancelTravelReminders(for travel: TravelInfoModel) {
        var identifiers = ["travel_departure_\(travel.id.uuidString)"]
        
        // Add itinerary item identifiers
        for item in travel.itineraryItems {
            identifiers.append("itinerary_\(item.id.uuidString)")
        }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    // MARK: - Time Zone Notifications
    func scheduleTimeZoneReminder(for travel: TravelInfoModel) {
        guard isAuthorized else { return }
        
        // Schedule reminder 2 hours after departure to adjust to new time zone
        let adjustmentTime = Calendar.current.date(byAdding: .hour, value: 2, to: travel.departureDate) ?? travel.departureDate
        
        let content = UNMutableNotificationContent()
        content.title = "Time Zone Adjustment"
        content.body = "Remember to adjust your schedule for \(travel.destination) time zone"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: adjustmentTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "timezone_\(travel.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule timezone reminder: \(error)")
            }
        }
    }
    
    // MARK: - General Utilities
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification tap
        let identifier = response.notification.request.identifier
        
        // You can add specific handling based on notification type
        if identifier.hasPrefix("task_") {
            // Handle task notification tap
            print("Task notification tapped: \(identifier)")
        } else if identifier.hasPrefix("travel_") || identifier.hasPrefix("itinerary_") {
            // Handle travel notification tap
            print("Travel notification tapped: \(identifier)")
        }
        
        completionHandler()
    }
}
