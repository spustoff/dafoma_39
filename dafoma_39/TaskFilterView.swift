//
//  TaskFilterView.swift
//  TaskVenture Fortune
//
//  Created by TaskVenture on 9/6/25.
//

import SwiftUI

struct TaskFilterView: View {
    @ObservedObject var viewModel: TaskViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sort By")) {
                    Picker("Sort Option", selection: $viewModel.sortOption) {
                        ForEach(TaskViewModel.SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: viewModel.sortOption) { _ in
                        viewModel.filterTasks()
                    }
                }
                
                Section(header: Text("Filter by Category")) {
                    HStack {
                        Button("All") {
                            viewModel.selectedCategory = nil
                            viewModel.filterTasks()
                        }
                        .foregroundColor(viewModel.selectedCategory == nil ? Color(hex: "#1ed55f") : .primary)
                        .font(.system(size: 14, weight: viewModel.selectedCategory == nil ? .bold : .regular, design: .rounded))
                        
                        Spacer()
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            Button(action: {
                                if viewModel.selectedCategory == category {
                                    viewModel.selectedCategory = nil
                                } else {
                                    viewModel.selectedCategory = category
                                }
                                viewModel.filterTasks()
                            }) {
                                HStack {
                                    Image(systemName: category.icon)
                                        .font(.caption)
                                    Text(category.rawValue)
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    viewModel.selectedCategory == category ?
                                    Color(hex: "#1ed55f").opacity(0.2) :
                                    Color.gray.opacity(0.1)
                                )
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            viewModel.selectedCategory == category ?
                                            Color(hex: "#1ed55f") :
                                            Color.clear,
                                            lineWidth: 1
                                        )
                                )
                            }
                            .foregroundColor(
                                viewModel.selectedCategory == category ?
                                Color(hex: "#1ed55f") :
                                .primary
                            )
                        }
                    }
                }
                
                Section(header: Text("Filter by Priority")) {
                    HStack {
                        Button("All") {
                            viewModel.selectedPriority = nil
                            viewModel.filterTasks()
                        }
                        .foregroundColor(viewModel.selectedPriority == nil ? Color(hex: "#1ed55f") : .primary)
                        .font(.system(size: 14, weight: viewModel.selectedPriority == nil ? .bold : .regular, design: .rounded))
                        
                        Spacer()
                    }
                    
                    VStack(spacing: 8) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Button(action: {
                                if viewModel.selectedPriority == priority {
                                    viewModel.selectedPriority = nil
                                } else {
                                    viewModel.selectedPriority = priority
                                }
                                viewModel.filterTasks()
                            }) {
                                HStack {
                                    Circle()
                                        .fill(Color(hex: priority.color))
                                        .frame(width: 12, height: 12)
                                    
                                    Text(priority.rawValue)
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                    
                                    Spacer()
                                    
                                    if viewModel.selectedPriority == priority {
                                        Image(systemName: "checkmark")
                                            .font(.caption)
                                            .foregroundColor(Color(hex: "#1ed55f"))
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    viewModel.selectedPriority == priority ?
                                    Color(hex: "#1ed55f").opacity(0.1) :
                                    Color.clear
                                )
                                .cornerRadius(8)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
                
                Section {
                    Button("Clear All Filters") {
                        viewModel.selectedCategory = nil
                        viewModel.selectedPriority = nil
                        viewModel.searchText = ""
                        viewModel.filterTasks()
                    }
                    .foregroundColor(Color(hex: "#eb262f"))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Filter & Sort")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color(hex: "#1ed55f"))
            )
        }
    }
}

#Preview {
    TaskFilterView(viewModel: TaskViewModel())
}
