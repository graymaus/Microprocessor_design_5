; STANDARD HEADER FILE
	PROCESSOR		16F876A
;---REGISTER FILES ���� ---
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
;---STATUS BITS ����---
IRP	 EQU	7
RP1	 EQU	6
RP0	 EQU	5
NOT_TO 	 EQU	4
NOT_PD 	 EQU	3
ZF 	 EQU	2 ;ZERO FLAG BIT
DC 	 EQU	1 ;DIGIT CARRY/BORROW BIT
CF 	 EQU	0 ;CARRY BORROW FLAG BIT

; -- INTCON BITS ���� --
; -- OPTION BITS ���� --

W 	 EQU	B'0' ; W ������ 0���� ����
F 	 EQU	.1   ; F ������ 1�� ����

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
	BSF 	STATUS,RP0 ; BANK�� 1�� ������
	MOVLW	B'00000111'; 
	MOVWF	TRISA
	MOVLW	B'00000000';
	MOVWF	TRISC	 ; PORTA��C�� ��� OUTPUT����
	MOVLW	B'00000111'
	MOVWF	ADCON1
	BCF	STATUS,RP0 ; BANK�� 0���� ����
	
	;1�ܰ� 
		
	BCF	PORTA,5	; ���� OFF ����
	BCF	PORTA,3 ; ��� LED1 OFF
	CALL 	CLEARP	; ��ȣ �ʱ�ȭ �κ�
	
	;2�ܰ�
	
LP 	MOVF	DISP_B,W ; ǥ���� �� W��
	CALL	DISP	 ; W���� ǥ����
	BTFSS	PORTA,4	 ; ��ȣ �Է� ����ġ �������� Ȯ��
	GOTO	PS0
	BTFSS	PORTA,1	 ;���� ���� ����ġ �������� Ȯ��
	GOTO	PS1
	BTFSS	PORTA,2	 ;���� ���� ����ġ �������� Ȯ��
	GOTO	PS2
	GOTO	LP
	
	;3�ܰ�
PS1	BSF	PORTA,3 ; �ڹ��� ON
	BSF	PORTA,5 ; ���� ON
	CALL	DELAY_1 
	BCF	PORTA,5 ; ���� OFF
	GOTO	LP1
PS2	BCF	PORTA,3 ; �ڹ��� OFF
	BSF	PORTA,5 ; ���� ON
	CALL	DELAY_1 
	BCF	PORTA,5 ; ���� OFF
	GOTO	LP1
;��ȣ��ġ �ʱ�ȭ
LP1	CALL	CLEARP  ; ��ȣ �ʱ�ȭ ���� 
	GOTO	LP
	;4�ܰ�
PS0	
	MOVLW	.9
	SUBWF	DISP_B,W
	BTFSC	STATUS,ZF
	CALL	CLEAR_B	
	INCF	DISP_B	; �ʱⰪ�� '0'���� ����
	MOVF	DISP_B,W
	CALL	DISP
	CALL	DELAY
	BTFSC	PORTA,0 ; ��ȣ �Է� ����ġ ������ Ȯ��
	GOTO	PSOFF
; ��ȣ �Է� ����ġ�� ��� ������
	GOTO	PS0
; ��ȣ �Է� ����ġ�� ������
PSOFF
;������ġ ����
	MOVF	PASS_C,W
	ANDLW	03H
	ADDWF	PCL,F 	; 4�ڸ��� ����
	GOTO 	SS_1
	GOTO 	SS_2
	GOTO 	SS_3
	GOTO 	SS_4
SS_1	MOVF	DISP_B,W
	MOVWF	PASS_1 	; 1��°�� ���� ��ȣ ����
	GOTO	LP3
SS_2	MOVF	DISP_B,W
	MOVWF	PASS_2 	; 2��°�� ���� ��ȣ ����
	GOTO	LP3
SS_3	MOVF	DISP_B,W
	MOVWF	PASS_3 	; 3��°�� ���� ��ȣ ����
	GOTO	LP3
; �� ���� ��ȣ�� ���� --> ���� ��ġ  ���� �� ǥ�ð� �ʱ�ȭ
LP3	INCF	PASS_C,F
	MOVLW	0FFH
	MOVWF	DISP_B
	GOTO	LP
;������ ��ȣ�� ����
SS_4	MOVF	DISP_B,W
	MOVWF	PASS_4 	; 4��°�� ���� ��ȣ ����
;��ȣ�� �� �������� ��ȣ �˻�
	MOVLW	1	; 1��° ���� ��ȣ ��
	SUBWF	PASS_1,W
	BTFSS 	STATUS, ZF
	GOTO	LP5 	; �ƴѰ�� �б�
	MOVLW	2	; 2��° ���� ��ȣ ��
	SUBWF	PASS_2,W
	BTFSS 	STATUS, ZF
	GOTO	LP5 	; �ƴѰ�� �б�
	MOVLW	3	; 3��° ���� ��ȣ ��
	SUBWF	PASS_3,W
	BTFSS 	STATUS, ZF
	GOTO	LP5 	; �ƴѰ�� �б�
	MOVLW	4	; 4��° ���� ��ȣ ��
	SUBWF	PASS_4,W
	BTFSS 	STATUS, ZF
	GOTO	LP5 	; �ƴѰ�� �б�
;��� ��ȣ�� �¾����Ƿ� �ڹ��� ON
	GOTO	PS1
; ��ȣ�� �ٸ��Ƿ� �ڹ��� OFF
LP5 	GOTO	PS2
;-------MAIN END--------
		
; SUBROUTINE
CLEAR_B
	MOVLW	0FFH
	MOVWF	DISP_B
	RETURN

DELAY_1			;������ ����
	MOVLW	.250
	MOVWF	DBUF1	 ; 125���� Ȯ���ϱ� ���� ����
LOOP1	MOVLW	.250
	MOVWF	DBUF2	 ; 10���� Ȯ���ϱ� ���� ����
LOOP2	NOP
	DECFSZ	DBUF2,F
	GOTO	LOOP2
	DECFSZ	DBUF1,F	 ; ������ ���ҽ��� 00�� �Ǿ��� Ȯ��
	GOTO	LOOP1	 ; ZERO�� �ƴϸ� ���⿡ ����
	RETURN


DELAY			; 0.75�� ������ 
	CALL 	DELAY_1
	CALL 	DELAY_1
	CALL 	DELAY_1

	RETURN

CLEARP			; ��ȣ �ʱ�ȭ �κ�
	CLRF	PASS_C	; ��ȣ��ġ ī���� �ʱ�ȭ 
	MOVLW	0FFH 	; ��ȣ�� ������ �ʾ��� ���� �ʱ� ��ﰪ 	
	MOVWF	PASS_1 	; ��ȣ��ġ �ʱ�ȭ
	MOVWF	PASS_2
	MOVWF	PASS_3
	MOVWF	PASS_4
	MOVWF	DISP_B 	; ���� ��ȣ ���ڸ� �ӽ÷� �����ϴ� ����
;ǥ�ù��۸� 0FFH �� �ϴ� ������ ǥ�ñ⿡�� ��ũ ���·� ����� ����
	RETURN
	
DISP	CALL	CONV 	; W�� 7SEG�� ����
	MOVWF	PORTC 	; ���� �� ���
	RETURN

CONV	ANDLW	0FH	 ; W�� low nibble ���� ��ȯ����
	ADDWF	PCL,F	 ; PCL+��ȯ ���ڰ� --> PCL
			 ; PC�� ����ǹǷ� �� ��ɾ� ���� ���� ��ġ�� ����
	RETLW	B'00000011'; '0'�� ǥ���ϴ� ���� W�� ��
	RETLW	B'10011111'; '1'�� ǥ���ϴ� ���� W�� ��
	RETLW	B'00100101'; '2'�� ǥ���ϴ� ���� W�� ��
	RETLW	B'00001101'; '3'�� ǥ���ϴ� ���� W�� ��
	RETLW	B'10011001'; '4'�� ǥ���ϴ� ���� W�� ��
	RETLW	B'01001001'; '5'�� ǥ���ϴ� ���� W�� ��
	RETLW	B'01000001'; '6'�� ǥ���ϴ� ���� W�� ��
	RETLW	B'00011011'; '7'�� ǥ���ϴ� ���� W�� ��
	RETLW	B'00000001'; '8'�� ǥ���ϴ� ���� W�� ��
	RETLW	B'00001001'; '9'�� ǥ���ϴ� ���� W�� ��
	RETLW	B'11111101'; '-'�� ǥ���ϴ� ���� W�� ��
	RETLW	B'11111111'; ' '�� ǥ���ϴ� ���� W�� ��
	RETLW	B'11100101'; 'C'�� ǥ���ϴ� ���� W�� ��
	RETLW	B'11111110'; '.'�� ǥ���ϴ� ���� W�� ��
	RETLW	B'01100001'; 'E'�� ǥ���ϴ� ���� W�� ��
	RETLW	B'11111111'; 'F'�� ǥ���ϴ� ���� W�� ��
			 
	
END