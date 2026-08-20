# Technical Walkthrough: Architecture & Low-Level Mechanics

This document explains how the core low-level mechanics of the **APU Global Secure Banking Simulator** operate at the CPU and kernel level.

## 1. Memory Segmentation Strategy
The program divides data into two explicit memory sections to maximize efficiency:
* **`.data Section`**: Stores static, immutable ASCII text blocks, UI menus, and ANSI terminal escape codes (`0x1B, '[2J'`).
* **`.bss Section` (Block Started by Symbol):** Declares uninitialized dynamic memory via the `resd` (reserve double-word) directive. Financial ledgers like `chk_bal` and `sav_bal` reside here, allowing real-time read and write operations during runtime.

## 2. Kernel-Level Communication (`int 0x80`)
Rather than relying on C library wrappers like `printf` or `scanf`, the application interacts directly with the Linux kernel:
* **`sys_write` (Syscall 4):** Triggered by loading `4` into `EAX`, `1` (stdout) into `EBX`, and executing `int 0x80`.
* **`sys_read` (Syscall 3):** Triggered by loading `3` into `EAX`, `0` (stdin) into `EBX`, capturing keyboard buffer inputs.
* **`sys_exit` (Syscall 1):** Safely flushes registers and returns control to the shell with code `0`.

## 3. Flag-Driven Control Flow & Security
* **Menu Routing:** User selections are compared against ASCII character codes using `CMP`. The `JE` (Jump if Equal) instruction checks the **Zero Flag (ZF)** to route execution directly to the designated financial subroutine.
* **Overdraft Defense:** Before executing a checking account deduction (`SUB`), the program evaluates liquidity using `CMP eax, 100` followed by `JL` (Jump if Less). If the balance is insufficient, the **Sign Flag (SF)** triggers an immediate diversion to `error_funds`, preventing negative account states.

## 4. Stack-Based Base-10 Binary-to-ASCII Conversion (`print_num`)
Because Linux terminals render text characters rather than raw binary integers, the `print_num` subroutine executes a dual-loop algorithm:
1. **Division Loop (`.div_loop`):** Zeroes out `EDX` via `XOR EDX, EDX` to prevent division overflow, divides `EAX` by 10 (`DIV ECX`), converts the remainder to ASCII by adding `'0'`, and pushes it onto the hardware stack.
2. **Print Loop (`.print_loop`):** Pops digits sequentially off the LIFO (Last-In, First-Out) hardware stack and writes them to stdout in the correct mathematical order.
