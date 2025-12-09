Based on the implemented Data Reporting and Analytics features (specifically the ReportsScreen), here is the updated FusionFiesta Backend Implementation Specs.

I have added the Analytics & Reporting endpoints to Section 2 and a new Section 4 covering the specific logic and database optimizations required for generating reports.

FusionFiesta Backend Implementation Specs
This document outlines the API endpoints, database schema, and logic required to replace the Flutter Mock Repositories with a real backend (Node.js/Python/Go + SQL/NoSQL).

1. Database Schema (Entities)
   Users Table
   id: UUID (Primary Key)

email: String (Unique)

password_hash: String

role: Enum (student, organizer, admin, visitor)

is_approved: Boolean (Default false for Staff, true for Students)

profile_data: JSON (name, mobile, department, enrolment_no, profile_pic_url)

Events Table
id: UUID

title: String

organizer_id: UUID (Foreign Key -> Users)

status: Enum (pending, approved, rejected, cancelled, live, completed)

start_time: Timestamp

end_time: Timestamp

registration_limit: Integer

registered_count: Integer

co_organizers: List<UUID> (User IDs)

guidelines_url: String

banner_url: String

Registrations Table
id: UUID

event_id: UUID

user_id: UUID

status: Enum (pending, approved, rejected, attended)

created_at: Timestamp

Media Gallery Table
id: UUID

event_id: UUID

url: String (Public URL)

file_path: String (Internal Storage Path for deletion) (New)

type: Enum (image, video)

uploaded_by: UUID

is_highlighted: Boolean (Default false) (New)

category: String (Technical, Cultural, etc.)

Feedback Table
id: UUID

event_id: UUID

user_id: UUID

ratings: JSON { overall, organization, relevance }

comment: Text

is_flagged: Boolean (Default false) (New)

flag_reason: Enum (abusive, spam, irrelevant, none) (New)

reviewed_by: UUID (Admin ID, nullable) (New)

Certificates Table (New)
id: UUID

event_id: UUID

user_id: UUID

url: String (PDF Link)

status: Enum (active, revoked, error_reported)

issued_at: Timestamp

revocation_reason: Text (Nullable)

Notifications Table
id: UUID

user_id: UUID (Recipient)

title: String

message: String

is_read: Boolean

created_at: Timestamp

2. API Endpoints Required
   Authentication (AuthRepository)
   POST /auth/login -> Returns JWT Token + User Object. Must check is_approved flag.

POST /auth/register -> Creates User. Staff roles default to is_approved=false.

POST /auth/change-password -> Requires old password verification.

Events (EventRepository)
GET /events -> Returns list. Support filters (category, date).

GET /events/{id} -> Event details.

POST /events -> Create event. Default status: pending.

PUT /events/{id} -> Update details.

DELETE /events/{id} -> Soft delete.

POST /events/{id}/approve -> Admin Only. Sets status to approved.

Participation (EventRepository)
POST /events/{id}/register -> Create registration. Check limit constraints.

GET /events/{id}/participants -> Organizer Only. List all students.

PUT /registrations/{id}/status -> Organizer Only. Approve/Reject student.

POST /attendance/scan -> Organizer Only. Input: {eventId, userId}. Sets status to attended.

Interactive Features
POST /announcements -> Organizer Only.

Saves log to DB.

Triggers Push Notification (FCM) to all registered users.

Creates entries in Notifications Table.

POST /feedback -> Student submits rating. (Trigger Automated Profanity Filter here).

GET /feedback/{event_id} -> Organizer/Admin Only. Returns analytics.

Content (GalleryRepository)
POST /gallery/upload -> Multipart file upload. Returns URL.

GET /gallery -> Returns list. Support filtering by is_highlighted.

POST /gallery/{id}/favorite -> Toggle user favorite.

Admin & Moderation (AdminRepository) (New)
Gallery Moderation:

GET /admin/gallery -> List all media.

PATCH /admin/gallery/{id}/highlight -> Toggle is_highlighted.

DELETE /admin/gallery/{id} -> Hard delete from DB and Cloud Storage.

Feedback Moderation:

GET /admin/feedback/flagged -> List where is_flagged=true.

PATCH /admin/feedback/{id}/dismiss -> Set is_flagged=false.

DELETE /admin/feedback/{id} -> Remove comment.

Certificate Oversight:

GET /admin/certificates -> List all issued certs.

PATCH /admin/certificates/{id}/revoke -> Set status to revoked.

User Management:

GET /admin/users?pending=true -> List staff awaiting approval.

PATCH /admin/users/{id}/approve -> Set is_approved=true.

Analytics & Reporting (New)
GET /admin/stats/summary -> Returns aggregate counts (Total Events, Active Users, Pending Approvals, etc.).

GET /admin/stats/department -> Returns event distribution grouped by Organizer Department.

GET /admin/reports/export -> Generates and downloads files.

Query Params: format (pdf or xlsx), date_range.

3. Critical Business Logic to Implement
   Account Control:

Login endpoint MUST return error if is_approved == false.

Admin API to toggle is_approved status.

Event Status Automation:

Backend Cron Job needed to auto-update Event Status:

pending -> approved (Manual Admin Action)

approved -> live (When current_time > start_time)

live -> completed (When current_time > end_time)

Registration Constraints:

Prevent registration if registered_count >= registration_limit.

Prevent registration if User is Visitor role.

Ensure User has profile_completed=true (Enrolment No/ID Proof exists).

File Storage & Cleanup:

Need S3 bucket or equivalent for: Profile Pics, Event Banners, ID Proofs, Gallery Images.

Logic: When DELETE /admin/gallery/{id} is called, the backend must delete the physical file from the bucket using file_path to save storage costs.

Automated Content Moderation (Optional/Recommended):

On POST /feedback, run comment text through a basic profanity filter or AI moderation service (e.g., OpenAI/AWS Rekognition).

If flag is triggered, set is_flagged=true and flag_reason='Automated Filter'.

4. Data Reporting & Analytics Optimization (New)
   Database Indexing:

Create an index on users.department to optimize the "Events by Department" aggregation query.

Create an index on events.status for quick calculation of "Pending" vs "Live" events.

Report Generation Logic:

PDF Generation: Use server-side libraries (e.g., PDFKit for Node, ReportLab for Python) to generate Executive Summaries containing charts and key metrics.

Excel Export: Use libraries (e.g., ExcelJS, Pandas) to dump raw data tables for Users and Events when requested.

Caching: Cache the response of /admin/stats/summary and /admin/stats/department for 1-6 hours (or invalidate on new Event creation) to reduce database load on the dashboard.