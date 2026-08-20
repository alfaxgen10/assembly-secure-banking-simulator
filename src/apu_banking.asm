### 4. Source Code (`src/apu_banking.asm`)
*(Here is your complete source code formatted cleanly for your repository)*

```assembly
section .data
    ; ANSI escape sequence to clear screen
    clear_str db 0x1B, '[2J', 0x1B, '[H'
    len_clear equ $ - clear_str

    ; Main menu layout
    menu db '==========================================', 0xA
         db '||     APU GLOBAL SECURE BANKING        ||', 0xA
         db '==========================================', 0xA
         db '|| [1] View Account Balances            ||', 0xA
         db '|| [2] Fast Cash Withdrawal (RM 100)    ||', 0xA
         db '|| [3] Custom Deposit (RM100 - RM900)   ||', 0xA
         db '|| [4] Transfer to Savings (RM 100)     ||', 0xA
         db '|| [5] Terminate Secure Session         ||', 0xA
         db '==========================================', 0xA
         db '>> Enter command (1-5): ', 0
    len_menu equ $ - menu

    ; System prompts and formatting
    msg_pause db 0xA, '>> Press [Enter] to return to main menu...', 0
    len_pause equ $ - msg_pause

    msg_border db '------------------------------------------', 0xA, 0
    len_border equ $ - msg_border

    msg_chk db ' Checking Balance     : RM ', 0
    len_chk equ $ - msg_chk

    msg_sav db ' Savings Balance      : RM ', 0
    len_sav equ $ - msg_sav

    msg_trans db ' Total Transactions   : ', 0
    len_trans equ $ - msg_trans

    msg_amt db '>> Select deposit tier [1 = RM100, 9 = RM900]: ', 0
    len_amt equ $ - msg_amt

    ; Transaction status messages
    msg_success db 0xA, '[SUCCESS] Transaction authorized and applied.', 0xA, 0
    len_success equ $ - msg_success

    msg_err db 0xA, '[DECLINED] Insufficient funds in Checking.', 0xA, 0
    len_err equ $ - msg_err

    msg_inv db 0xA, '[ERROR] Invalid command detected.', 0xA, 0
    len_inv equ $ - msg_inv

    newline db 0xA, 0

section .bss
    input resb 2
    dummy resb 2
    temp resb 1
    chk_bal resd 1
    sav_bal resd 1
    trans_cnt resd 1

section .text
    global _start

_start:
    ; Initialize variables
    mov dword [chk_bal], 1000
    mov dword [sav_bal], 0
    mov dword [trans_cnt], 0

main_loop:
    call clear_screen

    ; Display main menu
    mov eax, 4
    mov ebx, 1
    mov ecx, menu
    mov edx, len_menu
    int 0x80

    ; Read user input
    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 2
    int 0x80

    ; Conditional branching for menu selection
    mov al, [input]
    cmp al, '1'
    je view_balances
    cmp al, '2'
    je fast_cash
    cmp al, '3'
    je custom_deposit
    cmp al, '4'
    je transfer_savings
    cmp al, '5'
    je exit_program
    jmp invalid_input

view_balances:
    call print_border

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_chk
    mov edx, len_chk
    int 0x80
    mov eax, [chk_bal]
    call print_num

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_sav
    mov edx, len_sav
    int 0x80
    mov eax, [sav_bal]
    call print_num

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_trans
    mov edx, len_trans
    int 0x80
    mov eax, [trans_cnt]
    call print_num

    call print_border
    call wait_for_enter
    jmp main_loop

fast_cash:
    mov eax, [chk_bal]
    cmp eax, 100
    jl error_funds
    sub dword [chk_bal], 100
    inc dword [trans_cnt]
    jmp success_msg

custom_deposit:
    call clear_screen
    call print_border

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_amt
    mov edx, len_amt
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 2
    int 0x80

    mov al, [input]
    sub al, '0'
    movzx eax, al
    imul eax, 100
    add [chk_bal], eax
    inc dword [trans_cnt]
    jmp success_msg

transfer_savings:
    mov eax, [chk_bal]
    cmp eax, 100
    jl error_funds
    sub dword [chk_bal], 100
    add dword [sav_bal], 100
    inc dword [trans_cnt]
    jmp success_msg

success_msg:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_success
    mov edx, len_success
    int 0x80
    call wait_for_enter
    jmp main_loop

error_funds:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_err
    mov edx, len_err
    int 0x80
    call wait_for_enter
    jmp main_loop

invalid_input:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_inv
    mov edx, len_inv
    int 0x80
    call wait_for_enter
    jmp main_loop

exit_program:
    call clear_screen
    mov eax, 1
    xor ebx, ebx
    int 0x80

; --- Subroutines ---
clear_screen:
    mov eax, 4
    mov ebx, 1
    mov ecx, clear_str
    mov edx, len_clear
    int 0x80
    ret

print_border:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_border
    mov edx, len_border
    int 0x80
    ret

wait_for_enter:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_pause
    mov edx, len_pause
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, dummy
    mov edx, 2
    int 0x80
    ret

print_num:
    mov ecx, 10
    push 0
.div_loop:
    xor edx, edx
    div ecx
    add dl, '0'
    push edx
    test eax, eax
    jnz .div_loop
.print_loop:
    pop edx
    test edx, edx
    jz .done
    mov [temp], dl
    push eax
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, temp
    mov edx, 1
    int 0x80
    pop ecx
    pop eax
    jmp .print_loop
.done:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret
