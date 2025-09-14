# 📌 Roll Call - Student Attendance Application

Final Project - Course: **Mobile Programming**  
Programming Language: **Flutter (Dart)**  
Database: **Firebase (Realtime Database, two-way sync)**  
Hardware Integration: **ESP32 + RFID**

---

## 👨‍💻 Team Members
- Trần Nguyễn Thành Tài
- Nguyễn Đăng Trường
- Nguyễn Thị Ngọc Hân
- Nguyễn Cao Tấn Thành
- Nguyễn Đức Tiến

---

## 📱 Project Overview
**Roll Call** is a mobile application that integrates **Flutter (mobile app)** and **ESP32 + RFID (hardware)** to build a smart student attendance management system.  
The system allows teachers to easily **manage, track, and analyze attendance data** in real-time, stored securely in Firebase.

---

## ✨ Features
- 🔑 **Account Management**: Create and manage user accounts with Firebase Authentication.  
- 📝 **Student List Management**: Add, edit, and remove students, with automatic two-way sync to Firebase.  
- ⏰ **Custom Attendance Time**: Teachers can set the start and end time for attendance.  
- ✅ **Attendance Status**: Mark students as *on time* or *late* depending on check-in time.  
- 📅 **Daily Attendance Records**: Store student names, check-in times, and dates separately for each day.  
- 📊 **Monthly Statistics**: Track attendance frequency to reward students with full participation.  
- 🔔 **Push Notifications**: Students receive notifications when attendance is successfully recorded.  
- 📡 **ESP32 + RFID Integration**: Students simply scan their RFID card, and the data is instantly synced with Firebase and the app.  

---

## 🏗️ System Architecture
### Components:
1. **Mobile Application (Flutter + Firebase)**  
   - User authentication and account management  
   - Real-time student attendance management  
   - Syncs directly with Firebase Realtime Database  

2. **Hardware (ESP32 + RFID)**  
   - Detects student RFID card scans  
   - Sends attendance data directly to Firebase  

---

## 📷 Screenshots / Demo
*(Insert app screenshots or demo GIFs here)*  

---

## ⚙️ Installation & Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/Thanhtai1305/Finalproject_Mobile_DIEM-DANH-SINH-VIEN.git
   cd Finalproject_Mobile_DIEM-DANH-SINH-VIEN
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Connect Firebase:
   * Enable Realtime Database
   * Configure Authentication
    
4. Run the application:
   ```bash
   flutter run
   ```
---
## 📊 Future Improvements
### 🔍 Add Face Recognition  
Use face recognition as an alternative attendance method.  

### 📑 Export Reports  
Generate and export attendance reports in **PDF/Excel** format.  

### 🎨 UI/UX Enhancement  
Upgrade the UI using **Material 3 / iOS style** for a modern look.  

---
## 📝 License

This project is developed for educational purposes only.

--- 


