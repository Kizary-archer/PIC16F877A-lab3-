#include "P16F877A.INC"

__CONFIG(_CP_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC)

left EQU 20h
right EQU 21h
indicator EQU 22h
ws EQU 23h

ORG 0
GOTO Start

ORG 4
;CALL interrupt
RETFIE

array:
	ADDWF PCL, F
	RETLW B'10010000' ;0
	RETLW B'11011011' ;1
	RETLW B'10001100' ;2
	RETLW B'10001001' ;3
	RETLW B'11000011' ;4
	RETLW B'10100001' ;5
	RETLW B'10100000' ;6
	RETLW B'10011011' ;7
	RETLW B'10000000' ;8
	RETLW B'10000001' ;9

Start:

	CLRF indicator
	CLRF right

MainLoop:

	CALL XOR10
	MOVFW indicator
	CALL array 
	INCF indicator,1
	;GOTO interrupt

GOTO MainLoop

XOR10:

    MOVF indicator,W 
    BCF  STATUS,Z 
    XORLW .10    
    BTFSC  STATUS,Z 
	GOTO Start
	RETURN

interrupt:

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
	;ждём пока отпустят кнопку
	;вкл прерывание по кнопке
	;переходим в основной цикл
GOTO MainLoop

MOD:
	MOVLW .10
	SUBWF indicator,1
	GOTO MainLoop

	END