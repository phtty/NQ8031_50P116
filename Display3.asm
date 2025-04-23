F_Display_Time3:								; ������ʾ������ʾ��ǰʱ��
	jsr		L_DisTime_Min3
	jsr		L_DisTime_Hour3
	rts

L_DisTime_Min3:
	lda		R_Time_Min
	tax
	lda		Table_DataDot,x
	pha
	and		#$0f
	ldx		#lcd3_d3
	jsr		L_Dis_7Bit_DigitDot_Prog3
	pla
	jsr		L_LSR_4Bit_Prog
	ldx		#lcd3_d2
	jsr		L_Dis_7Bit_DigitDot_Prog3
	rts

L_DisTime_Hour3:								; ��ʾСʱ
	bbr0	Clock_Flag,L_24hMode_Time3
	lda		R_Time_Hour
	cmp		#12
	bcs		L_Time12h_PM3
	ldx		#lcd3_AM							; 12hģʽAM��Ҫ��PM����AM��
	jsr		F_DispSymbol3
	ldx		#lcd3_PM
	jsr		F_ClrpSymbol3
	lda		R_Time_Hour							; ��ʾ�������Aֵ������ȡ����
	cmp		#0
	beq		L_Time_0Hour3
	bra		L_Start_DisTime_Hour3
L_Time12h_PM3:
	ldx		#lcd3_AM							; 12hģʽPM��Ҫ��AM����PM��
	jsr		F_ClrpSymbol3
	ldx		#lcd3_PM
	jsr		F_DispSymbol3
	lda		R_Time_Hour							; ��ʾ�������Aֵ������ȡ����
	sec
	sbc		#12
	cmp		#0
	bne		L_Start_DisTime_Hour3
L_Time_0Hour3:									; 12hģʽ0����Ҫ���12��
	lda		#12
	bra		L_Start_DisTime_Hour3

L_24hMode_Time3:
	ldx		#lcd3_AM							; 24hģʽ����Ҫ��AM��PM��
	jsr		F_ClrpSymbol3
	ldx		#lcd3_PM
	jsr		F_ClrpSymbol3
	lda		R_Time_Hour
L_Start_DisTime_Hour3:
	tax
	lda		Table_DataDot,x
	pha
	and		#$0f
	ldx		#lcd3_d1
	jsr		L_Dis_7Bit_DigitDot_Prog3
	pla
	and		#$f0
	jsr		L_LSR_4Bit_Prog
	ldx		#lcd3_d0
	jsr		L_Dis_3Bit_DigitDot_Prog3
	rts 

F_UnDisplay_Time3:
	lda		#0
	ldx		#lcd3_d0
	jsr		L_Dis_3Bit_DigitDot_Prog3
	lda		#10
	ldx		#lcd_d1
	jsr		L_Dis_7Bit_DigitDot_Prog3
	lda		#10
	ldx		#lcd_d2
	jsr		L_Dis_7Bit_DigitDot_Prog3
	lda		#10
	ldx		#lcd_d3
	jsr		L_Dis_7Bit_DigitDot_Prog3
	rts



; ��ʾ���ں���
F_Display_Date3:
	jsr		L_DisDate_Day3
	jsr		L_DisDate_Month3
	jsr		L_DisDate_Week3
	rts

L_DisDate_Day3:
	ldx		R_Date_Day
	lda		Table_DataDot,x
	pha
	and		#$0f
	ldx		#lcd3_d7
	jsr		L_Dis_7Bit_DigitDot_Prog3
	pla
	jsr		L_LSR_4Bit_Prog
	ldx		#lcd3_d8
	jsr		L_Dis_4Bit_DigitDot_Prog3			; ���ڵ�ʮλ��4��
	rts

L_DisDate_Month3:
	ldx		R_Date_Month
	lda		Table_DataDot,x
	pha
	and		#$0f
	ldx		#lcd3_d9
	jsr		L_Dis_7Bit_DigitDot_Prog3
	pla
	jsr		L_LSR_4Bit_Prog
	cmp		#$0									; �·ݵ�ʮλֻ��1�Σ�����ѡ����symbol��ʾ
	beq		No_Month_Tens3
	ldx		#lcd3_d10
	jsr		F_DispSymbol3
	rts
No_Month_Tens3:
	ldx		#lcd3_d10
	jsr		F_ClrpSymbol3
	rts

L_DisDate_Year3:
	ldx		#00									; 20xx��Ŀ�ͷ20�ǹ̶���
	lda		Table_DataDot,x						; ����20�̶�����ʾ
	ldx		#lcd3_d1
	jsr		L_Dis_7Bit_DigitDot_Prog3
	ldx		#02
	lda		Table_DataDot,x
	ldx		#lcd3_d0
	jsr		L_Dis_3Bit_DigitDot_Prog3

	ldx		R_Date_Year							; ��ʾ��ǰ�����
	lda		Table_DataDot,x
	pha
	and		#$0f
	ldx		#lcd3_d3
	jsr		L_Dis_7Bit_DigitDot_Prog3
	pla
	and		#$f0
	jsr		L_LSR_4Bit_Prog
	ldx		#lcd3_d2
	jsr		L_Dis_7Bit_DigitDot_Prog3
	rts

L_DisDate_Week3:
	jsr		L_GetWeek
	lda		R_Date_Week
	ldx		#lcd3_d4
	jsr		L_Dis_12Bit_DigitDot_Prog3
	lda		R_Date_Week
	ldx		#lcd3_d5
	jsr		L_Dis_9Bit_DigitDot_Prog3
	lda		R_Date_Week
	ldx		#lcd3_d6
	jsr		L_Dis_14Bit_DigitDot_Prog3
	rts

F_UnDisplay_Date3:								; ��˸ʱȡ����ʾ�õĺ���
	lda		#00
	ldx		#lcd3_d0
	jsr		L_Dis_3Bit_DigitDot_Prog3
	lda		#10
	ldx		#lcd3_d1
	jsr		L_Dis_7Bit_DigitDot_Prog3
	lda		#10
	ldx		#lcd3_d2
	jsr		L_Dis_7Bit_DigitDot_Prog3
	lda		#10
	ldx		#lcd3_d3
	jsr		L_Dis_7Bit_DigitDot_Prog3
	lda		#10
	ldx		#lcd3_d7
	jsr		L_Dis_7Bit_DigitDot_Prog3
	lda		#00
	ldx		#lcd3_d8
	jsr		L_Dis_6Bit_DigitDot_Prog3
	lda		#10
	ldx		#lcd3_d9
	jsr		L_Dis_7Bit_DigitDot_Prog3
	ldx		#lcd3_d10
	jsr		F_ClrpSymbol3
	rts

; ��ʾ�����趨ֵ����
F_Display_Alarm3:
	jsr		L_DisAlarm_Min3
	jsr		L_DisAlarm_Hour3
	rts

L_DisAlarm_Min3:
	lda		R_Alarm_Min
	tax
	lda		Table_DataDot,x
	pha
	and		#$0F
	ldx		#lcd3_d3
	jsr		L_Dis_7Bit_DigitDot_Prog3
	pla
	jsr		L_LSR_4Bit_Prog
	ldx		#lcd3_d2
	jsr		L_Dis_7Bit_DigitDot_Prog3
	rts	

L_DisAlarm_Hour3:								; ��ʾ����Сʱ
	bbr0	Clock_Flag,L_24hMode_Alarm3
	lda		R_Alarm_Hour
	cmp		#12
	bcs		L_Alarm12h_PM3						
	ldx		#lcd3_PM							; 12hģʽ����AM��Ҫ��PM��AM
	jsr		F_ClrpSymbol3
	ldx		#lcd3_AM
	jsr		F_DispSymbol3
	lda		R_Alarm_Hour						; ��ʾ�������Aֵ������ȡ����
	cmp		#0
	beq		L_Alarm_0Hour3
	bra		L_Start_DisAlarm_Hour3
L_Alarm12h_PM3:
	ldx		#lcd3_PM							; 12hģʽ����PM��Ҫ��PM��AM
	jsr		F_DispSymbol3
	ldx		#lcd3_AM
	jsr		F_ClrpSymbol3
	lda		R_Alarm_Hour						; ��ʾ�������Aֵ������ȡ����
	sec
	sbc		#12
	cmp		#0
	bne		L_Start_DisAlarm_Hour3
L_Alarm_0Hour3:									; 12hģʽ0����Ҫ���12��
	lda		#12
	bra		L_Start_DisAlarm_Hour3

L_24hMode_Alarm3:
	ldx		#lcd3_PM							; 24hģʽ������Ҫ��PM��AM��
	jsr		F_ClrpSymbol3
	ldx		#lcd3_AM
	jsr		F_ClrpSymbol3
	lda		R_Alarm_Hour
L_Start_DisAlarm_Hour3:
	tax
	lda		Table_DataDot,x
	pha
	and		#$0f
	ldx		#lcd3_d1
	jsr		L_Dis_7Bit_DigitDot_Prog3
	pla
	and		#$f0
	jsr		L_LSR_4Bit_Prog
	ldx		#lcd3_d0
	jsr		L_Dis_3Bit_DigitDot_Prog3
	rts

F_UnDisplay_Alarm3:
	lda		#10
	ldx		#lcd3_d3
	jsr		L_Dis_7Bit_DigitDot_Prog3
	lda		#10
	ldx		#lcd3_d2
	jsr		L_Dis_7Bit_DigitDot_Prog3
	lda		#10
	ldx		#lcd3_d1
	jsr		L_Dis_7Bit_DigitDot_Prog3
	lda		#0
	ldx		#lcd3_d0
	jsr		L_Dis_3Bit_DigitDot_Prog3
	rts

;��ʾ�����ķ���
F_Display_Symbol3:
	ldx		#lcd3_DotC
	jsr		F_DispSymbol3
	ldx		#lcd3_Day
	jsr		F_DispSymbol3
	ldx		#lcd3_MDS
	jsr		F_DispSymbol3
	rts

F_UnDisplay_InDateMode3:
	ldx		#lcd3_AM
	jsr		F_ClrpSymbol3
	ldx		#lcd3_PM
	jsr		F_ClrpSymbol3
	ldx		#lcd3_DotC
	jsr		F_ClrpSymbol3
	rts


F_Display_All3:
	jsr		F_Display_Symbol3
	jsr		F_Display_Date3
	jsr		F_Display_Time3
	rts


F_SymbolRegulate3:
	bbs3	Sys_Status_Flag,L_No_ClrALM
	ldx		#lcd3_ALM
	jsr		F_ClrpSymbol3
L_No_ClrALM:
	bbr1	Clock_Flag,L_No_Alarm3
	ldx		#lcd3_bell
	jsr		F_DispSymbol3
	bbr3	Clock_Flag,L_Snz_Juge3
	bbr2	Clock_Flag,L_Loud_Juge_Exit3		; Zz��������ΪLoud!=0 Snz!=1
L_Snz_Juge3:
	ldx		#lcd3_Zz
	jsr		F_DispSymbol3
L_Loud_Juge_Exit3
	rts
L_No_Alarm3:
	ldx		#lcd3_Zz
	jsr		F_ClrpSymbol3
	ldx		#lcd3_bell
	jsr		F_ClrpSymbol3
	rts

