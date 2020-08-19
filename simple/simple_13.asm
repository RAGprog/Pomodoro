;====================================================================
; Main.asm file generated by New Project wizard
; txt coding:	utf-8
;
; Created:   Чт авг 13 2020
; Processor: Attini13
; Compiler:  AVRASM (Proteus)
;====================================================================

;====================================================================
; DEFINITIONS	|	Определения
;====================================================================

#include "const_13.inc" ;.INCLUDE 
#include "macro_13.inc"


; ____________Настройка_параметров_____________
; ___________________Setup_____________________
freq 9	;MHz
testmode 1 ; 1 = test mode (3s), 0 = prod. mode (25min)

;====================================================================
; VARIABLES	|	Переменные
;====================================================================

.def temp = r16
.def pin = r17

;====================================================================
; RESET and INTERRUPT VECTORS	|	Сброс и векторы прерываний
;====================================================================

    rjmp	RESET	    ;	Reset	Handler	
    rjmp	EXT_INT0	;	IRQ0	Handler	
    reti    ;rjmp	PCINT0i	    ;	PCINT0	Handler	
    rjmp	TIM0_OVF	;	Timer0	Overflow	Handler
    reti    ;rjmp	EE_RDY	    ;	EEPROM	Ready	Handler
    reti    ;rjmp	ANA_COMP	;	Analog	Comparator	Handler
    reti    ;rjmp	TIM0_COMPA	;	Timer0	CompareA	Handler
    reti    ;rjmp	TIM0_COMPB	;	Timer0	CompareB	Handler
    reti    ;rjmp	WATCHDOG	;	Watchdog	Interrupt	Handler
    reti    ;rjmp	ADCi        ;	ADC	Conversion	Handler

;====================================================================
; CODE SEGMENT
;====================================================================

EXT_INT0:
    ;
reti

TIM0_OVF:
    ;
    eor temp, pin ;исключающее ИЛИ (OR)
    out PORTB, temp 
reti

reset:  ;_____________________________________________________________
    tout SPL, low(RAMEND)   ; Set Stack Pointer to top of RAM

    ;загрузка в регистр temp "1", смещенной на TOIE0, прерывание по переполнению таймера 0
    tout TIMSK0, (1<<TOIE0)
    ;загрузка двух единиц смещенных на CS00 и CS02 в регистр temp, тактовая частота разделена на 1024
    tout TCCR0B, (1<<CS00)|(1<<CS02)
    out TCCR0B, temp 
    ldi pin, (1<<3) ;загрузка в рег 1, смещ на 4 разряда влево
    out DDRB, pin
    ;отключение компаратора:
    tout ACSR, 1<<ADC   ;off
    clr temp 

    sei

loop:
    ;sleep
    rjmp loop