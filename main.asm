
; TRAFFIC LIGHT USING ATMEGA32 MICROCONTROLLER

; 7-Segment Countdown + LED + Buzzer (Common Anode)

.def temp = R16    ; Temporary register
.def i = R17       ; Loop counter

.org 0x00
    rjmp start     ; Jump to main program

; 7-Segment Common Anode Lookup Table (9 to 0)

.equ SEGMENT_PORT = PORTD   ; 7-Segment Display on PORTD
.equ SEGMENT_DDR  = DDRD
.equ LED_PORT = PORTB       ; LEDs on PORTB
.equ LED_DDR  = DDRB
.equ BUZZER_PORT = PORTA    ; Buzzer on PA1
.equ BUZZER_DDR  = DDRA
.equ BUZZER_PIN  = 1        ; PA1 bit position

; Hex codes for common anode 7-segment (Active LOW)
segment_table:
    .db 0xC0, 0xF9, 0xA4, 0xB0, 0x99, 0x92, 0x82, 0xF8, 0x80, 0x90  ; 0 to 9


; Main Program Initialization

.org 0x0050
start:
    ; Initialize Stack Pointer
    ldi temp, HIGH(RAMEND)
    out SPH, temp
    ldi temp, LOW(RAMEND)
    out SPL, temp

    ; Set PORTC (7-Segment), PORTB (LEDs) as Output
    ldi temp, 0xFF
    out SEGMENT_DDR, temp
    out LED_DDR, temp

    ; Set PD1 (Buzzer) as Output
    sbi BUZZER_DDR, BUZZER_PIN

main_loop:
    ; Phase 1: Countdown 9 to 0 (Red LED ON, No buzzer)
    ldi temp, 0x01      ; Red LED ON (PB0)
    out LED_PORT, temp
    ldi i, 9
    rcall countdown     ; Countdown from 9 to 0 (No buzzer)


    ; Phase 2: Countdown 9 to 0 (Green LED ON, No buzzer)
    ldi temp, 0x04      ; Green LED ON (PB2)
    out LED_PORT, temp
    ldi i, 9
    rcall countdown     ; Countdown from 9 to 0 (No buzzer)

    ; Phase 3: Countdown 3 to 0 (Green + Yellow LEDs ON, Buzzer ON)
    ldi temp, 0x06      ; Green + Yellow LEDs ON (PB0 & PB1)
    out LED_PORT, temp
    sbi BUZZER_PORT, BUZZER_PIN  ; Turn ON Buzzer
    ldi i, 3
    rcall countdown     ; Countdown from 3 to 0 (With buzzer)
    cbi BUZZER_PORT, BUZZER_PIN  ; Turn OFF Buzzer

    rjmp main_loop  ; Repeat sequence


; Countdown Routine (Handles Both Cases)

countdown:
countdown_loop:
    ; Load corresponding 7-segment value
    mov temp, i
    ldi ZH, HIGH(segment_table << 1)
    ldi ZL, LOW(segment_table << 1)
    add ZL, temp
    lpm temp, Z
    out SEGMENT_PORT, temp

    call Delay_1s   ; Wait 1 second

    dec i
    brpl countdown_loop  ; Repeat until i < 0

    ret

; 1 Second Delay Routine 

Delay_1s:
    ldi R20, 8
Delay1:
    ldi R21, 250
Delay2:
    ldi R22, 250
Delay3:
    dec R22
    brne Delay3
    dec R21
    brne Delay2
    dec R20
    brne Delay1
    ret
