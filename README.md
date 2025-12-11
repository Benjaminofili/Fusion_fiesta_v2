# FusionFiesta 🚀

**FusionFiesta** is a comprehensive, cross-platform mobile application designed to digitize and streamline the entire lifecycle of college events. From registration to certification, it bridges the gap between Students, Organizers, and Administrators in a unified ecosystem.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![State Management](https://img.shields.io/badge/State_Management-Streams_%26_Repository-success?style=for-the-badge)

## 📱 Screenshots

| Student Dashboard | Event Details | Organizer Panel | Admin Analytics |
|:---:|:---:|:---:|:---:|
| | | | |

## ✨ Key Features

The application implements a strict **Role-Based Access Control (RBAC)** system:

### 🎓 Student (Participant)
* **Event Catalog:** Browse events with advanced filtering (Technical, Cultural, Sports).
* **One-Click Registration:** Seamless registration flow with profile verification.
* **Digital Wallet:** Access QR-code tickets and download earned e-certificates.
* **Engagement:** Save favorite events and provide post-event feedback.
* **Notifications:** Receive real-time updates on schedule changes and announcements.

### 📋 Organizer (Staff/Faculty)
* **Event Lifecycle Management:** Create, edit, and manage event details.
* **Attendance System:** Built-in QR Code Scanner for rapid student check-in.
* **Communication:** Broadcast announcements to all registered participants.
* **Post-Event Tools:** Upload results and generate bulk certificates.
* **Analytics:** View registration counts and capacity in real-time.

### 🛡️ Administrator
* **System Overview:** High-level dashboard with system health and usage stats.
* **Approval Workflow:** Review and approve/reject event proposals from organizers.
* **User Management:** Approve staff accounts and manage user roles.
* **Content Moderation:** Moderate gallery uploads and feedback to ensure community standards.
* **Reports:** Generate executive summaries and export data.

## 🛠️ Tech Stack & Architecture

This project follows a **Feature-First, Clean Architecture** approach to ensure scalability and maintainability.

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Routing:** `go_router` for robust navigation and deep linking.
* **Dependency Injection:** `get_it` for service location.
* **Local Storage:** `hive` for secure, offline-first session management.
* **State Management:** Reactive Repository Pattern using Dart `Stream` and `StreamBuilder`.
* **UI/UX:** `flutter_screenutil` for responsiveness, `flutter_animate` for micro-interactions, and Lottie animations.
* **Hardware Integration:** `mobile_scanner` (Camera), `url_launcher`, and File System access.

## 📂 Project Structure

```text
lib/
├── app/                 # App configuration, Router, DI injection
├── core/                # Constants, Services (Auth, Storage), Reusable Widgets
├── data/                # Data Layer (Models, Repositories)
├── features/            # Feature-first modules
│   ├── admin/           # Admin-specific screens (Approvals, Reports, Users)
│   ├── common/          # Shared screens (Auth, Gallery, Profile)
│   ├── organizer/       # Organizer screens (Scanner, Creator, Dashboard)
│   └── student/         # Student screens (Tickets, Catalog, Certificates)
├── mock/                # Mock Data Services (Simulated Backend)
└── main.dart            # Entry point
