F_DisTime_Run3:
	bbs0	Timer_Flag,L_TimeDot_Out3
	rts
L_TimeDot_Out3:
	rmb0	Timer_Flag
	bbs1	Timer_Flag,L_Dot_Clear3
	bbr1	Clock_Flag,L_Snooze_Blink13			; Alarm
	bbs2	Clock_Flag,L_Snooze_Blink13			; Loud
	bbr3	Clock_Flag,L_Snooze_Blink13			; Snooze	
	ldx		#lcd3_Zz							; Zz��˸����:
	jsr		F_DispSymbol3						; Snooze==1 && loud==0 && Alarm==1
L_Snooze_Blink13:
	jsr		F_Display_Time3
	bbr1	Calendar_Flag,No_Date_Add3			; ���������ڣ��������ʾ���ں���
	rmb1	Calendar_Flag
	jsr		F_Display_Date3
	rts											; ��S����ʱû1S��־����ʱ��ֱ�ӷ���
L_Dot_Clear3:
	rmb1	Timer_Flag							; ��1S��־

	bbr1	Clock_Flag,L_Snooze_Blink23			; Alarm
	bbs2	Clock_Flag,L_Snooze_Blink23			; Loud
	bbr3	Clock_Flag,L_Snooze_Blink23			; Snooze	
	ldx		#lcd3_Zz							; Zz��˸����:
	jsr		F_ClrpSymbol3						; Snooze==1 && loud==0
L_Snooze_Blink23:
	jsr		F_Display_Time3
	bbr1	Calendar_Flag,No_Date_Add3			; ���������ڣ��������ʾ���ں���
	rmb1	Calendar_Flag
	jsr		F_Display_Date3
No_Date_Add3:
	rts


F_DisTime_Set3:
	bbs0	Timer_Flag,L_Blink_Time3			; û�а�S��־ʱ����˸
	rts
L_Blink_Time3:
	rmb0	Timer_Flag							; ���S��־
	bbr1	Calendar_Flag,L_No_Date_Add_TS3
	rmb1	Calendar_Flag
	jsr		F_Display_Date3
L_No_Date_Add_TS3:
	bbs1	Timer_Flag,L_Time_Clear3
	jsr		F_Display_Time3						; ��S��

	rts
L_Time_Clear3:
	rmb1	Timer_Flag
	lda		PA									; �а���ʱ����˸
	and		#$C0
	bne		L_Blink_Time3
	jsr		F_UnDisplay_Time3					; 1S��

	rts
