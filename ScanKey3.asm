; ����ֻ����״̬�仯������Ҫ�����������
F_Switch_Scan3:									; ����������Ҫɨ�账��
	jsr		F_SwitchPort_ScanReady
	jsr		F_Delay
	lda		PC
	cmp		PC_IO_Backup						; �ж�IO��״̬�Ƿ����ϴ���ͬ
	bne		L_Switch_Delay3						; �����ͬ˵������״̬�иı䣬������
	jsr		F_SwitchPort_ScanReset				; ����©��
	rts
L_Switch_Delay3:
	lda		#$00
	sta		P_Temp
L_Delay_S3:										; ������ʱѭ���ñ�ǩ
	inc		P_Temp
	lda		P_Temp
	bne		L_Delay_S3							; �������

	lda		PC_IO_Backup
	cmp		PC
	bne		L_Switched3

	jsr		F_SwitchPort_ScanReset				; ����©��
	rts
L_Switched3:									; ��⵽IO��״̬���ϴεĲ�ͬ������벦������
	lda		PC
	sta		PC_IO_Backup						; ���±����IO��״̬

	and		#$04
	cmp		#$04
	bne		Alarm_OFF3
	jsr		Switch_Alarm_ON3
	bra		Alarm_ON3
Alarm_OFF3:
	jsr		Switch_Alarm_OFF3
	bra		Sys_Mode_Process3
Alarm_ON3:
	jsr		Switch_Alarm_ON3
Sys_Mode_Process3:
	lda		PC
	and		#$38
	cmp		#$00
	bne		No_Runtime_Mode3
	jmp		Switch_Runtime_Mode3
No_Runtime_Mode3:
	lda		PC
	and		#$08
	cmp		#$08
	bne		No_Date_Set_Mode3
	jmp		Switch_Date_Set_Mode3
No_Date_Set_Mode3:
	lda		PC
	and		#$10
	cmp		#$10
	bne		No_Time_Set_Mode3
	jmp		Switch_Time_Set_Mode3
No_Time_Set_Mode3:
	lda		PC
	and		#$20
	cmp		#$20
	bne		No_Alarm_Set_Mode3
	jmp		Switch_Alarm_Set_Mode3
No_Alarm_Set_Mode3:
	jsr		F_SwitchPort_ScanReset				; ����©��
	rts 

; ���ӿ�����رղ�������
Switch_Alarm_ON3:
	smb1	Clock_Flag
	ldx		#lcd3_bell
	jsr		F_DispSymbol3
	ldx		#lcd3_Zz
	jsr		F_DispSymbol3
	rts
Switch_Alarm_OFF3:
	rmb1	Clock_Flag
	ldx		#lcd3_bell
	jsr		F_ClrpSymbol3
	ldx		#lcd3_Zz
	jsr		F_ClrpSymbol3
	jsr		L_NoSnooze_CloseLoud				; ������ֺ�̰˯
	rts

; ����ģʽ�л��Ĳ�������
Switch_Runtime_Mode3:
	lda		#0001B
	sta		Sys_Status_Flag
	jsr		F_Display_All3
	jsr		F_SwitchPort_ScanReset				; ����©��
	rts
Switch_Date_Set_Mode3:
	lda		#0010B
	sta		Sys_Status_Flag
	jsr		L_DisDate_Year3
	jsr		F_Display_Date3
	jsr		F_UnDisplay_InDateMode3				; ��������ģʽ��ֹͣ��ʾһЩ����
	jsr		L_NoSnooze_CloseLoud				; ������ֺ�̰˯
	jsr		F_SwitchPort_ScanReset				; ����©��
	rts
Switch_Time_Set_Mode3:
	lda		#0100B
	sta		Sys_Status_Flag
	jsr		F_Display_All3
	jsr		L_NoSnooze_CloseLoud				; ������ֺ�̰˯
	jsr		F_SwitchPort_ScanReset				; ����©��
	rts
Switch_Alarm_Set_Mode3:
	lda		#1000B
	sta		Sys_Status_Flag
	jsr		F_Display_Alarm3
	jsr		F_Display_Date3
	ldx		#lcd3_ALM
	jsr		F_DispSymbol3
	jsr		L_NoSnooze_CloseLoud				; ������ֺ�̰˯
	jsr		F_SwitchPort_ScanReset				; ����©��
	rts



; ������ʱģʽ�İ�������
F_KeyTrigger_RunTimeMode3:
	bbs0	Key_Flag,L_KeyTrigger_RunTimeMode3
	rts
L_KeyTrigger_RunTimeMode3:
	rmb0	Key_Flag
	TMR1_OFF									; û�п�ӹ��ܲ���Ҫ��Timer1��8Hz��ʱ
	lda		#$00
	sta		P_Temp
L_DelayTrigger_RunTimeMode3:					; ������ʱѭ���ñ�ǩ
	inc		P_Temp
	lda		P_Temp
	bne		L_DelayTrigger_RunTimeMode3			; �������

	lda		PA									; ������ʱģʽ��ֻ��2����������Ӧ
	and		#$f0
	cmp		#$80
	bne		No_KeyHTrigger_RunTimeMode3			; ������תָ��Ѱַ���������⣬�������jmp������ת
	jmp		L_KeyHTrigger_RunTimeMode3			; Month/Hour��������
No_KeyHTrigger_RunTimeMode3:
	cmp		#$40
	bne		No_KeyMTrigger_RunTimeMode3
	jmp		L_KeyMTrigger_RunTimeMode3			; Date/Min��������
No_KeyMTrigger_RunTimeMode3:
	cmp		#$20
	bne		No_KeySTrigger_RunTimeMode3
	jmp		L_KeySTrigger_RunTimeMode3			; 12/24h & year����
No_KeySTrigger_RunTimeMode3:
	cmp		#$10
	bne		L_KeyExit_RunTimeMode3
	jmp		L_KeyBTrigger_RunTimeMode3			; Backlight & SNZ����

L_KeyExit_RunTimeMode3:
	rts

L_KeyMTrigger_RunTimeMode3:						; ����ʱģʽ�£�M��H����ֻ����̰˯��һ������
L_KeyHTrigger_RunTimeMode3:
	jsr		L_NoSnooze_CloseLoud
	rts

L_KeyBTrigger_RunTimeMode3:
	smb3	Key_Flag							; ���⼤�ͬʱ����̰˯
	smb2	PB
	lda		#0									; ÿ�ΰ����ⶼ�����ü�ʱ
	sta		Backlight_Counter
	bbr2	Clock_Flag,L_KeyBTrigger_Exit3		; �������������ģʽ�£��򲻻ᴦ��̰˯
	smb6	Clock_Flag							; ̰˯��������						
	smb3	Clock_Flag							; ����̰˯ģʽ

	lda		R_Snooze_Min						; ̰˯���ӵ�ʱ���5
	clc
	adc		#5
	cmp		#60
	bcs		L_Snooze_OverflowMin3
	sta		R_Snooze_Min
	bra		L_KeyBTrigger_Exit3
L_Snooze_OverflowMin3:
	sec
	sbc		#60
	sta		R_Snooze_Min						; ����̰˯���ֵķ��ӽ�λ
	inc		R_Snooze_Hour
	lda		R_Snooze_Hour
	cmp		#24
	bcc		L_KeyBTrigger_Exit3
	lda		#00									; ����̰˯Сʱ��λ
	sta		R_Snooze_Hour
L_KeyBTrigger_Exit3:
	rts

L_KeySTrigger_RunTimeMode3:
	bbs2	Clock_Flag,L_LoundSnz_Handle3		; ��������ģʽ��̰˯ģʽ�����л�ʱ��ģʽ��ֻ������ֺ�̰˯
	bbs3	Clock_Flag,L_LoundSnz_Handle3
	lda		Clock_Flag							; ÿ��һ�η�תclock_flag bit0״̬
	eor		#$01
	sta		Clock_Flag
	jsr		F_Display_Time3
L_LoundSnz_Handle3:
	jsr		L_NoSnooze_CloseLoud				; ������ֺ�̰˯
	rts



; ��������ģʽ�İ�������
F_KeyTrigger_DateSetMode3:
	bbs3	Timer_Flag,L_Key4Hz_DateSetMode3	; �п����ֱ���ж�4Hz��־λ
	bbr1	Key_Flag,L_KeyScan_DateSetMode3		; �״ΰ�������
	rmb1	Key_Flag
	lda		#$00
	sta		P_Temp
L_DelayTrigger_DateSetMode3:					; ������ʱѭ���ñ�ǩ
	inc		P_Temp
	lda		P_Temp
	bne		L_DelayTrigger_DateSetMode3			; �������
	lda		PA
	and		#$f0
	cmp		#$00
	bne		L_KeyYes_DateSetMode3				; ����Ƿ��а�������
	bra		L_KeyExit_DateSetMode3
	rts
L_KeyYes_DateSetMode3:
	sta		PA_IO_Backup
	bra		L_KeyHandle_DateMode3				; �״δ����������

L_Key4Hz_DateSetMode3:
	bbr2	Key_Flag,L_Key4HzExit_DateSetMode3
	rmb2	Key_Flag
L_KeyScan_DateSetMode3:							; ����������
	bbr0	Key_Flag,L_KeyExit_DateSetMode3		; û��ɨ����־ֱ���˳�

	jsr		F_QuikAdd_ScanReady					; ����Ϊ����
	jsr		F_Delay
	bbr4	Timer_Flag,L_Key4HzExit_DateSetMode3; 8Hz��־λ����ǰҲ�����а�������(�����)
	rmb4	Timer_Flag
	lda		PA
	and		#$f0
	cmp		PA_IO_Backup						; ����⵽�а�����״̬�仯���˳�����жϲ�����
	beq		L_4Hz_Count_DateSetMode3
	bra		L_KeyExit_DateSetMode3
	rts
L_4Hz_Count_DateSetMode3:
	inc		QuickAdd_Counter
	lda		QuickAdd_Counter
	cmp		#24
	bcs		L_QuikAdd_DateSetMode3
	rts											; ������ʱ��������1S���п��
L_QuikAdd_DateSetMode3:
	smb3	Timer_Flag
	rmb2	Key_Flag

L_KeyHandle_DateMode3:
	lda		PA									; �ж�4�ְ����������
	and		#$f0
	cmp		#$80
	bne		No_KeyHTrigger_DateSetMode3			; ������תָ��Ѱַ���������⣬�������jmp������ת
	jmp		L_KeyHTrigger_DateSetMode3			; Month��������
No_KeyHTrigger_DateSetMode3:
	cmp		#$40
	bne		No_KeyMTrigger_DateSetMode3
	jmp		L_KeyMTrigger_DateSetMode3			; Date��������
No_KeyMTrigger_DateSetMode3:
	cmp		#$20
	bne		No_KeySTrigger_DateSetMode3
	jmp		L_KeySTrigger_DateSetMode3			; year����
No_KeySTrigger_DateSetMode3:
	cmp		#$10
	bne		L_KeyExit_DateSetMode3
	jmp		L_KeyBTrigger_DateSetMode3			; Backlight��������

L_KeyExit_DateSetMode3:
	TMR1_OFF									; �رտ��8Hz��ʱ�Ķ�ʱ��
	rmb0	Key_Flag							; ����ر�־λ
	rmb3	Timer_Flag
	lda		#0									; ������ر���
	sta		QuickAdd_Counter
L_Key4HzExit_DateSetMode3:
	jsr		F_QuikAdd_ScanReady					; ����Ϊ����
	rts


L_KeyMTrigger_DateSetMode3:
	jsr		F_QuikAdd_ScanReset					; �п�ӵ������Ҫ����IO��Ϊ����߱���©��
	jsr		F_Is_Leap_Year
	ldx		R_Date_Month						; �·�����Ϊ���������·�������
	dex											; ��ͷ��0��ʼ�����·��Ǵ�1��ʼ
	bbs0	Calendar_Flag,L_Leap_Year_Set3		; ����������·�������
	lda		L_Table_Month_Common,x				; �����ƽ���·�������
	bra		L_Day_Juge_Set3
L_Leap_Year_Set3:
	lda		L_Table_Month_Leap,x
L_Day_Juge_Set3:
	cmp		R_Date_Day
	bne		L_Day_Add_Set3
	lda		#1
	sta		R_Date_Day							; �ս�λ�����»ص�1
	jsr		F_Display_Date3						; ��ʾ�����������
	rts
L_Day_Add_Set3:
	inc		R_Date_Day
	jsr		F_Display_Date3						; ��ʾ�����������
	rts

L_KeyHTrigger_DateSetMode3:
	jsr		F_QuikAdd_ScanReset					; �п�ӵ������Ҫ����IO��Ϊ����߱���©��
	lda		R_Date_Month
	cmp		#12
	bcc		L_Month_Juge3
	lda		#1
	sta		R_Date_Month
	jsr		F_Display_Date3
	rts
L_Month_Juge3:
	inc		R_Date_Month						; �����·�
	jsr		F_Is_Leap_Year						; ����������·���������û��Խ��
	ldx		R_Date_Month						; �·�����Ϊ���������·�������
	dex											; ��ͷ��0��ʼ�����·��Ǵ�1��ʼ
	bbs0	Calendar_Flag,L_Leap_Year_Set13		; ����������·�������
	lda		L_Table_Month_Common,x				; �����ƽ���·�������
	bra		L_Day_Juge_Set13
L_Leap_Year_Set13:
	lda		L_Table_Month_Leap,x
L_Day_Juge_Set13:
	cmp		R_Date_Day
	bcs		L_Month_Add_Set3
	lda		#1
	sta		R_Date_Day							; ��������͵�ǰ�·�����ƥ�䣬���ʼ������
L_Month_Add_Set3:
	jsr		F_Display_Date3
	rts

L_KeyBTrigger_DateSetMode3:
	smb3	Key_Flag							; ���⼤��
	smb2	PB
	lda		#0
	sta		Backlight_Counter					; ÿ�ΰ����ⶼ�����ü�ʱ
	rts

L_KeySTrigger_DateSetMode3:
	jsr		F_QuikAdd_ScanReset					; �п�ӵ������Ҫ����IO��Ϊ����߱���©��
	lda		R_Date_Year
	cmp		#99
	bcc		L_Year_Juge3
	lda		#0
	sta		R_Date_Year
	jsr		L_DisDate_Year3
	rts
L_Year_Juge3:
	inc		R_Date_Year							; �������
	jsr		F_Is_Leap_Year						; ��������������������û��Խ��
	ldx		R_Date_Month						; �·�����Ϊ���������·�������
	dex											; ��ͷ��0��ʼ�����·��Ǵ�1��ʼ
	bbs0	Calendar_Flag,L_Leap_Year_Set23		; ����������·�������
	lda		L_Table_Month_Common,x				; �����ƽ���·�������
	bra		L_Day_Juge_Set23
L_Leap_Year_Set23:
	lda		L_Table_Month_Leap,x
L_Day_Juge_Set23:
	cmp		R_Date_Day
	bcs		L_Year_Add_Set3
	lda		#1
	sta		R_Date_Day							; �������������ǰ�·����ֵ�����ʼ������
L_Year_Add_Set3:
	jsr		L_DisDate_Year3
	rts



; ʱ������ģʽ�İ�������
F_KeyTrigger_TimeSetMode3:
	bbs3	Timer_Flag,L_Key4Hz_TimeSetMode3	; �п����ֱ���ж�8Hz��־λ
	bbr1	Key_Flag,L_KeyScan_TimeSetMode3		; �״ΰ�������
	rmb1	Key_Flag
	lda		#$00
	sta		P_Temp
L_DelayTrigger_TimeSetMode3:					; ������ʱѭ���ñ�ǩ
	inc		P_Temp
	lda		P_Temp
	bne		L_DelayTrigger_TimeSetMode3			; �������
	lda		PA
	and		#$f0
	cmp		#$00
	bne		L_KeyYes_TimeSetMode3				; ����Ƿ��а�������
	bra		L_KeyExit_TimeSetMode3
	rts
L_KeyYes_TimeSetMode3:
	sta		PA_IO_Backup
	bra		L_KeyHandle_TimeSetMode3			; �״δ����������

L_Key4Hz_TimeSetMode3:
	bbr2	Key_Flag,L_Key4HzExit_TimeSetMode3
	rmb2	Key_Flag
L_KeyScan_TimeSetMode3:							; ����������
	bbr0	Key_Flag,L_KeyExit_TimeSetMode3		; û��ɨ����־ֱ���˳�

	jsr		F_QuikAdd_ScanReady					; ����Ϊ����
	jsr		F_Delay
	bbr4	Timer_Flag,L_Key4HzExit_TimeSetMode3; 8Hz��־λ����ǰҲ�����а�������(�����)
	rmb4	Timer_Flag
	lda		PA
	and		#$f0
	cmp		PA_IO_Backup						; ����⵽�а�����״̬�仯���˳�����жϲ�����
	beq		L_4Hz_Count_TimeSetMode3
	bra		L_KeyExit_TimeSetMode3
	rts
L_4Hz_Count_TimeSetMode3:
	inc		QuickAdd_Counter
	lda		QuickAdd_Counter
	cmp		#24
	bcs		L_QuikAdd_TimeSetMode3
	rts											; ������ʱ��������1S���п��
L_QuikAdd_TimeSetMode3:
	smb3	Timer_Flag
	rmb2	Key_Flag

L_KeyHandle_TimeSetMode3:
	lda		PA									; �ж�4�ְ����������
	and		#$f0
	cmp		#$80
	bne		No_KeyHTrigger_TimeSetMode3			; ������תָ��Ѱַ���������⣬�������jmp������ת
	jmp		L_KeyHTrigger_TimeSetMode3			; Hour��������
No_KeyHTrigger_TimeSetMode3:
	cmp		#$40
	bne		No_KeyMTrigger_TimeSetMode3
	jmp		L_KeyMTrigger_TimeSetMode3			; Min��������
No_KeyMTrigger_TimeSetMode3:
	bbs3	Timer_Flag,L_KeyExit_TimeSetMode3	; �����12hģʽ�л�����Ҫ���
	cmp		#$20
	bne		No_KeySTrigger_TimeSetMode3
	jmp		L_KeySTrigger_TimeSetMode3			; 12/24h����
No_KeySTrigger_TimeSetMode3:
	cmp		#$10
	bne		L_KeyExit_TimeSetMode3
	jmp		L_KeyBTrigger_TimeSetMode3			; Backlight/SNZ��������

L_KeyExit_TimeSetMode3:
	TMR1_OFF									; �رտ��8Hz��ʱ�Ķ�ʱ��
	rmb0	Key_Flag							; ����ر�־λ
	rmb3	Timer_Flag
	lda		#0									; ������ر���
	sta		QuickAdd_Counter
L_Key4HzExit_TimeSetMode3:
	jsr		F_QuikAdd_ScanReady					; ����Ϊ����
	rts


L_KeyMTrigger_TimeSetMode3:
	jsr		F_QuikAdd_ScanReset					; �п�ӵ������Ҫ����IO��Ϊ����߱���©��
	lda		#00
	sta		R_Time_Sec							; �����ӻ���S����
	inc		R_Time_Min
	lda		#59
	cmp		R_Time_Min
	bcs		L_MinSet_Juge3
	lda		#00
	sta		R_Time_Min
L_MinSet_Juge3:
	jsr		F_Display_Time3

	rts
L_KeyHTrigger_TimeSetMode3:
	jsr		F_QuikAdd_ScanReset					; �п�ӵ������Ҫ����IO��Ϊ����߱���©��
	inc		R_Time_Hour
	lda		#23
	cmp		R_Time_Hour
	bcs		L_HourSet_Juge3
	lda		#00
	sta		R_Time_Hour
L_HourSet_Juge3:
	jsr		F_Display_Time3

	rts
L_KeyBTrigger_TimeSetMode3:
	smb3	Key_Flag
	smb2	PB
	lda		#0
	sta		Backlight_Counter					; ÿ�ΰ����ⶼ�����ü�ʱ
	rts
L_KeySTrigger_TimeSetMode3:
	lda		Clock_Flag
	eor		#0001B
	sta		Clock_Flag
	jsr		F_Display_Time3

	rts



; ��������ģʽ�İ�������
F_KeyTrigger_AlarmSetMode3:
	bbs3	Timer_Flag,L_Key4Hz_AlarmSetMode3	; �п����ֱ���ж�8Hz��־λ
	bbr1	Key_Flag,L_KeyScan_AlarmSetMode3	; �״ΰ�������
	rmb1	Key_Flag
	lda		#$00
	sta		P_Temp
L_DelayTrigger_AlarmSetMode3:					; ������ʱѭ���ñ�ǩ
	inc		P_Temp
	lda		P_Temp
	bne		L_DelayTrigger_AlarmSetMode3		; �������
	lda		PA
	and		#$f0
	cmp		#$00
	bne		L_KeyYes_AlarmSetMode3				; ����Ƿ��а�������
	bra		L_KeyExit_AlarmSetMode3
	rts
L_KeyYes_AlarmSetMode3:
	sta		PA_IO_Backup
	bra		L_KeyHandle_AlarmSetMode3			; �״δ����������

L_Key4Hz_AlarmSetMode3:
	bbr2	Key_Flag,L_Key4HzExit_AlarmSetMode3
	rmb2	Key_Flag
L_KeyScan_AlarmSetMode3:						; ����������
	bbr0	Key_Flag,L_KeyExit_AlarmSetMode3	; û��ɨ����־ֱ���˳�

	jsr		F_QuikAdd_ScanReady					; ����Ϊ����
	jsr		F_Delay
	bbr4	Timer_Flag,L_Key4HzExit_AlarmSetMode3; 8Hz��־λ����ǰҲ�����а�������(�����)
	rmb4	Timer_Flag
	lda		PA
	and		#$f0
	cmp		PA_IO_Backup						; ����⵽�а�����״̬�仯���˳�����жϲ�����
	beq		L_4Hz_Count_AlarmSetMode3
	bra		L_KeyExit_AlarmSetMode3
	rts
L_4Hz_Count_AlarmSetMode3:
	inc		QuickAdd_Counter
	lda		QuickAdd_Counter
	cmp		#24
	bcs		L_QuikAdd_AlarmSetMode3
	rts											; ������ʱ��������1S���п��
L_QuikAdd_AlarmSetMode3:
	smb3	Timer_Flag
	rmb2	Key_Flag

L_KeyHandle_AlarmSetMode3:
	lda		PA									; �ж�4�ְ����������
	and		#$f0
	cmp		#$80
	bne		No_KeyHTrigger_AlarmSetMode3		; ������תָ��Ѱַ���������⣬�������jmp������ת
	jmp		L_KeyHTrigger_AlarmSetMode3			; Hour��������
No_KeyHTrigger_AlarmSetMode3:
	cmp		#$40
	bne		No_KeyMTrigger_AlarmSetMode3
	jmp		L_KeyMTrigger_AlarmSetMode3			; Min��������
No_KeyMTrigger_AlarmSetMode3:
	bbs3	Timer_Flag,L_KeyExit_AlarmSetMode3	; �����12hģʽ�л�����Ҫ���
	cmp		#$20
	bne		No_KeySTrigger_AlarmSetMode3
	jmp		L_KeySTrigger_AlarmSetMode3			; 12/24h����
No_KeySTrigger_AlarmSetMode3:
	cmp		#$10
	bne		L_KeyExit_AlarmSetMode3
	jmp		L_KeyBTrigger_AlarmSetMode3			; Backlight��������

L_KeyExit_AlarmSetMode3:
	TMR1_OFF									; �رտ��8Hz��ʱ�Ķ�ʱ��
	rmb0	Key_Flag							; ����ر�־λ
	rmb3	Timer_Flag
	lda		#0									; ������ر���
	sta		QuickAdd_Counter
L_Key4HzExit_AlarmSetMode3:
	jsr		F_QuikAdd_ScanReady					; ����Ϊ����
	rts

L_KeyMTrigger_AlarmSetMode3:
	jsr		F_QuikAdd_ScanReset					; �п�ӵ������Ҫ����IO��Ϊ����߱���©��
	inc		R_Alarm_Min
	lda		#59
	cmp		R_Alarm_Min
	bcs		L_AlarmMinSet_Juge3
	lda		#00
	sta		R_Alarm_Min
L_AlarmMinSet_Juge3:
	jsr		F_Display_Alarm3
	rts

L_KeyHTrigger_AlarmSetMode3:
	jsr		F_QuikAdd_ScanReset					; �п�ӵ������Ҫ����IO��Ϊ����߱���©��
	inc		R_Alarm_Hour
	lda		#23
	cmp		R_Alarm_Hour
	bcs		L_AlarmHourSet_Juge3
	lda		#00
	sta		R_Alarm_Hour
L_AlarmHourSet_Juge3:	
	jsr		F_Display_Alarm3
	rts
L_KeyBTrigger_AlarmSetMode3:
	smb3	Key_Flag
	smb2	PB
	lda		#0
	sta		Backlight_Counter					; ÿ�ΰ����ⶼ�����ü�ʱ
	rts
L_KeySTrigger_AlarmSetMode3:
	lda		Clock_Flag
	eor		#0001B
	sta		Clock_Flag
	jsr		F_Display_Alarm3
	rts
