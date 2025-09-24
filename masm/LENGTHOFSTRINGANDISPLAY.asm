DATA SEGMENT
    STR DB "HELLO THE WORLDDDD!!!!",'$' 
    ; STR2 DB "LMAOOOOOOO",'$'
    LEN DB ?
DATA ENDS
CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
    START:
        MOV AX, DATA
        MOV DS, AX
        LEA DX, STR
        MOV AH, 09H 
        INT 21H    
        
        ; LEA DX, STR2
        ; MOV AH, 09H
        ; INT 21H 
            
        MOV CL, 00H
        LEA SI, STR
    L2:
        CMP [SI], '$'
        JE L1
        INC CL
        INC SI
        JMP L2
    L1:
        MOV LEN, CL   
CODE ENDS
END START