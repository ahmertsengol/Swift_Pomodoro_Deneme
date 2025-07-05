//
//  Persistence.swift
//  Pomodoro_deneme
//
//  Created by Ahmet Mert Şengöl on 5.07.2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample data for preview
        let sampleSessions = [
            ("Work", 25 * 60, true),
            ("Short Break", 5 * 60, true),
            ("Work", 25 * 60, true),
            ("Short Break", 5 * 60, false),
            ("Work", 25 * 60, true)
        ]
        
        for (type, duration, isCompleted) in sampleSessions {
            let newSession = PomodoroSession(context: viewContext)
            newSession.sessionType = type
            newSession.duration = Int32(duration)
            newSession.isCompleted = isCompleted
            newSession.date = Date().addingTimeInterval(TimeInterval.random(in: -86400...0)) // Random date within last 24 hours
            if isCompleted {
                newSession.completedAt = newSession.date?.addingTimeInterval(TimeInterval(duration))
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Pomodoro_deneme")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

// MARK: - Helper methods for session management
extension PersistenceController {
    
    func saveSession(type: SessionType, duration: Int, isCompleted: Bool) {
        let context = container.viewContext
        let session = PomodoroSession(context: context)
        
        session.sessionType = type.rawValue
        session.duration = Int32(duration)
        session.isCompleted = isCompleted
        session.date = Date()
        
        if isCompleted {
            session.completedAt = Date()
        }
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            print("Failed to save session: \(nsError), \(nsError.userInfo)")
        }
    }
    
    func getTodaysSessions() -> [PomodoroSession] {
        let context = container.viewContext
        let request: NSFetchRequest<PomodoroSession> = PomodoroSession.fetchRequest()
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PomodoroSession.date, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch today's sessions: \(error)")
            return []
        }
    }
    
    func getWeeklyStats() -> (totalSessions: Int, completedSessions: Int, workSessions: Int) {
        let context = container.viewContext
        let request: NSFetchRequest<PomodoroSession> = PomodoroSession.fetchRequest()
        
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        request.predicate = NSPredicate(format: "date >= %@", weekAgo as NSDate)
        
        do {
            let sessions = try context.fetch(request)
            let totalSessions = sessions.count
            let completedSessions = sessions.filter { $0.isCompleted }.count
            let workSessions = sessions.filter { $0.sessionType == "Work" }.count
            
            return (totalSessions, completedSessions, workSessions)
        } catch {
            print("Failed to fetch weekly stats: \(error)")
            return (0, 0, 0)
        }
    }
}
