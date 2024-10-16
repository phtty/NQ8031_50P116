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
