F_DisAlarm_Set2:
	bbs0	Timer_Flag,L_TimeDot_Out2_AlarmSet
	rts
L_TimeDot_Out2_AlarmSet:
	rmb0	Timer_Flag
	bbs1	Timer_Flag,L_Dot_Clear2_AlarmSet
	bbr1	Clock_Flag,L_Snooze_Blink52			; Alarm
	lda		Clock_Flag
	and		#1100B
	beq		L_Snooze_Blink52					; Loud和Snooze都为0时不闪烁			
	ldx		#lcd2_Zz
	jsr		F_DispSymbol2
L_Snooze_Blink52:
	jsr		F_Display_Alarm2
	rts											; 半S触发时没1S标志不走时，直接返回
L_Dot_Clear2_AlarmSet:
	rmb1	Timer_Flag							; 清1S标志
	bbr1	Clock_Flag,L_Snooze_Blink62			; Alarm
	lda		Clock_Flag
	and		#1100B
	beq		L_Snooze_Blink62					; Loud和Snooze都为0时不闪烁	
	ldx		#lcd2_Zz							; Zz闪烁条件:
	jsr		F_ClrpSymbol2						; Snooze==1 && loud==0
L_Snooze_Blink62:
	jsr		F_Display_Alarm2
	rts


F_Alarm_Handler2:
	jsr		L_IS_AlarmTrigger2					; 判断闹钟是否触发
	bbr2	Clock_Flag,L_No_Alarm_Process2		; 有响闹标志位再进处理
	jsr		L_Alarm_Process2
	rts
L_No_Alarm_Process2:
	TMR0_OFF
	rmb7	TMRC
	PB2_PB2_COMS								; 不响铃时配置为输出口，避免漏电
	rmb2	PB
	rmb6	Timer_Flag
	rmb7	Timer_Flag
	lda		#0
	sta		AlarmLoud_Counter
	rts

L_IS_AlarmTrigger2:
	bbr1	Clock_Flag,L_CloseLoud2				; 没有开启闹钟不会进响闹模式
	bbs3	Clock_Flag,L_Snooze2
	lda		R_Time_Hour							; 没有贪睡的情况下
	cmp		R_Alarm_Hour						; 闹钟设定值和当前时间不匹配不会进响闹模式
	bne		L_CloseLoud2
	lda		R_Time_Min
	cmp		R_Alarm_Min
	bne		L_CloseLoud2
	bbs2	Clock_Flag,L_Alarm_NoStop2
	lda		R_Time_Sec
	cmp		#00
	bne		L_CloseLoud2
L_Start_Loud_Juge2:
	lda		R_Alarm_Hour						; 在贪睡启动前，必定先触发设定闹钟
	sta		R_Snooze_Hour						; 此时同步设定闹钟时间至贪睡闹钟
	lda		R_Alarm_Min							; 之后贪睡触发时只需要在自己的基础上加5min
	sta		R_Snooze_Min
	bra		L_AlarmTrigger2
L_Snooze2:
	lda		R_Time_Hour							; 有贪睡的情况下
	cmp		R_Snooze_Hour						; 贪睡闹钟设定值和当前时间不匹配不会进响闹模式
	bne		L_Snooze_CloseLoud2
	lda		R_Time_Min
	cmp		R_Snooze_Min
	bne		L_Snooze_CloseLoud2
	bbs2	Clock_Flag,L_Alarm_NoStop2
	lda		R_Time_Sec
	cmp		#00
	bne		L_Snooze_CloseLoud2
L_AlarmTrigger2:
	smb7	Timer_Flag							
	TMR0_ON
	smb2	Clock_Flag							; 开启响闹模式和蜂鸣器计时TIM0
L_Alarm_NoStop2:								; 判断退出条件，响闹模式的backup跟随
	bbs5	Clock_Flag,L_AlarmTrigger_Exit2
	smb5	Clock_Flag							; 保存响闹模式的值,区分响闹结束状态和未响闹状态
L_AlarmTrigger_Exit2:
	rts
L_Snooze_CloseLoud2:
	rmb2	Clock_Flag
	bbr5	Clock_Flag,L_CloseLoud2				; last==1 && now==0
	rmb5	Clock_Flag							; 响闹结束状态同步响闹模式的保存值
	bbr6	Clock_Flag,L_NoSnooze_CloseLoud2
	rmb6	Clock_Flag							; 清贪睡按键触发
	bra		L_CloseLoud2
L_NoSnooze_CloseLoud2:
	rmb3	Clock_Flag							; 没有贪睡按键触发&&贪睡模式&&响闹结束状态
	rmb6	Clock_Flag							; 才结束贪睡模式
L_CloseLoud2:
	rmb2	Clock_Flag							; 非以上情况关闭响闹模式
	rmb5	Clock_Flag
	rmb7	TMRC
	PB2_PB2_COMS								; 不响铃时配置为输出口，避免漏电
	rmb2	PB
	rmb6	Timer_Flag
	rmb7	Timer_Flag
	TMR0_OFF
	rts


L_Alarm_Process2:
	bbs7	Timer_Flag,L_BeepStart2				; 每S进一次
	rts
L_BeepStart2:
	rmb7	Timer_Flag
	inc		AlarmLoud_Counter					; 响铃1次加1响铃计数
	lda		#2									; 0-10S响闹的序列为2，1声
	sta		Beep_Serial
	rmb4	Clock_Flag							; 0-30S为序列响铃
	lda		AlarmLoud_Counter
	cmp		#11
	bcc		L_Alarm_Exit2
	lda		#4									; 10-20S响闹的序列为4，2声
	sta		Beep_Serial
	lda		AlarmLoud_Counter
	cmp		#21
	bcc		L_Alarm_Exit2
	lda		#8									; 20-30S响闹的序列为8，4声
	sta		Beep_Serial
	lda		AlarmLoud_Counter
	cmp		#31
	bcc		L_Alarm_Exit2
	smb4	Clock_Flag							; 30S以上使用持续响铃

L_Alarm_Exit2:
	rts


F_Louding2:
	bbs6	Timer_Flag,L_Beeping2
	rts
L_Beeping2:
	rmb6	Timer_Flag
	bbs4	Clock_Flag,L_ConstBeep_Mode2
	lda		Beep_Serial							; 序列响铃模式
	cmp		#0
	beq		L_NoBeep_Serial_Mode2
	dec		Beep_Serial
	bbr0	Beep_Serial,L_NoBeep_Serial_Mode2
	smb0	SYSCLK
	PB2_PWM
	smb7	TMRC
	rts
L_NoBeep_Serial_Mode2:
	rmb7	TMRC
	PB2_PB2_COMS								; 不响铃时配置为输出口，避免漏电
	rmb2	PB
	bbs0	Test_Flag,L_SerialBeep_Exit2
	rmb0	SYSCLK
L_SerialBeep_Exit2:
	rts

L_ConstBeep_Mode2:
	lda		Beep_Serial							; 持续响铃模式
	eor		#01B								; Beep_Serial翻转第一位
	sta		Beep_Serial

	lda		Beep_Serial
	bbr0	Beep_Serial,L_NoBeep_Const_Mode2
	smb0	SYSCLK
	PB2_PWM
	smb7	TMRC
	rts
L_NoBeep_Const_Mode2:
	rmb7	TMRC
	PB2_PB2_COMS								; 不响铃时配置为输出口，避免漏电
	rmb2	PB
	rmb0	SYSCLK
	rts