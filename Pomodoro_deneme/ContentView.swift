//
//  ContentView.swift
//  Pomodoro_deneme
//
//  Created by Ahmet Mert Şengöl on 5.07.2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var pomodoroTimer = PomodoroTimer()
    @State private var showingSettings = false
    @State private var showingStats = false
    
    var body: some View {
        ZStack {
            // Clean background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top navigation
                HStack {
                    Button(action: {
                        showingStats.toggle()
                    }) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showingSettings.toggle()
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                // Main content
                VStack(spacing: 40) {
                    // Session type
                    VStack(spacing: 12) {
                        Text(pomodoroTimer.currentSession.rawValue)
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text("Session \(pomodoroTimer.completedWorkSessions + 1)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Timer circle
                    ZStack {
                        // Background circle
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                            .frame(width: 260, height: 260)
                        
                        // Progress circle
                        Circle()
                            .trim(from: 0, to: pomodoroTimer.progress)
                            .stroke(
                                getSessionColor(),
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .frame(width: 260, height: 260)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.3), value: pomodoroTimer.progress)
                        
                        // Time text
                        Text(pomodoroTimer.formatTime(pomodoroTimer.timeRemaining))
                            .font(.system(size: 42, weight: .light, design: .monospaced))
                            .foregroundColor(.primary)
                    }
                    
                    // Control buttons
                    HStack(spacing: 24) {
                        // Reset button
                        Button(action: {
                            pomodoroTimer.resetTimer()
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                        .opacity(pomodoroTimer.timerState == .stopped ? 0.3 : 1.0)
                        .disabled(pomodoroTimer.timerState == .stopped)
                        
                        // Main play/pause button
                        Button(action: {
                            switch pomodoroTimer.timerState {
                            case .stopped, .paused:
                                pomodoroTimer.startTimer()
                            case .running:
                                pomodoroTimer.pauseTimer()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(getSessionColor())
                                    .frame(width: 72, height: 72)
                                    .shadow(color: getSessionColor().opacity(0.3), radius: 8, x: 0, y: 4)
                                
                                Image(systemName: getPlayButtonIcon())
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                            }
                        }
                        .scaleEffect(pomodoroTimer.timerState == .running ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: pomodoroTimer.timerState)
                        
                        // Skip button
                        Button(action: {
                            pomodoroTimer.skipSession()
                        }) {
                            Image(systemName: "forward.fill")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                        .opacity(pomodoroTimer.timerState == .stopped ? 0.3 : 1.0)
                        .disabled(pomodoroTimer.timerState == .stopped)
                    }
                    
                    // Completed sessions indicator
                    if pomodoroTimer.completedWorkSessions > 0 {
                        HStack(spacing: 8) {
                            ForEach(0..<min(pomodoroTimer.completedWorkSessions, 4), id: \.self) { _ in
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)
                            }
                            
                            if pomodoroTimer.completedWorkSessions > 4 {
                                Text("+\(pomodoroTimer.completedWorkSessions - 4)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .transition(.opacity)
                    }
                }
                
                Spacer()
                Spacer()
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(pomodoroTimer: pomodoroTimer)
        }
        .sheet(isPresented: $showingStats) {
            StatisticsView()
                .environment(\.managedObjectContext, viewContext)
        }
    }
    
    private func getSessionColor() -> Color {
        switch pomodoroTimer.currentSession {
        case .work:
            return Color(red: 0.96, green: 0.26, blue: 0.21) // Soft red
        case .shortBreak:
            return Color(red: 0.20, green: 0.78, blue: 0.35) // Soft green
        case .longBreak:
            return Color(red: 0.00, green: 0.48, blue: 1.00) // Soft blue
        }
    }
    
    private func getPlayButtonIcon() -> String {
        switch pomodoroTimer.timerState {
        case .stopped:
            return "play.fill"
        case .running:
            return "pause.fill"
        case .paused:
            return "play.fill"
        }
    }
}

struct SettingsView: View {
    @ObservedObject var pomodoroTimer: PomodoroTimer
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("Work")
                        Spacer()
                        Text("\(pomodoroTimer.workDuration / 60) min")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Short Break")
                        Spacer()
                        Text("\(pomodoroTimer.shortBreakDuration / 60) min")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Long Break")
                        Spacer()
                        Text("\(pomodoroTimer.longBreakDuration / 60) min")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Timer")
                }
                
                Section {
                    HStack {
                        Text("Work Duration")
                        Spacer()
                        Stepper(
                            "\(pomodoroTimer.workDuration / 60) min",
                            value: Binding(
                                get: { pomodoroTimer.workDuration / 60 },
                                set: { pomodoroTimer.workDuration = $0 * 60 }
                            ),
                            in: 5...60,
                            step: 5
                        )
                        .labelsHidden()
                    }
                    
                    HStack {
                        Text("Short Break")
                        Spacer()
                        Stepper(
                            "\(pomodoroTimer.shortBreakDuration / 60) min",
                            value: Binding(
                                get: { pomodoroTimer.shortBreakDuration / 60 },
                                set: { pomodoroTimer.shortBreakDuration = $0 * 60 }
                            ),
                            in: 1...15,
                            step: 1
                        )
                        .labelsHidden()
                    }
                    
                    HStack {
                        Text("Long Break")
                        Spacer()
                        Stepper(
                            "\(pomodoroTimer.longBreakDuration / 60) min",
                            value: Binding(
                                get: { pomodoroTimer.longBreakDuration / 60 },
                                set: { pomodoroTimer.longBreakDuration = $0 * 60 }
                            ),
                            in: 10...30,
                            step: 5
                        )
                        .labelsHidden()
                    }
                } header: {
                    Text("Customize")
                }
                
                Section {
                    Toggle("Sound", isOn: $pomodoroTimer.isSoundEnabled)
                    Toggle("Notifications", isOn: $pomodoroTimer.isNotificationEnabled)
                } header: {
                    Text("Alerts")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct StatisticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PomodoroSession.date, ascending: false)],
        animation: .default)
    private var sessions: FetchedResults<PomodoroSession>
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Stats overview
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        StatCard(
                            title: "Total",
                            value: "\(sessions.count)",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Completed",
                            value: "\(sessions.filter { $0.isCompleted }.count)",
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                    
                    // Recent sessions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Sessions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 8) {
                            ForEach(Array(sessions.prefix(8)), id: \.self) { session in
                                SessionRow(session: session)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SessionRow: View {
    let session: PomodoroSession
    
    var body: some View {
        HStack {
            Circle()
                .fill(session.sessionType == "Work" ? Color.red : Color.green)
                .frame(width: 10, height: 10)
            
            Text(session.sessionType ?? "Unknown")
                .font(.body)
            
            Spacer()
            
            Text(session.date ?? Date(), style: .time)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if session.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 70)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
