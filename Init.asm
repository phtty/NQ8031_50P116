L_Init_SystemRam_Prog:							; 系统初始化
	lda		#0
	sta		Key_Flag
	sta		Beep_Serial
	sta		Beep_Serial+1
	sta		Counter_4Hz
	sta		Counter_1Hz
	sta		Counter_16Hz
	sta		Frame_Counter
	sta		Frame_Flag
	sta		Timer_Flag
	sta		Overflow_Flag
	sta		CC1
	sta		CC2

	lda		#$01
	sta		Sys_Status_Flag

	lda		#99
	sta		R_Time_Min
	lda		#55
	sta		R_Time_Sec

	rts


F_LCD_Init:
	jsr		F_ClearScreen						; LCD初始化

	CHECK_LCD

	PC67_SEG									; 配置IO口为SEG线模式
	PD03_SEG
	PD47_SEG

	rmb1	LCD_COM								; 配置COM线数量
	smb0	LCD_COM

	LCD_ON
	jsr		F_ClearScreen						; 清屏

	rts


F_Port_Init:
	lda		PA_WAKE								; PA4~7做唤醒
	ora		#$f0
	sta		PA_WAKE
	lda		PA_DIR								; 配置为输入
	ora		#$f0
	sta		PA_DIR
	lda		PA									; 设置下拉
	ora		#$f0
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

	rts


F_Timer_Init:
	TMR1_CLK_512Hz								; TIM1时钟源Fsub/64(512Hz)
	TMR0_CLK_FSUB								; TIM0时钟源Fsub(32768Hz)
	DIV_256HZ									; DIV分频512Hz

	lda		#$0									; 重装载计数设置为0
	sta		TMR0
	sta		TMR2

	lda		#$ef
	sta		TMR1

	rmb6	DIVC								; 关闭定时器同步

	EN_TMR1_IRQ									; 开定时器终端
	EN_TMR2_IRQ
	EN_TMR0_IRQ
	TMR0_OFF
	TMR1_OFF
	TMR2_OFF

	rts


F_Beep_Init:
	TONE_2KHZ									; 配置蜂鸣音调频率
	lda		#$0
	sta		AUDCR
	lda		#$ff
	sta		AUD0
