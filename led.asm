# Register usage:
# AL: byte sent to the 8255
# BL: segment pattern for the current letter
# DX: I/O port address
# SI: digit position of E, from 0 to 5
# BP: movement direction (+1 or -1)
# DI: number of refresh cycles before moving
# CX: digit position, or temporary delay counter
# CL: shift count used to generate the digit-selection mask

# ---------- Initialize the 8255 ----------

movw $0x643, %dx
movb $0b10000000, %al
# D7 = 1: mode-set command
# D6-D5 = 00: Group A Mode 0
# D4 = 0: Port A output
# D3 = 0: Port C upper output
# D2 = 0: Group B Mode 0
# D1 = 0: Port B output
# D0 = 0: Port C lower output
outb %al, %dx

movw $0x640, %dx
movb $0xFF, %al         # Active-low digit selection: all off
outb %al, %dx

movw $0x641, %dx
movb $0x00, %al         # Active-high segments: all off
outb %al, %dx

movw $0, %si           # E starts at dig-0
movw $1, %bp           # Move toward higher digit numbers

# ---------- Hold the current SHE position ----------

.Lposition:
    movw $100, %di     # Refresh SHE 100 times before moving
                       # Adjust for the actual CPU/simulator speed

.Lrefresh:
    # Display E at digit SI
    movw %si, %cx
    movb $0b01111001, %bl
    call .Lshow_digit

    # Display H at digit SI + 1
    movw %si, %cx
    incw %cx
    movb $0b01110110, %bl
    call .Lshow_digit

    # Display S at digit SI + 2
    movw %si, %cx
    addw $2, %cx
    movb $0b01101101, %bl
    call .Lshow_digit

    decw %di
    jnz .Lrefresh

# ---------- Update movement direction ----------

    cmpw $5, %si       # SHE has reached the left edge
    je .Lmove_right

    cmpw $0, %si       # SHE has reached the right edge
    je .Lmove_left

    jmp .Ladvance

.Lmove_right:
    movw $-1, %bp
    jmp .Ladvance

.Lmove_left:
    movw $1, %bp

.Ladvance:
    addw %bp, %si      # Move E, H, and S together by one digit
    jmp .Lposition

# ---------- Display one letter briefly ----------
# Inputs:
#   BL = segment pattern
#   CX = digit position, 0 to 7
# Preserves CX; changes AL and DX.

.Lshow_digit:
    # 1. Turn all digits off before changing the segment pattern
    movw $0x640, %dx
    movb $0xFF, %al
    outb %al, %dx

    # 2. Load the new letter's segment pattern
    movw $0x641, %dx
    movb %bl, %al
    outb %al, %dx

    # 3. Generate an active-low digit-selection mask
    movb $1, %al
    shlb %cl, %al      # AL = 1 << digit position
    notb %al           # Selected bit becomes 0; other bits become 1

    movw $0x640, %dx
    outb %al, %dx

    # 4. Keep the selected digit on briefly
    pushw %cx          # Save position before using CX for the delay
    movw $500, %cx     # Adjustable delay count; not a fixed time

.Ldelay:
    loop .Ldelay

    popw %cx           # Restore the digit position

    # 5. Turn all digits off before returning
    movw $0x640, %dx
    movb $0xFF, %al
    outb %al, %dx
    ret
