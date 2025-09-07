//
//  OnboardingView.swift
//  TaskVenture Fortune
//
//  Created by TaskVenture on 9/6/25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("onboarding_completed") private var onboardingCompleted = false
    @State private var currentPage = 0
    @State private var showMainApp = false
    
    let pages = [
        OnboardingPage(
            title: "Welcome to TaskVenture",
            subtitle: "Fortune",
            description: "Your ultimate companion for productivity and travel organization",
            imageName: "airplane.departure",
            backgroundColor: Color(hex: "#ae2d27")
        ),
        OnboardingPage(
            title: "Organize Your Tasks",
            subtitle: "Efficiently",
            description: "Create, manage, and track tasks with smart reminders that adapt to different time zones",
            imageName: "checklist",
            backgroundColor: Color(hex: "#dfb492")
        ),
        OnboardingPage(
            title: "Smart Travel Companion",
            subtitle: "Integrated",
            description: "Manage travel itineraries, get local tips, and sync your tasks with your travel schedule",
            imageName: "map.fill",
            backgroundColor: Color(hex: "#ffc934")
        ),
        OnboardingPage(
            title: "Custom Automation",
            subtitle: "Personalized",
            description: "Set routines that integrate home and travel schedules with intelligent suggestions",
            imageName: "gear.badge.checkmark",
            backgroundColor: Color(hex: "#1ed55f")
        )
    ]
    
    var body: some View {
        if showMainApp {
            ContentView()
                .transition(.opacity)
        } else {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        pages[currentPage].backgroundColor,
                        pages[currentPage].backgroundColor.opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Glassmorphism effect
                RoundedRectangle(cornerRadius: 30)
                    .fill(.ultraThinMaterial)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 60)
                
                VStack(spacing: 0) {
                    // Page indicator
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.white : Color.white.opacity(0.4))
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut(duration: 0.3), value: currentPage)
                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Content
                    VStack(spacing: 24) {
                        // Icon
                        Image(systemName: pages[currentPage].imageName)
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        // Title and Subtitle
                        VStack(spacing: 8) {
                            Text(pages[currentPage].title)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text(pages[currentPage].subtitle)
                                .font(.system(size: 24, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        
                        // Description
                        Text(pages[currentPage].description)
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .lineLimit(nil)
                    }
                    
                    Spacer()
                    
                    // Navigation buttons
                    HStack {
                        if currentPage > 0 {
                            Button("Previous") {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    currentPage -= 1
                                }
                            }
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                        }
                        
                        Spacer()
                        
                        if currentPage < pages.count - 1 {
                            Button("Next") {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    currentPage += 1
                                }
                            }
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(20)
                        } else {
                            Button("Get Started") {
                                completeOnboarding()
                            }
                            .foregroundColor(pages[currentPage].backgroundColor)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(25)
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 40)
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        let threshold: CGFloat = 50
                        if value.translation.width > threshold && currentPage > 0 {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                currentPage -= 1
                            }
                        } else if value.translation.width < -threshold && currentPage < pages.count - 1 {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                currentPage += 1
                            }
                        }
                    }
            )
        }
    }
    
    private func completeOnboarding() {
        onboardingCompleted = true
        DataService.shared.setOnboardingCompleted(true)
        
        withAnimation(.easeInOut(duration: 0.8)) {
            showMainApp = true
        }
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
    let backgroundColor: Color
}

// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    OnboardingView()
}
