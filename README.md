# 🌧️ RainGuard: FPGA-Based Smart Irrigation System

RainGuard is a Verilog-based smart irrigation project implemented on an FPGA, designed to automate crop protection during rainfall. It intelligently detects rain and soil conditions, and controls a servo motor to cover or uncover crops accordingly.

---

## 🧠 System Overview

- **FSM-Based Control**: Efficient Finite State Machine to handle crop cover decisions.
- **Sensor Inputs**:
  -  Rain Sensor (Digital)
  -  Soil Moisture Sensor (Digital)
- **Output**: Servo Motor (via PWM)

---

## 📂 Folder Structure

```
RainGuard_SmartIrrigation/
├── Verilog_Code/
│ ├── pwm_servo.v
│ ├── rain_guard_fsm.v
│ └── rain_guard_top.v
├── Simulation/
│ ├── testbench.v
│ └── Simulation Output.png
│ └── Tcl console Output
├── Media/
| ├── Finite State Machine.jpg
│ ├── FPGA Development Setup 1.jpg
│ ├── FPGA Development Setup 2.jpg
│ └── Demo video.mp4
├── Constraints
```
---

## ⚙️ How It Works

> ⚠️ **Note on Rain Sensor Logic:**
> 
> The rain sensor used in this system is **active-low**:
> - `rain_detected = 0` → **Rain is present**
> - `rain_detected = 1` → **No rain**
>
> This logic is used throughout the FSM and testbench.

| **State**      | **Condition**           | **Next State** | **Description**                                              |
|----------------|-------------------------|----------------|--------------------------------------------------------------|
| `IDLE`         | `rain_detected = 1`     | `CHECK_SOIL`   | If no rain, check the soil condition.                        |
|                | `rain_detected = 0`     | `IDLE`         | Stay in IDLE if rain is detected (servo stays at 0°).        |
| `CHECK_SOIL`   | `rain_detected = 0`     | `IDLE`         | If rain starts during check, return to IDLE.                 |
|                | `soil_dry = 1`          | `LEAVE_OPEN`   | If soil is dry → leave crops uncovered (servo at 0°).        |
|                | `soil_dry = 0`          | `COVER_CROP`   | If soil is wet → cover crops (servo at 90°).                 |
| `COVER_CROP`   | `rain_detected = 0`     | `IDLE`         | If rain starts, return to IDLE.                              |
|                | `rain_detected = 1`     | `COVER_CROP`   | Stay in COVER_CROP if no rain.                               |
| `LEAVE_OPEN`   | `rain_detected = 0`     | `IDLE`         | If rain starts, return to IDLE.                              |
|                | `soil_dry = 0`          | `COVER_CROP`   | If soil becomes wet, switch to covering crops.               |
|                | `soil_dry = 1`          | `LEAVE_OPEN`   | Stay in open state if soil is still dry.                     |

---

## ▶️ Demo Video & Images

Find outputs and working demo in `Media/` folder.

---

## 📁 Project Highlights

- Designed using FSM in Verilog.
- PWM-based servo control.
- 50MHz FPGA-compatible simulation and timing.
- Fully testbench verified.

---

## 💡 Future Improvements

- Add analog sensor support.
- Integrate temperature & humidity.
- IoT-based control or mobile app integration.

---

> ⚙️ Built in 2 days | Verified with real sensors | Powered by Verilog & Passion!

