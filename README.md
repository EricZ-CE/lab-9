# lab-9

**Author:** Eric Zhuang

This 8086 assembly program uses the 8255 Programmable Peripheral Interface to scroll “SHE” back and forth across an eight-digit seven-segment display. The code uses GNU assembler (AT&T) syntax.

## Port Configuration

| I/O address | Register | Purpose |
|-------------|----------|---------|
| `0x640` | Port A | Selects a digit by driving its bit low. `0xFF` turns all digits off. |
| `0x641` | Port B | Selects the segments to light. The patterns are `0x6D` for S, `0x76` for H, and `0x79` for E. |
| `0x643` | Control register | Receives `0x80` to configure all ports as Mode 0 outputs. |

## Program Operation

1. The program starts at the right edge with E on digit 0, H on digit 1, and S on digit 2. Since digit 0 is the rightmost digit, the display reads “SHE” from left to right.
2. For each letter, `.Lshow_digit` blanks the display, writes the segment pattern to Port B, and enables the selected digit through Port A for a 500-count delay.
3. After 100 complete scans of the three letters, the program shifts the word by one digit. It reverses when S reaches digit 7 or E reaches digit 0, then continues scrolling.
