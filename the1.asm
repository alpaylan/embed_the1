#include "p18f8722.inc"
; CONFIG1H
  CONFIG  OSC = HSPLL, FCMEN = OFF, IESO = OFF
; CONFIG2L
  CONFIG  PWRT = OFF, BOREN = OFF, BORV = 3
; CONFIG2H
  CONFIG  WDT = OFF, WDTPS = 32768
; CONFIG3L
  CONFIG  MODE = MC, ADDRBW = ADDR20BIT, DATABW = DATA16BIT, WAIT = OFF
; CONFIG3H
  CONFIG  CCP2MX = PORTC, ECCPMX = PORTE, LPT1OSC = OFF, MCLRE = ON
; CONFIG4L
  CONFIG  STVREN = ON, LVP = OFF, BBSIZ = BB2K, XINST = OFF
; CONFIG5L
  CONFIG  CP0 = OFF, CP1 = OFF, CP2 = OFF, CP3 = OFF, CP4 = OFF, CP5 = OFF
  CONFIG  CP6 = OFF, CP7 = OFF
; CONFIG5H
  CONFIG  CPB = OFF, CPD = OFF
; CONFIG6L
  CONFIG  WRT0 = OFF, WRT1 = OFF, WRT2 = OFF, WRT3 = OFF, WRT4 = OFF
  CONFIG  WRT5 = OFF, WRT6 = OFF, WRT7 = OFF
; CONFIG6H
  CONFIG  WRTC = OFF, WRTB = OFF, WRTD = OFF
; CONFIG7L
  CONFIG  EBTR0 = OFF, EBTR1 = OFF, EBTR2 = OFF, EBTR3 = OFF, EBTR4 = OFF
  CONFIG  EBTR5 = OFF, EBTR6 = OFF, EBTR7 = OFF
; CONFIG7H
  CONFIG  EBTRB = OFF

;*******************************************************************************
; Variables & Constants
;*******************************************************************************
UDATA_ACS
  t1	res 1	; used in delay
  t2	res 1	; used in delay
  t3	res 1	; used in delay
  state res 1	; controlled by RB0 button
  countRA4 udata 0x20
  countRA4
  
  countRE3 udata 0x24
  countRE3
  
  countRE4 udata 0x28
  countRE4
  
;*******************************************************************************
; Reset Vector
;*******************************************************************************

RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

;*******************************************************************************
; MAIN PROGRAM
;*******************************************************************************

MAIN_PROG CODE	; let linker place main program

 
START
    call INIT	; initialize variables and ports
    call DELAY	; wait a second
    call SHUSH	; shut all leds
    
MAIN_LOOP        
    call SET_MODE
    call SET_A
    call SET_B
    call OPERATE
    
    GOTO MAIN_LOOP  ; loop forever
    
SET_MODE ; select addition or multiplication
mode_loop:
    BTFSC PORTA, 4
    call WAIT_RA4_THEN_TOG
    BTFSS PORTE, 3
    goto mode_loop
mode_end:
    call WAIT_RE3
    return
SET_A ; set the value of A
    MOVLW 0x3
    MOVWF countRE4
a_loop:
    BTFSC PORTE, 4
    call WAIT_RE4_THEN_DEC

a_end:
    call WAIT_RE3
    return
SET_B ; set the value of B
    MOVLW 0x3
    MOVWF countRE4
b_loop:
    BTFSC PORTE, 4
    call WAIT_RE4_THEN_DEC
    

b_end:
    call WAIT_RE3
    return
OPERATE ; perform the operation A+B or |A-B|
    BTFSS countRA4, 0
    goto _sub
_add:
    call OP_ADD
    goto _reset
_sub:
    call OP_SUB
_reset:
    call DELAY
    call SHUSH
    return

OP_ADD
    return
OP_SUB
    return
OP_RESET
    return
WAIT_RE4_THEN_DEC
    return
WAIT_RA4_THEN_TOG    
    BTFSC PORTA, 4
    goto WAIT_RA4_THEN_TOG
    BTG	countRA4, 0
    return

WAIT_RE3
    BTFSC PORTE, 3
    goto WAIT_RE3
    return
INIT
    CLRF    PORTA
    CLRF    PORTB
    CLRF    PORTC
    CLRF    PORTD
    CLRF    PORTE
    ; all ports are cleared
    MOVLW   b'11111111'
    MOVWF   TRISA
    MOVWF   TRISE
    ; RA4, RE3 and RE4 are configures as inputs
    MOVLW   b'11110000'
    MOVWF   TRISB
    MOVWF   TRISC
    CLRF    TRISD
    ; RB[0-3], RC[0-3], RD[0-7] are configured as outputs
    MOVLW   b'11111111'
    MOVWF   LATD
    MOVWF   LATB
    MOVWF   LATC
    ; All leds are lit
    return

SHUSH
    CLRF LATB
    CLRF LATC
    CLRF LATD
    ; All leds are shut
    return
    
DELAY	; Time Delay Routine with 3 nested loops
    MOVLW 82	; Copy desired value to W
    MOVWF t3	; Copy W into t3
    _loop3:
	MOVLW 0xA0  ; Copy desired value to W
	MOVWF t2    ; Copy W into t2
	_loop2:
	    MOVLW 0x9F	; Copy desired value to W
	    MOVWF t1	; Copy W into t1
	    _loop1:
		decfsz t1,F ; Decrement t1. If 0 Skip next instruction
		GOTO _loop1 ; ELSE Keep counting down
		decfsz t2,F ; Decrement t2. If 0 Skip next instruction
		GOTO _loop2 ; ELSE Keep counting down
		decfsz t3,F ; Decrement t3. If 0 Skip next instruction
		GOTO _loop3 ; ELSE Keep counting down
		return
END
