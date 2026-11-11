# Workout Timer Pro

**Workout Timer Pro** is a context-aware Garmin Connect IQ data field that dynamically adapts its layout and metrics based on your active session—seamlessly switching between free-form activities, course navigation, and structured workouts without requiring manual screen changes.

---

## ✨ Key Features

* **Context-Aware Dynamic Display:** Automatically detects whether you are in a **Default Activity**, **Navigating a Course**, or executing a **Structured Workout** (or combining workouts with navigation) and updates the displayed metrics accordingly.
* **Smart Structured Workout Timer:**
  * Counts down remaining time for timed workout steps (`WORKOUT_STEP_DURATION_TIME`) and estimates remaining step distance based on your current average speed.
  * Tracks elapsed step time for open/lap-button steps (`WORKOUT_STEP_DURATION_OPEN`).
  * Supports interval steps (`WorkoutIntervalStep`) by automatically reading the active step.
* **Two-Stage Step Transition Alerts:** Triggers configurable **Ready** (`WORKOUT_ALERT`) and **Red Alert** (`WORKOUT_ALERT_RED`) states as a timed step nears completion, switching the countdown to a clean seconds-only format during final seconds.
* **Intelligent Course Navigation Tracking:**
  * Activates navigation metrics once you pass a configurable minimum distance (`MinDistanceToActivate`) and remain within your allowed off-course threshold (`AllowedOffCourseDistance`).
  * Calculates **Estimated Time to Destination (ETE)** dynamically using remaining distance and average speed, and automatically marks the course complete when within **50 meters** of the destination.
* **Adaptive Layout & Obscurity Handling:** Automatically scales primary and secondary fonts to fit any data field grid size and adjusts X/Y alignment based on screen curvature (`OBSCURE_TOP`, `OBSCURE_BOTTOM`, `OBSCURE_LEFT`, `OBSCURE_RIGHT`).
* **Zero Permissions Required:** Operates completely offline using built-in `Activity.Info` telemetry with zero external app permissions.

---

## 📊 How the Display Adapts

The data field uses a bitmask state machine (`DEFAULT`, `DISTANCE`, `NAVIGATION`, `WORKOUT`, `WORKOUT_ALERT`, `WORKOUT_ALERT_RED`, `WORKOUT_OPEN_LAP`) to prioritize the most relevant metrics in real time:

| Active Mode | Primary Metric | Secondary Metric | Extra / Context Metrics |
| :--- | :--- | :--- | :--- |
| **Default Activity** | Elapsed Activity Time | Elapsed Distance | Current Time of Day (`HH:MM`) |
| **Navigation Active** | Elapsed Activity Time | Time to Destination (`ETE`) | Distance to Destination & Elapsed Distance |
| **Structured Workout** | Workout Step Countdown / Elapsed | Elapsed Activity Time | Estimated Distance to Complete Step & Elapsed Distance |
| **Workout + Navigation** | Workout Step Countdown / Elapsed | Elapsed Activity Time | Time to Destination (`ETE`) & Elapsed Distance |

* **Distance Formatting:** Displays distances under 1,000 m rounded to the nearest 10 meters (e.g., `450 m`), exact kilometers as `X KM`, and fractional kilometers to one decimal place (e.g., `4.2 K`).
* **Time Formatting:** Displays `H:MM:SS` for durations over an hour, `M:SS` for standard durations, and `S` (seconds only) when a workout alert threshold is active.

---

## 📱 Supported Devices

Requires **Connect IQ API Level 5.2.0** or higher:

* **fēnix 7 Series:** fēnix 7, 7S, 7X, 7 Pro, 7S Pro, 7X Pro (including No Wi-Fi editions)
* **fēnix 8 & fēnix E Series:** fēnix 8 (43mm, 47mm), fēnix 8 Pro (47mm), fēnix 8 Solar (47mm, 51mm), fēnix E
* **Forerunner Series:** Forerunner 165 / 165 Music, 170 / 170 Music, 255 / 255S / 255 Music / 255S Music, 265 / 265S, 570 (42mm, 47mm), 955, 965, 970

---

## ⚙️ Configuration & Settings

All settings can be customized via **Garmin Connect** or **Garmin Express**:

### General Settings

| Property | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `DefaultTag` | Text (`alphaNumeric`) | Required, max 10 chars | Default label tag displayed during standard activity states. |
| `ExpandExtraFields` | Toggle (`boolean`) | — | Enables expanded secondary fields when the data field is placed in a non-top/bottom-obscured layout slot. |

### Advanced Settings

| Property | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `OpenLapTag` | Text (`alphaNumeric`) | Required, max 10 chars | Tag displayed when a workout step has an open duration (`WORKOUT_OPEN_LAP`). |
| `PhoneAlertTag` | Text (`alphaNumeric`) | Required, max 10 chars | Tag used for phone alert states. |
| `WorkoutAlertReadyTag` | Text (`alphaNumeric`) | Required, max 10 chars | Tag displayed when entering the initial workout step alert threshold. |
| `WorkoutRedAlertSetTag` | Text (`alphaNumeric`) | Required, max 10 chars | Tag displayed during the final red alert countdown ("Set"). |
| `WorkoutRedAlertGoTag` | Text (`alphaNumeric`) | Required, max 10 chars | Tag displayed upon workout step transition ("Go"). |
| `WorkoutAlertTheshold` | Number (`numeric`) | Min `0` | Seconds remaining in a timed workout step to trigger `WORKOUT_ALERT`. |
| `WorkoutRedAlertTheshold` | Number (`numeric`) | `0` – `60` | Seconds remaining in a timed workout step to trigger `WORKOUT_ALERT_RED`. |
| `OpenLapDisplayInSeconds` | Number (`numeric`) | Min `1` | Controls seconds display behavior during open laps. |
| `AllowedOffCourseDistance` | Number (`numeric`) | Min `100` | Maximum off-course distance (in meters) before navigation metrics are suppressed. |
| `MinDistanceToActivate` | Number (`numeric`) | Min `100` | Minimum elapsed activity distance (in meters) required to activate distance/navigation states. |

---

## 📲 Installation

1. Download **Workout Timer Pro** from the [Garmin Connect IQ Store](https://apps.garmin.com/apps/e2f6fd9d-16f3-4843-a589-083c939e1445).
2. Sync your watch using **Garmin Connect** or **Garmin Express**.
3. On your Garmin device, go to **Activity Settings** → **Data Screens**, pick a layout, and assign **Connect IQ Fields** → **Workout Timer Pro**.

---

## 🛠️ Building from Source

### Prerequisites
* [Visual Studio Code](https://visualstudio.com) with the **Monkey C** extension.
* [Garmin Connect IQ SDK Manager](https://developer.garmin.com/connect-iq/sdk/) (SDK supporting API 5.2.0+) and a developer key.

### Build & Run
1. Clone the repository:
   ```bash
   git clone https://github.com
   cd GarminDatafieldWorkoutTimer
   ```
2. Open the folder in **VS Code**.
3. Press `F5` (or run **Monkey C: Build for Device** from the Command Palette) to launch the Connect IQ Simulator.

---

## 📂 Project Structure

```text
GarminDatafieldWorkoutTimer/
├── .vscode/          # VS Code launch and build tasks
├── resources/        # App icons, strings, layouts, and settings XMLs
├── source/           # Monkey C (.mc) source files (WorkoutTimerProDataFieldView, TimerGauge, etc.)
├── manifest.xml      # App metadata, API level (5.2.0), and target devices
└── monkey.jungle     # Build configuration and resource mapping
```

---

## 👤 Author

* **Anton Rudnev** (`@antonrudnev` / **endurolabs**)
* **Connect IQ Store:** [Workout Timer Pro](https://apps.garmin.com/apps/e2f6fd9d-16f3-4843-a589-083c939e1445)
