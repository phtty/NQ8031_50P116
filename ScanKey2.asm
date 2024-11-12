; 正常走时模式的按键处理
F_KeyTrigger_RunTimeMode2:
	bbs0	Key_Flag,L_KeyTrigger_RunTimeMode2
	rts
L_KeyTrigger_RunTimeMode2:
	rmb0	Key_Flag
	rmb1	Key_Flag
	TMR1_OFF									; 没有快加功能不需要开Timer1的8Hz计时
	lda		#$00
	sta		P_Temp
L_DelayTrigger_RunTimeMode2:					; 消抖延时循环用标签
	inc		P_Temp
	lda		P_Temp
	bne		L_DelayTrigger_RunTimeMode2			; 软件消抖

	lda		PA
	and		#$fc
	cmp		#$80
	bne		No_KeySTrigger_RunTimeMode2			; 由于跳转指令寻址能力的问题，这里采用jmp进行跳转
	jmp		L_KeySTrigger_RunTimeMode2			; on/off Alarm触发
No_KeySTrigger_RunTimeMode2:
	cmp		#$40
	bne		No_KeyTTrigger_RunTimeMode2
	jmp		L_KeyTTrigger_RunTimeMode2			; Time_Set触发
No_KeyTTrigger_RunTimeMode2:
	cmp		#$20
	bne		No_KeyMTrigger_RunTimeMode2
	jmp		L_KeyMTrigger_RunTimeMode2			; Min触发
No_KeyMTrigger_RunTimeMode2:
	cmp		#$10
	bne		No_KeyATrigger_RunTimeMode2
	jmp		L_KeyATrigger_RunTimeMode2			; Alarm_Set触发
No_KeyATrigger_RunTimeMode2:
	cmp		#$08
	bne		No_KeyHTrigger_RunTimeMode2
	jmp		L_KeyHTrigger_RunTimeMode2			; Hour触发
No_KeyHTrigger_RunTimeMode2:
	cmp		#$04
	bne		L_KeyExit_RunTimeMode2
	jmp		L_KeyBTrigger_RunTimeMode2			; Backlight/Snooze触发

L_KeyExit_RunTimeMode2:
	rts


L_KeyTTrigger_RunTimeMode2:
	lda		#0100B
	sta		Sys_Status_Flag
	rmb1	Key_Flag							; 进入时间设置模式的处理
	sta		AlarmLoud_Counter					; 清空响铃计数
	jsr		L_NoSnooze_CloseLoud2				; 清理响铃计时、16Hz计时、响铃计数、贪睡等标志位
	pla
	pla
	jmp		MainLoop2

L_KeyHTrigger_RunTimeMode2:
	bra		L_KeyBTrigger_RunTimeMode2

L_KeyBTrigger_RunTimeMode2:
	smb3	Key_Flag							; 背光激活，同时启动贪睡
	smb2	PB
	lda		#0									; 每次按背光都会重置计时
	sta		Backlight_Counter
	bbs2	Clock_Flag,L_KeyBTrigger_NoLoud2	; 如果不是在响闹模式下，则退出贪睡
	jsr		L_NoSnooze_CloseLoud2
	rts
L_KeyBTrigger_NoLoud2:
	smb6	Clock_Flag							; 贪睡按键触发						
	smb3	Clock_Flag							; 进入贪睡模式

	lda		R_Snooze_Min						; 贪睡闹钟的时间加5
	clc
	adc		#8
	cmp		#60
	bcs		L_Snooze_OverflowMin2
	sta		R_Snooze_Min
	bra		L_KeyBTrigger_Exit2
L_Snooze_OverflowMin2:
	sec
	sbc		#60
	sta		R_Snooze_Min						; 产生贪睡响闹的分钟进位
	inc		R_Snooze_Hour
	lda		R_Snooze_Hour
	cmp		#24
	bcc		L_KeyBTrigger_Exit2
	lda		#00									; 产生贪睡小时进位
	sta		R_Snooze_Hour
L_KeyBTrigger_Exit2:
	lda		R_Snooze_Hour
	lda		R_Snooze_Min
	rts

L_KeyMTrigger_RunTimeMode2:
	bra		L_KeyBTrigger_RunTimeMode2

L_KeyATrigger_RunTimeMode2:
	lda		#1000B
	sta		Sys_Status_Flag
	rmb1	Key_Flag							; 清首次触发，等待闹钟设置模式的首个按键
	jsr		F_Display_Alarm2
	lda		#00
	sta		AlarmLoud_Counter					; 清空响铃计数
	jsr		L_NoSnooze_CloseLoud2				; 清理响铃计时、16Hz计时、响铃计数、贪睡等标志位
	pla
	pla
	jmp		MainLoop2

L_KeySTrigger_RunTimeMode2:
	bbs2	Clock_Flag,L_LoundSnz_Handle12		; 若有响闹模式或贪睡模式，则不切换时间模式，只打断响闹和贪睡
	bbs3	Clock_Flag,L_LoundSnz_Handle12
	lda		Clock_Flag							; 每按一次翻转闹钟模式的状态
	eor		#0010B
	sta		Clock_Flag
	bbr1	Clock_Flag,L_Alarm_off_RunTime
	ldx		#lcd2_bell
	jsr		F_DispSymbol2
	ldx		#lcd2_Zz
	jsr		F_DispSymbol2
L_LoundSnz_Handle12:
	jsr		L_NoSnooze_CloseLoud2
	rts
L_Alarm_off_RunTime:
	ldx		#lcd2_bell
	jsr		F_ClrpSymbol2
	ldx		#lcd2_Zz
	jsr		F_ClrpSymbol2
	jsr		L_NoSnooze_CloseLoud2
	rts




; 时间设置模式的按键处理
F_KeyTrigger_TimeSetMode2:
	bbs3	Timer_Flag,L_Key8Hz_TimeSetMode2	; 有快加则直接判断8Hz标志位
	bbr1	Key_Flag,L_KeyScan_TimeSetMode2		; 首次按键触发
	rmb1	Key_Flag
	lda		#$00
	sta		P_Temp
L_DelayTrigger_TimeSetMode2						; 消抖延时循环用标签
	inc		P_Temp
	lda		P_Temp
	bne		L_DelayTrigger_TimeSetMode2			; 软件消抖
	lda		PA
	and		#$ac
	cmp		#$00
	bne		L_KeyYes_TimeSetMode2				; 检测是否有按键触发
	bra		L_KeyExit_TimeSetMode2
	rts
L_KeyYes_TimeSetMode2:
	sta		PA_IO_Backup
	bra		L_KeyHandle_TimeSetMode2			; 首次触发处理结束

L_KeyScan_TimeSetMode2:							; 长按处理部分
	bbr0	Key_Flag,L_KeyExit_TimeSetMode2		; 没有扫键标志直接退出
L_Key8Hz_TimeSetMode2:
	bbr4	Timer_Flag,L_Key8HzExit_TimeSetMode2; 8Hz标志位到来前也不进行按键处理(快加下)
	rmb4	Timer_Flag
	lda		PA
	and		#$ac
	cmp		PA_IO_Backup						; 若检测到有按键的状态变化则退出快加判断并结束
	beq		L_8Hz_Count_TimeSetMode2
	bra		L_KeyExit_TimeSetMode2
	rts
L_8Hz_Count_TimeSetMode2:
	inc		QuickAdd_Counter
	lda		QuickAdd_Counter
	cmp		#12
	bcs		L_QuikAdd_TimeSetMode2
	rts											; 长按计时，必须满1.5S才有快加
L_QuikAdd_TimeSetMode2:
	smb3	Timer_Flag

L_KeyHandle_TimeSetMode2:
	lda		PA
	and		#$ac
	cmp		#$80
	bne		No_KeySTrigger_TimeSetMode2			; 由于跳转指令寻址能力的问题，这里采用jmp进行跳转
	jmp		L_KeySTrigger_TimeSetMode2			; on/off Alarm触发
No_KeySTrigger_TimeSetMode2:
	cmp		#$20
	bne		No_KeyMTrigger_TimeSetMode2
	jmp		L_KeyMTrigger_TimeSetMode2			; Min触发
No_KeyMTrigger_TimeSetMode2:
	cmp		#$08
	bne		No_KeyHTrigger_TimeSetMode2
	jmp		L_KeyHTrigger_TimeSetMode2			; Hour触发
No_KeyHTrigger_TimeSetMode2:
	cmp		#$04
	bne		L_KeyExit_TimeSetMode2
	jmp		L_KeyBTrigger_TimeSetMode2			; Backlight/Snooze触发

L_KeyExit_TimeSetMode2:
	TMR1_OFF									; 关闭快加8Hz计时的定时器
	rmb0	Key_Flag							; 清相关标志位
	rmb3	Timer_Flag
	lda		#0									; 清理相关变量
	sta		QuickAdd_Counter
L_Key8HzExit_TimeSetMode2:
	rts

L_KeyMTrigger_TimeSetMode2:
	lda		#01
	sta		R_Time_Sec							; 调分钟会清S计数
	inc		R_Time_Min
	lda		#59
	cmp		R_Time_Min
	bcs		L_MinSet_Juge2
	lda		#00
	sta		R_Time_Min
L_MinSet_Juge2:
	jsr		L_DisTime_Min2
	bra		L_KeyBTrigger_TimeSetMode2			; M也会触发背光
L_KeyHTrigger_TimeSetMode2:
	inc		R_Time_Hour
	lda		#23
	cmp		R_Time_Hour
	bcs		L_HourSet_Juge2
	lda		#00
	sta		R_Time_Hour
L_HourSet_Juge2:
	jsr		L_DisTime_Hour2						; H也会触发背光
L_KeyBTrigger_TimeSetMode2:
	jmp		L_KeyBTrigger_RunTimeMode2
	rts
L_KeySTrigger_TimeSetMode2:
	bbs2	Clock_Flag,L_LoundSnz_Handle22		; 若有响闹模式或贪睡模式，则不切换时间模式，只打断响闹和贪睡
	bbs3	Clock_Flag,L_LoundSnz_Handle22
	lda		Clock_Flag							; 每按一次翻转闹钟模式的状态
	eor		#0010B
	sta		Clock_Flag
	bbr1	Clock_Flag,L_Alarm_off_TimeSet
	ldx		#lcd2_bell
	jsr		F_DispSymbol2
	ldx		#lcd2_Zz
	jsr		F_DispSymbol2
L_LoundSnz_Handle22:
	jsr		L_NoSnooze_CloseLoud2
	rts
L_Alarm_off_TimeSet:
	ldx		#lcd2_bell
	jsr		F_ClrpSymbol2
	ldx		#lcd2_Zz
	jsr		F_ClrpSymbol2
	rts

F_Is_KeyTKeep:
	bbs3	Timer_Flag,L_QA_KeyTKeep			; 有快加时不退出
	bbr6	PA,L_NoKeyT_Keep
L_QA_KeyTKeep:
	rts
L_NoKeyT_Keep:
	TMR1_OFF									; 关闭快加8Hz计时的定时器
	rmb0	Key_Flag							; 清相关标志位
	rmb3	Timer_Flag
	lda		#0									; 清理相关变量
	sta		QuickAdd_Counter
	lda		#0001B								; 回到走时模式
	sta		Sys_Status_Flag
	jsr		F_Display_Time2
	jsr		L_NoSnooze_CloseLoud2
	rts




; 闹钟设置模式的按键处理
F_KeyTrigger_AlarmSetMode2:
	bbs3	Timer_Flag,L_Key8Hz_AlarmSetMode2	; 有快加则直接判断8Hz标志位
	bbr1	Key_Flag,L_KeyScan_AlarmSetMode2	; 首次按键触发
	rmb1	Key_Flag
	lda		#$00
	sta		P_Temp
L_DelayTrigger_AlarmSetMode2:					; 消抖延时循环用标签
	inc		P_Temp
	lda		P_Temp
	bne		L_DelayTrigger_AlarmSetMode2		; 软件消抖
	lda		PA
	and		#$ac
	cmp		#$00
	bne		L_KeyYes_AlarmSetMode2				; 检测是否有按键触发
	bra		L_KeyExit_AlarmSetMode2
	rts
L_KeyYes_AlarmSetMode2:
	sta		PA_IO_Backup
	bra		L_KeyHandle_AlarmSetMode2			; 首次触发处理结束

L_KeyScan_AlarmSetMode2:						; 长按处理部分
	bbr0	Key_Flag,L_KeyExit_AlarmSetMode2	; 没有扫键标志直接退出
L_Key8Hz_AlarmSetMode2:
	bbr4	Timer_Flag,L_Key8HzExit_AlarmSetMode2; 8Hz标志位到来前也不进行按键处理(快加下)
	rmb4	Timer_Flag
	lda		PA
	and		#$ac
	cmp		PA_IO_Backup						; 若检测到有按键的状态变化则退出快加判断并结束
	beq		L_8Hz_Count_AlarmSetMode2
	bra		L_KeyExit_AlarmSetMode2
	rts
L_8Hz_Count_AlarmSetMode2:
	inc		QuickAdd_Counter
	lda		QuickAdd_Counter
	cmp		#12
	bcs		L_QuikAdd_AlarmSetMode2
	rts											; 长按计时，必须满1.5S才有快加
L_QuikAdd_AlarmSetMode2:
	smb3	Timer_Flag

L_KeyHandle_AlarmSetMode2:
	lda		PA
	and		#$ac
	cmp		#$80
	bne		No_KeySTrigger_AlarmSetMode2		; 由于跳转指令寻址能力的问题，这里采用jmp进行跳转
	jmp		L_KeySTrigger_AlarmSetMode2			; on/off Alarm触发
No_KeySTrigger_AlarmSetMode2:
	cmp		#$20
	bne		No_KeyMTrigger_AlarmSetMode2
	jmp		L_KeyMTrigger_AlarmSetMode2			; Min触发
No_KeyMTrigger_AlarmSetMode2:
	cmp		#$08
	bne		No_KeyHTrigger_AlarmSetMode2
	jmp		L_KeyHTrigger_AlarmSetMode2			; Hour触发
No_KeyHTrigger_AlarmSetMode2:
	cmp		#$04
	bne		L_KeyExit_AlarmSetMode2
	jmp		L_KeyBTrigger_AlarmSetMode2			; Backlight/Snooze触发

L_KeyExit_AlarmSetMode2:
	TMR1_OFF									; 关闭快加8Hz计时的定时器
	rmb0	Key_Flag							; 清相关标志位
	rmb3	Timer_Flag
	lda		#0									; 清理相关变量
	sta		QuickAdd_Counter
L_Key8HzExit_AlarmSetMode2:
	rts


L_KeyMTrigger_AlarmSetMode2:
	inc		R_Alarm_Min
	lda		#59
	cmp		R_Alarm_Min
	bcs		L_AlarmMinSet_Juge2
	lda		#00
	sta		R_Alarm_Min
L_AlarmMinSet_Juge2:
	jsr		L_DisAlarm_Min2
	bra		L_KeyBTrigger_AlarmSetMode2			; M触发也会触发背光
L_KeyHTrigger_AlarmSetMode2:
	inc		R_Alarm_Hour
	lda		#23
	cmp		R_Alarm_Hour
	bcs		L_AlarmHourSet_Juge2
	lda		#00
	sta		R_Alarm_Hour
L_AlarmHourSet_Juge2:
	jsr		L_DisAlarm_Hour2					; H触发也会触发背光
L_KeyBTrigger_AlarmSetMode2:
	jmp		L_KeyBTrigger_RunTimeMode2
	rts
L_KeySTrigger_AlarmSetMode2:
	bbs2	Clock_Flag,L_LoundSnz_Handle32		; 若有响闹模式或贪睡模式，则不切换时间模式，只打断响闹和贪睡
	bbs3	Clock_Flag,L_LoundSnz_Handle32
	lda		Clock_Flag							; 每按一次翻转闹钟模式的状态
	eor		#0010B
	sta		Clock_Flag
	bbr1	Clock_Flag,L_Alarm_off_AlarmSet
	ldx		#lcd2_bell
	jsr		F_DispSymbol2
	ldx		#lcd2_Zz
	jsr		F_DispSymbol2
L_LoundSnz_Handle32:
	jsr		L_NoSnooze_CloseLoud2
	rts
L_Alarm_off_AlarmSet:
	ldx		#lcd2_bell
	jsr		F_ClrpSymbol2
	ldx		#lcd2_Zz
	jsr		F_ClrpSymbol2
	rts

F_Is_KeyAKeep:
	bbs3	Timer_Flag,L_QA_KeyAKeep			; 有快加时不退出
	bbr4	PA,L_NoKeyA_Keep
L_QA_KeyAKeep:
	rts
L_NoKeyA_Keep:
	lda		Timer_Flag
	TMR1_OFF									; 关闭快加8Hz计时的定时器
	rmb0	Key_Flag							; 清相关标志位
	rmb3	Timer_Flag
	lda		#0									; 清理相关变量
	sta		QuickAdd_Counter
	lda		#0001B								; 回到走时模式
	sta		Sys_Status_Flag
	jsr		F_Display_Time2
	jsr		L_NoSnooze_CloseLoud2
	rts
