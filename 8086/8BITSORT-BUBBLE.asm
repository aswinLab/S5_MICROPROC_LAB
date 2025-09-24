

LOOP_A: 
    MOV SI,8000H
    MOV DX, CX
LOOP_B:
    MOV AL, [SI]
    MOV AH, [SI+1]
    
    CMP AL,AH
    
    JC SKIP
    JE SKIP
    
    MOV [SI+1], AL
    MOV [SI], AH
    
SKIP:
    INC SI
    DEC DX
    JNZ LOOP_B
    DEC CX
    JNZ LOOP_A
    
HLT   