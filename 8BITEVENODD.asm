MOV AL, [8000H]  
MOV BL, 02H
DIV BL             
CMP AH, 00H         
JZ L1               
MOV [8010H], 00H    
HLT
L1: MOV [8010H], 0FFH 
HLT
