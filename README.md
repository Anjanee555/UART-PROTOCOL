UART Communication System
🚀 Project Overview

This project implements a fully synthesizable UART (Universal Asynchronous Receiver Transmitter) communication system using Verilog HDL.

The design demonstrates reliable asynchronous serial communication between transmitter and receiver, including baud rate generation and FIFO-based buffering for stable data transfer.

The system is developed and verified using Xilinx Vivado.

🏗️ System Architecture

The data flow inside the system:

UART TX FIFO → UART Transmitter → Serial Line → UART Receiver → UART RX FIFO

The system is integrated in a top-level module.

🔧 RTL Modules Description (rtl/)

1️⃣ uart_bg.v (Baud Generator)

Generates baud rate clock from system clock.

Configurable baud rate (e.g., 9600 / 115200 bps).

Provides timing reference for TX and RX modules.

2️⃣ uart_tx.v (UART Transmitter)

Converts 8-bit parallel data into serial format.

Implements standard UART frame:

1 Start bit

8 Data bits

1 Stop bit

Sends data based on baud tick.

Reads data from TX FIFO.

3️⃣ uart_rx.v (UART Receiver)

Receives serial data from RX line.

Detects start bit.

Samples incoming bits using baud clock.

Reconstructs 8-bit parallel data.

Writes received data into RX FIFO.

4️⃣ fifo_tx.v (Transmit FIFO)

Buffers outgoing parallel data before transmission.

Prevents data loss during continuous transmission.

Generates:

full

empty

write_enable

read_enable

5️⃣ fifo_rx.v (Receive FIFO)

Stores received data bytes.

Allows safe reading of received data.

Prevents overflow during high-speed reception.

6️⃣ uart_top.v (Top Module)

Integrates:

Baud Generator

UART TX

UART RX

TX FIFO

RX FIFO

Connects internal modules.

Provides system-level interface signals.

🧪 Testbench (tb/)
uart_tb.v

Generates system clock.

Applies reset.

Sends test data into TX FIFO.

Verifies:

Serial transmission

Proper reception

FIFO functionality

Confirms correct loopback behavior.

📊 Simulation Results (waveform/)

uart_waveform.jpeg

Shows start bit, data bits, and stop bit.

Confirms correct serial transmission and reception timing.

tcl_console fifo memory check.jpeg

Verifies FIFO memory content using simulation console.

Confirms correct data storage and retrieval.

📄 Report (report/)

uart_report.pdf

Complete project documentation.

Design explanation.

Block diagrams.

Simulation results.

Observations and conclusions.

🛠️ Technical Features

Protocol: UART (Asynchronous Serial Communication)

Language: Verilog HDL

Baud Rate Generator

Separate TX and RX FIFOs

Synthesizable Design

Vivado Simulation Verified

🔧 Tools Used

Xilinx Vivado 2023.x

Vivado XSim Simulator

Verilog HDL

📜 How to Run

Open Vivado.

Create a new RTL project.

Add all files from the rtl/ folder as Design Sources.

Add tb/uart_tb.v as Simulation Source.

Set uart_tb as the top module.

Run Behavioral Simulation.

Observe waveform results.