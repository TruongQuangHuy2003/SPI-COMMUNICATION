# README - SPI Communication System

This repository contains a Verilog implementation of an SPI (Serial Peripheral Interface) communication system. The system comprises a master module and two slave modules, with a selectable signal to switch between the slaves.

---

## Overview

SPI is a synchronous serial communication protocol widely used for short-distance communication between a master device and one or more slave devices. This implementation provides an SPI master and two slaves that can be dynamically selected using a `sel` signal.

### Key Features:
1. **Master-Slave Communication**:
   - The `master` module initiates and controls the communication.
   - Two `slave` modules receive the transmitted data and respond accordingly.

2. **Dynamic Slave Selection**:
   - A `sel` signal determines which slave is active during the communication process.

3. **Configurable Data Width**:
   - The design supports 8-bit data transfer between the master and slaves.

4. **Modular Design**:
   - Each component (master, slave, top module) is implemented independently for scalability and ease of testing.

---

## Modules Description

### 1. **Top Module (`spi`)**
   - Manages the interaction between the master and slaves.
   - Routes the data and signals based on the selected slave (`sel` signal).
   - Outputs:
     - `data_out1`: Data received from Slave 1.
     - `data_out2`: Data received from Slave 2.
     - `done`: Indicates the completion of the SPI transaction.

### 2. **Master Module (`master`)**
   - Implements an SPI master with an FSM (Finite State Machine).
   - States:
     - **IDLE**: Waits for the `start` signal.
     - **START**: Prepares data and initializes communication.
     - **TRANSFER**: Sends data bits over the SPI bus and reads data from the selected slave.
     - **DONE**: Concludes the communication and resets signals.
   - Generates the SPI clock (`sck`), chip select (`cs`), and Master Out Slave In (`mosi`) signals.

### 3. **Slave Module (`slave`)**
   - Receives data from the master via `mosi`.
   - Shifts the received bits into an internal shift register.
   - Responds with data over the Master In Slave Out (`miso`) signal.
   - Outputs the received data after completing an 8-bit transfer.

---

## How It Works

1. **Initialization**:
   - The master initializes the communication upon receiving a `start` signal.

2. **Slave Selection**:
   - The `sel` signal determines which slave is active.
     - `sel = 0`: Slave 1 is selected.
     - `sel = 1`: Slave 2 is selected.

3. **Data Transmission**:
   - The master sends 8 bits of data to the selected slave.
   - Simultaneously, the slave responds with its own data over the `miso` line.

4. **Completion**:
   - The master indicates the completion of the transaction via the `done` signal.

---

## Advantages of This Design

- **Scalability**: Additional slaves can be integrated by extending the `sel` mechanism.
- **Ease of Testing**: Modular design allows independent testing of each component.
- **Practicality**: Emulates real-world SPI communication with accurate timing and control signals.

---

## Applications

- Embedded systems requiring communication between microcontrollers and peripherals (e.g., sensors, memory chips, ADC/DAC).
- Prototyping SPI-based systems.
- Educational purposes for learning SPI protocol and FSM design in Verilog.

---

## Future Improvements

- Add support for higher data widths (e.g., 16-bit, 32-bit).
- Implement interrupt-based communication for enhanced performance.
- Introduce error detection mechanisms (e.g., parity bit or CRC).
- Design a verification environment for automated testing.

---
