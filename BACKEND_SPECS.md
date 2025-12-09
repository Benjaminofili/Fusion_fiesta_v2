# FusionFiesta Backend Implementation Specs

This document outlines the API endpoints, database schema, and logic required to replace the Flutter Mock Repositories with a real backend (Node.js/Python/Go + SQL/NoSQL).

## 1. Database Schema (Entities)

### Users Table
- **id**: UUID (Primary Key)
- **email**: String (Unique)
- **password_hash**: String
- **role**: Enum (student, organizer, admin, visitor)
- **is_approved**: Boolean (Default false for Staff, true for Students)
- **profile_data**: JSON (name, mobile, department, enrolment_no, profile_pic_url)

### Events Table
- **id**: UUID
- **title**: String
- **organizer_id**: UUID (Foreign Key -> Users)
- **status**: Enum (pending, approved, rejected, cancelled, live, completed)
- **start_time**: Timestamp
- **end_time**: Timestamp
- **registration_limit**: Integer
- **registered_count**: Integer
- **co_organizers**: List<UUID> (User IDs)

### Registrations Table
- **id**: UUID
- **event_id**: UUID
- **user_id**: UUID
- **status**: Enum (pending, approved, rejected, attended)
- **created_at**: Timestamp

### Media Gallery Table
- **id**: UUID
- **event_id**: UUID
- **url**: String (S3/Cloud Storage link)
- **type**: Enum (image, video)
- **uploaded_by**: UUID

### Feedback Table
- **id**: UUID
- **event_id**: UUID
- **user_id**: UUID
- **ratings**: JSON { overall, organization, relevance }
- **comment**: Text

### Notifications Table
- **id**: UUID
- **user_id**: UUID (Recipient)
- **title**: String
- **message**: String
- **is_read**: Boolean

---

## 2. API Endpoints Required

### Authentication (`AuthRepository`)
- `POST /auth/login` -> Returns JWT Token + User Object. **Must check `is_approved` flag.**
- `POST /auth/register` -> Creates User. Staff roles default to `is_approved=false`.
- `POST /auth/change-password` -> Requires old password verification.

### Events (`EventRepository`)
- `GET /events` -> Returns list. Support filters (category, date).
- `GET /events/{id}` -> Event details.
- `POST /events` -> Create event. Default status: `pending`.
- `PUT /events/{id}` -> Update details.
- `DELETE /events/{id}` -> Soft delete.
- `POST /events/{id}/approve` -> **Admin Only**. Sets status to `approved`.

### Participation (`EventRepository`)
- `POST /events/{id}/register` -> Create registration. Check limit constraints.
- `GET /events/{id}/participants` -> **Organizer Only**. List all students.
- `PUT /registrations/{id}/status` -> **Organizer Only**. Approve/Reject student.
- `POST /attendance/scan` -> **Organizer Only**. Input: `{eventId, userId}`. Sets status to `attended`.

### Interactive Features
- `POST /announcements` -> **Organizer Only**.
    1. Saves log to DB.
    2. Triggers Push Notification (FCM) to all registered users.
    3. Creates entries in Notifications Table.
- `POST /feedback` -> Student submits rating.
- `GET /feedback/{event_id}` -> **Organizer/Admin Only**. Returns analytics.

### Content (`GalleryRepository`)
- `POST /gallery/upload` -> Multipart file upload. Returns URL.
- `GET /gallery` -> Returns list.

---

## 3. Critical Business Logic to Implement

1.  **Account Control:**
    * Login endpoint MUST return error if `is_approved == false`.
    * Admin API to toggle `is_approved` status.

2.  **Event Status Automation:**
    * Backend Cron Job needed to auto-update Event Status:
        * `pending` -> `approved` (Manual Admin Action)
        * `approved` -> `live` (When `current_time > start_time`)
        * `live` -> `completed` (When `current_time > end_time`)

3.  **Registration Constraints:**
    * Prevent registration if `registered_count >= registration_limit`.
    * Prevent registration if User is `Visitor` role.

4.  **File Storage:**
    * Need S3 bucket or equivalent for: Profile Pics, Event Banners, ID Proofs, Gallery Images.