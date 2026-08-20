# APU Global Secure Banking Simulator (x86 Assembly)

[![Module](https://img.shields.io/badge/Module-Computer%20System%20Low%20Level%20Techniques-blue)](https://www.apu.edu.my/)
[![Architecture](https://img.shields.io/badge/Architecture-x86%20(32--bit)-orange)](https://en.wikipedia.org/wiki/X86)
[![Assembler](https://img.shields.io/badge/Assembler-NASM-green)](https://www.nasm.us/)
[![OS](https://img.shields.io/badge/OS-Linux%20(Ubuntu%2FParrot)-red)](https://ubuntu.com/)

An interactive, menu-driven financial terminal simulator written entirely in bare-metal **32-bit x86 assembly language** using the Netwide Assembler (NASM) and Linux kernel interrupts (`int 0x80`). This project was developed as an individual assignment for the Computer System Low Level Techniques (CSLLT) module at Asia Pacific University (APU).

---

## 🚀 Project Overview
Unlike high-level applications that abstract memory management, typecasting, and garbage collection, this program operates directly at the hardware level. It manages memory segments (`.data` and `.bss`), processes CPU registers (`EAX`, `EBX`, `ECX`, `EDX`), tracks execution state via CPU status flags, and manually translates raw binary integers into printable ASCII strings using stack-based loops.

### Key Features
* **Multi-Ledger Tracking:** Manages a Checking Account (default RM 1000), Savings Account (default RM 0), and a real-time Session Transaction Counter.
* **Hardware-Level Security:** Employs the `JL` (Jump if Less) instruction to evaluate the CPU's **Sign Flag**, ensuring zero-latency overdraft protection before any ALU subtraction.
* **Tiered Dynamic Arithmetic:** Uses hardware integer multiplication (`IMUL`) to scale custom user deposits dynamically ($100 \times \text{tier}$).
* **Base-10 Division Conversion:** Implements a custom stack-based loop (`PUSH`/`POP`) to convert raw binary ledger values into printable ASCII character sequences for terminal rendering.
* **Robust Exception Handling:** Intercepts out-of-bounds inputs and insufficient fund attempts without crashing the application loop.

---

## 🛠️ System Prerequisites
To assemble, link, and execute this binary, you require a Linux environment (such as Ubuntu, Kali Linux, or Parrot OS) with 32-bit compilation support (`multilib`):
* **Assembler:** NASM (Netwide Assembler)
* **Linker:** GNU Linker (`ld`)

---

## ⚙️ Compilation and Execution Protocol

Open your Linux terminal and execute the following commands sequentially inside the `src/` directory:

```bash
# 1. Assemble the source code into a 32-bit ELF object file
nasm -f elf32 apu_banking.asm -o apu_banking.o

# 2. Link the object file using the x86 emulation flag
ld -m elf_i386 apu_banking.o -o apu_banking

# 3. Execute the binary
./apu_banking
