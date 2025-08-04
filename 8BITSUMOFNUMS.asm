MOV AL, [8000H]  
MOV BL, 00H
L1:ADD BL, AL
DEC AL
CMP AL, 00H         
JNZ L1               
MOV [8010H], BL    
HLT
