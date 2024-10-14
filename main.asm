;********************************************************************************
; PROJECT	: Time Counter(ET50P104)					*
; AUTHOR	: WYH										*
; REVISION	: 09/23/2024  V1.0							*
; High OSC CLK  : Internal RC 4.4MHz	Fcpu = Fosc/2	*
; Function	: 											*
;********************************************************************************
	.CHIP	W65C02S		;cpu的选型
	;.INCLIST	ON		;宏定义和文件
	.MACLIST	ON
;***************************************
CODE_BEG	EQU		F000H ;C000H(4K*4次)		;起始地址
;***************************************

PROG	SECTION	OFFSET	CODE_BEG				;定义代码段的偏移量从CODE_BEG开始，用于组织程序代码。

;***************************************
;*	header include								;头文件
;***************************************
	.include	50Px1x.h
	.include	RAM.INC	
	.include	50P116.mac
	.include	MACRO.mac
;***************************************
STACK_BOT		EQU		FFH						;堆栈底部
;***************************************
	.PROG										;程序开始
V_RESET:
	nop
	nop
	nop
	ldx		#STACK_BOT  
	txs											; 使用这个值初始化堆栈指针，这通常是为了设置堆栈的底部地址，确保程序运行中堆栈的正确使用。
	lda		#$B7								; #$07    
	sta		SYSCLK								; 设置系统时钟
	ClrAllRam									; 清RAM
	lda		#$0
	sta		DIVC								; 分频控制器，定时器与DICV异步
	sta		IER									; 除能中断
	sta		IFR									; 初始化中断标志位
	sta		PB
	lda		FUSE
	sta		MF0									;为内部RC振荡器提供校准数据

	jsr		F_Beep_Init
	jsr		L_Init_SystemRam_Prog				;初始化系统RAM并禁用所有断电保留的RAM

	jsr		F_LCD_Init
	jsr		F_Port_Init

	lda		#$07								;系统时钟和中断使能
	sta		SYSCLK

	jsr		F_Timer_Init

	cli											; 开总中断
	jsr		F_Display_All
	
	; test Code
	smb0	Clock_Flag


;***********************************************************************
;***********************************************************************
MainLoop:
	jsr		F_Time_Run
	jsr		F_Switch_Scan
	bbr0	Key_Flag,Status_Juge
	rmb0	Key_Flag
	
Status_Juge:
	bbs0	Sys_Status_Flag,Status_Runtime
	bbs1	Sys_Status_Flag,Status_Calendar_Set
	bbs2	Sys_Status_Flag,Status_Time_Set
	bbs3	Sys_Status_Flag,Status_Alarm_Set
	bra		MainLoop
Status_Runtime:
	jsr		F_KeyTrigger_RunTimeMode
	jsr		F_DisTime_Run
	bra		MainLoop
Status_Calendar_Set:
	jsr		F_KeyTrigger_DateSet_Mode
	jsr		F_DisCalendar_Set
	bra		MainLoop
Status_Time_Set:
	jsr		F_KeyTrigger_TimeSet_Mode
	jsr		F_DisTime_Set
	bra		MainLoop
Status_Alarm_Set:
	jsr		F_KeyTrigger_AlarmSet_Mode
	jsr		F_DisAlarm_Set
	bra		MainLoop


;***********************************************************************
;***********************************************************************
V_IRQ:
	pha
	lda		IER
	and		IFR
	sta		R_Int_Backup	

	bbs0	R_Int_Backup,L_DivIrq
	bbs1	R_Int_Backup,L_Timer0Irq
	bbs2	R_Int_Backup,L_Timer1Irq
	bbs3	R_Int_Backup,L_Timer2Irq
	bbs4	R_Int_Backup,L_PaIrp
	bbs6	R_Int_Backup,L_LcdIrq

	bra		L_EndIrq

L_DivIrq:
	CLR_DIV_IRQ_FLAG
	bra		L_EndIrq

L_Timer2Irq:
	CLR_TMR2_IRQ_FLAG
	smb0	Timer_Flag							; 半秒标志
	lda		Counter_1Hz
	cmp		#01
	bcs		L_1Hz_Out
	inc		Counter_1Hz
	bra		L_EndIrq
L_1Hz_Out:
	lda		#$0
	sta		Counter_1Hz
	smb1	Timer_Flag							; 1S标志，用于闪烁
	smb2	Timer_Flag							; 增S标志，用于计时
	bra		L_EndIrq

L_Timer0Irq:									; 用于蜂鸣器
	CLR_TMR0_IRQ_FLAG
	lda		Counter_16Hz						; 16Hz计数
	cmp		#07
	bcs		L_16Hz_Out
	inc		Counter_16Hz
	bra		L_EndIrq
L_16Hz_Out:
	lda		#$0
	sta		Counter_16Hz
	smb3	Timer_Flag							; 响铃判断标志
	bra		L_EndIrq

L_Timer1Irq:									; 用于快加计时
	CLR_TMR1_IRQ_FLAG
	smb3	Timer_Flag
	bra		L_EndIrq

L_PaIrp:
	CLR_KEY_IRQ_FLAG

	smb0	Key_Flag
	smb1	Key_Flag							; 首次触发
	rmb3	Timer_Flag							; 快加标志位

	TMR1_ON

	bra		L_EndIrq

L_LcdIrq:
	CLR_LCD_IRQ_FLAG

L_EndIrq:
	pla
	rti


;***********************************************************************
.INCLUDE	ScanKey.asm
.INCLUDE	Time.asm
.INCLUDE	Alarm.asm
.INCLUDE	Calendar.asm
.INCLUDE	Init.asm
.INCLUDE	Disp.asm
.INCLUDE	Lcdtab.asm
.INCLUDE	Display.asm
;--------------------------------------------------------	
;***********************************************************************
.BLKB	0FFF8H-$,0FFH
	
.ORG	0FFF8H
	DB		C_RST_SEL + C_OMS0 + C_PAIM
	DB		C_PB32IS + C_PROTB
	DW		0FFFFH
;***********************************************************************
.ORG	0FFFCH
	DW		V_RESET
	DW		V_IRQ

.ENDS
.END
	