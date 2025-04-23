; ������ʱģʽ�İ�������
F_KeyTrigger_RunTimeMode2:
	bbs0	Key_Flag,L_KeyTrigger_RunTimeMode2
	rts
L_KeyTrigger_RunTimeMode2:
	rmb0	Key_Flag
	rmb1	Key_Flag
	TMR1_OFF									; û�п�ӹ��ܲ���Ҫ��Timer1��8Hz��ʱ
	jsr		L_KeyDelay							; �������

	lda		PA
	and		#$fc
	cmp		#$80
	bne		No_KeySTrigger_RunTimeMode2			; ������תָ��Ѱַ���������⣬�������jmp������ת
	jmp		L_KeySTrigger_RunTimeMode2			; on/off Alarm����
No_KeySTrigger_RunTimeMode2:
	cmp		#$40
	bne		No_KeyTTrigger_RunTimeMode2
	jmp		L_KeyTTrigger_RunTimeMode2			; Time_Set����
No_KeyTTrigger_RunTimeMode2:
	cmp		#$20
	bne		No_KeyMTrigger_RunTimeMode2
	jmp		L_KeyMTrigger_RunTimeMode2			; Min����
No_KeyMTrigger_RunTimeMode2:
	cmp		#$10
	bne		No_KeyATrigger_RunTimeMode2
	jmp		L_KeyATrigger_RunTimeMode2			; Alarm_Set����
No_KeyATrigger_RunTimeMode2:
	cmp		#$08
	bne		No_KeyHTrigger_RunTimeMode2
	jmp		L_KeyHTrigger_RunTimeMode2			; Hour����
No_KeyHTrigger_RunTimeMode2:
	cmp		#$04
	bne		L_KeyExit_RunTimeMode2
	jmp		L_KeyBTrigger_RunTimeMode2			; Backlight/Snooze����

L_KeyExit_RunTimeMode2:
	rts


L_KeyTTrigger_RunTimeMode2:
	lda		#0100B
	sta		Sys_Status_Flag
	rmb1	Key_Flag							; ����ʱ������ģʽ�Ĵ���
	sta		AlarmLoud_Counter					; ����������
	jsr		L_NoSnooze_CloseLoud2				; ���������ʱ��16Hz��ʱ�����������̰˯�ȱ�־λ
	smb6	IER									; ��LCD�жϣ������пպ����ļ�ʱ��Ӧ
	pla
	pla
	jmp		MainLoop2

L_KeyHTrigger_RunTimeMode2:
	bra		L_KeyBTrigger_RunTimeMode2

L_KeyBTrigger_RunTimeMode2:
	smb3	Key_Flag							; ���⼤�ͬʱ����̰˯
	smb3	PB
	lda		#0									; ÿ�ΰ����ⶼ�����ü�ʱ
	sta		Backlight_Counter
	bbs2	Clock_Flag,L_KeyBTrigger_NoLoud2	; �������������ģʽ�£����˳�̰˯
	jsr		L_NoSnooze_CloseLoud2
	rts
L_KeyBTrigger_NoLoud2:
	smb6	Clock_Flag							; ̰˯��������						
	smb3	Clock_Flag							; ����̰˯ģʽ

	lda		R_Snooze_Min						; ̰˯���ӵ�ʱ���5
	clc
	adc		#8
	cmp		#60
	bcs		L_Snooze_OverflowMin2
	sta		R_Snooze_Min
	bra		L_KeyBTrigger_Exit2
L_Snooze_OverflowMin2:
	sec
	sbc		#60
	sta		R_Snooze_Min						; ����̰˯���ֵķ��ӽ�λ
	inc		R_Snooze_Hour
	lda		R_Snooze_Hour
	cmp		#24
	bcc		L_KeyBTrigger_Exit2
	lda		#00									; ����̰˯Сʱ��λ
	sta		R_Snooze_Hour
L_KeyBTrigger_Exit2:
	rts

L_KeyMTrigger_RunTimeMode2:
	bra		L_KeyBTrigger_RunTimeMode2

L_KeyATrigger_RunTimeMode2:
	lda		#1000B
	sta		Sys_Status_Flag
	rmb1	Key_Flag							; ���״δ������ȴ���������ģʽ���׸�����
	jsr		F_Display_Alarm2
	lda		#00
	sta		AlarmLoud_Counter					; ����������
	jsr		L_NoSnooze_CloseLoud2				; ���������ʱ��16Hz��ʱ�����������̰˯�ȱ�־λ
	smb6	IER									; ��LCD�жϣ������пպ����ļ�ʱ��Ӧ
	pla
	pla
	jmp		MainLoop2

L_KeySTrigger_RunTimeMode2:
	bbs2	Clock_Flag,L_LoundSnz_Handle12		; ��������ģʽ��̰˯ģʽ�����л�ʱ��ģʽ��ֻ������ֺ�̰˯
	bbs3	Clock_Flag,L_LoundSnz_Handle12
	lda		Clock_Flag							; ÿ��һ�η�ת����ģʽ��״̬
	eor		#0010B
	sta		Clock_Flag
	bbr1	Clock_Flag,L_Alarm_off_RunTime
	ldx		#lcd2_bell
	jsr		F_DispSymbol2
	ldx		#lcd2_Zz
	jsr		F_DispSymbol2
L_LoundSnz_Handle12:
	jsr		L_NoSnooze_CloseLoud2
	rts
L_Alarm_off_RunTime:
	ldx		#lcd2_bell
	jsr		F_ClrpSymbol2
	ldx		#lcd2_Zz
	jsr		F_ClrpSymbol2
	jsr		L_NoSnooze_CloseLoud2
	rts




; ʱ������ģʽ�İ�������
F_KeyTrigger_TimeSetMode2:
	bbs3	Timer_Flag,L_Key4Hz_TimeSetMode2	; �п����ֱ���ж�4Hz��־λ
	bbr1	Key_Flag,L_KeyScan_TimeSetMode2		; �״ΰ�������
	rmb1	Key_Flag
	lda		#$00
	sta		P_Temp
L_DelayTrigger_TimeSetMode2						; ������ʱѭ���ñ�ǩ
	inc		P_Temp
	lda		P_Temp
	bne		L_DelayTrigger_TimeSetMode2			; �������
	lda		PA
	and		#$ac
	cmp		#$00
	bne		L_KeyYes_TimeSetMode2				; ����Ƿ��а�������
	bra		L_KeyExit_TimeSetMode2
	rts
L_KeyYes_TimeSetMode2:
	sta		PA_IO_Backup
	bra		L_KeyHandle_TimeSetMode2			; �״δ����������

L_Key4Hz_TimeSetMode2:
	bbr2	Key_Flag,L_Key4HzExit_TimeSetMode2
	rmb2	Key_Flag
L_KeyScan_TimeSetMode2:							; ����������
	bbr0	Key_Flag,L_KeyExit_TimeSetMode2		; û��ɨ����־ֱ���˳�

	bbr4	Timer_Flag,L_Key4HzExit_TimeSetMode2; 8Hz��־λ����ǰҲ�����а�������(�����)
	rmb4	Timer_Flag
	lda		PA
	and		#$ac
	cmp		PA_IO_Backup						; ����⵽�а�����״̬�仯���˳�����жϲ�����
	beq		L_4Hz_Count_TimeSetMode2
	bra		L_KeyExit_TimeSetMode2
	rts
L_4Hz_Count_TimeSetMode2:
	inc		QuickAdd_Counter
	lda		QuickAdd_Counter
	cmp		#24
	bcs		L_QuikAdd_TimeSetMode2
	rts											; ������ʱ��������1.5S���п��
L_QuikAdd_TimeSetMode2:
	smb3	Timer_Flag
	rmb2	Key_Flag

L_KeyHandle_TimeSetMode2:
	lda		PA
	and		#$ac
	cmp		#$80
	bne		No_KeySTrigger_TimeSetMode2			; ������תָ��Ѱַ���������⣬�������jmp������ת
	jmp		L_KeySTrigger_TimeSetMode2			; on/off Alarm����
No_KeySTrigger_TimeSetMode2:
	cmp		#$20
	bne		No_KeyMTrigger_TimeSetMode2
	jmp		L_KeyMTrigger_TimeSetMode2			; Min����
No_KeyMTrigger_TimeSetMode2:
	cmp		#$08
	bne		No_KeyHTrigger_TimeSetMode2
	jmp		L_KeyHTrigger_TimeSetMode2			; Hour����
No_KeyHTrigger_TimeSetMode2:
	cmp		#$04
	bne		L_KeyExit_TimeSetMode2
	jmp		L_KeyBTrigger_TimeSetMode2			; Backlight/Snooze����

L_KeyExit_TimeSetMode2:
	TMR1_OFF									; �رտ��8Hz��ʱ�Ķ�ʱ��
	rmb0	Key_Flag							; ����ر�־λ
	rmb3	Timer_Flag
	lda		#0									; ������ر���
	sta		QuickAdd_Counter
L_Key4HzExit_TimeSetMode2:
	rts

L_KeyMTrigger_TimeSetMode2:
	lda		#01
	sta		R_Time_Sec							; �����ӻ���S����
	inc		R_Time_Min
	lda		#59
	cmp		R_Time_Min
	bcs		L_MinSet_Juge2
	lda		#00
	sta		R_Time_Min
L_MinSet_Juge2:
	jsr		L_DisTime_Min2
	bra		L_KeyBTrigger_TimeSetMode2			; MҲ�ᴥ������

L_KeyHTrigger_TimeSetMode2:
	inc		R_Time_Hour
	lda		#23
	cmp		R_Time_Hour
	bcs		L_HourSet_Juge2
	lda		#00
	sta		R_Time_Hour
L_HourSet_Juge2:
	jsr		L_DisTime_Hour2						; HҲ�ᴥ������

L_KeyBTrigger_TimeSetMode2:
	jmp		L_KeyBTrigger_RunTimeMode2
	rts

L_KeySTrigger_TimeSetMode2:
	bbs2	Clock_Flag,L_LoundSnz_Handle22		; ��������ģʽ��̰˯ģʽ�����л�ʱ��ģʽ��ֻ������ֺ�̰˯
	bbs3	Clock_Flag,L_LoundSnz_Handle22
	lda		Clock_Flag							; ÿ��һ�η�ת����ģʽ��״̬
	eor		#0010B
	sta		Clock_Flag
	bbr1	Clock_Flag,L_Alarm_off_TimeSet
	ldx		#lcd2_bell
	jsr		F_DispSymbol2
	ldx		#lcd2_Zz
	jsr		F_DispSymbol2
L_LoundSnz_Handle22:
	jsr		L_NoSnooze_CloseLoud2
	rts
L_Alarm_off_TimeSet:
	ldx		#lcd2_bell
	jsr		F_ClrpSymbol2
	ldx		#lcd2_Zz
	jsr		F_ClrpSymbol2
	rts

F_Is_KeyTKeep:
	bbs3	Timer_Flag,L_QA_KeyTKeep			; �п��ʱ���˳�
	bbr6	PA,L_NoKeyT_Keep
L_QA_KeyTKeep:
	rts
L_NoKeyT_Keep:
	TMR1_OFF									; �رտ��8Hz��ʱ�Ķ�ʱ��
	rmb0	Key_Flag							; ����ر�־λ
	rmb3	Timer_Flag
	rmb6	IER
	lda		#0									; ������ر���
	sta		QuickAdd_Counter
	lda		#0001B								; �ص���ʱģʽ
	sta		Sys_Status_Flag
	jsr		F_Display_Time2
	jsr		L_NoSnooze_CloseLoud2
	rts




; ��������ģʽ�İ�������
F_KeyTrigger_AlarmSetMode2:
	bbs3	Timer_Flag,L_Key4Hz_AlarmSetMode2	; �п����ֱ���ж�4Hz��־λ
	bbr1	Key_Flag,L_KeyScan_AlarmSetMode2	; �״ΰ�������
	rmb1	Key_Flag
	lda		#$00
	sta		P_Temp
L_DelayTrigger_AlarmSetMode2:					; ������ʱѭ���ñ�ǩ
	inc		P_Temp
	lda		P_Temp
	bne		L_DelayTrigger_AlarmSetMode2		; �������
	lda		PA
	and		#$ac
	cmp		#$00
	bne		L_KeyYes_AlarmSetMode2				; ����Ƿ��а�������
	bra		L_KeyExit_AlarmSetMode2
	rts
L_KeyYes_AlarmSetMode2:
	sta		PA_IO_Backup
	bra		L_KeyHandle_AlarmSetMode2			; �״δ����������

L_Key4Hz_AlarmSetMode2:
	bbr2	Key_Flag,L_Key4HzExit_AlarmSetMode2
	rmb2	Key_Flag
L_KeyScan_AlarmSetMode2:						; ����������
	bbr0	Key_Flag,L_KeyExit_AlarmSetMode2	; û��ɨ����־ֱ���˳�

	bbr4	Timer_Flag,L_Key4HzExit_AlarmSetMode2; 8Hz��־λ����ǰҲ�����а�������(�����)
	rmb4	Timer_Flag
	lda		PA
	and		#$ac
	cmp		PA_IO_Backup						; ����⵽�а�����״̬�仯���˳�����жϲ�����
	beq		L_4Hz_Count_AlarmSetMode2
	bra		L_KeyExit_AlarmSetMode2
	rts
L_4Hz_Count_AlarmSetMode2:
	inc		QuickAdd_Counter
	lda		QuickAdd_Counter
	cmp		#24
	bcs		L_QuikAdd_AlarmSetMode2
	rts											; ������ʱ��������1.5S���п��
L_QuikAdd_AlarmSetMode2:
	smb3	Timer_Flag
	rmb2	Key_Flag

L_KeyHandle_AlarmSetMode2:
	lda		PA
	and		#$ac
	cmp		#$80
	bne		No_KeySTrigger_AlarmSetMode2		; ������תָ��Ѱַ���������⣬�������jmp������ת
	jmp		L_KeySTrigger_AlarmSetMode2			; on/off Alarm����
No_KeySTrigger_AlarmSetMode2:
	cmp		#$20
	bne		No_KeyMTrigger_AlarmSetMode2
	jmp		L_KeyMTrigger_AlarmSetMode2			; Min����
No_KeyMTrigger_AlarmSetMode2:
	cmp		#$08
	bne		No_KeyHTrigger_AlarmSetMode2
	jmp		L_KeyHTrigger_AlarmSetMode2			; Hour����
No_KeyHTrigger_AlarmSetMode2:
	cmp		#$04
	bne		L_KeyExit_AlarmSetMode2
	jmp		L_KeyBTrigger_AlarmSetMode2			; Backlight/Snooze����

L_KeyExit_AlarmSetMode2:
	TMR1_OFF									; �رտ��8Hz��ʱ�Ķ�ʱ��
	rmb0	Key_Flag							; ����ر�־λ
	rmb3	Timer_Flag
	lda		#0									; ������ر���
	sta		QuickAdd_Counter
L_Key4HzExit_AlarmSetMode2:
	rts


L_KeyMTrigger_AlarmSetMode2:
	inc		R_Alarm_Min
	lda		#59
	cmp		R_Alarm_Min
	bcs		L_AlarmMinSet_Juge2
	lda		#00
	sta		R_Alarm_Min
L_AlarmMinSet_Juge2:
	jsr		L_DisAlarm_Min2
	bra		L_KeyBTrigger_AlarmSetMode2			; M����Ҳ�ᴥ������
L_KeyHTrigger_AlarmSetMode2:
	inc		R_Alarm_Hour
	lda		#23
	cmp		R_Alarm_Hour
	bcs		L_AlarmHourSet_Juge2
	lda		#00
	sta		R_Alarm_Hour
L_AlarmHourSet_Juge2:
	jsr		L_DisAlarm_Hour2					; H����Ҳ�ᴥ������
L_KeyBTrigger_AlarmSetMode2:
	jmp		L_KeyBTrigger_RunTimeMode2
	rts
L_KeySTrigger_AlarmSetMode2:
	bbs2	Clock_Flag,L_LoundSnz_Handle32		; ��������ģʽ��̰˯ģʽ�����л�ʱ��ģʽ��ֻ������ֺ�̰˯
	bbs3	Clock_Flag,L_LoundSnz_Handle32
	lda		Clock_Flag							; ÿ��һ�η�ת����ģʽ��״̬
	eor		#0010B
	sta		Clock_Flag
	bbr1	Clock_Flag,L_Alarm_off_AlarmSet
	ldx		#lcd2_bell
	jsr		F_DispSymbol2
	ldx		#lcd2_Zz
	jsr		F_DispSymbol2
L_LoundSnz_Handle32:
	jsr		L_NoSnooze_CloseLoud2
	rts
L_Alarm_off_AlarmSet:
	ldx		#lcd2_bell
	jsr		F_ClrpSymbol2
	ldx		#lcd2_Zz
	jsr		F_ClrpSymbol2
	rts

F_Is_KeyAKeep:
	bbs3	Timer_Flag,L_QA_KeyAKeep			; �п��ʱ���˳�
	bbr4	PA,L_NoKeyA_Keep
L_QA_KeyAKeep:
	rts
L_NoKeyA_Keep:
	lda		Timer_Flag
	TMR1_OFF									; �رտ��8Hz��ʱ�Ķ�ʱ��
	rmb0	Key_Flag							; ����ر�־λ
	rmb3	Timer_Flag
	lda		#0									; ������ر���
	sta		QuickAdd_Counter
	lda		#0001B								; �ص���ʱģʽ
	sta		Sys_Status_Flag
	jsr		F_Display_Time2
	jsr		L_NoSnooze_CloseLoud2
	rts
