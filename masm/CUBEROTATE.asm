.MODEL SMALL
.STACK 100H

.DATA
    ; Cube vertices (x,y,z) relative to center
    VERTICES     DW  -2, -2,  2    ; 0: left,  top,  front
                 DW   2, -2,  2    ; 1: right, top,  front
                 DW   2,  2,  2    ; 2: right, bot,  front
                 DW  -2,  2,  2    ; 3: left,  bot,  front
                 DW  -2, -2, -2    ; 4: left,  top,  back
                 DW   2, -2, -2    ; 5: right, top,  back
                 DW   2,  2, -2    ; 6: right, bot,  back
                 DW  -2,  2, -2    ; 7: left,  bot,  back
    NUM_VERTICES EQU 8

    ; Faces (pairs of vertex indices)
    FACES        DW  0, 1,  1, 2,  2, 3,  3, 0    ; Front face
                 DW  4, 5,  5, 6,  6, 7,  7, 4    ; Back face
                 DW  0, 4,  1, 5,  2, 6,  3, 7    ; Connecting edges
    NUM_FACES    EQU 12 * 2    ; 12 edges * 2 points per edge

    ; Sine/Cosine lookup table (angle 0-90 degrees, scaled by 256)
    SINCOS       DW  0, 60, 119, 175, 224, 268, 306, 337, 361, 378   ; cos*256
                 DW  0, 13, 26, 38, 50, 61, 71, 80, 88, 95          ; sin*256
    ANGLE        DB  0

    CLEAR_SCREEN DB  0CH        ; DOS code to clear screen

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; Set text mode
    MOV AX, 03H
    INT 10H

RENDER_LOOP:
    ; Clear screen
    MOV AH, 09H
    LEA DX, CLEAR_SCREEN
    INT 21H

    ; Draw cube
    CALL DRAW_CUBE

    ; Delay
    MOV CX, 2
DELAY:
    PUSH CX
    MOV CX, 0FFFFH
INNER_DELAY:
    LOOP INNER_DELAY
    POP CX
    LOOP DELAY

    ; Increment angle
    INC ANGLE
    CMP ANGLE, 90
    JLE SKIP_RESET
    MOV ANGLE, 0
SKIP_RESET:

    ; Check for keypress
    MOV AH, 0BH
    INT 21H
    CMP AL, 0FFH
    JNE RENDER_LOOP

    ; Exit
    MOV AH, 4CH
    INT 21H
MAIN ENDP

;--------------------------------------------------
; ROTATE_Y - Rotate point around Y axis
; Input:  AX=X, CX=Y, DX=Z (via registers)
; Output: AX=rotated X, CX=rotated Z (Y unchanged)
;--------------------------------------------------
ROTATE_Y PROC
    PUSH BX
    PUSH DX

    ; Get sin/cos from lookup table
    MOV AL, ANGLE
    XOR AH, AH
    SHL AX, 1            ; AX = angle * 2 (for DW indexing)
    MOV SI, AX
    MOV BX, SINCOS[SI]   ; BX = cos(angle)*256
    MOV AX, [ESP+6]      ; AX = input X (from stack)
    IMUL BX              ; DX:AX = X * cos (result in DX:AX, but we use AX)
    SHR AX, 8            ; Divide by 256 (fixed-point math)
    MOV BX, AX           ; BX = X*cos

    MOV AX, DX           ; AX = input Z
    MOV CX, SINCOS[SI+18] ; CX = sin(angle)*256 (90 entries * 2 bytes = 180, but we use +18 for second table)
    IMUL CX              ; DX:AX = Z * sin
    SHR AX, 8            ; Divide by 256
    ADD BX, AX           ; BX = X*cos + Z*sin (rotated X)

    ; Second calculation: Z*cos - X*sin
    MOV AX, [ESP]        ; AX = input Z (from stack)
    IMUL SINCOS[SI]      ; Z * cos
    SHR AX, 8
    MOV CX, AX           ; CX = Z*cos
    MOV AX, [ESP+6]      ; AX = input X
    IMUL SINCOS[SI+18]   ; X * sin
    SHR AX, 8
    SUB CX, AX           ; CX = Z*cos - X*sin (rotated Z)

    ; Return results
    MOV AX, BX           ; AX = rotated X
    ; CX already has rotated Z

    POP DX
    POP BX
    RET
ROTATE_Y ENDP

;--------------------------------------------------
; PLOT_POINT - Plot a character at (X,Y)
; Input:  AX=X, CX=Y (column, row)
;--------------------------------------------------
PLOT_POINT PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH BX

    MOV BH, 0          ; Page 0
    MOV AH, 02H        ; BIOS set cursor
    MOV DH, CL         ; Y (row)
    MOV DL, AL         ; X (column)
    INT 10H

    MOV AH, 0AH        ; BIOS write character
    MOV AL, '+'        ; Character to print
    MOV CX, 1          ; Print 1 time
    INT 10H

    POP BX
    POP DX
    POP CX
    POP AX
    RET
PLOT_POINT ENDP

;--------------------------------------------------
; DRAW_LINE - Draw line from (AX,CX) to (BX,DX)
; (Simple version - just prints '#' along the path)
;--------------------------------------------------
DRAW_LINE PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

LINE_LOOP:
    ; Move towards target
    CMP AX, BX
    JE CHECK_Y
    JL INC_X
    DEC AX
    JMP CHECK_Y
INC_X:
    INC AX

CHECK_Y:
    CMP CX, DX
    JE PRINT    JL INC_Y
    DEC CX
    JMP PRINT
INC_Y:
    INC CX

PRINT:
    PUSH AX
    MOV BH, 0
    MOV AH, 02H
    MOV DH, CL
    MOV DL, AL
    INT 10H
    MOV AH, 0AH
    MOV AL, '#'
    MOV CX, 1
    INT 10H
    POP AX

    ; Check if reached target
    CMP AX, BX
    JNE LINE_LOOP
    CMP CX, DX
    JNE LINE_LOOP

    POP DX
    POP CX
    POP BX
    POP AX
    RET
DRAW_LINE ENDP

;--------------------------------------------------
; DRAW_CUBE - Draw the entire cube
;--------------------------------------------------
DRAW_CUBE PROC
    MOV DI, 0          ; Face index

FACE_LOOP:
    ; Get first vertex
    MOV AX, FACES[DI]       ; Vertex index
    SHL AX, 3               ; *8 (3 words per vertex)
    MOV SI, AX
    MOV AX, VERTICES[SI]    ; X1
    MOV CX, VERTICES[SI+2]  ; Y1
    MOV DX, VERTICES[SI+4]  ; Z1

    CALL ROTATE_Y           ; Rotate point 1 (returns AX=X', CX=Z')
    ADD AX, 40              ; Center X    ADD CX, 12              ; Center Y
    MOV BX, AX              ; Save X'
    MOV BP, CX              ; Save Y'

    ; Get second vertex
    MOV AX, FACES[DI+2]     ; Next vertex index
    SHL AX, 3
    MOV SI, AX
    MOV AX, VERTICES[SI]    ; X2
    MOV CX, VERTICES[SI+2]  ; Y2
    MOV DX, VERTICES[SI+4]  ; Z2

    CALL ROTATE_Y           ; Rotate point 2
    ADD AX, 40    ADD CX, 12

    ; Draw line between (BX,BP) and (AX,CX)
    MOV DX, CX              ; DX = Y2
    MOV CX, BP              ; CX = Y1
    MOV BX, AX              ; BX = X2 (overwrites saved X1)
    MOV AX, [ESP+4]         ; Restore X1 (from stack) - HACK!
    ; Instead, let's re-save in simpler way:
    PUSH AX                 ; Save X2
    PUSH CX                 ; Save Y2
    MOV AX, BX              ; AX = X1
    MOV CX, BP              ; CX = Y1
    MOV BX, [ESP+2]         ; BX = X2
    MOV DX, [ESP]           ; DX = Y2
    CALL DRAW_LINE
    ADD SP, 4               ; Clean stack

    ADD DI, 4               ; Next edge (2 DWs)
    CMP DI, NUM_FACES
    JL FACE_LOOP

    RET
DRAW_CUBE ENDP

END MAIN