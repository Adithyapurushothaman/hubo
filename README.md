# hubo

A new Flutter project.

## Getting Started
How to Run the App

-Make sure you have installed:

**Flutter SDK (version 3.19 or above)
**Android Studio or VS Code
**Android/iOS emulator or a real device

1. Clone the gihub repo
2. run Flutter pub get
3. run ''dart run build_runner build'' for generated files 
4. run flutter run 

Offline vs Online Mode

The app uses Connectivity Plus to detect network status-
- turn off the wifi or mob data for simulating the offline and online mode 

How the Sync Process Works

- offline first approch, when an authenticated user opens app, user is navigated to the dashboard , recent 7 data from db is fetched at first and Ui is loading state , after successfull UI launch, backend api call can be called.And when user add new vitals, added to the local db using drift, fetched from the db first for state update , and then api call for post is called .. as of now mock.

Users can add vitals anytime, even offline
App does NOT lose data
Sync happens safely after reconnection
Dashboard is always reactive, so no stale values appear

Architecture - Feature based Clean Architecture 

lib/
 ├── core/
 │    ├── db/ (Drift)
 │    ├── network/ (Dio + API client)
 │    └── utils/
 ├── feature/
 │    ├── auth/
 │    │     ├── data/ (repo impl)
 │    │     ├── domain/ (entities, repo contract)
 │    │     └── presentation/
 │    └── health/
 │          ├── data/ (vitals DAO + repo)
 │          ├── domain/ (entities + contracts)
 │          └── presentation/ (screens + notifiers)
 └── main.dart
