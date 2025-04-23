F_DisAlarm_Set2:
	bbs0	Timer_Flag,L_TimeDot_Out2_AlarmSet
	rts
L_TimeDot_Out2_AlarmSet:
	rmb0	Timer_Flag
	bbs1	Timer_Flag,L_Dot_Clear2_AlarmSet
	bbr1	Clock_Flag,L_Snooze_Blink52			; Alarm
	lda		Clock_Flag
	and		#1100B
	beq		L_Snooze_Blink52					; Loud��Snooze��Ϊ0ʱ����˸			
	ldx		#lcd2_Zz
	jsr		F_DispSymbol2
L_Snooze_Blink52:
	jsr		F_Display_Alarm2
	rts											; ��S����ʱû1S��־����ʱ��ֱ�ӷ���
L_Dot_Clear2_AlarmSet:
	rmb1	Timer_Flag							; ��1S��־
	bbr1	Clock_Flag,L_Snooze_Blink62			; Alarm
	lda		Clock_Flag
	and		#1100B
	beq		L_Snooze_Blink62					; Loud��Snooze��Ϊ0ʱ����˸	
	ldx		#lcd2_Zz							; Zz��˸����:
	jsr		F_ClrpSymbol2						; Snooze==1 && loud==0
L_Snooze_Blink62:
	jsr		F_Display_Alarm2
	rts


F_Alarm_Handler2:
	jsr		L_IS_AlarmTrigger2					; �ж������Ƿ񴥷�
	bbr2	Clock_Flag,L_No_Alarm_Process2		; �����ֱ�־λ�ٽ�����
	jsr		L_Alarm_Process2
	rts
L_No_Alarm_Process2:
	TMR0_OFF
	rmb7	TMRC
	PB2_PB2_COMS								; ������ʱ����Ϊ����ڣ�����©��
	rmb2	PB
	rmb6	Timer_Flag
	rmb7	Timer_Flag
	lda		#0
	sta		AlarmLoud_Counter
	rts

L_IS_AlarmTrigger2:
	bbr1	Clock_Flag,L_CloseLoud2				; û�п������Ӳ��������ģʽ
	bbs3	Clock_Flag,L_Snooze2
	lda		R_Time_Hour							; û��̰˯�������
	cmp		R_Alarm_Hour						; �����趨ֵ�͵�ǰʱ�䲻ƥ�䲻�������ģʽ
	bne		L_CloseLoud2
	lda		R_Time_Min
	cmp		R_Alarm_Min
	bne		L_CloseLoud2
	bbs2	Clock_Flag,L_Alarm_NoStop2
	lda		R_Time_Sec
	cmp		#00
	bne		L_CloseLoud2
L_Start_Loud_Juge2:
	lda		R_Alarm_Hour						; ��̰˯����ǰ���ض��ȴ����趨����
	sta		R_Snooze_Hour						; ��ʱͬ���趨����ʱ����̰˯����
	lda		R_Alarm_Min							; ֮��̰˯����ʱֻ��Ҫ���Լ��Ļ����ϼ�5min
	sta		R_Snooze_Min
	bra		L_AlarmTrigger2
L_Snooze2:
	lda		R_Time_Hour							; ��̰˯�������
	cmp		R_Snooze_Hour						; ̰˯�����趨ֵ�͵�ǰʱ�䲻ƥ�䲻�������ģʽ
	bne		L_Snooze_CloseLoud2
	lda		R_Time_Min
	cmp		R_Snooze_Min
	bne		L_Snooze_CloseLoud2
	bbs2	Clock_Flag,L_Alarm_NoStop2
	lda		R_Time_Sec
	cmp		#00
	bne		L_Snooze_CloseLoud2
L_AlarmTrigger2:
	smb7	Timer_Flag							
	TMR0_ON
	smb2	Clock_Flag							; ��������ģʽ�ͷ�������ʱTIM0
L_Alarm_NoStop2:								; �ж��˳�����������ģʽ��backup����
	bbs5	Clock_Flag,L_AlarmTrigger_Exit2
	smb5	Clock_Flag							; ��������ģʽ��ֵ,�������ֽ���״̬��δ����״̬
L_AlarmTrigger_Exit2:
	rts
L_Snooze_CloseLoud2:
	rmb2	Clock_Flag
	bbr5	Clock_Flag,L_CloseLoud2				; last==1 && now==0
	rmb5	Clock_Flag							; ���ֽ���״̬ͬ������ģʽ�ı���ֵ
	bbr6	Clock_Flag,L_NoSnooze_CloseLoud2
	rmb6	Clock_Flag							; ��̰˯��������
	bra		L_CloseLoud2
L_NoSnooze_CloseLoud2:
	rmb3	Clock_Flag							; û��̰˯��������&&̰˯ģʽ&&���ֽ���״̬
	rmb6	Clock_Flag							; �Ž���̰˯ģʽ
L_CloseLoud2:
	rmb2	Clock_Flag							; ����������ر�����ģʽ
	rmb5	Clock_Flag
	rmb7	TMRC
	PB2_PB2_COMS								; ������ʱ����Ϊ����ڣ�����©��
	rmb2	PB
	rmb6	Timer_Flag
	rmb7	Timer_Flag
	TMR0_OFF
	rts


L_Alarm_Process2:
	bbs7	Timer_Flag,L_BeepStart2				; ÿS��һ��
	rts
L_BeepStart2:
	rmb7	Timer_Flag
	inc		AlarmLoud_Counter					; ����1�μ�1�������
	lda		#2									; 0-10S���ֵ�����Ϊ2��1��
	sta		Beep_Serial
	rmb4	Clock_Flag							; 0-30SΪ��������
	lda		AlarmLoud_Counter
	cmp		#11
	bcc		L_Alarm_Exit2
	lda		#4									; 10-20S���ֵ�����Ϊ4��2��
	sta		Beep_Serial
	lda		AlarmLoud_Counter
	cmp		#21
	bcc		L_Alarm_Exit2
	lda		#8									; 20-30S���ֵ�����Ϊ8��4��
	sta		Beep_Serial
	lda		AlarmLoud_Counter
	cmp		#31
	bcc		L_Alarm_Exit2
	smb4	Clock_Flag							; 30S����ʹ�ó�������

L_Alarm_Exit2:
	rts


F_Louding2:
	bbs6	Timer_Flag,L_Beeping2
	rts
L_Beeping2:
	rmb6	Timer_Flag
	bbs4	Clock_Flag,L_ConstBeep_Mode2
	lda		Beep_Serial							; ��������ģʽ
	cmp		#0
	beq		L_NoBeep_Serial_Mode2
	dec		Beep_Serial
	bbr0	Beep_Serial,L_NoBeep_Serial_Mode2
	smb0	SYSCLK
	PB2_PWM
	smb7	TMRC
	rts
L_NoBeep_Serial_Mode2:
	rmb7	TMRC
	PB2_PB2_COMS								; ������ʱ����Ϊ����ڣ�����©��
	rmb2	PB
	bbs0	Test_Flag,L_SerialBeep_Exit2
	rmb0	SYSCLK
L_SerialBeep_Exit2:
	rts

L_ConstBeep_Mode2:
	lda		Beep_Serial							; ��������ģʽ
	eor		#01B								; Beep_Serial��ת��һλ
	sta		Beep_Serial

	lda		Beep_Serial
	bbr0	Beep_Serial,L_NoBeep_Const_Mode2
	smb0	SYSCLK
	PB2_PWM
	smb7	TMRC
	rts
L_NoBeep_Const_Mode2:
	rmb7	TMRC
	PB2_PB2_COMS								; ������ʱ����Ϊ����ڣ�����©��
	rmb2	PB
	rmb0	SYSCLK
	rts