.macro timer_var
    ;====================================================================
    ; VARIABLES & consts?	|	Переменные
    ;====================================================================
    ;.def temp = r16

    .def setStatus = r2
    .def mode = r21	; 1 = 1s, 2 = 3s
    .def bmode = r22	; modes for button

    ; general timer
    .def timeL = @0     ; r23
    .def timeH = @1     ; r24
    .def timeHH = @2    ; r25

    ;; comp. vars ???
    ;.def tcompL = @3
    ;.def tcompH = @4
    ;.def tcompHH = @5

    ;; flags
    ;.def trflags = @6

    ; universal reg
    .def tcomp = @3     ; temp
    .def trflags = @4   ; r22

    ; zyx = 31:26

    .equ RAMbeg = $60   ; the beginning of RAM address | адрес начала ОЗУ
    .equ blink_delay = 61   ; ~ 1s

	.equ init_time = day - $10000
	; вместо 255:255:254 должны устанавливаться нулевые значения полного круга
	; минус текущее время	[ ] (connected)

	.equ init_blink_delay = init_time - blink_delay

	.set next_RAM = 0	; убедиться в корректности работы
.endmacro

.macro old_timer_var
    ;====================================================================
    ; VARIABLES	|	Переменные
    ;====================================================================
    .def temp = r16
    .def countHH = r20
    .def countH = r17
    .def countL = r18
    .def one = r19

    ;.def temp_blink = r23

    .def setStatus = r2
    .def mode = r21	; 1 = 1s, 2 = 3s
    .def bmode = r22	; modes for button

    ;general timer
    .def timeL = r23
    .def timeH = r24
    .def timeHH = r25

    ; zyx = 31:26
.endmacro

.macro timer_var_init
    ; general timer init ; set a time [ ]
	clr r27
    ldi r26, RAMbeg
    ldi tcomp, LOW(init_time)  ; @0 - рассчитать из HH:MM:SS -> HH:H:L		[ ] исправить инициализацию (co)
    st x+, tcomp	; TL = 255
	ldi tcomp, BYTE2(init_time)
    st x+, tcomp	; TH = 255
	ldi tcomp, BYTE3(init_time)
    st x+, tcomp	; THH = 254
	; вместо 255:255:254 должны устанавливаться нулевые значения полного круга
	; минус текущее время	[ ] (connected)

	; вместо 255:255:254 должны устанавливаться нулевые значения полного круга,
	; т.е. сутки	-

    ; blink init ; убедиться в правильности/удобности порядка [ ]
	; сначала загружаем старший байт, после вычисления его значения
	; нельзя считать отдельно, т.к. не учитывается перенос!
    ldi tcomp, BYTE3(init_blink_delay)
    st x+, tcomp
    ldi tcomp, BYTE2(init_blink_delay)
    st x+, tcomp
    ldi tcomp, LOW(init_blink_delay)
    st x+, tcomp

	; автоматизировать инициализацию ПП [ ]
	ldi tcomp, BYTE3(init_time - 90)
    st x+, tcomp
    ldi tcomp, BYTE2(init_time - 90)
    st x+, tcomp
    ldi tcomp, LOW(init_time - 90)
    st x+, tcomp	; почему-то удалял?

;	ldi tcomp, BYTE3(init_time - 30)
;    st x+, tcomp
;    ldi tcomp, BYTE2(init_time - 30)
;    st x+, tcomp
;    ldi tcomp, LOW(init_time - 30)
;    st x+, tcomp	; почему-то удалял?

	; нулевая инициализация не работает, минимум - 1
	; несколько раз:
	rcall null_rou_time_init
	rcall null_rou_time_init
.endmacro

.macro null_rou_time_init_m
	; Запускать по умолчанию со второго прерывания
	ldi tcomp, BYTE3(init_time - 1)
    st x+, tcomp
    ldi tcomp, BYTE2(init_time - 1)
    st x+, tcomp
    ldi tcomp, LOW(init_time - 1)
    st x+, tcomp
	ret
.endmacro

.macro timer_m
    cli ; int off	; это производится автоматически?{ }

	; сохранение содержимого регистров в стеке______________
	;push timeL
	;push timeH
	;push timeHH
	; чтобы активировать нужно добавить pop в конце:
	;pop timeHH
	;pop timeH
	;pop timeL
	; возможно, целесообразнее использовать call завершающей процедуры

    ; loading from RAM | загрузка из ОЗУ ; add for start [ ]_________
    clr r27
    ldi r26, RAMbeg
    ld timeL, x+
    ld timeH, x+
    ld timeHH, x	; оставляем, для перезаписи

	; general timer_________________________
	clc
	subi timeL, 1	; согласно doc dec не изменяет C, проверить синонимичность { }
	sbci timeH, 0	; отнять с остатком (отнимет 1 только при переходе через ноль)
	sbci timeHH, 0
	; проверка окончания суток (вместо пред. констр.):
	;brlo time	; елси отняли 1 от 0, то перейти на метку "time" 
	brcc time	; если не было перехода в отрицательные значения, то 
				; перейти на метку "time"
	; Если отняли 1 от 0, то обнулить таймер:
	ldi timeL, LOW(day)
	ldi timeH, BYTE2(day)
	ldi timeHH, BYTE3(day)
	; Проверить правильность сброса таймера [ ]:
    ; обновить значения сравниваемых с таймером значений
    ; rcall ... ; вызов записи в eeprom и др.

    time:
		; Запись в ОЗУ
		st x, timeHH
		st -x, timeH
		st -x, timeL
		; возвращаем адрес
		;ldi r26, RAMbeg + 3	; можно переместить на требуемое место	
	;ldi r26, RAMbeg + 3	; можно переместить на требуемое место
		;ldi r26, RAMbeg + 3	; можно переместить на требуемое место	


    ;____________________________________________________________________
	; testing | тестовое мигание светодиодом
	;____________________________________________________________________
    ; (?) Проверяем, настало ли время действовать
    ; address in RAM for blinking by LED | адрес для этой операции в ОЗУ
    ;clr r27
    ; можно пропустить, так как адрес уже установлен предыдущей загрузкой
    .set next_RAM = next_RAM + 3
	ldi r26, RAMbeg + next_RAM ; - after timer's bytes | после байтов таймера
    ; удобнее сравнить сначала старшие (H), значит и хранить так
    ; нужно инициализировать [ ]
    ld tcomp, x+
    cp tcomp, timeHH
    brne tim_rou_1
    ld tcomp, x+
    cp tcomp, timeH
    brne tim_rou_1
    ld tcomp, x
    cp tcomp, timeL
    brne tim_rou_1

    ; включение/отключение светодиода каждый вызов
    ldi tcomp, 1 << 5	; маска, по которой будет происходить операция XOR
    mov r4, tcomp	; хранится в r4
    in tcomp, portB
    eor tcomp, r4
    out portB, tcomp

    ; обновление переменных в ОЗУ
    ld tcomp, x
    subi tcomp, LOW(blink_delay)
    st x, tcomp
    ld tcomp, -x
    sbci tcomp, BYTE2(blink_delay)
    st x, tcomp
    ld tcomp, -x
    sbci tcomp, BYTE3(blink_delay)
    st x, tcomp
    ; при переходе через ноль?
    ;brlo fix   ; [~]
	brcc tim_rou_1	; если не было перехода в отрицательные значения, то 
				; перейти на метку "not_update_blink_delay"/"tim_rou_1"
	; отнять от (time - blink_delay) дельту между ffffff и day
	ldi r26, RAMbeg + 3
	ld tcomp, x
    subi tcomp, LOW($ffffff - day)
    st x, tcomp
    ld tcomp, -x
    sbci tcomp, BYTE2($ffffff - day)
    st x, tcomp
    ld tcomp, -x
    sbci tcomp, BYTE3($ffffff - day)
    st x, tcomp
	;not_update_blink_delay:
    tim_rou_1:
    ; *адрес потерян

    ;sei    ; устанавливается сам?
;reti   ; to ad after macro | добавить после макроса
.endmacro

.macro new_t_routine	; @0 - lbl of rou
	;LOCAL skip_tim_rou { }
	.set next_RAM = next_RAM + 3
	ldi r26, RAMbeg + next_RAM
	rcall event_comp
	;brtc @0	; @0 - метка, для пропуска выполнения кода ПП
	brtc @0
	

.endmacro

.macro end_t_routine	; @0 - lbl of rou, @1 - delay, <add init [ ]

	; обновление переменных в ОЗУ
	; возможно реализовать вызываемую пп с константой в регистрах...
    ld tcomp, x
    subi tcomp, LOW(@0)
    st x, tcomp
    ld tcomp, -x
    sbci tcomp, BYTE2(@0)
    st x, tcomp
    ld tcomp, -x
    sbci tcomp, BYTE3(@0)
    st x, tcomp
    ; при переходе через ноль
	brcc tim_rou_1	; если не было перехода в отрицательные значения, то 
				; перейти на метку 
	; отнять от (time - @0) дельту между ffffff и day
		ldi r26, RAMbeg + next_RAM
		rcall zerro_correction
	tim_rou_1:
.endmacro

.macro event_comp_m
	; сравнение содержимого таймера и отсечки события
	event_comp:
		clt	; снятие флага перед использованием
		ld tcomp, x+
		cp tcomp, timeHH
		brlo event_comp_skip	; brne to brlo, fix missings
		ld tcomp, x+
		cp tcomp, timeH
		brlo event_comp_skip
		ld tcomp, x
		cp tcomp, timeL
		brlo event_comp_skip
			set	; set flag T
		event_comp_skip:
	ret
.endmacro

.macro zerro_correction_m
	zerro_correction:
		;ldi r26, RAMbeg + next_RAM	; не будет здесь работать (т.к. nR меняется)
		ld tcomp, x
		subi tcomp, LOW($ffffff - day)
		st x, tcomp
		ld tcomp, -x
		sbci tcomp, BYTE2($ffffff - day)
		st x, tcomp
		ld tcomp, -x
		sbci tcomp, BYTE3($ffffff - day)
		st x, tcomp
		tim_rou_1:
	ret
.endmacro

.macro old_timer_m
		cli	; int off
		
		; for stack usage:
		;pop r5			; предположительно - PC, pointer
		; in temp, sreg	; status reg saving
		; push temp
		
		; general timer
		subi timeL, 1
		;brne time	; перейти на метку "time", если не было перехода через ноль
		sbci timeH, 0	; отнять с остатком (отнимет 1 только при переходе через ноль)
		;brne time
		sbci timeHH, 0
		; Проверка окончания суток:
		cpi timeL, LOW(day)	; сравнить
		brne time	;	перейти на метку "time", если не равны
		cpi timeH, BYTE2(day)
		brne time
		cpi timeH, BYTE3(day)
		brne time
		; Проверить правильность сброса таймера [ ]:
		ldi timeL, 255
		ldi timeH, 255
		ldi timeHH, 255

		time:

		; modes
		; 1	- 4 x 25
		cpi mode, 1
		breq mode_1
		cpi mode, 3
		breq mode_1
		cpi mode, 5
		breq mode_1
		cpi mode, 7
		breq mode_1
		; 2 - 3 x 5
		cpi mode, 2
		breq mode_2
		cpi mode, 4
		breq mode_2
		cpi mode, 6
		breq mode_2
		; 3 - 1 x 15
		cpi mode, 8
		breq mode_3		; out of rich [ ] to fix
		; else (if mode not 0):
		cpi mode, 0
		breq mode_0
		;sbrc SREG, Z	; bit1 in sreg	; [+] replace, doesn't work
		ldi bmode, 1	; reset bmode, if mode == 0: skip
		mode_0:


		
		
		;push r5		; перенесено выше, т.к. в прот.случае придется повторять в ветках
		
		mov temp, setStatus
		; int0 noise skiping, falling
		cpi temp, 1
		breq tim0_int0_1
		cpi temp, 2
		breq tim0_int0_2
		; int0 noise skiping, rising
		cpi temp, 4
		breq tim0_int0_4
		cpi temp, 5
		breq tim0_int0_5

		mov setStatus, temp
		
		sei
	reti
		tim0_int0_1:
			inc temp
			mov setStatus, temp
			sei
	reti
		tim0_int0_2:
			inc temp
			mov setStatus, temp
			; rising int:
			tout	MCUCR,	MCUCR_pint0r
			sei
	reti
		tim0_int0_4:
			inc temp
			mov setStatus, temp
			sei
	reti
		tim0_int0_5:
			clr temp	; first state
			mov setStatus, temp
			; faling int:
			tout	MCUCR,	MCUCR_pint0f
			sei
	reti
		mode_1:	; 3s + LED	;to macro
			mov r4, temp	; saving temp
			clr temp
			
			; LEDs on
			;cbi Portb, green_pnum	; LED2 off
			sbi Portb, red_pnum		; LED1 on
		
			;inc countL	 ; not work for this (theory: it is subi -1)
			ldi one, 1
			add countL, one		; true +1
			adc countH, temp	; +carry	(temp = 0)
			adc countHH, temp

			
			cpi countHH, tim_m1HH
			brne notatime_1;endoftim
			cpi countH, tim_m1H
			brne notatime_1;endoftim
			cpi countL, tim_m1L
			brne notatime_1
			; it's the time:
			ldi countL, 0
			ldi countH, 0
			clr countHH
			
			; LEDs off
			cbi Portb, red_pnum	; LED off
			
			ldi mode, 0
			inc bmode	; next - mode 2, 4, 6...
			
			notatime_1:
			
			mov temp, r4	; temp recovery
			sei
	reti
		mode_2:
		rjmp mode_2j
		mode_3:
		rjmp mode_3j
		; ldi r30, LOW(mode_3j)
		; ldi r31, HIGH(mode_3j)
		; ijmp	; переход по адресу в rZ(jump to address in rZ)
		mode_2j:	; 1s + other LED
			mov r4, temp	; saving temp
			clr temp
			
			; LEDs
			;cbi Portb, red_pnum		; LED1 off
			sbi Portb, green_pnum	; LED2 on
		
			;inc countL	 ; not work for this (theory: it is subi -1)
			ldi one, 1
			add countL, one		; true +1
			adc countH, temp	; +carry	(temp = 0)
			
			cpi countHH, tim_m2HH
			brne notatime_2
			cpi countH, tim_m2H
			brne notatime_2;endoftim
			cpi countL, tim_m2L
			brne notatime_2
			; it's the time:
			ldi countL, 0
			ldi countH, 0
			clr countHH	; L, H, HH = 0
			
			; LEDs off
			cbi Portb, green_pnum	; LED off
			
			ldi mode, 0	; возврат режима 0
			inc bmode	; next - mode 3, 5, etc.
			
			notatime_2:
			
			mov temp, r4	; temp recovery
			sei
	reti
		mode_3j:
			mov r4, temp	; saving temp
			clr temp
			
			; LEDs
			;cbi Portb, red_pnum		; LED1 off
			sbi Portb, green_pnum	; LED2 on
		
			;inc countL	 ; not work for this (theory: it is subi -1)
			ldi one, 1
			add countL, one		; true +1
			adc countH, temp	; +carry	(temp = 0)
			
			;add temp_blink, one
			;cpi temp_blink, s1
			;brlo skip_bl
			;cbi Portb, green_pnum
			;skip_bl:
			;cpi temp_blink, s1 * 2
			;brlo skip_bl2
			;sbi portB, green_pnum
			;skip_bl2:


			cpi countHH, tim_m3HH
			brne notatime_3
			cpi countH, tim_m3H
			brne notatime_3;endoftim
			cpi countL, tim_m3L
			brne notatime_3
			; it's the time:
			ldi countL, 0
			ldi countH, 0
			clr countHH	; L, H, HH = 0
			
			; LEDs off
			cbi Portb, green_pnum	; LED off
			
			ldi mode, 0	; возврат режима 0
			inc bmode	; next - mode 3, 5, etc.
			
			notatime_3a:
			notatime_3:
			
			mov temp, r4	; temp recovery
			sei
	reti
.endmacro
