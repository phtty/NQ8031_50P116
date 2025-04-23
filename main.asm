	.CHIP	W65C02S		;cpu��ѡ��
	;.INCLIST	ON		;�궨����ļ�
	.MACLIST	ON
;***************************************
CODE_BEG	EQU		C000H						;��ʼ��ַ
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
	nop
	nop
	nop
	ldx		#STACK_BOT
	txs											; ʹ�����ֵ��ʼ����ջָ�룬��ͨ����Ϊ�����ö�ջ�ĵײ���ַ��ȷ�����������ж�ջ����ȷʹ�á�
	lda		#$17								; #$97
	sta		SYSCLK								; ����ϵͳʱ��
	ClrAllRam									; ��RAM
	lda		#$0
	sta		DIVC								; ��Ƶ����������ʱ����DIV�첽
	sta		IER									; �����ж�
	sta		IFR									; ��ʼ���жϱ�־λ
	lda		FUSE
	sta		MF0									;Ϊ�ڲ�RC�����ṩУ׼����	

	jsr		F_Beep_Init
	jsr		F_Init_SystemRam_Prog				;��ʼ��ϵͳRAM���������жϵ籣����RAM

	jsr		F_LCD_Init
	jsr		F_Port_Init

	lda		#$07								;ϵͳʱ�Ӻ��ж�ʹ��
	sta		SYSCLK

	jsr		F_Timer_Init

	lda		PC
	and		#11B
	beq		L_MODE0
	cmp		#01B
	beq		L_MODE1
	cmp		#10B
	beq		L_MODE2
	bra		V_RESET

L_MODE0:										; MODE0������Բʱ��
	jsr		F_Port_Init2						; Mode0��ʼ��
	jsr		F_LCD_Init2
	jsr		F_Beep_Init2						; ��Բʱ�ӵķ������ڲ�һ��
	jsr		F_MODE0_Init
	jsr		F_BoundPort_Reset					; ��ѡȷ������������ڱ���©��
	cli											; �����ж�

	jsr		F_Test_Mode2
	jsr		F_Display_Symbol2
	jsr		F_Display_Time2
	jmp		MainLoop2

L_MODE1:										; MODE1����ɷ���ʱ��
	jsr		F_BoundPort_Reset					; ��ѡȷ������������ڱ���©��
	cli											; �����ж�
	rmb0	Key_Flag
	smb0	Clock_Flag
	jsr		F_Test_Mode
	jsr		F_Display_Symbol
	jmp		MainLoop

L_MODE2:										; MODE2�������ڷ���ʱ��
	jsr		F_BoundPort_Reset					; ��ѡȷ������������ڱ���©��
	cli
	smb0	Clock_Flag
	jsr		F_Test_Mode
	jsr		F_Display_Symbol3
	jsr		F_Display_Date3
	jmp		MainLoop3

;***********************************************************************
;***********************************************************************
; ����ʱ�ӣ��ɣ�״̬��
MainLoop:
	jsr		F_Time_Run							; ��ʱȫ����Ч
	jsr		F_Switch_Scan						; ����ɨ��ȫ����Ч
	jsr		F_Backlight							; ����ȫ����Ч
	jsr		F_Louding							; ���崦��ȫ����Ч
	jsr		F_SymbolRegulate

Status_Juge:
	bbs0	Sys_Status_Flag,Status_Runtime
	bbs1	Sys_Status_Flag,Status_Calendar_Set
	bbs2	Sys_Status_Flag,Status_Time_Set
	bbs3	Sys_Status_Flag,Status_Alarm_Set
	bra		MainLoop
Status_Runtime:
	jsr		F_KeyTrigger_RunTimeMode			; RunTimeģʽ�°����߼�
	jsr		F_DisTime_Run
	jsr		F_Alarm_Handler						; ֻ��RunTimeģʽ�²Ż�����
	bbs7	TMRC,L_InBeep_NoHalt_Runtime
	sta		HALT
L_InBeep_NoHalt_Runtime:
	bra		MainLoop
Status_Calendar_Set:
	jsr		F_KeyTrigger_DateSetMode			; DateSetģʽ�°����߼�
	jsr		F_DisCalendar_Set
	bbs7	TMRC,L_InBeep_NoHalt_Calendar_Set

	sta		HALT
L_InBeep_NoHalt_Calendar_Set:
	bra		MainLoop
Status_Time_Set:
	jsr		F_KeyTrigger_TimeSetMode			; TimeSetģʽ�°����߼�
	jsr		F_DisTime_Set
	bbs7	TMRC,L_InBeep_NoHalt_Time_Set
	sta		HALT
L_InBeep_NoHalt_Time_Set:
	bra		MainLoop
Status_Alarm_Set:
	jsr		F_KeyTrigger_AlarmSetMode			; AlarmSetģʽ�°����߼�
	jsr		F_DisAlarm_Set
	bbs7	TMRC,L_InBeep_NoHalt_Alarm_Set
	sta		HALT
L_InBeep_NoHalt_Alarm_Set:
	bra		MainLoop


;***********************************************************************
;***********************************************************************
; �жϷ�����
V_IRQ:
	pha
	lda		IER
	and		IFR
	sta		R_Int_Backup	

	bbs0	R_Int_Backup,L_DivIrq
	bbs1	R_Int_Backup,L_Timer0Irq
	bbs2	R_Int_Backup,L_Timer1Irq
	bbs3	R_Int_Backup,L_Timer2Irq
	bbs4	R_Int_Backup,L_PaIrq
	bbs6	R_Int_Backup,L_LcdIrq

	bra		L_EndIrq

L_DivIrq:
	CLR_DIV_IRQ_FLAG
	bra		L_EndIrq

L_Timer2Irq:
	CLR_TMR2_IRQ_FLAG
	smb0	Timer_Flag							; �����־
	lda		Counter_1Hz
	cmp		#01
	bcs		L_1Hz_Out
	inc		Counter_1Hz
	bra		L_EndIrq
L_1Hz_Out:
	lda		#$0
	sta		Counter_1Hz
	lda		Timer_Flag
	ora		#10100110B							; 1S����S�����⡢�����1S��־λ
	sta		Timer_Flag
	bra		L_EndIrq

L_Timer0Irq:									; ���ڷ�����
	CLR_TMR0_IRQ_FLAG
	lda		Counter_16Hz						; 16Hz����
	cmp		#07
	bcs		L_16Hz_Out
	inc		Counter_16Hz
	bra		L_EndIrq
L_16Hz_Out:
	lda		#$0
	sta		Counter_16Hz
	smb6	Timer_Flag							; 16Hz��־
	bra		L_EndIrq

L_Timer1Irq:									; ���ڿ�Ӽ�ʱ
	CLR_TMR1_IRQ_FLAG
	smb4	Timer_Flag							; ɨ��16Hz��־
	lda		Counter_4Hz							; 4Hz����
	cmp		#03
	bcs		L_4Hz_Out
	inc		Counter_4Hz
	bra		L_EndIrq
L_4Hz_Out:
	lda		#$0
	sta		Counter_4Hz
	smb2	Key_Flag							; ���4Hz��־
	bra		L_EndIrq

L_PaIrq:
	CLR_KEY_IRQ_FLAG

	smb0	Key_Flag
	smb1	Key_Flag							; �״δ���
	rmb3	Timer_Flag							; ������µ��½��ص��������ӱ�־λ
	rmb4	Timer_Flag							; 16Hz��ʱ

	TMR1_ON										; ��Ӷ�ʱ

	bra		L_EndIrq

L_LcdIrq:
	CLR_LCD_IRQ_FLAG
	inc		CC0
	lda		CC0
	cmp		#5
	beq		Lcd_15Hz
	bra		L_EndIrq
Lcd_15Hz:
	lda		#0
	sta		CC0
	smb4	Key_Flag							; AlarmSet��TimeSet�����п�ɨ��

L_EndIrq:
	pla
	rti


;***********************************************************************
.include	main2.asm
.include	main3.asm
.include	ScanKey.asm
.include	ScanKey2.asm
.include	ScanKey3.asm
.include	Time.asm
.include	Time2.asm
.include	Time3.asm
.include	Calendar.asm
.include	Calendar3.asm
.include	Alarm.asm
.include	Alarm2.asm
.include	Alarm3.asm
.include	Backlight.asm
.include	Init.asm
.include	Disp.asm
.include	Disp2.asm
.include	Disp3.asm
.include	Display.asm
.include	Display2.asm
.include	Display3.asm
.include	Lcdtab.asm
.include	Lcdtab2.asm
.include	Lcdtab3.asm
.include	TestMode.asm

;--------------------------------------------------------	
;***********************************************************************
.BLKB	0FFFFH-$,0FFH							; �ӵ�ǰ��ַ��FFFFȫ�����0xFF

.ORG	0FFF8H
	DB		C_RST_SEL+C_VOLT_V30+C_OMS0+C_PAIM
	DB		C_PB32IS+C_PROTB
	DW		0FFFFH
;***********************************************************************
.ORG	0FFFCH
	DW		V_RESET
	DW		V_IRQ

.ENDS
.END
	