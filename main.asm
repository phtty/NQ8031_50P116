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

	; test Code
	

;***********************************************************************
;***********************************************************************
MainLoop:
main:
	jsr		F_Switch_Scan
	bbr0	Key_Flag,MainLoop
	rmb0	Key_Flag
	jsr		F_Key_Trigger
	bra		MainLoop


;***********************************************************************
;***********************************************************************
V_IRQ:
	pha
	lda		IER
	and		IFR
	sta		R_Int_Backup	

	bbs6	R_Int_Backup,L_LcdIrq
	bbs3	R_Int_Backup,L_Timer2Irq
	bbs4	R_Int_Backup,L_PaIrp
	bbs0	R_Int_Backup,L_DivIrq
	bbs2	R_Int_Backup,L_Timer1Irq
	bbs1	R_Int_Backup,L_Timer0Irq
	bra		L_EndIrq

L_DivIrq:
	CLR_DIV_IRQ_FLAG
	bra		L_EndIrq

L_Timer2Irq:
	CLR_TMR2_IRQ_FLAG
	smb0	Timer_Flag							; 半秒标志，定时器本身是1秒
	smb1	Timer_Flag							; 走时标志，第一次进计数子程序需要走时
	bra		L_EndIrq							; 下半秒由动画完成时定义

L_Timer0Irq:
	CLR_TMR0_IRQ_FLAG

	bra		L_EndIrq

L_Timer1Irq:
	CLR_TMR1_IRQ_FLAG

	bra		L_EndIrq

L_PaIrp:
	CLR_KEY_IRQ_FLAG

	smb0	Key_Flag
	smb1	Key_Flag							; 首次触发
	rmb4	Timer_Flag							; 快加标志位
	rmb6	Timer_Flag

	EN_LCD_IRQ

	bra		L_EndIrq

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
	