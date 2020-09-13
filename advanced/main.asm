;====================================================================
; Main.asm файл скопирован из simple
; txt coding:	utf-8
;
; Created:   Пт авг 7 2020
; Processor: AT90S2313
; Compiler:  AVRASM (Proteus)
;====================================================================

;====================================================================
; DEFINITIONS	|	Определения
;====================================================================

#include "const.inc" ;.INCLUDE 
#include "macro.inc"
#include "timer.inc"


; ____________Настройка_параметров_____________
; ___________________Setup_____________________
freq 16	;MHz
testmode 1 ; 1 = test mode (3s), 0 = prod. mode (25min)


;====================================================================
; VARIABLES	|	Переменные
;====================================================================
.def temp = r16

.def act_flags = r17	; 0 - noiseT
; act_flags's bits:
.equ noiseT = 0
.equ noiseT_release = 1
.equ RedT = 2  ; Зажеч светодиод после отпускания кнопки
.equ Pom_Count_0 = 3	; Подсчет включений таймера
.equ Pom_Count_1 = 4	; (max = 2^2 = 4)
.equ Pom_break_flag = 5	; Следующая задержка - перерыв (5мин)
.equ digits_flag = 7

;.def setStatus = r2
;.def mode = r21	; 1 = 1s, 2 = 3s
;.def bmode = r22	; modes for button

timer_var r23, r24, r25, r16, r22

; zyx = 31:26

;====================================================================
; RESET and INTERRUPT VECTORS	|	Сброс и векторы прерываний
;====================================================================

      ; Reset Vector
      rjmp  Start
	rjmp EXT_INT0 ; IRQ0 Handler
	reti	;	rjmp EXT_INT1 ; IRQ1 Handler
	reti	;	rjmp TIM_CAPT1 ; Timer1 Capture Handler
	reti	;	rjmp TIM_COMP1 ; Timer1 Compare Handler
	rjmp TIM_OVF1 ; Timer1 Overflow Handler
	rjmp TIM_OVF0 ; Timer0 Overflow Handler
	reti	;	rjmp UART_RXC ; UART RX Complete Handler
	reti	;	rjmp UART_DRE ; UDR Empty Handler
	reti	;	rjmp UART_TXC ; UART TX Complete Handler
	reti	;	rjmp ANA_COMP ; Analog Comparator Handler

;====================================================================
; CODE SEGMENT
;====================================================================

; calls
event_comp: event_comp_m
zerro_correction: zerro_correction_m

null_rou_time_init: null_rou_time_init_m

rou_to_null: rou_to_null_m r18, r19, r20

EXT_INT0: ;________________________________
	; set noise timer flag
	set
	bld act_flags, noiseT   ; bit load, бит задержки против шума в рег.флагов
reti
;old:
	; noise reduction:
	
;	mov temp, setStatus
	; go to timer
;	cpi temp, 0
;	breq int0_push
	
	; button released, do smth, another 1 timer ckl skip
;	cpi temp, 3
;	breq int0_release
;	mov setStatus, temp
;reti
;	int0_push:
;		inc temp	; status 1
;		mov setStatus, temp
;reti
	int0_release:
		;inc setStatus	; что-то сделать с этим: задержка откладывается до выполнения задачи mode

;		mov mode, bmode

reti

TIM_OVF1: ;________________________________

reti

TIM_OVF0: ;________________________________
	timer_m

	; Пример новой ПП: | Exemple of new subroutine:
	; Далее @0 - номер вывода, @1 - значение задержки
	; начало ПП:
	;new_t_routine lbl1
	; тело ПП:
	;	; включение/отключение светодиода каждый вызов
	;	ldi tcomp, 1 << @0    ; маска, по которой будет происходить операция XOR
	;	mov r4, tcomp	; хранится в r4
	;	in tcomp, portB
	;	eor tcomp, r4
	;	out portB, tcomp
	; конец ПП:
	;end_t_routine @1
	;lbl1:

	;blink_m 4, 120, lbl1
	;lbl1:


	; skip if noiseT flag not set    |  Пропустить, если флаг noiseT не установлен
	sbrc act_flags, noiseT  ;
	rcall button	; нужен ли ...
	sbrc act_flags, RedT
	rcall red_delay
	; где-то обнулить таймер

reti

red_delay:
	new_t_routine lbl3
		cbi portB, red_pnum
		cbi portB, green_pnum
		clt
		bld act_flags, RedT ; флаг ожидания для СД
	;end_t_routine 90	; ??? [ ]
	lbl3:
ret

button:
	clt
	bld act_flags, noiseT
	; две ветви действия: нажатие и отпускание
	sbrc act_flags, noiseT_release  ; fix
	rjmp button_release	; rcall не подходит (возврат)
	;rjmp button_press
button_press:
	; перемещено в б_релиз

	set
	bld act_flags, noiseT_release
	tout	MCUCR,	MCUCR_pint0r

	; digits ON
	set
	bld act_flags, digits_flag
ret
button_release:
 	clt
 	bld act_flags, noiseT_release
	tout	MCUCR,	MCUCR_pint0f    ; проверить [~]

	; digits OFF
	clt
	bld act_flags, digits_flag

	
	
	; if Pom_Count < 3 & Pom_break_flag = 1:
	;		set_short_break
	; elif Pom_Count = 3 & Pom_break_flag = 1:
	;		set_long_break
	; --> if Pom_b_f = 0 : main_t
	;	else: if Pom_count = 3: long
	;			else: short

	; решение проблемы с одновременным включением двух СД:
	; проверка активности СД:
	sbrc act_flags, redT
		ret

	sbrc act_flags, Pom_break_flag	; if P_b_f = 1
		rjmp set_break
	rjmp set_main_t					; else main_t
	ret	; никогда не выполняется

	set_main_t:
		; change flags? [ ]
		; обновление Pom_break_flag
		set
		bld act_flags, Pom_break_flag
			; обнуление
		; Старший байт? (должен быть младший)
		ldi r26, RAMbeg
		;end_t_routine 90
		;ldi r26, RAMbeg + next_RAM
		ld temp, x
		subi temp, LOW(tim_m1)	; M25
		ldi r26, RAMbeg + next_RAM + 2
		st x, temp

		ldi r26, RAMbeg + 1
		ld temp, x
		sbci temp, BYTE2(tim_m1)
		ldi r26, RAMbeg + next_RAM + 1
		st x, temp

		ldi r26, RAMbeg + 2
		ld temp, x
		sbci temp, BYTE3(tim_m1)
		ldi r26, RAMbeg + next_RAM
		st x, temp
		
		ldi r26, RAMbeg + next_RAM + 2

		; включение СД
		set
		bld act_flags, RedT ; флаг ожидания для СД
		sbi portB, red_pnum	; изменение, относительно Att13, проверить там [ ]

		ret

	set_break:
		; обновление Pom_break_flag
		clt
		bld act_flags, Pom_break_flag

		clr temp
		bst act_flags, Pom_Count_0	; проверить, не сломалась ли процедура с T
		bld temp, 0
		bst act_flags, Pom_Count_1	; проверить, не сломалась ли процедура с T
		bld temp, 1
		inc temp
		; обнуление двух битов счетчика в регистре флагов act_flags
		andi act_flags, 0b11111111 - (0b11 << Pom_Count_0)	; cbr? ; можно заранее [ ]
		
		; if Pom_Count > 3
		sbrc temp, 2	; ~log2 + 1 ; Skip if Bit in Register Cleared
			rjmp set_long_break
	set_short_break:
		; обновление Pom_count
		; change flags? [ ]
		
		; сдвиг счетчика в temp в его позицию в act_flags
		; macro
		;lsl temp
		log_shift_left temp, Pom_Count_0
		; прибавление к РФ act_flags значения счетчика:
		add act_flags, temp

			; обнуление
		; Старший байт? (должен быть младший)
		ldi r26, RAMbeg
		;end_t_routine 90
		;ldi r26, RAMbeg + next_RAM
		ld temp, x
		subi temp, LOW(tim_m2)	; M25
		ldi r26, RAMbeg + next_RAM + 2
		st x, temp

		ldi r26, RAMbeg + 1
		ld temp, x
		sbci temp, BYTE2(tim_m2)
		ldi r26, RAMbeg + next_RAM + 1
		st x, temp

		ldi r26, RAMbeg + 2
		ld temp, x
		sbci temp, BYTE3(tim_m2)
		ldi r26, RAMbeg + next_RAM
		st x, temp
		
		ldi r26, RAMbeg + next_RAM + 2

		; включение СД изменить redT? [ ]
		set
		bld act_flags, RedT ; флаг ожидания для СД
		sbi portB, green_pnum	; изменение, относительно Att13, проверить там [ ]

		ret

	set_long_break:
		; обновление Pom_count
		; change flags? [ ]

			; обнуление
		; Старший байт? (должен быть младший)
		ldi r26, RAMbeg
		;end_t_routine 90
		;ldi r26, RAMbeg + next_RAM
		ld temp, x
		subi temp, LOW(tim_m3)	; M25
		ldi r26, RAMbeg + next_RAM + 2
		st x, temp

		ldi r26, RAMbeg + 1
		ld temp, x
		sbci temp, BYTE2(tim_m3)
		ldi r26, RAMbeg + next_RAM + 1
		st x, temp

		ldi r26, RAMbeg + 2
		ld temp, x
		sbci temp, BYTE3(tim_m3)
		ldi r26, RAMbeg + next_RAM
		st x, temp
		
		ldi r26, RAMbeg + next_RAM + 2

		; включение СД изменить redT? [ ]
		set
		bld act_flags, RedT ; флаг ожидания для СД
		sbi portB, green_pnum	; изменение, относительно Att13, проверить там [ ]

		ret

	


;_____________________
Start: ;_____________________________RESET:__________________________

	ldi temp, RAMend	; init stack
	out SPL, temp

; timers
	; t0

	; prescaler
	ldi temp, 1 << cs02 | 1 << cs00	; clock select ck/1024
	out TCCR0, temp
	
	tout	TIMSK,	1 << TOIE1 |	0 << OCIE1A |	0 << TICIE1 |	1 << TOIE0

	; general timer init ; set a time [ ]
	timer_var_init

; pins int
	; int0

	tout	GIMSK,	0 << int1 |	1 << int0	; General Interrupt Mask
	; MCU Control Register, Interrupt Sense Control
	tout	MCUCR,	sleep_e |	sleep_m |	0 << ISC11 |	0 << ISC10 |	1 << ISC01 |	0 << ISC00
	; ...Interrupt 0 Sense Control 10 - falling edge, 11 - rising, 00 - Low lvl; = MCUCR_pint0r

; sleep mode and pwr down
	tout ACSR, 1 << ACD ; Analog Comparator Disable
	
;======

    tout ddrB, 255	; init outputs
	
	tout portD, setup_pin	; init setup button

	ldi bmode, 1	; init first mode
	; clr from random val
	clr setStatus
	clr mode

	
	;  на всякий случай, для переменных таймера, очищаем 2 ячейки стека
	clr temp
	clr r17
	clr r18
	clr r19
	clr r20
	clr r21
	clr r22
	clr r23
	clr r24
	clr r25
	push temp
	push temp
	
	sei	; interrupts ON

	;deep sleep on reset
	;tout MCUCR, 1 << SM |	MCUCR_pint0f
	;sleep	; sleep 'til ext_int occure
	;tout MCUCR, MCUCR_pint0f
	
	
Loop: ;________________________________
	;sbis pinD, setup_pnum
	;out portB, temp	;rcall new

	sbrs act_flags, digits_flag
		sleep	;
	sbrc act_flags, digits_flag
		d7seg_pre
      rjmp  Loop

;====================================================================
