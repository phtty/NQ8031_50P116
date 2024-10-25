F_DisTime_Run3:
	bbs0	Timer_Flag,L_TimeDot_Out3
	rts
L_TimeDot_Out3:
	rmb0	Timer_Flag
	bbs1	Timer_Flag,L_Dot_Clear3
	bbr1	Clock_Flag,L_Snooze_Blink13			; Alarm
	bbs2	Clock_Flag,L_Snooze_Blink13			; Loud
	bbr3	Clock_Flag,L_Snooze_Blink13			; Snooze	
	ldx		#lcd3_Zz							; Zz闪烁条件:
	jsr		F_DispSymbol3						; Snooze==1 && loud==0 && Alarm==1
L_Snooze_Blink13:
	ldx		#lcd3_DotC							; 没1S亮点
	jsr		F_DispSymbol3
	jsr		F_Display_Time3
	bbr1	Calendar_Flag,No_Date_Add3			; 如有增日期，则调用显示日期函数
	rmb1	Calendar_Flag
	jsr		F_Display_Date3
	rts											; 半S触发时没1S标志不走时，直接返回
L_Dot_Clear3:
	rmb1	Timer_Flag							; 清1S标志
	ldx		#lcd3_DotC							; 1S触发后必定进灭点，同时走时
	jsr		F_ClrpSymbol3
	bbr1	Clock_Flag,L_Snooze_Blink23			; Alarm
	bbs2	Clock_Flag,L_Snooze_Blink23			; Loud
	bbr3	Clock_Flag,L_Snooze_Blink23			; Snooze	
	ldx		#lcd3_Zz							; Zz闪烁条件:
	jsr		F_ClrpSymbol3						; Snooze==1 && loud==0
L_Snooze_Blink23:
	jsr		F_Display_Time3
	bbr1	Calendar_Flag,No_Date_Add3			; 如有增日期，则调用显示日期函数
	rmb1	Calendar_Flag
	jsr		F_Display_Date3
No_Date_Add3:
	rts


F_DisTime_Set3:
	bbs0	Key_Flag,L_KeyTrigger_NoBlink_Time3	; 有按键时不闪烁
	bbs0	Timer_Flag,L_Blink_Time3			; 没有半S标志时不闪烁
	rts
L_Blink_Time3:
	rmb0	Timer_Flag							; 清半S标志
	bbr1	Calendar_Flag,L_No_Date_Add_TS3
	rmb1	Calendar_Flag
	jsr		F_Display_Date3
L_No_Date_Add_TS3:
	bbs1	Timer_Flag,L_Time_Clear3
L_KeyTrigger_NoBlink_Time3:
	jsr		F_Display_Time3						; 半S亮
	ldx		#lcd3_DotC
	jsr		F_DispSymbol3
	rts
L_Time_Clear3:
	rmb1	Timer_Flag
	jsr		F_UnDisplay_Time3					; 1S灭
	ldx		#lcd3_DotC
	jsr		F_ClrpSymbol3
	rts
