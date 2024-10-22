F_Time_Run2:
	bbs2	Timer_Flag,L_TimeRun_Add2			; 有增S标志才进处理
	rts
L_TimeRun_Add2:
	rmb2	Timer_Flag							; 清增S标志

	inc		R_Time_Sec
	lda		R_Time_Sec
	cmp		#60
	bcc		L_Time_SecRun_Exit2					; 未发生分钟进位
	lda		#0
	sta		R_Time_Sec
	inc		R_Time_Min
	lda		R_Time_Min
	cmp		#60
	bcc		L_Time_SecRun_Exit2					; 未发生小时进位
	lda		#0
	sta		R_Time_Min
	inc		R_Time_Hour
	lda		R_Time_Hour
	cmp		#24
	bcc		L_Time_SecRun_Exit2					; 未发生天进位
	lda		#0
	sta		R_Time_Hour
L_Time_SecRun_Exit2:
	rts


F_DisTime_Run2:
	bbs0	Timer_Flag,L_TimeDot_Out2
	rts
L_TimeDot_Out2:
	rmb0	Timer_Flag
	bbs1	Timer_Flag,L_Dot_Clear2
	bbr1	Clock_Flag,L_Snooze_Blink12			; Alarm
	lda		Clock_Flag
	and		#1100B
	beq		L_Snooze_Blink12					; Loud和Snooze都为0时不闪烁			
	ldx		#lcd2_Zz							; Zz闪烁条件:Alarm==1
	jsr		F_DispSymbol2						; Snooze==1 || loud==1
L_Snooze_Blink12:
	jsr		F_Display_Time2
	rts											; 半S触发时没1S标志不走时，直接返回

L_Dot_Clear2:
	rmb1	Timer_Flag							; 清1S标志
	bbr1	Clock_Flag,L_Snooze_Blink22			; Alarm
	lda		Clock_Flag
	and		#1100B
	beq		L_Snooze_Blink22					; Loud和Snooze都为0时不闪烁	
	ldx		#lcd2_Zz							; Zz闪烁条件:
	jsr		F_ClrpSymbol2						; Snooze==1 && loud==0
L_Snooze_Blink22:
	jsr		F_Display_Time2
	rts


F_DisTime_Set2:
	bbs0	Timer_Flag,L_DisTime_Set2			; 没有半S标志时不更新
	rts
L_DisTime_Set2:
	rmb0	Timer_Flag
	jsr		F_Display_Time2						; 更新时间显示
	rts
