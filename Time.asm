F_Time_Run:
	bbs2	Timer_Flag,L_TimeRun_Add			; 有增S标志才进处理
	rts
L_TimeRun_Add:
	rmb2	Timer_Flag							; 清增S标志

	inc		R_Time_Sec
	lda		R_Time_Sec
	cmp		#60
	bcc		L_Time_SecRun_Exit					; 未发生分钟进位
	lda		#0
	sta		R_Time_Sec
	inc		R_Time_Min
	lda		R_Time_Min
	cmp		#60
	bcc		L_Time_SecRun_Exit					; 未发生小时进位
	lda		#0
	sta		R_Time_Min
	inc		R_Time_Hour
	lda		R_Time_Hour
	cmp		#24
	bcc		L_Time_SecRun_Exit					; 未发生天进位
	lda		#0
	sta		R_Time_Hour
	jsr		F_Calendar_Add
L_Time_SecRun_Exit:
	rts


F_DisTime_Run:
	bbs0	Timer_Flag,L_TimeDot_Out
	rts
L_TimeDot_Out:
	rmb0	Timer_Flag
	bbs1	Timer_Flag,L_Dot_Clear
	ldx		#lcd_DotC							; 没1S亮点
	jsr		F_DispSymbol
	rts											; 半S触发时没1S标志不走时，直接返回
L_Dot_Clear:
	rmb1	Timer_Flag							; 清1S标志
	ldx		#lcd_DotC							; 1S触发后必定进灭点，同时走时
	jsr		F_ClrpSymbol
	jsr		F_Display_Time
	bbr1	Calendar_Flag,No_Date_Add			; 如有增日期，则调用显示日期函数
	jsr		F_Display_Date
No_Date_Add:
	rts


F_DisTime_Set:
	bbs0	Key_Flag,L_KeyTrigger_NoBlink_Time	; 有按键时不闪烁
	bbs0	Timer_Flag,L_Blink_Time				; 没有半S标志时不闪烁
	rts
L_Blink_Time:
	rmb0	Timer_Flag							; 清半S标志
	bbs1	Timer_Flag,L_Time_Clear
L_KeyTrigger_NoBlink_Time:
	jsr		F_Display_Time						; 半S亮
	ldx		#lcd_DotC
	jsr		F_DispSymbol
	rts
L_Time_Clear:
	rmb1	Timer_Flag
	jsr		F_UnDisplay_Time					; 1S灭
	ldx		#lcd_DotC
	jsr		F_ClrpSymbol
	rts
