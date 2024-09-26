;********************************************************************************
; PROJECT	: Time Counter(ET50P104)					*
; AUTHOR	: WYH										*
; REVISION	: 09/23/2024  V1.0							*
; High OSC CLK  : Internal RC 4.4MHz	Fcpu = Fosc/2	*
; Function	: 											*
;********************************************************************************
	.CHIP	W65C02S		;cpu��ѡ��
	;.INCLIST	ON		;�궨����ļ�
	.MACLIST	ON
;***************************************
CODE_BEG	EQU		F000H ;C000H(4K*4��)		;��ʼ��ַ
;***************************************

PROG	SECTION	OFFSET	CODE_BEG				;�������ε�ƫ������CODE_BEG��ʼ��������֯������롣

;***************************************
;*	header include								;ͷ�ļ�
;***************************************
	.include	50Px1x.h
	.include	RAM.INC	
	.include	50P116.mac
	.include	MACRO.mac
;***************************************
STACK_BOT		EQU		FFH						;��ջ�ײ�
;***************************************
	.PROG										;����ʼ
V_RESET:
	NOP
	NOP
	NOP
	LDX		#STACK_BOT  
	TXS											; ʹ�����ֵ��ʼ����ջָ�룬��ͨ����Ϊ�����ö�ջ�ĵײ���ַ��ȷ�����������ж�ջ����ȷʹ�á�
	LDA		#$B7								; #$07    
	STA		SYSCLK								; ����ϵͳʱ��
	ClrAllRam									; ��RAM
	LDA		#$0
	STA		DIVC								; ��Ƶ����������ʱ����DICV�첽
	STA		IER									; �����ж�
	STA		IFR									; ��ʼ���жϱ�־λ
	STA		PB
	LDA		FUSE
	STA		MF0									;Ϊ�ڲ�RC�����ṩУ׼����

	jsr		F_Beep_Init
	jsr		L_Init_SystemRam_Prog				;��ʼ��ϵͳRAM���������жϵ籣����RAM

	jsr		F_LCD_Init
	jsr		F_Port_Init

	lda		#$07								;ϵͳʱ�Ӻ��ж�ʹ��
	sta		SYSCLK

	jsr		F_Timer_Init
	jsr		F_Display_Time

	cli											; �����ж�

	; test Code

;***********************************************************************
;***********************************************************************
MainLoop:
main:
	lda		Timer_Flag							; �ж��Ƿ���Ҫ����
	and		#1100B
	cmp		#$00
	beq		Beep_Out
	jsr		F_Beep_Manage

Beep_Out:
	bbs1	Key_Flag,Key_QA_Out					; �״δ����ض���ɨ��
	bbr6	Timer_Flag,Key_Out					; ������4Hz��ʱ��־���ܽ�ɨ��
	rmb6	Timer_Flag							; ��4Hz��־
	bbs4	Timer_Flag,Key_QA_Out
	inc		Counter_1Hz
	lda		Counter_1Hz
	cmp		#$8
	bcc		Key_QA_Out
	lda		#$0
	sta		Counter_1Hz
	smb4	Timer_Flag							; ����1s�͸���ӱ�־

Key_QA_Out:
	smb0	Key_Flag							; ɨ����־λ

Key_Flag_Out:
	bbr0	Key_Flag,Key_Out
	jsr		F_Key_Trigger						; �а������ºͳ�����ʱ���˲�ɨ��

Key_Out:
	; �жϴ�������״̬���������Ӧ״̬�Ĵ���
	bbs0	Sys_Status_Flag, Status_Init
	bbs3	Sys_Status_Flag, Status_Pause
	bbs1	Sys_Status_Flag, Status_Pos
	bbs2	Sys_Status_Flag, Status_Des
	bbs4	Sys_Status_Flag, Status_Finish

Status_Init:

	bra		MainLoop
Status_Pos:
	jsr		F_Sec_Pos_Counter
	bra		MainLoop
Status_Des:
	jsr		F_Sec_Des_Counter
	bra		MainLoop
Status_Pause:

	bra		MainLoop
Status_Finish:
	jsr		F_Des_Counter_Finish
	bra		MainLoop


;***********************************************************************
;***********************************************************************
V_IRQ:
	PHA
	LDA		P_IER
	AND		P_IFR
	STA		R_Int_Backup	

	BBS6	R_Int_Backup,L_LcdIrq
	BBS3	R_Int_Backup,L_Timer2Irq
	BBS4	R_Int_Backup,L_PaIrp
	BBS0	R_Int_Backup,L_DivIrq
	BBS2	R_Int_Backup,L_Timer1Irq
	BBS1	R_Int_Backup,L_Timer0Irq
	BRA		L_EndIrq

L_DivIrq:
	CLR_DIV_IRQ_FLAG
	BRA		L_EndIrq

L_Timer2Irq:
	CLR_TMR2_IRQ_FLAG
	smb0	Timer_Flag							; �����־����ʱ��������1��
	smb1	Timer_Flag							; ��ʱ��־����һ�ν������ӳ�����Ҫ��ʱ
	bra		L_EndIrq							; �°����ɶ������ʱ����

L_Timer0Irq:
	CLR_TMR0_IRQ_FLAG
	lda		Counter_16Hz						; ֡��ʱ
	cmp		#8
	bcc		L_16Hz_Count_Out
	lda		#0
	sta		Counter_16Hz
	smb7	Timer_Flag
	bra		L_EndIrq
L_16Hz_Count_Out:
	inc		Counter_16Hz
	BRA		L_EndIrq

L_Timer1Irq:
	CLR_TMR1_IRQ_FLAG
	smb5	Timer_Flag
	BRA		L_EndIrq

L_PaIrp:
	CLR_KEY_IRQ_FLAG

	smb0	Key_Flag
	smb1	Key_Flag							; �״δ���
	rmb4	Timer_Flag							; ��ӱ�־λ
	rmb6	Timer_Flag

	EN_LCD_IRQ

	BRA		L_EndIrq

L_LcdIrq:
	CLR_LCD_IRQ_FLAG
	lda		Counter_4Hz
	cmp		#$4
	bcc		L_LCD_4Hz_Out
	lda		#$0
	sta		Counter_4Hz
	smb6	Timer_Flag
	bra		L_EndIrq
L_LCD_4Hz_Out:
	inc		Counter_4Hz

L_EndIrq:
;	BBS3	IFR,L_Timer2Irq
	PLA
	RTI


;***********************************************************************
.INCLUDE	ScanKey.asm
.INCLUDE	Time.asm
.INCLUDE	Beep.asm
.INCLUDE	Init.asm
.INCLUDE	Disp.asm
.INCLUDE	Lcdtab.asm
.INCLUDE	Display.asm
.INCLUDE	Delay.asm
;--------------------------------------------------------	
;***********************************************************************
.BLKB	0FFF8H-$,0FFH
	
.ORG	0FFF8H
	DB		C_RST_SEL + C_OMS0 + C_ROM1+ C_PAIM 	;+ C_ROM0
	DB		C_PB32IS + C_PROTB
	DW		0FFFFH
;***********************************************************************
.ORG	0FFFCH
	DW		V_RESET
	DW		V_IRQ

.ENDS
.END
	