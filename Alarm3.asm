F_DisAlarm_Set3:
	bbs0	Timer_Flag,L_Blink_Alarm3			; û�а�S��־ʱ����˸
	rts
L_Blink_Alarm3:
	rmb0	Timer_Flag							; ���S��־
	ldx		#lcd3_ALM
	jsr		F_DispSymbol3
	bbr1	Calendar_Flag,L_No_Date_Add_AS3		; ���������ڣ��������ʾ���ں���
	rmb1	Calendar_Flag
	jsr		F_Display_Date3
L_No_Date_Add_AS3:
	bbs1	Timer_Flag,L_Alarm_Clear3
	jsr		F_Display_Alarm3					; ��S��
	rts
L_Alarm_Clear3:
	rmb1	Timer_Flag
	lda		PA									; �а���ʱ����˸
	and		#$C0
	bne		L_Blink_Alarm3
	jsr		F_UnDisplay_Alarm3					; 1S��
	rts
