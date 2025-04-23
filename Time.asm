F_Time_Run:
	bbs2	Timer_Flag,L_TimeRun_Add			; ����S��־�Ž�����
	rts
L_TimeRun_Add:
	rmb2	Timer_Flag							; ����S��־

	inc		R_Time_Sec
	lda		R_Time_Sec
	cmp		#60
	bcc		L_Time_SecRun_Exit					; δ�������ӽ�λ
	lda		#0
	sta		R_Time_Sec
	inc		R_Time_Min
	lda		R_Time_Min
	cmp		#60
	bcc		L_Time_SecRun_Exit					; δ����Сʱ��λ
	lda		#0
	sta		R_Time_Min
	inc		R_Time_Hour
	lda		R_Time_Hour
	cmp		#24
	bcc		L_Time_SecRun_Exit					; δ�������λ
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
	bbr1	Clock_Flag,L_Snooze_Blink1			; Alarm
	bbs2	Clock_Flag,L_Snooze_Blink1			; Loud
	bbr3	Clock_Flag,L_Snooze_Blink1			; Snooze	
	ldx		#lcd_Zz								; Zz��˸����:
	jsr		F_DispSymbol						; Snooze==1 && loud==0 && Alarm==1
L_Snooze_Blink1:
	jsr		F_Display_Time
	bbr1	Calendar_Flag,No_Date_Add			; ���������ڣ��������ʾ���ں���
	rmb1	Calendar_Flag
	jsr		F_Display_Date
	rts											; ��S����ʱû1S��־����ʱ��ֱ�ӷ���
L_Dot_Clear:
	rmb1	Timer_Flag							; ��1S��־
	bbr1	Clock_Flag,L_Snooze_Blink2			; Alarm
	bbs2	Clock_Flag,L_Snooze_Blink2			; Loud
	bbr3	Clock_Flag,L_Snooze_Blink2			; Snooze	
	ldx		#lcd_Zz								; Zz��˸����:
	jsr		F_ClrpSymbol						; Snooze==1 && loud==0
L_Snooze_Blink2:
	jsr		F_Display_Time
	bbr1	Calendar_Flag,No_Date_Add			; ���������ڣ��������ʾ���ں���
	rmb1	Calendar_Flag
	jsr		F_Display_Date
No_Date_Add:
	rts


F_DisTime_Set:
	bbs0	Timer_Flag,L_Blink_Time				; û�а�S��־ʱ����˸
	rts
L_Blink_Time:
	rmb0	Timer_Flag							; ���S��־
	bbr1	Calendar_Flag,L_No_Date_Add_TS
	rmb1	Calendar_Flag
	jsr		F_Display_Date
L_No_Date_Add_TS:
	bbs1	Timer_Flag,L_Time_Clear
	jsr		F_Display_Time						; ��S��
	rts
L_Time_Clear:
	rmb1	Timer_Flag
	lda		PA									; �а���ʱ����˸
	and		#$C0
	bne		L_Blink_Time
	jsr		F_UnDisplay_Time					; 1S��
	rts
