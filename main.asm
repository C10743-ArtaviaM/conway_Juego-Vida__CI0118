; ============================================================================
; Juego de la Vida
; Tarea Programada 1 - Lenguaje Ensamblador
; ============================================================================
; Este programa nos inicializa un grid de tamaño n x n y mostrara un patrón 
; simple.
; ============================================================================

section .data
    prompt db "Por favor, ingrese el tamano del grid (min 5, max 20): ", 0
    prompt_len equ $-prompt

    newline db 0xA, 0        ; Caracter de salto de línea.

    alive db '1'             ; Caracter para célula viva.
    dead  db '0'             ; Caracter para célula muerta.

    max_size equ 20          ; Tamaño máximo que permitiremos para el grid.

section .bss
    input resb 4             ; Buffer encargado de leer la entrada del usuario.
    grid resb max_size * max_size   ; Buffer encargado del grid principal.
    grid_size resb 1         ; Variable de almacenamiento del tamaño del grid.
    char_buffer resb 1       ; Buffer encargado de la impresion de un caracter.

section .text
    global _start

; ============================================================================
; Convertimos una cadena de caracteres a entero (str -> int).
; Entrada: ESI apunta a la cadena.
; Salida:  ECX contiene el número convertido.
; ============================================================================
str2int:
    xor ecx, ecx

.nextchar:
    lodsb
    cmp al, 0xA
    je .done
    cmp al, 0
    je .done
    cmp al, ' '
    je .nextchar
    sub al, '0'
    imul ecx, ecx, 10
    add ecx, eax
    jmp .nextchar

.done:
    ret

; ============================================================================
; Inicializamos un patrón simple dentro del grid (glider).
; ============================================================================
init_pattern:
    movzx ecx, byte [grid_size]
    cmp ecx, 5
    jb small_grid

    ; Limpiar el grid 
    mov edi, grid
    mov ecx, max_size * max_size
    xor eax, eax
    rep stosb

    ; Posiciones de un pequeño glider
    mov esi, grid
    movzx ebx, byte [grid_size]
    
    ; Fila 0, columna 1
    mov byte [esi + 1], 1
    
    ; Fila 1, columna 2
    lea eax, [esi + ebx + 2]
    mov byte [eax], 1
    
    ; Fila 2, columnas 0, 1, 2
    lea eax, [esi + ebx*2]
    mov byte [eax], 1
    mov byte [eax + 1], 1
    mov byte [eax + 2], 1
    
    ret
; ============================================================================
; Inicializamos un grid pequeño si el tamaño es menor a 5.
; ============================================================================
small_grid:
    mov esi, grid
    mov byte [esi], 1
    ret

; ============================================================================
; Muestra el grid en consola.
; Imprime '1' para células vivas y '0' para células muertas.
; ============================================================================
show_grid:
    movzx ecx, byte [grid_size]  ; Número de filas.
    mov esi, grid                ; Inicio del grid.
    
.row_loop:
    push ecx                     ; Guarda el contador de filas.
    movzx ecx, byte [grid_size]  ; Número de columnas por fila.
    
.col_loop:
    mov al, [esi]
    cmp al, 0
    je .print_dead
    mov al, [alive]
    jmp .print_char

.print_dead:
    mov al, [dead]

.print_char:
    mov [char_buffer], al
    push ecx                     ; Guarda el contador de columnas.
    mov eax, 4                   ; sys_write.
    mov ebx, 1                   ; STDOUT.
    mov ecx, char_buffer
    mov edx, 1
    int 0x80
    pop ecx                      ; Recupera el contador de columnas.

    inc esi
    loop .col_loop

    ; Imprimir salto de línea.
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    pop ecx

    pop ecx                      ; Recupera el contador de filas.
    loop .row_loop
    ret

; ============================================================================
; Punto de la entrada principal.
; ============================================================================
_start:
    ; Mostramos el prompt.
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    ; Leemos la entrada del usuario.
    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 4
    int 0x80

    ; Convertimos entrada a entero.
    mov ecx, 0
    mov esi, input
    call str2int

    ; Validamos el tamaño máximo.
    cmp ecx, max_size
    jbe size_ok
    mov ecx, max_size

size_ok:
    mov [grid_size], cl

    ; Limpiar el grid
    mov edi, grid
    mov ecx, max_size * max_size
    xor eax, eax

clear_grid:
    mov [edi], al
    inc edi
    loop clear_grid

    ; Inicializamos el patrón.
    call init_pattern

    ; Mostramos el grid.
    call show_grid

    ; Salimos del programa.
    mov eax, 1
    xor ebx, ebx
    int 0x80