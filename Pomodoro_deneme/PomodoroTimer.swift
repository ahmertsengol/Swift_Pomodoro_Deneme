//
//  PomodoroTimer.swift
//  Pomodoro_deneme
//
//  Created by Ahmet Mert Şengöl on 5.07.2025.
//

import Foundation
import Combine
import AVFoundation
import UserNotifications

enum SessionType: String, CaseIterable {
    case work = "Work"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"
    
    var duration: Int {
        switch self {
        case .work: return 25 * 60 // 25 minutes
        case .shortBreak: return 5 * 60 // 5 minutes
        case .longBreak: return 15 * 60 // 15 minutes
        }
    }
    
    var color: String {
        switch self {
        case .work: return "red"
        case .shortBreak: return "green"
        case .longBreak: return "blue"
        }
    }
}

enum TimerState {
    case stopped
    case running
    case paused
}

class PomodoroTimer: ObservableObject {
    @Published var currentSession: SessionType = .work
    @Published var timeRemaining: Int = 0
    @Published var timerState: TimerState = .stopped
    @Published var completedWorkSessions: Int = 0
    @Published var progress: Double = 0.0
    
    private var timer: Timer?
    private var audioPlayer: AVAudioPlayer?
    private let workSessionsBeforeLongBreak = 4
    private var currentSessionStartTime: Date?
    private var currentSessionInitialDuration: Int = 0
    
    // Settings
    @Published var workDuration: Int = 25 * 60
    @Published var shortBreakDuration: Int = 5 * 60
    @Published var longBreakDuration: Int = 15 * 60
    @Published var isSoundEnabled: Bool = true
    @Published var isNotificationEnabled: Bool = true
    
    init() {
        setupAudio()
        requestNotificationPermission()
        resetTimer()
    }
    
    private func setupAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isNotificationEnabled = granted
            }
        }
    }
    
    func startTimer() {
        guard timerState != .running else { return }
        
        timerState = .running
        
        // Record session start time and initial duration
        if currentSessionStartTime == nil {
            currentSessionStartTime = Date()
            currentSessionInitialDuration = getCurrentSessionDuration()
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateTimer()
        }
    }
    
    func pauseTimer() {
        guard timerState == .running else { return }
        
        timerState = .paused
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer() {
        // Save incomplete session if it was started
        if let startTime = currentSessionStartTime, timerState != .stopped {
            let actualDuration = currentSessionInitialDuration - timeRemaining
            saveCurrentSession(isCompleted: false, actualDuration: actualDuration)
        }
        
        timerState = .stopped
        timer?.invalidate()
        timer = nil
        
        timeRemaining = getCurrentSessionDuration()
        updateProgress()
        
        // Reset session tracking
        currentSessionStartTime = nil
        currentSessionInitialDuration = 0
    }
    
    func skipSession() {
        timer?.invalidate()
        timer = nil
        
        // Save skipped session as incomplete
        if currentSessionStartTime != nil {
            let actualDuration = currentSessionInitialDuration - timeRemaining
            saveCurrentSession(isCompleted: false, actualDuration: actualDuration)
        }
        
        // Move to next session without completing current one
        currentSession = getNextSession()
        resetTimer()
    }
    
    private func updateTimer() {
        guard timeRemaining > 0 else {
            completeSession()
            return
        }
        
        timeRemaining -= 1
        updateProgress()
    }
    
    private func updateProgress() {
        let totalDuration = getCurrentSessionDuration()
        progress = Double(totalDuration - timeRemaining) / Double(totalDuration)
    }
    
    private func getCurrentSessionDuration() -> Int {
        switch currentSession {
        case .work: return workDuration
        case .shortBreak: return shortBreakDuration
        case .longBreak: return longBreakDuration
        }
    }
    
    private func completeSession() {
        timer?.invalidate()
        timer = nil
        timerState = .stopped
        
        // Save completed session
        saveCurrentSession(isCompleted: true, actualDuration: currentSessionInitialDuration)
        
        if currentSession == .work {
            completedWorkSessions += 1
        }
        
        playNotificationSound()
        scheduleNotification()
        
        // Move to next session
        currentSession = getNextSession()
        resetTimer()
    }
    
    private func getNextSession() -> SessionType {
        switch currentSession {
        case .work:
            return (completedWorkSessions % workSessionsBeforeLongBreak == 0) ? .longBreak : .shortBreak
        case .shortBreak, .longBreak:
            return .work
        }
    }
    
    private func playNotificationSound() {
        guard isSoundEnabled else { return }
        
        // Play system sound
        AudioServicesPlaySystemSound(1322) // Glass sound
    }
    
    private func scheduleNotification() {
        guard isNotificationEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Pomodoro Timer"
        content.body = "\(currentSession.rawValue) session completed! Time for \(getNextSession().rawValue.lowercased())."
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private func saveCurrentSession(isCompleted: Bool, actualDuration: Int) {
        PersistenceController.shared.saveSession(
            type: currentSession,
            duration: actualDuration,
            isCompleted: isCompleted
        )
    }
}

// MARK: - AudioServicesPlaySystemSound
import AudioToolbox 