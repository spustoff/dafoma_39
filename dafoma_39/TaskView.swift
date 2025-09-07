//
//  TaskView.swift
//  TaskVenture Fortune
//
//  Created by TaskVenture on 9/6/25.
//

import SwiftUI

struct TaskView: View {
    @StateObject private var taskViewModel = TaskViewModel()
    @State private var showingAddTask = false
    @State private var showingFilterSheet = false
    @State private var selectedTask: TaskModel?
    
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
                
                VStack(spacing: 0) {
                    // Search and Filter Bar
                    HStack {
                        // Search
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            
                            TextField("Search tasks...", text: $taskViewModel.searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .onChange(of: taskViewModel.searchText) { _ in
                                    taskViewModel.filterTasks()
                                }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        
                        // Filter button
                        Button(action: {
                            showingFilterSheet = true
                        }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.title2)
                                .foregroundColor(Color(hex: "#1ed55f"))
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // Task Statistics
                    if !taskViewModel.tasks.isEmpty {
                        TaskStatisticsView(tasks: taskViewModel.tasks)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    }
                    
                    // Tasks List
                    if taskViewModel.filteredTasks.isEmpty {
                        EmptyTasksView(hasFilters: taskViewModel.selectedCategory != nil || taskViewModel.selectedPriority != nil || !taskViewModel.searchText.isEmpty)
                    } else {
                        List {
                            ForEach(taskViewModel.filteredTasks) { task in
                                TaskRowView(
                                    task: task,
                                    onToggleComplete: {
                                        taskViewModel.toggleTaskCompletion(task)
                                    },
                                    onEdit: {
                                        selectedTask = task
                                    }
                                )
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                            .onDelete(perform: deleteTasks)
                        }
                        .listStyle(PlainListStyle())
                        .refreshable {
                            taskViewModel.filterTasks()
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                trailing: Button(action: {
                    showingAddTask = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color(hex: "#1ed55f"))
                }
            )
        }
        .sheet(isPresented: $showingAddTask) {
            AddEditTaskView(viewModel: taskViewModel)
        }
        .sheet(item: $selectedTask) { task in
            AddEditTaskView(viewModel: taskViewModel, editingTask: task)
        }
        .sheet(isPresented: $showingFilterSheet) {
            TaskFilterView(viewModel: taskViewModel)
        }
        .onAppear {
            if taskViewModel.tasks.isEmpty {
                taskViewModel.createSampleTasks()
            }
        }
    }
    
    private func deleteTasks(offsets: IndexSet) {
        for index in offsets {
            let task = taskViewModel.filteredTasks[index]
            taskViewModel.deleteTask(task)
        }
    }
}

struct TaskRowView: View {
    let task: TaskModel
    let onToggleComplete: () -> Void
    let onEdit: () -> Void
    
    private var timeZoneFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.timeZone = task.timeZone
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = task.timeZone
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion checkbox
            Button(action: onToggleComplete) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? Color(hex: "#1ed55f") : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(task.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(task.isCompleted ? .gray : .primary)
                    .strikethrough(task.isCompleted)
                
                // Description
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Due date and time zone
                if let dueDate = task.dueDate {
                    HStack(spacing: 8) {
                        Label(dateFormatter.string(from: dueDate), systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(dueDate < Date() && !task.isCompleted ? Color(hex: "#eb262f") : .secondary)
                        
                        if task.timeZone != TimeZone.current {
                            Label(task.timeZone.abbreviation() ?? "UTC", systemImage: "globe")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Category and Priority
                HStack(spacing: 8) {
                    // Category
                    Label(task.category.rawValue, systemImage: task.category.icon)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Priority
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(hex: task.priority.color))
                            .frame(width: 8, height: 8)
                        
                        Text(task.priority.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Edit button
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct TaskStatisticsView: View {
    let tasks: [TaskModel]
    
    private var completedCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    private var overdueCount: Int {
        tasks.filter { !$0.isCompleted && ($0.dueDate ?? Date.distantFuture) < Date() }.count
    }
    
    private var completionRate: Double {
        guard tasks.count > 0 else { return 0.0 }
        return Double(completedCount) / Double(tasks.count)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Total tasks
            StatisticItem(
                title: "Total",
                value: "\(tasks.count)",
                color: Color(hex: "#dfb492")
            )
            
            // Completed tasks
            StatisticItem(
                title: "Completed",
                value: "\(completedCount)",
                color: Color(hex: "#1ed55f")
            )
            
            // Overdue tasks
            if overdueCount > 0 {
                StatisticItem(
                    title: "Overdue",
                    value: "\(overdueCount)",
                    color: Color(hex: "#eb262f")
                )
            }
            
            // Completion rate
            StatisticItem(
                title: "Progress",
                value: "\(Int(completionRate * 100))%",
                color: Color(hex: "#ffc934")
            )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct StatisticItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct EmptyTasksView: View {
    let hasFilters: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: hasFilters ? "line.3.horizontal.decrease.circle" : "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(hasFilters ? "No tasks match your filters" : "No tasks yet")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            
            if !hasFilters {
                Text("Tap the + button to add your first task")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 60)
    }
}

#Preview {
    TaskView()
}
