# Exhibition Booth Reservation — Flutter Starter

A minimal, local-first Flutter app for Exhibition / Booth management (starter).  
This project includes:

- Guest browsing of published exhibitions
- Read-only floorplan viewing
- Exhibitor interactive floorplan selection + application workflow (basic)
- Admin floorplan mapping UI (draw / edit / delete booths)
- Organizer application review UI (approve/reject with reason)
- Local SQLite (sqflite) storage
- Authentication (local, simplified) using flutter_secure_storage
- Navigation: go_router
- State management: flutter_riverpod
- SVG assets rendered with flutter_svg

Packages used (examples from pubspec.yaml):
- go_router
- flutter_riverpod
- flutter_secure_storage
- flutter_svg
- sqflite
- path_provider
- path
- intl

Seeded user credentials (for testing)
- Admin: username `admin` / password `admin`
- Organizer: username `organizer` / password `orgpass`
- Exhibitor: username `exhibitor` / password `expass`

Quick Start
1. Ensure you have Flutter 3.10+ installed.
2. Create a new Flutter project or use this folder as the project root (it must contain `pubspec.yaml`).
3. Replace or add the `lib/` files and `assets/` as provided in the project.
4. Run:
   - flutter pub get
   - flutter run

Notes and limitations
- This is a starter local app. Passwords are stored in SQLite for demo only — do NOT use in production.
- Route guards will prevent non-admins from opening admin routes and non-organizers from opening organizer routes.
- The Admin floorplan mapping screen assumes SVG viewBox 1000x800 for coordinate mapping.
- Some organizer/admin actions display placeholders (e.g., Manage Exhibitions) and can be implemented next.

Project structure (important files)
- lib/main.dart — app entry and router creation (role-aware)
- lib/app_router.dart — router creation helper with guards
- lib/widgets/app_drawer.dart — role-aware drawer with navigation buttons & badges
- lib/widgets/root_scaffold.dart — global scaffold wrapper (drawer + appbar) used across screens
- lib/screens/admin/admin_floorplan_manage.dart — admin mapping UI (draw/edit/delete booths)
- lib/screens/organizer/organizer_applications_review.dart — organizer review UI (approve/reject)
- lib/screens/exhibition_detail_screen.dart — exhibition detail (now uses RootScaffold)
- lib/screens/exhibitor/floorplan_screen.dart — interactive floorplan screen (now uses RootScaffold)
- lib/services/db_service.dart — DB helpers (save booths, update application status, seed data)
- assets/svg — includes logo.svg, expo1.svg, expo2.svg

Creating a ZIP (local)
From the project root (where pubspec.yaml sits):

macOS / Linux:
- flutter pub get
- rm -rf build
- zip -r ../exhibition_booth_app.zip . -x "build/*" ".gradle/*" ".idea/*" ".vscode/*"

Windows (PowerShell):
- flutter pub get
- Remove-Item -Recurse -Force .\build\
- Compress-Archive -Path * -DestinationPath ..\exhibition_booth_app.zip -Force

If you want, I can:
- Add more complete Organizer/Organizer event management screens.
- Add adjacency enforcement and conflict checks.
- Implement a remote backend / Firebase sync.
- Prepare a GitHub-ready repository file list for direct copy.

Enjoy! If anything fails when you run the app, paste the error here and I’ll help fix it.
