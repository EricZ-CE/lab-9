# Register usage:
# AL: byte sent to the 8255
# BL: segment pattern for the current letter
# DX: I/O port address
# SI: digit position of E, from 0 to 5
# BP: movement direction (+1 or -1)
# DI: number of refresh cycles before moving
# CX: digit position, or temporary delay counter
# CL: shift count used to generate the digit-selection mask

movw $0x643, %dx
movb $0b10000000, %al
outb %al, %dx

movw $0x640, %dx
movb $0xFF, %al
outb %al, %dx

movw $0x641, %dx
movb $0x00, %al
outb %al, %dx

movw $0, %si
movw $1, %bp

.Lposition:
    movw $100, %di

.Lrefresh:
    movw %si, %cx
    movb $0b01111001, %bl
    call .Lshow_digit

    movw %si, %cx
    incw %cx
    movb $0b01110110, %bl
    call .Lshow_digit

    movw %si, %cx
    addw $2, %cx
    movb $0b01101101, %bl
    call .Lshow_digit

    decw %di
    jnz .Lrefresh

    cmpw $5, %si
    je .Lmove_right

    cmpw $0, %si
    je .Lmove_left

    jmp .Ladvance

.Lmove_right:
    movw $-1, %bp
    jmp .Ladvance

.Lmove_left:
    movw $1, %bp

.Ladvance:
    addw %bp, %si
    jmp .Lposition

.Lshow_digit:
    movw $0x640, %dx
    movb $0xFF, %al
    outb %al, %dx

    movw $0x641, %dx
    movb %bl, %al
    outb %al, %dx

    movb $1, %al
    shlb %cl, %al
    notb %al

    movw $0x640, %dx
    outb %al, %dx

    pushw %cx
    movw $500, %cx

.Ldelay:
    loop .Ldelay

    popw %cx

    movw $0x640, %dx
    movb $0xFF, %al
    outb %al, %dx
    ret
