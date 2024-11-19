F_Init_SystemRam_Prog:							; 系统初始化
	lda		#0
	sta		Counter_1Hz
	sta		Counter_4Hz
	sta		Counter_16Hz
	sta		Key_Flag
	sta		Timer_Flag
	sta		Clock_Flag
	sta		Calendar_Flag
	sta		AlarmLoud_Counter					; 阶段响闹计数
	sta		QuickAdd_Counter					; 快加标志的计数
	sta		Backlight_Counter

	lda		#01
	sta		Sys_Status_Flag

	lda		#00
	sta		R_Time_Hour
	lda		#00
	sta		R_Time_Min
	lda		#00
	sta		R_Time_Sec

	lda		#06
	sta		R_Alarm_Hour
	lda		#00
	sta		R_Alarm_Min

	lda		#01
	sta		R_Date_Day
	lda		#01
	sta		R_Date_Month
	lda		#07
	sta		R_Date_Year
	lda		#00
	sta		R_Date_Week

	rts


F_LCD_Init:
	LCD_C_TYPE
	LCD_ENCH_EN
	LCD_4COM
	LCD_DRIVE_8
	smb2	LCDCTRL
	smb3	LCDCTRL

	PC67_SEG									; 配置IO口为SEG线模式
	PD03_SEG
	PD47_SEG

	LCD_ON
	jsr		F_ClearScreen						; 清屏

	rts


F_Port_Init:
	lda		#$f0
	sta		PA_WAKE
	lda		#$f0
	sta		PA_DIR
	lda		#$f0								; PA口初始配置为下拉输入
	sta		PA
	EN_PA_IRQ									; 打开PA口外部中断

	lda		PB
	and		#$f3
	sta		PB
	rmb2	PB_TYPE
	rmb3	PB_TYPE
	PB2_PB2_COMS								; PB2口作背光输出
	
	lda		PC_SEG								; 配置PC0~5为普通IO口
	and		#$e0
	sta		PC_SEG
	lda		PC_DIR								; PC2~5作拨键输入，PC0、1做邦选
	ora		#$3f
	sta		PC_DIR
	lda		PC									; PC0~5配置为下拉
	ora		#$3f
	sta		PC

	lda		#$00
	sta		PC_IO_Backup

	rts


F_Timer_Init:
	TMR0_CLK_FSUB								; TIM0时钟源Fsub(32768Hz)
	TMR1_CLK_512Hz								; TIM1时钟源Fsub/64(512Hz)
	DIV_512HZ									; TIM2时钟源DIV分频

	lda		#$0									; 重装载计数设置为0
	sta		TMR0
	sta		TMR2

	lda		#$df								; 8Hz一次中断
	sta		TMR1

	rmb6	DIVC								; 关闭定时器同步

	EN_TMR1_IRQ									; 开定时器终端
	EN_TMR2_IRQ
	EN_TMR0_IRQ
	TMR0_OFF
	TMR1_OFF
	TMR2_ON

	DIS_LCD_IRQ

	rts


F_Beep_Init:
	PB3_PB3_COMS								; PN(PB3)初始化成IO输出，避免漏电
	rmb3	PB

	rmb2    DIVC								; 配置蜂鸣音调频率(占空比3/4)
    rmb3    DIVC
	rmb7	DIVC
	rmb1	AUDCR								; 配置BP位，选择AUD开启时的模式，这里选择TONE模式				
	lda		#$ff
	sta		AUD0								; TONE模式下其实AUD0没用

	rts


F_Beep_Init2:
	PB2_PB2_COMS								; PP(PB2)初始化成IO输出，避免漏电
	rmb2	PB

	rmb2    DIVC								; 配置蜂鸣音调频率(占空比3/4)
    rmb3    DIVC
	rmb7	DIVC
	rmb1	AUDCR								; 配置BP位，选择AUD开启时的模式，这里选择TONE模式				
	lda		#$ff
	sta		AUD0

	rts

F_Port_Init2:
	lda		#$fc
	sta		PA_WAKE
	lda		#$fc
	sta		PA_DIR
	lda		#$fc
	sta		PA
	EN_PA_IRQ									; 打开PA口外部中断

	PB3_PB3_COMS								; PB3口作背光输出
	
	lda		PC_SEG								; 配置PC0~5为普通IO口
	and		#$e0
	sta		PC_SEG
	lda		PC_DIR								; PC0/2~5作拨键输入
	and		#$c0
	sta		PC_DIR
	lda		PC									; PC0/2~5配置为下拉
	and		#$c0
	sta		PC

	lda		#$00
	sta		PC_IO_Backup

	rts

F_LCD_Init2:
	LCD_OFF
	LCD_3COM
	LCD_ON

	jsr		F_ClearScreen						; 清屏

	rts


F_BoundPort_Reset:
	rmb0	PC_DIR
	rmb1	PC_DIR
	smb0	PC									; 邦选完成后配置成输出高避免漏电
	smb1	PC
	rts


F_SwitchPort_ScanReady:
	lda		PC_DIR
	ora		#$3c
	sta		PC_DIR
	lda		PC									; PC2~5配置为下拉
	ora		#$3c
	sta		PC
	rts

F_SwitchPort_ScanReset:
	lda		PC_DIR
	and		#$c3
	sta		PC_DIR
	lda		PC									; PC2~5配置为下拉
	ora		#$3c
	sta		PC
	rts

F_QuikAdd_ScanReady:							; PA口配置为下拉输入
	bbs3	Timer_Flag,L_QuikAdd_ScanReady
	rts
L_QuikAdd_ScanReady:
	CLR_PA_IRQ_FLAG
	EN_PA_IRQ
	lda		#$f0
	sta		PA_DIR
	lda		#$f0
	sta		PA
	rts

F_QuikAdd_ScanReset:							; PA口配置为输出高
	bbs3	Timer_Flag,L_QuikAdd_ScanReset
	rts
L_QuikAdd_ScanReset:
	DIS_PA_IRQ
	lda		#$00
	sta		PA_DIR
	lda		#$f0
	sta		PA
	rts

F_QuikAdd_ScanReady2:
	bbs3	Timer_Flag,L_QuikAdd_ScanReady2
	rts
L_QuikAdd_ScanReady2:
	CLR_PA_IRQ_FLAG
	EN_PA_IRQ
	lda		#$fc
	sta		PA_DIR
	lda		#$fc
	sta		PA
	rts

F_QuikAdd_ScanReset2:
	bbs3	Timer_Flag,L_QuikAdd_ScanReset2
	rts
L_QuikAdd_ScanReset2:
	DIS_PA_IRQ
	lda		#$00
	sta		PA_DIR
	lda		#$00
	sta		PA
	lda		Timer_Flag
	rts

F_Delay:
	lda		#$f5
	sta		P_Temp
L_Delay_f5:										; 延时循环用标签
	inc		P_Temp
	lda		P_Temp
	bne		L_Delay_f5
	rts