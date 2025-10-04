; Linear Search in MASM
; Searches for a key in an array and returns index or -1 if not found

.model small
.stack 100h
data segment
    arr db 10, 20, 30, 40, 50, 60, 70 ; array of bytes
    arr_len db 7                      ; length of the array
    key db 40                        ; the value to search
    result dw ?                      ; result index (-1 if not found)

code segment
    assume cs:code, ds:data
    start:
    mov ax, data
    mov ds, ax

    mov cl, arr_len      ; set loop counter to array length
    mov si, 0            ; index counter (SI) starts at 0
    mov al, key          ; value to search in AL
    mov bx, -01h           ; default result if not found

    search_loop:
    mov dl, arr[si]      ; load arr[si] into DL
    cmp dl, al           ; compare arr[si] with key
    je found             ; if equal, jump to found
    inc si               ; increment index
    loop search_loop     ; decrement cx and loop if cx != 0

    ; not found
    mov result, bx       ; store -1 in result
    jmp done

    found:
    mov result, si       ; store index in result 

    done:
    ; Exit program (DOS interrupt)
    mov dx, offset result
    mov ah, 09h
    int 21h 
END start
