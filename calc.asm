global _start

sys_read equ 0
sys_write equ 1
stdin equ 0
stdout equ 1

buff_len equ 10

section .data
  ;in_buff: times buff_len db 0
  ;arg_1_buff: times buff_len db 0
  ;arg_2_buff: times buff_len db 0
section .bss
  in_buff: resb buff_len
  out_buff: resb buff_len
  arg_1: resq 1
  arg_2: resq 1
  op: resq 1


section .text
  _start:
    ; Prompt User
    mov rax, sys_write
    mov rdi, stdout
    mov rsi, input_text
    mov rdx, input_text_len
    syscall

    ; Read input
    mov rax, sys_read
    mov rdi, stdin
    mov rsi, in_buff
    mov rdx, 10
    syscall


    ; Split
    ; First Operand
    mov rcx, buff_len
    mov rdi, in_buff
    mov [arg_1], rdi
    mov ax, 20h
    repne scasb
    ; Null Terminate
    mov rbx, rdi
    sub rbx, 1
    mov byte [rbx], 00h
    ; Operator
    mov [op], rdi
    repne scasb
    ; Null Terminate
    mov rbx, rdi
    sub rbx, 1
    mov byte [rbx], 00h
    ; Second Operand
    mov [arg_2], rdi
    mov ax, 0Ah
    repne scasb
    ; Null Terminate
    mov rbx, rdi
    sub rbx, 1
    mov byte [rbx], 00h

    mov rsi, [arg_1]
    call _atoi
    mov rcx, rax
    mov rsi, [arg_2]
    call _atoi
    mov rdx, rax
    mov rax, [op]
    mov al, byte [rax]
    cmp al, 2Dh
    je _subtract
    cmp al, 2Bh
    je _addition
    jmp _unkown
    _subtract:
    mov rax, rcx
    sub rax, rdx
    jmp _print_result
    _addition:
    mov rax, rcx
    add rax, rdx
    jmp _print_result
    _unkown:
    mov rax, 00h
    jmp _print_result
    _print_result:
    mov rdi, out_buff
    call _itoa

    mov rax, out_buff
    call _strlen
    mov rdx, rax
    mov rax, sys_write
    mov rdi, stdout
    mov rsi, out_buff
    syscall

    ; Newline
    mov rax, sys_write
    mov rdi, stdout
    mov rsi, newline
    mov rdx, 1
    syscall

    mov eax, 60
    mov ebx, 0
    syscall

    _atoi:
      push rbx
      push rcx
      push rdx
      mov rax, 00h
      mov rcx, 0Ah
      cmp byte [rsi],00h
      jne _atoi_loop
      pop rdx
      pop rcx
      pop rbx
      ret
    _atoi_loop:
      mul rcx
      movzx rbx, byte [rsi]
      sub rbx, 30h
      add rax, rbx
      inc rsi
      cmp byte [rsi], 00h
      jne _atoi_loop
      pop rdx
      pop rcx
      pop rbx
      ret


    _strlen:
      push rbx
      mov rbx, rax
      cmp byte [rbx],00h
      jne _strlen_loop
      mov rax, 00h
      ret
    _strlen_loop:
        inc rax
        cmp byte [rax], 00h
        jne _strlen_loop
      sub rax, rbx
      pop rbx
      ret

    _itoa:
      push rbx
      push rcx
      push rdx
      push rsi
      mov rsi, rdi
      mov rbx, 0Ah
      ;mov rbx, rax
      cmp rax, 00h
      jne _itoa_loop
      pop rdx
      pop rcx
      pop rbx
      mov byte [rdi], 30h
      inc rdi
      mov byte [rdi],00h
      ret
    _itoa_loop:
      cmp rax, rbx
      jl _itoa_break
      mov rdx, 00h
      div rbx
      add rdx, 30h
      mov byte [rdi], dl
      inc rdi
      ;cmp rax, 00h
      jmp _itoa_loop
    _itoa_break:
      add rax, 30h
      mov byte [rdi], al
    _itoa_flip_loop:
      mov cl, byte [rsi]
      mov dl, byte [rdi]
      mov byte [rsi], dl
      mov byte [rdi], cl
      dec rdi
      inc rsi
      cmp rsi, rdi
      jle _itoa_flip_loop
      mov rdi, rsi
      inc rdi
      pop rsi
      pop rdx
      pop rcx
      pop rbx
      mov byte [rdi],00h
      ret


section .rodata
  input_text: db "Enter Equation: "
  input_text_len: equ $ - input_text
  newline: db 0Ah
