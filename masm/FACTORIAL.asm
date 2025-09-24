DATA SEGMENT
    A DB 01H
    B DB 04H
    C DB 00H
DATA ENDS
CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
    START:
        MOV AX,DATA
        MOV DS, AX
        MOV AL,A
        MOV BL,B
        MOV CL,C
        FACT: MUL BL
        DEC BL
        CMP BL,CL
        JNZ FACT 
        MOV A,AL
CODE ENDS
END START