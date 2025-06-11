; ============================================================================
; Juego de la Vida
; Tarea Programada 1 - Lenguaje Ensamblador
; ============================================================================
; Este programa inicializa un grid de tamaño n x n y muestra un patrón 
; simple. Se implementan las funciones para inicializar el grid, mostrarlo 
; en consola, y permitir la entrada del tamaño del grid por parte del usuario.
; ============================================================================
 
section .data
    ; Mensaje para pedir el tamaño del grid.
    prompt db "Por favor, ingrese el tamano del grid (min 5, max 20): ", 0
    prompt_len equ $-prompt   ; Longitud del mensaje prompt.
    
    continue_msg db 0xA, "Enter: Continuar, Q: Salir: ", 0
    continue_msg_len equ $-continue_msg

    newline db 0xA, 0        ; Caracter de salto de línea (LF).
    
    alive db '1'             ; Caracter para célula viva en el grid.
    dead  db '0'             ; Caracter para célula muerta en el grid.
    
    max_size equ 20          ; Tamaño máximo permitido para el grid.
    min_size equ 5

section .bss
    input resb 4             ; Buffer para almacenar la entrada del usuario
                             ; (tamaño del grid).
    ; Buffer para almacenar el grid completo (máximo 20x20).
    grid resb max_size * max_size
    grid_size resb 1         ; Variable para almacenar el tamaño del grid.
    char_buffer resb 1       ; Buffer para almacenar un único carácter (para 
                             ; impresión).
    ; Copia temporal del grid
    grid_copy resb max_size * max_size
    neighbor_count resd 1    ; Contador de vecinos

section .text
    global _start            ; Definición de la etiqueta de entrada del
                             ; programa.

; ============================================================================
; Convertimos una cadena de caracteres a un número entero (str -> int).
; Entrada: ESI apunta a la cadena.
; Salida:  ECX contiene el número convertido.
; ============================================================================
str2int:
    xor ecx, ecx            ; Inicializamos ECX a 0 (almacenará el número
                            ; resultante).

.nextchar:
    lodsb                    ; Cargar el siguiente byte (carácter) de la cadena
                             ; en AL.
    cmp al, 0xA              ; Comprobar si es un salto de línea (fin de la
                             ; cadena).
    je .done                 ; Si es salto de línea, hemos terminado.
    cmp al, 0                ; Comprobar si es un valor nulo (fin de cadena).
    je .done                 ; Si es nulo, hemos terminado.
    cmp al, ' '              ; Comprobar si es un espacio en blanco.
    je .nextchar             ; Si es un espacio, continuar con el siguiente
                             ; carácter.
    sub al, '0'              ; Convertir el carácter ASCII a su valor numérico.
    imul ecx, ecx, 10        ; Multiplicar el valor actual por 10 (shift a la
                             ; izquierda por 1 dígito).
    add ecx, eax             ; Agregar el valor del carácter al total.
    jmp .nextchar            ; Volver a leer el siguiente carácter.

.done:
    ret                      ; Retornamos con el número convertido en ECX.

; ============================================================================
; Inicializamos un patrón simple dentro del grid (glider).
; ============================================================================
init_pattern:
    movzx ecx, byte [grid_size]  ; Cargar el tamaño del grid en ECX.
    cmp ecx, 5                   ; Si el tamaño es menor que 5, usamos un grid
                                 ; pequeño.
    jb small_grid                ; Salta a la inicialización de un grid pequeño.

    ; Limpiar el grid: Rellenar todo el grid con 0 (células muertas).
    mov edi, grid                ; Dirección del inicio del grid.
    mov ecx, max_size * max_size ; Número total de celdas.
    xor eax, eax                 ; Limpiar el valor de EAX (0 para células
                                 ; muertas).
    rep stosb                    ; Usar rep para llenar el grid con 0s.

    ; Posiciones de un pequeño "glider" en el grid.
    mov esi, grid                ; Dirección de inicio del grid.
    movzx ebx, byte [grid_size]  ; Número de columnas por fila (tamaño del
                                 ; grid).
    
    ; Fila 0, columna 1: Hacer célula viva.
    mov byte [esi + 1], 1
    
    ; Fila 1, columna 2: Hacer célula viva.
    lea eax, [esi + ebx + 2]     ; Dirección de la fila 1, columna 2.
    mov byte [eax], 1
    
    ; Fila 2, columnas 0, 1, 2: Hacer células vivas.
    lea eax, [esi + ebx*2]       ; Dirección de la fila 2.
    mov byte [eax], 1
    mov byte [eax + 1], 1
    mov byte [eax + 2], 1
    
    ret                          ; Retornar a la ejecución principal.

; ============================================================================
; Inicializamos un grid pequeño si el tamaño es menor a 5.
; ============================================================================
small_grid:
    mov esi, grid                ; Dirección de inicio del grid.
    mov byte [esi], 1            ; Inicializar la única célula viva en la
                                 ; posición [0].
    ret

; ============================================================================
; Muestra el grid en consola.
; Imprime '1' para células vivas y '0' para células muertas.
; ============================================================================
show_grid:
    movzx ecx, byte [grid_size]  ; Número de filas.
    mov esi, grid                ; Dirección de inicio del grid.
    
.row_loop:
    push ecx                     ; Guarda el contador de filas.
    movzx ecx, byte [grid_size]  ; Número de columnas por fila.
    
.col_loop:
    mov al, [esi]                ; Cargar el valor de la célula en AL.
    cmp al, 0                    ; Verificar si la célula está muerta.
    je .print_dead               ; Si está muerta, ir a imprimir '0'.
    mov al, [alive]              ; Si está viva, ir a imprimir '1'.
    jmp .print_char              ; Imprimir el carácter correspondiente.

.print_dead:
    mov al, [dead]               ; Imprimir '0' para células muertas.

.print_char:
    mov [char_buffer], al        ; Almacenar el carácter en el buffer.
    push ecx                     ; Guarda el contador de columnas.
    mov eax, 4                   ; sys_write: llamada al sistema para escribir
                                 ; en consola.
    mov ebx, 1                   ; STDOUT: salida estándar (pantalla).
    mov ecx, char_buffer         ; Dirección del carácter a imprimir.
    mov edx, 1                   ; Longitud del carácter (1 byte).
    int 0x80                     ; Llamada al sistema para imprimir.
    pop ecx                      ; Recupera el contador de columnas.

    inc esi                      ; Avanza a la siguiente célula en el grid.
    loop .col_loop               ; Decrementa ECX y repite si no ha terminado.

    ; Imprimir salto de línea después de cada fila.
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    pop ecx

    pop ecx                      ; Recupera el contador de filas.
    loop .row_loop               ; Decrementa ECX y repite si no ha terminado.
    ret                          ; Retorna al flujo principal del programa.

; ============================================================================
; Calcula la siguiente generación del grid según las reglas del Juego de la Vida
; ============================================================================
next_generation:
    ; Necesitamos una copia temporal del grid actual para no modificar mientras leemos
    mov esi, grid
    mov edi, grid_copy
    mov ecx, max_size * max_size
    rep movsb                   ; Copiamos el grid actual a grid_copy
    
    movzx ebx, byte [grid_size] ; Tamaño del grid
    mov esi, grid_copy          ; Usamos la copia como referencia
    mov edi, grid               ; Y escribimos en el grid original
    
    xor ecx, ecx                ; Contador de filas (i)
    
.row_loop:
    xor edx, edx                ; Contador de columnas (j)
    
.col_loop:
    ; Calcular posición actual en el grid (i*size + j) de forma más simple
    push ecx                    ; Guardar ecx (i)
    mov eax, ecx                ; eax = i
    mul ebx                     ; eax = i * size
    add eax, edx                ; eax = i*size + j
    mov ebp, eax                ; ebp = offset en el grid
    
    ; Contar vecinos vivos
    push edx
    push esi
    push edi
    
    lea edi, [esi + ebp]        ; Posición actual en grid_copy
    call count_neighbors
    mov [neighbor_count], eax   ; Guardar número de vecinos
    
    pop edi
    pop esi
    pop edx
    pop ecx                     ; Recuperar ecx (i)
    
    ; Obtener estado actual de la célula (forma más simple)
    mov eax, ecx                ; eax = i
    mul ebx                     ; eax = i * size
    add eax, edx                ; eax = i*size + j
    mov al, [esi + eax]         ; Estado actual de la célula
    
.apply_rules:
    test al, al                 ; ¿Está viva?
    jz .dead_cell
    
    ; Reglas para células vivas
    mov eax, [neighbor_count]
    cmp eax, 2
    jb .die                     ; Menos de 2 vecinos: muere
    cmp eax, 3
    ja .die                     ; Más de 3 vecinos: muere
    jmp .survive                ; 2 o 3 vecinos: sobrevive
    
.dead_cell:
    ; Regla para células muertas
    mov eax, [neighbor_count]
    cmp eax, 3
    je .born                    ; Exactamente 3 vecinos: nace
    jmp .die
    
.born:
    ; Calcular posición de destino
    mov eax, ecx                ; eax = i
    mul ebx                     ; eax = i * size
    add eax, edx                ; eax = i*size + j
    mov byte [edi + eax], 1
    jmp .next_cell
    
.survive:
    ; Calcular posición de destino
    mov eax, ecx                ; eax = i
    mul ebx                     ; eax = i * size
    add eax, edx                ; eax = i*size + j
    mov byte [edi + eax], 1
    jmp .next_cell
    
.die:
    ; Calcular posición de destino
    mov eax, ecx                ; eax = i
    mul ebx                     ; eax = i * size
    add eax, edx                ; eax = i*size + j
    mov byte [edi + eax], 0
    
.next_cell:
    inc edx
    cmp edx, ebx
    jb .col_loop
    
    inc ecx
    cmp ecx, ebx
    jb .row_loop
    
    ret
; ============================================================================
; Cuenta el número de vecinos vivos para una célula dada
; Entrada: EDI = puntero a la célula en grid_copy
;          EBX = tamaño del grid
; Salida:  EAX = número de vecinos vivos
; ============================================================================
count_neighbors:
    xor eax, eax                ; Contador de vecinos
    mov esi, edi                ; Copiamos posición actual
    
    ; Coordenadas relativas para los 8 vecinos
    mov ecx, -1                 ; delta i
.neighbor_row:
    mov edx, -1                 ; delta j
.neighbor_col:
    ; Saltar la célula central
    test ecx, ecx
    jnz .check_neighbor
    test edx, edx
    jz .next_neighbor
    
.check_neighbor:
    ; Calcular posición absoluta
    push ebx
    mov eax, ecx
    imul eax, ebx               ; i * size
    add eax, edx                ; + j
    add eax, esi                ; + base
    
    ; Verificar límites del grid
    cmp eax, grid_copy
    jb .next_neighbor
    lea ebx, [grid_copy + max_size*max_size]
    cmp eax, ebx
    jae .next_neighbor
    
    ; Verificar si la célula está viva
    cmp byte [eax], 1
    jne .next_neighbor
    inc dword [neighbor_count]
    
.next_neighbor:
    pop ebx
    inc edx
    cmp edx, 1
    jle .neighbor_col
    
    inc ecx
    cmp ecx, 1
    jle .neighbor_row
    
    mov eax, [neighbor_count]
    ret

; ============================================================================
; Punto de la entrada principal.
; ============================================================================
_start:
    ; Mostrar el prompt al usuario.
    mov eax, 4                   ; sys_write: llamada al sistema para imprimir
                                 ; en consola.
    mov ebx, 1                   ; STDOUT.
    mov ecx, prompt              ; Dirección del mensaje prompt.
    mov edx, prompt_len          ; Longitud del mensaje prompt.
    int 0x80                     ; Llamada al sistema para imprimir.

    ; Leer la entrada del usuario (tamaño del grid).
    mov eax, 3                   ; sys_read: llamada al sistema para leer desde
                                 ; stdin.
    mov ebx, 0                   ; STDIN.
    mov ecx, input               ; Dirección del buffer de entrada.
    mov edx, 4                   ; Número de bytes a leer (tamaño máximo de la
                                 ; entrada).
    int 0x80                     ; Llamada al sistema para leer.

    ; Convertir la entrada a entero.
    mov ecx, 0                   ; Limpiar ECX para usarlo como número
                                 ; resultante.
    mov esi, input               ; Dirección de la entrada del usuario.
    call str2int                 ; Convertir la cadena a entero.

    ; Validar que el tamaño no exceda el máximo.
    cmp ecx, max_size            ; Comprobar si el tamaño es mayor al máximo
                                 ; permitido.
    jbe size_ok                  ; Si el tamaño es válido, continuar.
    mov ecx, max_size            ; Si es mayor, asignamos el tamaño máximo.

size_ok:
    mov [grid_size], cl          ; Guardar el tamaño del grid.

    ; Limpiar el grid: Inicializarlo con células muertas (0).
    mov edi, grid                ; Dirección del grid.
    mov ecx, max_size * max_size ; Número total de celdas.
    xor eax, eax                 ; Valor de 0 para células muertas.
    
clear_grid:
    mov [edi], al                ; Colocar el valor 0 en la célula.
    inc edi                      ; Avanzar al siguiente byte del grid.
    loop clear_grid              ; Repetir hasta que todas las celdas sean
                                 ; inicializadas.

    ; Inicializar el patrón (glider).
    call init_pattern            ; Llamar a la función para colocar el patrón.

    ; Asegurar que grid_size sea al menos 1
    cmp byte [grid_size], 1
    jb set_min_loop
    jmp continue_loop
set_min_loop:
    mov byte [grid_size], 1
continue_loop:
    ; Mostrar el grid en consola grid_size veces
    movzx edi, byte [grid_size]  ; Obtener cuántas veces mostrar (n veces)

show_loop:
    call show_grid               ; Mostrar el grid

    ; Mostrar mensaje para continuar
    mov eax, 4
    mov ebx, 1
    mov ecx, continue_msg
    mov edx, continue_msg_len
    int 0x80

    ; Leer entrada del usuario (esperar Enter)
    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 1
    int 0x80

    ; Verificar si quiere salir (tecla 'q')
    cmp byte [input], 'q'
    je .exit_program

    ; Imprimir salto de línea entre repeticiones (para claridad)
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    dec edi
    jmp show_loop               ; Disminuir ECX y repetir si no es cero

    ; Calcular siguiente generación
    call next_generation

    ; Continuar el bucle
    ; jmp show_loop

.exit_program:
    ; Salir del programa.
    mov eax, 1                   ; sys_exit: llamada al sistema para terminar el
                                 ; programa.
    xor ebx, ebx                 ; Código de salida 0.
    int 0x80                     ; Llamada al sistema para salir del programa.