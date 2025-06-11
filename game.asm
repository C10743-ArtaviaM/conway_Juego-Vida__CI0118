global update_game_of_life
section .text

; void update_game_of_life(unsigned int* tablero, unsigned int* vecinos, int* dir, unsigned int size)
update_game_of_life:
    ; Linux x86-64 ABI
    ; rdi = tablero (unsigned int*)
    ; rsi = vecinos (unsigned int*)
    ; rdx = dir (int*)
    ; rcx = size (unsigned int)

    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    xor r8d, r8d        ; i = 0

count_vecinos_loop:
    cmp r8d, ecx
    jge update_tablero_loop_start

    mov eax, [rdi + r8*4]    ; tablero[i]
    test eax, eax
    jz skip_vecinos_count

    xor r9d, r9d             ; j = 0

vecinos_inner_loop:
    cmp r9d, 8
    jge skip_vecinos_count

    mov eax, [rdx + r9*4]    ; dir[j]
    mov ebx, r8d             ; i
    add ebx, eax             ; i + dir[j]

    ; Ajustar índice para borde (mod size), con wrap-around positivo
    ; Si ebx < 0, ebx += size
    cmp ebx, 0
    jl .add_size
    jmp .mod_done

.add_size:
    add ebx, ecx

.mod_done:
    ; Ahora ebx está en [0, size-1]

    ; Incrementar vecinos[ebx]
    mov eax, [rsi + rbx*4]
    inc eax
    mov [rsi + rbx*4], eax

    inc r9d
    jmp vecinos_inner_loop

skip_vecinos_count:
    inc r8d
    jmp count_vecinos_loop

update_tablero_loop_start:
    xor r8d, r8d

update_tablero_loop:
    cmp r8d, ecx
    jge done

    mov eax, [rdi + r8*4]    ; tablero[i]
    mov ebx, [rsi + r8*4]    ; vecinos[i]

    cmp eax, 0
    jne tablero_on

    ; tablero[i] == 0 && vecinos[i] == 3 -> tablero[i] = 1
    cmp ebx, 3
    jne skip_update_off
    mov dword [rdi + r8*4], 1
    jmp reset_vecinos

tablero_on:
    ; tablero[i] == 1 && (vecinos[i] < 2 || vecinos[i] > 3) -> tablero[i] = 0
    cmp ebx, 2
    jl set_off
    cmp ebx, 3
    jle skip_update_off
set_off:
    mov dword [rdi + r8*4], 0

skip_update_off:
reset_vecinos:
    mov dword [rsi + r8*4], 0
    inc r8d
    jmp update_tablero_loop

done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
