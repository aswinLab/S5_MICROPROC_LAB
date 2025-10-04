DATA SEGMENT
    STR1 DB "OMEMO", '$'
    ; STR2 DB "hello", '$'
    STR2 DB 5 DUP(?)  
    ;NEWLINE DB 0Dh, 0Ah, '$'
    MSG1 DB "equal", '$'
    MSG2 DB "not equal", '$'
    LEN DB 05H
DATA ENDS
CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
    START:
    MOV AX, DATA
    MOV DS, AX
    MOV AX, DATA
    MOV ES, AX   
    MOV CL, 05H
    MOV SI, OFFSET STR1   ; LEA SI, STR1
    MOV DI, OFFSET STR2+5 ; LEA DI, STR2
    ;ADD DI, 0005H
    ;DEC SI

    ;REV_LOOP:
    ;MOV AL, [SI]
    ;MOV [DI], AL
    ;INC DI
    ;DEC SI
    ;LOOP REV_LOOP
    ;MOV BYTE PTR [DI], '$'
    ;MOV DX, OFFSET STR2
    ;MOV AH, 09H
    ;INT 21H   
    
    MOV CL, 05H
    L3: CLD
    LODSB
    STD
    STOSB
    LOOP L3 
    MOV DX, OFFSET STR2
    MOV AH, 09H
    INT 21H
    
    ;LEA DX, NEWLINE
    ;MOV AH, 09H
    ;INT 21H
    
    MOV SI, OFFSET STR1 ; LEA SI, STR1
    MOV DI, OFFSET STR2 ; LEA DI, STR2
    MOV CL, 5
    CLD
    REPE CMPSB
    JNZ L1
    ; MOV DI, OFFH
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    JMP L2
    L1:;MOV DI,O1H
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H
    L2: CODE ENDS
END START