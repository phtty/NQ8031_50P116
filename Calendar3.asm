F_DisCalendar_Set3:
	bbs0	Key_Flag,L_KeyTrigger_NoBlink_Date3	; 有按键时不闪烁
	bbs0	Timer_Flag,L_Blink_Date3			; 没有半S标志不闪烁
	rts
L_Blink_Date3:
	rmb0	Timer_Flag							; 清半S标志
	bbs1	Timer_Flag,L_Date_Clear3			; 有1S标志时灭
L_KeyTrigger_NoBlink_Date3:
	jsr		L_DisDate_Year3
	jsr		F_Display_Date3
	rts	
L_Date_Clear3:
	rmb1	Timer_Flag							; 清1S标志
	jsr		F_UnDisplay_Date3
	rts

