F_DisAlarm_Set:
	bbs0	Key_Flag,L_KeyTrigger_NoBlink_Alarm	; 有按键时不闪烁
	bbs0	Timer_Flag,L_Blink_Alarm			; 没有半S标志时不闪烁
	rts
L_Blink_Alarm:
	rmb0	Timer_Flag							; 清半S标志
	bbs1	Timer_Flag,L_Alarm_Clear
L_KeyTrigger_NoBlink_Alarm:
	jsr		F_Display_Alarm						; 半S亮
	ldx		#lcd_DotC
	jsr		F_DispSymbol
	bbr1	Calendar_Flag,No_Date_Add1			; 如有增日期，则调用显示日期函数
	jsr		F_Display_Date
	rts
L_Alarm_Clear:
	rmb1	Timer_Flag
	jsr		F_UnDisplay_Alarm					; 1S灭
	ldx		#lcd_DotC
	jsr		F_ClrpSymbol
	jsr		F_Display_Time
	bbr1	Calendar_Flag,No_Date_Add1			; 如有增日期，则调用显示日期函数
	jsr		F_Display_Date
No_Date_Add1:
	rts



F_Alarm_Handler:
	jsr		L_IS_AlarmTrigger					; 判断闹钟是否触发
	bbr2	Clock_Flag,L_No_Alarm_Process		; 有响闹标志位再进处理
	jsr		L_Alarm_Process
	rts
L_No_Alarm_Process:
	TMR0_OFF
	rmb6	Timer_Flag
	rmb7	Timer_Flag
	rts

L_IS_AlarmTrigger:
	bbr1	Clock_Flag,L_CloseLoud				; 没有开启闹钟拨键不会进响闹模式
	bbs3	Clock_Flag,L_Snooze
	lda		R_Time_Hour							; 没有贪睡的情况下
	cmp		R_Alarm_Hour						; 闹钟设定值和当前时间不匹配不会进响闹模式
	bne		L_CloseLoud
	lda		R_Time_Min
	cmp		R_Alarm_Min
	bne		L_CloseLoud
	bra		L_No_Snooze
L_Snooze:
	lda		R_Time_Hour							; 有贪睡的情况下
	cmp		R_Snooze_Hour						; 贪睡闹钟设定值和当前时间不匹配不会进响闹模式
	bne		L_CloseLoud
	lda		R_Time_Min
	cmp		R_Snooze_Min
	bne		L_CloseLoud
L_No_Snooze:
	smb2	Clock_Flag							; 开启响闹模式和蜂鸣器计时TIM0
	TMR0_ON
	rts
L_CloseLoud:
	rmb2	Clock_Flag							; 非以上情况关闭响闹模式
	rmb7	TMRC
	rts


L_Alarm_Process:
	bbs7	Timer_Flag,L_BeepStart				; 每S进一次
	rts
L_BeepStart:
	rmb7	Timer_Flag
	inc		AlarmLoud_Counter					; 响铃1次加1响铃计数
	lda		#2									; 0-10S响闹的序列为2，1声
	sta		Beep_Serial
	rmb4	Clock_Flag							; 0-30S为序列响铃
	lda		AlarmLoud_Counter
	cmp		#10
	bcc		L_Alarm_Exit
	lda		#4									; 10-20S响闹的序列为4，2声
	sta		Beep_Serial
	lda		AlarmLoud_Counter
	cmp		#20
	bcc		L_Alarm_Exit
	lda		#8									; 20-30S响闹的序列为8，4声
	sta		Beep_Serial
	lda		AlarmLoud_Counter
	cmp		#30
	bcc		L_Alarm_Exit
	smb4	Clock_Flag							; 30S以上使用持续响铃

L_Alarm_Exit:
	rts


L_Louding:
	bbs6	Timer_Flag,L_Beeping
	rts
L_Beeping:
	rmb6	Timer_Flag
	bbs4	Clock_Flag,L_ConstBeep_Mode
	lda		Beep_Serial							; 序列响铃模式
	cmp		#0
	beq		L_NoBeep_Serial_Mode
	dec		Beep_Serial
	bbr0	Beep_Serial,L_NoBeep_Serial_Mode
	smb7	TMRC
	rts
L_NoBeep_Serial_Mode:
	rmb7	TMRC
	rts

L_ConstBeep_Mode:
	lda		Beep_Serial							; 持续响铃模式
	eor		#01B								; Beep_Serial翻转第一位
	sta		Beep_Serial

	lda		Beep_Serial
	bbr0	Beep_Serial,L_NoBeep_Const_Mode
	smb7	TMRC
	rts
L_NoBeep_Const_Mode:
	rmb7	TMRC
	rts