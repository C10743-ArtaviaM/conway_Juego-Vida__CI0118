global update_game_of_life
section .text

;#########################################################
;# Función que actualiza el tablero del Juego de la Vida #
;#########################################################
; Parámetros:
;   rdi: tablero (unsigned int*) - arreglo de celdas
;   rsi: vecinos (unsigned int*) - arreglo de conteo de vecinos
;   rdx: dir (int*) - direcciones de los vecinos
;   rcx: size (unsigned int) - tamaño del tablero

update_game_of_life:
    push rbp                        ; Prologo estándar 
    mov rbp, rsp                    ; Guardar el marco de pila

    
    push rbx                        ; Guardar registros que se modificarán (convención ABI)
    push r12
    push r13
    push r14
    push r15

    xor r8d, r8d                    ; Inicializar contador i = 0 (r8d)

;#####################################################
;# Bucle principal para contar vecinos de cada celda #
;#####################################################

count_vecinos_loop:
    cmp r8d, ecx                    ; Comparar i con size (rcx)
    jge update_tablero_loop_start   ; Si i >= size, saltar a actualizar tablero

    mov eax, [rdi + r8*4]           ; Cargar valor de tablero[i] en eax

    test eax, eax                   
    jz skip_vecinos_count           ; Si está muerta (0), saltar al final del bucle

    xor r9d, r9d                    ; Inicializar contador j = 0 (r9d) para vecinos


;######################################################
;# Bucle interno para procesar los 8 vecinos posibles #
;######################################################

vecinos_inner_loop:
    cmp r9d, 8                      ; Comparar j con 8 (vecinos totales)
    jge skip_vecinos_count          ; Si j >= 8, terminar bucle de vecinos

    mov eax, [rdx + r9*4]           ; Cargar dirección del vecino j (dir[j])
    mov ebx, r8d                    ; Copiar índice actual i a ebx
    add ebx, eax                    ; Calcular índice del vecino: i + dir[j]

    ; Ajustar índice para borde (mod size), con wrap-around positivo
    ; Si ebx < 0, ebx += size
    cmp ebx, 0
    jl .add_size                    ; Si es negativo, ajustar sumando size
    jmp .mod_done

.add_size:
    add ebx, ecx                    ; Ajustar índice negativo: ebx += size

.mod_done:
    ; Ahora ebx está en [0, size-1]

    ; Incrementar contador de vecinos para la celda vecina
    
    mov eax, [rsi + rbx*4]          ; Cargar valor actual de vecinos[ebx]
    inc eax                         ; Incrementar contador
    mov [rsi + rbx*4], eax          ; Guardar nuevo valor en vecinos[eax]

    inc r9d                         ; Incrementar contador de vecinos j
    jmp vecinos_inner_loop          ; Continuar bucle de vecinos


;################################################
; Salto para celdas muertas no procesar vecinos #
;################################################

skip_vecinos_count:
    inc r8d                         ; Incrementar contador principal i
    jmp count_vecinos_loop          ; Continuar bucle principal


;######################################################
; Sección para actualizar el tablero basado en vecinos#
;######################################################

update_tablero_loop_start:
    xor r8d, r8d                    ; Reiniciar contador i = 0


;##################################
; Bucle para actualizar el tablero#
;##################################

update_tablero_loop:
    cmp r8d, ecx                    ; Comparar i con size
    jge done                        ; Si i >= size, terminar función


    ; Cargar valor de tablero[i] y vecinos[i]
    mov eax, [rdi + r8*4]           ; tablero[i]
    mov ebx, [rsi + r8*4]           ; vecinos[i]

    ; Verificar si la celda está viva
    cmp eax, 0
    jne tablero_on

    ;Celda muerta: verificar regla de nacimiento (exactamente 3 vecinos)
    cmp ebx, 3
    jne skip_update_off

    ; Nacer celda: tablero[i] = 1
    mov dword [rdi + r8*4], 1
    jmp reset_vecinos

;###############################################
; Celda viva: verificar reglas de supervivencia#
;###############################################

tablero_on:
    ; Celda viva con menos de 2 vecinos (soledad) o más de 3 (sobrepoblación)
    cmp ebx, 2
    jl set_off                      ; Menos de 2 vecinos - morir
    cmp ebx, 3
    jle skip_update_off             ; 2 o 3 vecinos - sobrevivir


set_off:
    ;Matar celda: tablero[i] = 0
    mov dword [rdi + r8*4], 0

; Punto común para resetear contador de vecinos
skip_update_off:
reset_vecinos:
    ; Resetear contador de vecinos para la siguiente generación
    mov dword [rsi + r8*4], 0       ; Incrementar contador i
    inc r8d
    jmp update_tablero_loop         ; Continuar bucle de actualización


; Epílogo

done:
    ; Restaurar registros guardados
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx

    pop rbp                         ; Restaurar marco de pila

    ret                             ; Retornar al llamador
