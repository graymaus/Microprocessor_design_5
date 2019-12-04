; STANDARD HEADER FILE
	PROCESSOR		16F876A
;---REGISTER FILES 선언 ---
;  BANK 0
INDF	 EQU	00H
TMR0	 EQU	01H
PCL	 EQU	02H
STATUS	 EQU	03H
FSR	 EQU	04H	
PORTA	 EQU	05H
PORTB	 EQU	06H
PORTC	 EQU	07H
EEDATA	 EQU	08H
EEADR	 EQU	09H
PCLATH	 EQU	0AH
INTCON	 EQU	0BH
; BANK 1
OPTINOR	 EQU	81H
TRISA	 EQU	85H
TRISB	 EQU	86H
TRISC	 EQU	87H
EECON1	 EQU	88H
EECON2	 EQU	89H
ADCON1	 EQU	9FH
;---STATUS BITS 선언---
IRP	 EQU	7
RP1	 EQU	6
RP0	 EQU	5
NOT_TO 	 EQU	4
NOT_PD 	 EQU	3
ZF 	 EQU	2 ;ZERO FLAG BIT
DC 	 EQU	1 ;DIGIT CARRY/BORROW BIT
CF 	 EQU	0 ;CARRY BORROW FLAG BIT

; -- INTCON BITS 선언 --
; -- OPTION BITS 선언 --

W 	 EQU	B'0' ; W 변수를 0으로 선언
F 	 EQU	.1   ; F 변수를 1로 선언

; --USER
DBUF1	 EQU  	20H
DBUF2	 EQU	21H
DISP_B	 EQU	22H
PASS_C	 EQU	23H
PASS_1	 EQU	24H
PASS_2	 EQU	25H
PASS_3	 EQU	26H
PASS_4	 EQU	27H


;MAIN PROGRAM
	ORG	0000
	BSF 	STATUS,RP0 ; BANK를 1로 변경함
	MOVLW	B'00000111'; 
	MOVWF	TRISA
	MOVLW	B'00000000';
	MOVWF	TRISC	 ; PORTA와C를 모두 OUTPUT설정
	MOVLW	B'00000111'
	MOVWF	ADCON1
	BCF	STATUS,RP0 ; BANK를 0으로 변경
	
	;1단계 
		
	BCF	PORTA,5	; 부져 OFF 설정
	BCF	PORTA,3 ; 출력 LED1 OFF
	CALL 	CLEARP	; 암호 초기화 부분
	
	;2단계
	
LP 	MOVF	DISP_B,W ; 표시할 값 W로
	CALL	DISP	 ; W값을 표시함
	BTFSS	PORTA,4	 ; 암호 입력 스위치 눌러진지 확인
	GOTO	PS0
	BTFSS	PORTA,1	 ;수동 열림 스위치 눌러진지 확인
	GOTO	PS1
	BTFSS	PORTA,2	 ;수동 닫힘 스위치 눌러진지 확인
	GOTO	PS2
	GOTO	LP
	
	;3단계
PS1	BSF	PORTA,3 ; 자물쇠 ON
	BSF	PORTA,5 ; 부져 ON
	CALL	DELAY_1 
	BCF	PORTA,5 ; 부져 OFF
	GOTO	LP1
PS2	BCF	PORTA,3 ; 자물쇠 OFF
	BSF	PORTA,5 ; 부져 ON
	CALL	DELAY_1 
	BCF	PORTA,5 ; 부져 OFF
	GOTO	LP1
;암호위치 초기화
LP1	CALL	CLEARP  ; 암호 초기화 구분 
	GOTO	LP
	;4단계
PS0	
	MOVLW	.9
	SUBWF	DISP_B,W
	BTFSC	STATUS,ZF
	CALL	CLEAR_B	
	INCF	DISP_B	; 초기값을 '0'으로 만듬
	MOVF	DISP_B,W
	CALL	DISP
	CALL	DELAY
	BTFSC	PORTA,0 ; 암호 입력 스위치 눌러짐 확인
	GOTO	PSOFF
; 암호 입력 스위치가 계속 눌러짐
	GOTO	PS0
; 암호 입력 스위치가 놓여짐
PSOFF
;저장위치 구분
	MOVF	PASS_C,W
	ANDLW	03H
	ADDWF	PCL,F 	; 4자리로 제한
	GOTO 	SS_1
	GOTO 	SS_2
	GOTO 	SS_3
	GOTO 	SS_4
SS_1	MOVF	DISP_B,W
	MOVWF	PASS_1 	; 1번째로 들어온 암호 저장
	GOTO	LP3
SS_2	MOVF	DISP_B,W
	MOVWF	PASS_2 	; 2번째로 들어온 암호 저장
	GOTO	LP3
SS_3	MOVF	DISP_B,W
	MOVWF	PASS_3 	; 3번째로 들어온 암호 저장
	GOTO	LP3
; 한 개의 암호가 들어옴 --> 다음 위치  지정 및 표시값 초기화
LP3	INCF	PASS_C,F
	MOVLW	0FFH
	MOVWF	DISP_B
	GOTO	LP
;마지막 암호가 들어옴
SS_4	MOVF	DISP_B,W
	MOVWF	PASS_4 	; 4번째로 들어온 암호 저장
;암호가 다 들어왓으니 암호 검사
	MOVLW	1	; 1번째 내부 암호 값
	SUBWF	PASS_1,W
	BTFSS 	STATUS, ZF
	GOTO	LP5 	; 아닌경우 분기
	MOVLW	2	; 2번째 내부 암호 값
	SUBWF	PASS_2,W
	BTFSS 	STATUS, ZF
	GOTO	LP5 	; 아닌경우 분기
	MOVLW	3	; 3번째 내부 암호 값
	SUBWF	PASS_3,W
	BTFSS 	STATUS, ZF
	GOTO	LP5 	; 아닌경우 분기
	MOVLW	4	; 4번째 내부 암호 값
	SUBWF	PASS_4,W
	BTFSS 	STATUS, ZF
	GOTO	LP5 	; 아닌경우 분기
;모든 암호가 맞았으므로 자물쇠 ON
	GOTO	PS1
; 암호가 다르므로 자물쇠 OFF
LP5 	GOTO	PS2
;-------MAIN END--------
		
; SUBROUTINE
CLEAR_B
	MOVLW	0FFH
	MOVWF	DISP_B
	RETURN

DELAY_1			;부저용 지연
	MOVLW	.250
	MOVWF	DBUF1	 ; 125번을 확인하기 위한 변수
LOOP1	MOVLW	.250
	MOVWF	DBUF2	 ; 10번을 확인하기 위한 변수
LOOP2	NOP
	DECFSZ	DBUF2,F
	GOTO	LOOP2
	DECFSZ	DBUF1,F	 ; 변수를 감소시켜 00이 되었나 확인
	GOTO	LOOP1	 ; ZERO가 아니면 여기에 들어옴
	RETURN


DELAY			; 0.75초 딜레이 
	CALL 	DELAY_1
	CALL 	DELAY_1
	CALL 	DELAY_1

	RETURN

CLEARP			; 암호 초기화 부분
	CLRF	PASS_C	; 암호위치 카운터 초기화 
	MOVLW	0FFH 	; 암호가 들어오지 않았을 때의 초기 기억값 	
	MOVWF	PASS_1 	; 암호위치 초기화
	MOVWF	PASS_2
	MOVWF	PASS_3
	MOVWF	PASS_4
	MOVWF	DISP_B 	; 들어온 암호 숫자를 임시로 저장하는 변수
;표시버퍼를 0FFH 로 하는 이유는 표시기에서 블랭크 상태로 만들기 위함
	RETURN
	
DISP	CALL	CONV 	; W를 7SEG로 변경
	MOVWF	PORTC 	; 숫자 값 출력
	RETURN

CONV	ANDLW	0FH	 ; W의 low nibble 값을 변환하자
	ADDWF	PCL,F	 ; PCL+변환 숫자값 --> PCL
			 ; PC가 변경되므로 이 명령어 다음 수행 위치가 변경
	RETLW	B'00000011'; '0'을 표현하는 값이 W로 들어감
	RETLW	B'10011111'; '1'을 표현하는 값이 W로 들어감
	RETLW	B'00100101'; '2'을 표현하는 값이 W로 들어감
	RETLW	B'00001101'; '3'을 표현하는 값이 W로 들어감
	RETLW	B'10011001'; '4'을 표현하는 값이 W로 들어감
	RETLW	B'01001001'; '5'을 표현하는 값이 W로 들어감
	RETLW	B'01000001'; '6'을 표현하는 값이 W로 들어감
	RETLW	B'00011011'; '7'을 표현하는 값이 W로 들어감
	RETLW	B'00000001'; '8'을 표현하는 값이 W로 들어감
	RETLW	B'00001001'; '9'을 표현하는 값이 W로 들어감
	RETLW	B'11111101'; '-'을 표현하는 값이 W로 들어감
	RETLW	B'11111111'; ' '을 표현하는 값이 W로 들어감
	RETLW	B'11100101'; 'C'을 표현하는 값이 W로 들어감
	RETLW	B'11111110'; '.'을 표현하는 값이 W로 들어감
	RETLW	B'01100001'; 'E'을 표현하는 값이 W로 들어감
	RETLW	B'11111111'; 'F'을 표현하는 값이 W로 들어감
			 
	
END