F_DisAlarm_Set:
	bbs0	Timer_Flag,L_Blink_Alarm		; 没有半S标志时不闪烁
	rts
L_Blink_Alarm:
	rmb0	Timer_Flag						; 清半S标志
	bbs1	Timer_Flag,L_Alarm_Clear
	jsr		F_Display_Alarm					; 半S亮
	jsr		F_Display_Time
	ldx		#lcd_DotC
	jsr		F_DispSymbol
	rts
L_Alarm_Clear:
	rmb1	Timer_Flag
	jsr		F_UnDisplay_Alarm				; 1S灭
	jsr		F_UnDisplay_Time
	ldx		#lcd_DotC
	jsr		F_ClrpSymbol
	rts
