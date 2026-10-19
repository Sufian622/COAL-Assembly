[org 0x0100]

jmp start

mess        db 'Sufian Work'
len         dw 11

para1       db 'I like cheesecake'
para1_len   dw 17

para2       db 'I am craving for cheesecake'
para2_len   dw 28

para3       db 'I will buy a cheesecake'
para3_len   dw 23

keyword     db 'cheese', 0

linebuf     times 61 db 0

status1     db 'Total Matches Found: '
status1_len dw 21

status2     db ' | Viewport Status: ACTIVE'
status2_len dw 26


clrscr:

push es
push ax
push cx
push di

mov ax,0xb800
mov es,ax

xor di,di
mov ax,0x0720
mov cx,2000

cld
rep stosw

pop di
pop cx
pop ax
pop es

ret


drawborder:

push es
push ax
push cx
push di

mov ax,0xb800
mov es,ax
mov ah,0x07

mov di,496
mov al,0xC9
mov [es:di],ax

add di,2
mov cx,63
mov al,0xCD
cld
rep stosw

mov al,0xBB
mov [es:di],ax

mov di,656
mov al,0xBA
mov cx,17

leftborder:
mov [es:di],ax
add di,160
loop leftborder

mov di,784
mov cx,17

rightborder:
mov [es:di],ax
add di,160
loop rightborder

mov di,3376
mov al,0xC8
mov [es:di],ax

add di,2
mov cx,63
mov al,0xCD
cld
rep stosw

mov al,0xBC
mov [es:di],ax

pop di
pop cx
pop ax
pop es

ret


printtitle:

push bp
mov bp,sp
sub sp,2

push ax
push bx
push si
push di
push es

mov ax,0xb800
mov es,ax

mov si,[bp+6]
mov ax,[bp+4]
mov [bp-2],ax

cmp ax,0
je titledone

mov bx,65
sub bx,ax
shr bx,1
add bx,8
shl bx,1
add bx,640
mov di,bx

mov ah,0x1E
cld

titleprint:
lodsb
stosw
dec word [bp-2]
jnz titleprint

titledone:

pop es
pop di
pop si
pop bx
pop ax

mov sp,bp
pop bp
ret 4


printpara:

push bp
mov bp,sp
sub sp,2

push ax
push si
push di
push es

mov ax,0xb800
mov es,ax

mov si,[bp+8]
mov di,[bp+4]
mov ax,[bp+6]

cmp ax,61
jbe paralenok
mov ax,61

paralenok:

mov [bp-2],ax
cmp ax,0
je paradone

mov ah,0x07
cld

paraprint:
lodsb
stosw
dec word [bp-2]
jnz paraprint

paradone:

pop es
pop di
pop si
pop ax

mov sp,bp
pop bp
ret 6


scroll_window_up:

push bp
mov bp,sp

sub sp,12

push ax
push bx
push cx
push dx
push si
push di
push ds
push es

mov ax,[bp+4]
cmp ax,0
jne checkscroll1
jmp near scrollfinish

checkscroll1:

mov bx,[bp+8]
sub bx,[bp+12]
sub bx,2

cmp ax,bx
jbe checkscroll2
jmp near scrollfinish

checkscroll2:

mov ax,0xb800
mov ds,ax
mov es,ax

mov ax,[bp+12]
add ax,2
add ax,[bp+4]
mov [bp-2],ax

mov ax,[bp+12]
add ax,2
mov [bp-4],ax

mov ax,[bp+8]
sub ax,[bp+12]
sub ax,2
sub ax,[bp+4]
mov [bp-6],ax

mov ax,[bp+6]
sub ax,[bp+10]
sub ax,3
mov [bp-8],ax

mov ax,[bp+8]
sub ax,[bp+4]
mov [bp-10],ax

mov ax,[bp+4]
mov [bp-12],ax

cld

copyrow:

cmp word [bp-6],0
jne copycontinue
jmp near blankrow

copycontinue:

mov ax,[bp-2]
mov bx,160
mul bx

mov bx,[bp+10]
add bx,2
shl bx,1
add ax,bx

mov si,ax

mov ax,[bp-4]
mov bx,160
mul bx

mov bx,[bp+10]
add bx,2
shl bx,1
add ax,bx

mov di,ax

mov cx,[bp-8]
rep movsw

inc word [bp-2]
inc word [bp-4]

dec word [bp-6]

jmp near copyrow

blankrow:

mov ax,[bp-10]
mov bx,160
mul bx

mov bx,[bp+10]
add bx,2
shl bx,1
add ax,bx

mov di,ax

mov ax,0x0720
mov cx,[bp-8]

rep stosw

inc word [bp-10]

dec word [bp-12]

jnz blankrow

scrollfinish:

pop es
pop ds
pop di
pop si
pop dx
pop cx
pop bx
pop ax

mov sp,bp
pop bp

ret 10


find_and_highlight:

push bp
mov bp,sp

sub sp,12

push ax
push bx
push cx
push dx
push si
push di
push es
push ds

mov word [bp-2],5
mov word [bp-8],0

push ds
pop es
mov di,[bp+6]
mov cx,0xFFFF
xor al,al
cld
repne scasb
not cx
dec cx
mov [bp-10],cx

mov ax,[bp-10]

cmp ax,1
jae checkkeylength
jmp near findfinish

checkkeylength:

cmp ax,61
jbe rowloop
jmp near findfinish

rowloop:

push ds
pop es
mov ax,0xb800
mov ds,ax

mov ax,[bp-2]
mov bx,160
mul bx

add ax,20
mov si,ax
mov di,linebuf

mov word [bp-12],61
cld

extractchars:
lodsw
stosb
dec word [bp-12]
jnz extractchars

push es
pop ds

mov ax,62
sub ax,[bp-10]
mov [bp-6],ax

mov word [bp-4],0

searchloop:

cmp word [bp-6],0
jne searchcontinue
jmp near nextrow

searchcontinue:

mov si,[bp+6]

mov di,[bp-4]
add di,linebuf

mov cx,[bp-10]

cld
repe cmpsb

jne nextposition

mov ax,[bp-2]
mov bx,160
mul bx

mov bx,[bp-4]
add bx,10
shl bx,1

add ax,bx
inc ax

mov di,ax

mov ax,0xb800
mov es,ax

mov al,[bp+4]
mov cx,[bp-10]

highlightloop:

mov [es:di],al
add di,2

loop highlightloop

push ds
pop es

inc word [bp-8]

nextposition:

inc word [bp-4]
dec word [bp-6]

jmp near searchloop

nextrow:

inc word [bp-2]

cmp word [bp-2],21
jb nextrowcontinue
jmp near findfinish

nextrowcontinue:

jmp near rowloop

findfinish:

mov ax,[bp-8]
mov [bp+8],ax

pop ds
pop es
pop di
pop si
pop dx
pop cx
pop bx
pop ax

mov sp,bp
pop bp

ret 4


printNum:

push bp
mov bp,sp
sub sp,2

push ax
push bx
push dx
push di
push es

mov ax,0xb800
mov es,ax

mov ax,[bp+6]
mov di,[bp+4]

mov bx,10
mov word [bp-2],0

convert:

xor dx,dx
div bx

push dx
inc word [bp-2]

cmp ax,0
jne convert

displaydigits:

pop dx

add dl,'0'
mov dh,0x07

mov [es:di],dx

add di,2

dec word [bp-2]
jnz displaydigits

mov [bp+8],di

pop es
pop di
pop dx
pop bx
pop ax

mov sp,bp
pop bp

ret 4


printStatus:

push bp
mov bp,sp

push ax
push cx
push si
push di
push es

mov ax,0xb800
mov es,ax

mov di,3700

mov si,status1
mov cx,[status1_len]
mov ah,0x07
cld

statusfirst:

lodsb
stosw

loop statusfirst

push word 0
push word [bp+4]
push di
call printNum
pop di

mov si,status2
mov cx,[status2_len]
mov ah,0x07

statussecond:

lodsb
stosw

loop statussecond

pop es
pop di
pop si
pop cx
pop ax

mov sp,bp
pop bp

ret 2


start:

call clrscr
call drawborder

push word mess
push word [len]
call printtitle

push word para1
push word [para1_len]
push word 820
call printpara

push word para2
push word [para2_len]
push word 980
call printpara

push word para3
push word [para3_len]
push word 1140
call printpara

push word 3
push word 8
push word 21
push word 72
push word 0

call scroll_window_up

push word 0
push word keyword
push word 0x00CE
call find_and_highlight

call printStatus

mov ah,0
int 0x16

mov ax,0x4C00
int 0x21
