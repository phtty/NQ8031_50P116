F_Time_Run:
	bbs0	Timer_Flag,L_TimeDot_Out
	rts
L_TimeDot_Out:
	rmb0	Timer_Flag						; 清半S标志
	bbs1	Timer_Flag,L_Dot_Clear			; 有1S就灭点
	ldx		#lcd_DotC						; 没1S亮点
	jsr		F_DispSymbol
	rts										; 半S触发时没1S标志不走时，直接返回
L_Dot_Clear:
	ldx		#lcd_DotC						; 1S触发后必定进灭点，同时走时
	jsr		F_ClrpSymbol

	rmb1	Timer_Flag						; 清1S标志

	inc		R_Time_Sec
	lda		R_Time_Sec
	cmp		#60
	bne		L_Time_SecRun_Exit				; 未发生分钟进位
	lda		#0
	sta		R_Time_Sec
	inc		R_Time_Min
	lda		R_Time_Min
	cmp		#60
	bne		L_Time_SecRun_Exit				; 未发生小时进位
	lda		#0
	sta		R_Time_Min
	inc		R_Time_Hour
	lda		R_Time_Hour
	cmp		#24
	bne		L_Time_SecRun_Exit				; 未发生天进位

L_Time_SecRun_Exit:
	jsr		F_Display_Time
	rts