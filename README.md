# 🍅 Pomodoro Timer iOS App

A beautiful, minimalist Pomodoro Timer app built with SwiftUI for iOS. This app helps you boost your productivity using the proven Pomodoro Technique.

## ✨ Features

### ⏱️ Timer Functionality
- **25-minute work sessions** with 5-minute short breaks
- **15-minute long breaks** after every 4 work sessions
- **Play/Pause/Reset** controls with smooth animations
- **Skip session** functionality
- **Visual progress indicator** with circular progress ring

### 🎨 Beautiful Design
- **Minimalist interface** with clean, modern design
- **Dynamic colors** that change based on session type
- **Smooth animations** and transitions
- **Intuitive controls** with haptic feedback
- **Elegant typography** with monospace timer display

### 📊 Progress Tracking
- **Session statistics** with Core Data persistence
- **Daily and weekly** progress overview
- **Completed sessions counter** with visual indicators
- **Session history** with timestamps
- **Work vs. break** session breakdown

### ⚙️ Customization
- **Adjustable timer durations** for work and break sessions
- **Sound notifications** on/off toggle
- **Push notifications** support
- **Persistent settings** using UserDefaults

### 🔔 Smart Notifications
- **Audio alerts** when sessions complete
- **Push notifications** with session completion details
- **Automatic session transitions**
- **Background timer** support

## 🚀 Technical Details

### Built With
- **SwiftUI** - Modern declarative UI framework
- **Core Data** - For persistent session storage
- **Combine** - Reactive programming for timer updates
- **UserNotifications** - For push notifications
- **AVFoundation** - For audio feedback

### Architecture
- **MVVM Pattern** - Clean separation of concerns
- **ObservableObject** - For reactive state management
- **Core Data Stack** - Proper data persistence
- **Singleton Pattern** - For PersistenceController

### Requirements
- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## 📱 Screenshots

*(Add your app screenshots here when available)*

## 🛠️ Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/pomodoro-timer-ios.git
```

2. Open the project in Xcode:
```bash
cd pomodoro-timer-ios
open Pomodoro_deneme.xcodeproj
```

3. Build and run the project on your device or simulator

## 🎯 How to Use

1. **Start Timer**: Tap the large play button to begin a work session
2. **Pause/Resume**: Tap the button again to pause or resume the timer
3. **Reset**: Use the reset button to restart the current session
4. **Skip**: Use the forward button to move to the next session
5. **Settings**: Tap the settings icon to customize timer durations
6. **Statistics**: View your progress in the statistics section

## 🍅 About the Pomodoro Technique

The Pomodoro Technique is a time management method developed by Francesco Cirillo in the late 1980s. It uses a timer to break down work into intervals, typically 25 minutes in length, separated by short breaks.

### The Process:
1. **Work** for 25 minutes
2. Take a **5-minute break**
3. After 4 work sessions, take a **15-minute long break**
4. **Repeat** the cycle

## 🔧 Customization

The app allows you to customize:
- **Work duration** (5-60 minutes)
- **Short break duration** (1-15 minutes)
- **Long break duration** (10-30 minutes)
- **Sound notifications** (on/off)
- **Push notifications** (on/off)

## 📊 Data Persistence

The app uses Core Data to store:
- Session history with timestamps
- Session completion status
- Session types (work, short break, long break)
- Session durations

## 🎨 Design Philosophy

This app follows a **minimalist design philosophy**:
- Clean, uncluttered interface
- Subtle animations and transitions
- Intuitive user interactions
- Accessibility-first approach
- Native iOS design patterns

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Ahmet Mert Şengöl**
- GitHub: [@yourusername](https://github.com/yourusername)
- Email: your.email@example.com

## 🙏 Acknowledgments

- Inspired by the Pomodoro Technique by Francesco Cirillo
- Built with love using SwiftUI and modern iOS development practices
- Special thanks to the iOS development community

---

**Happy Productivity! 🚀** 