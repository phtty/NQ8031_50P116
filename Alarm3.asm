F_DisAlarm_Set3:
	bbs0	Timer_Flag,L_Blink_Alarm3			; 没有半S标志时不闪烁
	rts
L_Blink_Alarm3:
	rmb0	Timer_Flag							; 清半S标志
	ldx		#lcd3_ALM
	jsr		F_DispSymbol3
	bbr1	Calendar_Flag,L_No_Date_Add_AS3		; 如有增日期，则调用显示日期函数
	rmb1	Calendar_Flag
	jsr		F_Display_Date3
L_No_Date_Add_AS3:
	bbs1	Timer_Flag,L_Alarm_Clear3
	jsr		F_Display_Alarm3					; 半S亮
	rts
L_Alarm_Clear3:
	rmb1	Timer_Flag
	lda		PA									; 有按键时不闪烁
	and		#$C0
	bne		L_Blink_Alarm3
	jsr		F_UnDisplay_Alarm3					; 1S灭
	rts
