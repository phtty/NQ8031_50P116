F_Init_SystemRam_Prog:							; 系统初始化
	lda		#0
	sta		Counter_1Hz
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
	LCD_C_1_3_BAIS_3V

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
	lda		#$f0
	sta		PA
	EN_PA_IRQ									; 打开PA口外部中断

	lda		PB
	and		#$f7
	sta		PB
	PB3_PB3_COMS								; PB3口作背光输出
	
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

	lda		#$bf								; 8Hz一次中断
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
	PB2_PWM										; PP(PB2)不作IO用，配置成PWM输出模式
	rmb2    DIVC								; 配置蜂鸣音调频率(占空比3/4)
    rmb3    DIVC
	rmb7	DIVC
	rmb1	AUDCR								; 配置BP位，选择AUD开启时的模式，这里选择TONE模式				
	lda		#$ff
	sta		AUD0								; TONE模式下其实AUD0没用


F_Port_Init2:
	lda		#$fc
	sta		PA_WAKE
	lda		#$fc
	sta		PA_DIR
	lda		#$fc
	sta		PA
	EN_PA_IRQ									; 打开PA口外部中断

	PB3_PB3_COMS								; PB口作背光输出
	
	lda		PC_SEG								; 配置PC0~5为普通IO口
	and		#$e0
	sta		PC_SEG
	lda		PC_DIR								; PC0/2~5作拨键输入
	ora		#$3d
	sta		PC_DIR
	lda		PC									; PC0/2~5配置为下拉
	ora		#$3d
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