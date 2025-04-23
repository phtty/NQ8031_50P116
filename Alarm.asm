F_DisAlarm_Set:
	bbs0	Timer_Flag,L_Blink_Alarm			; û�а�S��־ʱ����˸
	rts
L_Blink_Alarm:
	rmb0	Timer_Flag							; ���S��־
	bbr1	Calendar_Flag,L_No_Date_Add_AS		; ���������ڣ��������ʾ���ں���
	rmb1	Calendar_Flag
	jsr		F_Display_Date
L_No_Date_Add_AS:
	bbs1	Timer_Flag,L_Alarm_Clear
	jsr		F_Display_Alarm						; ��S��
	rts
L_Alarm_Clear:
	rmb1	Timer_Flag
	bbs0	Key_Flag,No_Alarm_UnDis
	jsr		F_UnDisplay_Alarm					; 1S��
No_Alarm_UnDis:
	jsr		F_Display_Time
	rts



F_Alarm_Handler:
	jsr		L_IS_AlarmTrigger					; �ж������Ƿ񴥷�
	bbr2	Clock_Flag,L_No_Alarm_Process		; �����ֱ�־λ�ٽ�����
	jsr		L_Alarm_Process
	rts
L_No_Alarm_Process:
	TMR0_OFF
	rmb7	TMRC
	PB3_PB3_COMS
	rmb3	PB
	rmb6	Timer_Flag
	rmb7	Timer_Flag
	lda		#0
	sta		AlarmLoud_Counter
	rts

L_IS_AlarmTrigger:
	bbr1	Clock_Flag,L_CloseLoud				; û�п������Ӳ������������ģʽ
	bbs3	Clock_Flag,L_Snooze
	lda		R_Time_Hour							; û��̰˯�������
	cmp		R_Alarm_Hour						; �����趨ֵ�͵�ǰʱ�䲻ƥ�䲻�������ģʽ
	bne		L_CloseLoud
	lda		R_Time_Min
	cmp		R_Alarm_Min
	bne		L_CloseLoud
	bbs2	Clock_Flag,L_Alarm_NoStop
	lda		R_Time_Sec
	cmp		#00
	bne		L_CloseLoud
L_Start_Loud_Juge:
	lda		R_Alarm_Hour						; ��̰˯����ǰ���ض��ȴ����趨����
	sta		R_Snooze_Hour						; ��ʱͬ���趨����ʱ����̰˯����
	lda		R_Alarm_Min							; ֮��̰˯����ʱֻ��Ҫ���Լ��Ļ����ϼ�5min
	sta		R_Snooze_Min
	bra		L_AlarmTrigger
L_Snooze:
	lda		R_Time_Hour							; ��̰˯�������
	cmp		R_Snooze_Hour						; ̰˯�����趨ֵ�͵�ǰʱ�䲻ƥ�䲻�������ģʽ
	bne		L_Snooze_CloseLoud
	lda		R_Time_Min
	cmp		R_Snooze_Min
	bne		L_Snooze_CloseLoud
	bbs2	Clock_Flag,L_Alarm_NoStop
	lda		R_Time_Sec
	cmp		#00
	bne		L_Snooze_CloseLoud
L_AlarmTrigger:
	smb7	Timer_Flag
	TMR0_ON
	smb2	Clock_Flag							; ��������ģʽ�ͷ�������ʱTIM0
L_Alarm_NoStop:
	bbs5	Clock_Flag,L_AlarmTrigger_Exit
	smb5	Clock_Flag							; ��������ģʽ��ֵ,�������ֽ���״̬��δ����״̬
L_AlarmTrigger_Exit:
	rts
L_Snooze_CloseLoud:
	bbr5	Clock_Flag,L_CloseLoud				; last==1 && now==0
	rmb5	Clock_Flag							; ���ֽ���״̬ͬ������ģʽ�ı���ֵ
	bbr6	Clock_Flag,L_NoSnooze_CloseLoud		; û��̰˯��������&&̰˯ģʽ&&���ֽ���״̬�Ż���Ȼ����̰˯ģʽ
	rmb6	Clock_Flag							; ��̰˯��������
	bra		L_CloseLoud
L_NoSnooze_CloseLoud:							; ����̰˯ģʽ���ر�����
	rmb3	Clock_Flag
	rmb6	Clock_Flag
L_CloseLoud:
	rmb2	Clock_Flag							; �ر�����ģʽ
	rmb5	Clock_Flag
	rmb7	TMRC
	PB3_PB3_COMS
	rmb3	PB
	rmb6	Timer_Flag
	rmb7	Timer_Flag
	TMR0_OFF
	rts


L_Alarm_Process:
	bbs7	Timer_Flag,L_BeepStart				; ÿS��һ��
	rts
L_BeepStart:
	rmb7	Timer_Flag
	inc		AlarmLoud_Counter					; ����1�μ�1�������
	lda		AlarmLoud_Counter
	cmp		#11
	bcs		No_Loud_Serial_2
	lda		#2									; 0-10S���ֵ�����Ϊ2��1��
	sta		Beep_Serial
	rmb4	Clock_Flag							; 0-30SΪ��������
	bra		L_Alarm_Exit
No_Loud_Serial_2:
	cmp		#21
	bcs		No_Loud_Serial_4
	lda		#4									; 10-20S���ֵ�����Ϊ4��2��
	sta		Beep_Serial
	rmb4	Clock_Flag
	bra		L_Alarm_Exit
No_Loud_Serial_4:
	cmp		#31
	bcs		No_Loud_Serial_8
	lda		#8									; 20-30S���ֵ�����Ϊ8��4��
	sta		Beep_Serial
	rmb4	Clock_Flag
	bra		L_Alarm_Exit
No_Loud_Serial_8:
	smb4	Clock_Flag							; 30S����ʹ�ó�������

L_Alarm_Exit:
	rts


F_Louding:
	bbs6	Timer_Flag,L_Beeping
	rts
L_Beeping:
	rmb6	Timer_Flag
	bbs4	Clock_Flag,L_ConstBeep_Mode
	lda		Beep_Serial							; ��������ģʽ
	cmp		#0
	beq		L_NoBeep_Serial_Mode
	dec		Beep_Serial
	bbr0	Beep_Serial,L_NoBeep_Serial_Mode
	smb0	SYSCLK
	PB3_PWM
	smb7	TMRC
	rts
L_NoBeep_Serial_Mode:
	rmb7	TMRC
	PB3_PB3_COMS
	rmb3	PB
	rmb0	SYSCLK
	rts

L_ConstBeep_Mode:
	lda		Beep_Serial							; ��������ģʽ
	eor		#01B								; Beep_Serial��ת��һλ
	sta		Beep_Serial

	lda		Beep_Serial
	bbr0	Beep_Serial,L_NoBeep_Const_Mode
	smb0	SYSCLK
	PB3_PWM
	smb7	TMRC
	rts
L_NoBeep_Const_Mode:
	rmb7	TMRC
	PB3_PB3_COMS
	rmb3	PB
	bbs0	Test_Flag,L_ConstBeep_Exit
	rmb0	SYSCLK
L_ConstBeep_Exit:
	rts