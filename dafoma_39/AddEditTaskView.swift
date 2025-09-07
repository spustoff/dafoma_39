//
//  AddEditTaskView.swift
//  TaskVenture Fortune
//
//  Created by TaskVenture on 9/6/25.
//

import SwiftUI

struct AddEditTaskView: View {
    @ObservedObject var viewModel: TaskViewModel
    let editingTask: TaskModel?
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority = TaskPriority.medium
    @State private var category = TaskCategory.personal
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    @State private var hasReminder = false
    @State private var reminderTime = Date()
    @State private var selectedTimeZone = TimeZone.current
    
    init(viewModel: TaskViewModel, editingTask: TaskModel? = nil) {
        self.viewModel = viewModel
        self.editingTask = editingTask
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task title", text: $title)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                    
                    TextField("Description (optional)", text: $description)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .lineLimit(3)
                }
                
                Section(header: Text("Priority & Category")) {
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(Color(hex: priority.color))
                                    .frame(width: 12, height: 12)
                                Text(priority.rawValue)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Picker("Category", selection: $category) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Due Date & Time")) {
                    Toggle("Set due date", isOn: $hasDueDate)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                    
                    if hasDueDate {
                        DatePicker("Due date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                        
                        Picker("Time Zone", selection: $selectedTimeZone) {
                            ForEach(commonTimeZones, id: \.identifier) { timeZone in
                                Text(timeZone.localizedName(for: .standard, locale: .current) ?? timeZone.identifier)
                                    .tag(timeZone)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        Toggle("Set reminder", isOn: $hasReminder)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                        
                        if hasReminder {
                            DatePicker("Reminder time", selection: $reminderTime, displayedComponents: [.date, .hourAndMinute])
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                        }
                    }
                }
            }
            .navigationTitle(editingTask == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color(hex: "#eb262f")),
                
                trailing: Button("Save") {
                    saveTask()
                }
                .foregroundColor(Color(hex: "#1ed55f"))
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
        }
        .onAppear {
            setupInitialValues()
        }
    }
    
    private var commonTimeZones: [TimeZone] {
        let identifiers = [
            "America/New_York",
            "America/Chicago",
            "America/Denver",
            "America/Los_Angeles",
            "Europe/London",
            "Europe/Paris",
            "Europe/Berlin",
            "Asia/Tokyo",
            "Asia/Shanghai",
            "Asia/Dubai",
            "Australia/Sydney"
        ]
        
        var timeZones = identifiers.compactMap { TimeZone(identifier: $0) }
        
        // Add current time zone if not already included
        if !timeZones.contains(TimeZone.current) {
            timeZones.insert(TimeZone.current, at: 0)
        }
        
        return timeZones
    }
    
    private func setupInitialValues() {
        if let task = editingTask {
            title = task.title
            description = task.description
            priority = task.priority
            category = task.category
            selectedTimeZone = task.timeZone
            
            if let dueDate = task.dueDate {
                self.dueDate = dueDate
                hasDueDate = true
            }
            
            if let reminderTime = task.reminderTime {
                self.reminderTime = reminderTime
                hasReminder = true
            }
        } else {
            // Set default reminder time to 1 hour before due date
            reminderTime = Calendar.current.date(byAdding: .hour, value: -1, to: dueDate) ?? dueDate
        }
    }
    
    private func saveTask() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        if let existingTask = editingTask {
            var updatedTask = existingTask
            updatedTask.title = trimmedTitle
            updatedTask.description = description
            updatedTask.priority = priority
            updatedTask.category = category
            updatedTask.timeZone = selectedTimeZone
            updatedTask.dueDate = hasDueDate ? dueDate : nil
            updatedTask.reminderTime = (hasDueDate && hasReminder) ? reminderTime : nil
            
            viewModel.updateTask(updatedTask)
            
            // Update notification
            NotificationService.shared.cancelTaskReminder(for: existingTask)
            if hasReminder && hasDueDate {
                NotificationService.shared.scheduleTaskReminder(for: updatedTask)
            }
        } else {
            let newTask = TaskModel(
                title: trimmedTitle,
                description: description,
                priority: priority,
                dueDate: hasDueDate ? dueDate : nil,
                timeZone: selectedTimeZone,
                category: category
            )
            
            if hasDueDate && hasReminder {
                var taskWithReminder = newTask
                taskWithReminder.reminderTime = reminderTime
                viewModel.addTask(taskWithReminder)
                NotificationService.shared.scheduleTaskReminder(for: taskWithReminder)
            } else {
                viewModel.addTask(newTask)
            }
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    AddEditTaskView(viewModel: TaskViewModel())
}
