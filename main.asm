#include "P16F877A.INC"

__CONFIG(_CP_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC)

VALUE EQU 20h
MASK EQU 28h
right EQU 21h
indicator EQU 22h
ws EQU 23h
count0 equ 25h	; задаЄм символьные обозначение €чеек пам€ти, расположенных по адресам 25h, 26h, 27h 
count1 equ 26h
count2 equ 27h

ORG 0
GOTO Start

ORG 4
goto interrupt


array:
	ADDWF PCL, F
	RETLW B'00010000' ;0
	RETLW B'01011011' ;1
	RETLW B'00001100' ;2
	RETLW B'00001001' ;3
	RETLW B'01000011' ;4
	RETLW B'00100001' ;5
	RETLW B'00100000' ;6
	RETLW B'00011011' ;7
	RETLW B'00000000' ;8
	RETLW B'00000001' ;9


Start:

	bsf STATUS,RP0			;переходим в банк 1
	BCF OPTION_REG,PSA ;? 0=prescaler to tmr0
	BCF OPTION_REG,T0CS ;? 0=internal clco, 1=source ra4/t0cki pin
	CLRF TRISC
	CLRF TRISD
	BSF TRISB,.6 ;кнопка				
	BCF STATUS,RP0		;переходим в банк 0	
	BSF INTCON,T0IE
	BSF INTCON,GIE
MOVLW 0x80
MOVWF MASK
CLRF PORTD

	CLRF indicator

MainLoop:
	
	CALL XOR10
	MOVFW indicator
	CALL array 
	MOVWF VALUE
	;MOVWF PORTC
	CALL delay
	CALL delay
	CALL delay
	BTFSS PORTB,.6 ;нажатие кнопки
	GOTO BUTTON_CLICK
	INCF indicator,1

GOTO MainLoop

interrupt:
BCF INTCON,T0IF
MOVFW MASK
ANDWF PORTC,F

MOVFW VALUE
XORWF PORTC,F

MOVFW MASK
XORWF PORTC,F

BSF PORTD,4
RETFIE

XOR10:

    MOVF indicator,W 
    BCF  STATUS,Z 
    XORLW .10    
    BTFSC  STATUS,Z 
	GOTO Start
	RETURN

BUTTON_CLICK:

	WAITBUTTON:
	BTFSS PORTB,.6 ;нажатие кнопки
	GOTO WAITBUTTON
	;вык прерывание по кнопке
	;умножаем число на 2
	MOVF indicator,W 
	ADDWF indicator,1
	;получаем mod 10 числа
	BCF  STATUS,Z
	MOVWF ws
	XORLW .5 
	BTFSC  STATUS,Z
	GOTO MOD
	MOVF ws,W
	BCF  STATUS,Z
	XORLW .6 
	BTFSC  STATUS,Z
	GOTO MOD
	MOVF ws,W
	BCF  STATUS,Z
	XORLW .7 
	BTFSC  STATUS,Z
	GOTO MOD
	MOVF ws,W
	BCF  STATUS,Z
	XORLW .8 
	BTFSC  STATUS,Z
	GOTO MOD
	MOVF ws,W
	BCF  STATUS,Z
	XORLW .9 
	BTFSC  STATUS,Z
	GOTO MOD

	;выводим на индикаторы
	;ждЄм пока отпуст€т кнопку
	;вкл прерывание по кнопке
	;переходим в основной цикл
GOTO MainLoop

MOD:
	MOVLW .10
	SUBWF indicator,1
	GOTO MainLoop

delay:				;подпрограмма задержки
	MOVLW 0xd
	MOVWF count0
	MOVLW 0xff
loop0:
		MOVWF count1
	loop1:
			MOVWF count2
		loop2:
			DECFSZ count2,F
			GOTO loop2 ; переход на метку loop2

		DECFSZ count1,F
		GOTO loop1
	DECFSZ count0,F
	GOTO loop0
RETURN

END