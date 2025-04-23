; ����ֻ����״̬�仯������Ҫ�����������
F_Switch_Scan:									; ����������Ҫɨ�账��
	jsr		F_SwitchPort_ScanReady
	jsr		F_Delay
	lda		PC
	cmp		PC_IO_Backup						; �ж�IO��״̬�Ƿ����ϴ���ͬ
	bne		L_Switch_Delay						; �����ͬ˵������״̬�иı䣬������
	jsr		F_SwitchPort_ScanReset				; ����©��
	rts
L_Switch_Delay:
	lda		#$00
	sta		P_Temp
L_Delay_S:										; ������ʱѭ���ñ�ǩ
	inc		P_Temp
	lda		P_Temp
	bne		L_Delay_S							; �������

	lda		PC_IO_Backup
	cmp		PC
	bne		L_Switched

	jsr		F_SwitchPort_ScanReset				; ����©��
	rts
L_Switched:										; ��⵽IO��״̬���ϴεĲ�ͬ������벦������
	lda		PC
	sta		PC_IO_Backup						; ���±����IO��״̬

	and		#$04
	cmp		#$04
	bne		Alarm_OFF
	jsr		Switch_Alarm_ON
	bra		Alarm_ON
Alarm_OFF:
	jsr		Switch_Alarm_OFF
	bra		Sys_Mode_Process
Alarm_ON:
	jsr		Switch_Alarm_ON
Sys_Mode_Process:
	lda		PC
	and		#$38
	cmp		#$00
	bne		No_Runtime_Mode
	jmp		Switch_Runtime_Mode
No_Runtime_Mode:
	lda		PC
	and		#$08
	cmp		#$08
	bne		No_Date_Set_Mode
	jmp		Switch_Date_Set_Mode
No_Date_Set_Mode:
	lda		PC
	and		#$10
	cmp		#$10
	bne		No_Time_Set_Mode
	jmp		Switch_Time_Set_Mode
No_Time_Set_Mode:
	lda		PC
	and		#$20
	cmp		#$20
	bne		No_Alarm_Set_Mode
	jmp		Switch_Alarm_Set_Mode
No_Alarm_Set_Mode:
	jsr		F_SwitchPort_ScanReset				; ����©��
	rts 

; ���ӿ�����رղ�������
Switch_Alarm_ON:
	smb1	Clock_Flag
	ldx		#lcd_bell
	jsr		F_DispSymbol
	ldx		#lcd_Zz
	jsr		F_DispSymbol
	rts
Switch_Alarm_OFF:
	rmb1	Clock_Flag
	ldx		#lcd_bell
	jsr		F_ClrpSymbol
	ldx		#lcd_Zz
	jsr		F_ClrpSymbol
	jsr		L_NoSnooze_CloseLoud				; ��������ֺ�̰˯���������ֺ�̰˯
	rts

; ����ģʽ�л��Ĳ�������
Switch_Runtime_Mode:
	lda		#0001B
	sta		Sys_Status_Flag
	jsr		F_Display_All
	jsr		F_SwitchPort_ScanReset				; ����©��
	rts
Switch_Date_Set_Mode:
	lda		#0010B
	sta		Sys_Status_Flag
	jsr		F_Display_Alarm
	jsr		F_Display_Date
	jsr		F_UnDisplay_InDateMode				; ��������ģʽ��ֹͣ��ʾһЩ����
	jsr		L_NoSnooze_CloseLoud				; ��������ֺ�̰˯���������ֺ�̰˯
	jsr		F_SwitchPort_ScanReset				; ����©��
	rts
Switch_Time_Set_Mode:
	lda		#0100B
	sta		Sys_Status_Flag
	jsr		F_Display_All
	jsr		L_NoSnooze_CloseLoud				; ��������ֺ�̰˯���������ֺ�̰˯
	jsr		F_SwitchPort_ScanReset				; ����©��
	rts
Switch_Alarm_Set_Mode:
	lda		#1000B
	sta		Sys_Status_Flag
	jsr		F_Display_All
	jsr		L_NoSnooze_CloseLoud				; ��������ֺ�̰˯���������ֺ�̰˯
	jsr		F_SwitchPort_ScanReset				; ����©��
	rts



; ������ʱģʽ�İ�������
F_KeyTrigger_RunTimeMode:
	bbs0	Key_Flag,L_KeyTrigger_RunTimeMode
	rts
L_KeyTrigger_RunTimeMode:
	rmb0	Key_Flag
	TMR1_OFF									; û�п�ӹ��ܲ���Ҫ��Timer1��8Hz��ʱ
	lda		#$00
	sta		P_Temp
L_DelayTrigger_RunTimeMode:						; ������ʱѭ���ñ�ǩ
	inc		P_Temp
	lda		P_Temp
	bne		L_DelayTrigger_RunTimeMode			; �������

	lda		PA									; ������ʱģʽ��ֻ��2����������Ӧ
	and		#$f0
	cmp		#$80
	bne		No_KeyHTrigger_RunTimeMode			; ������תָ��Ѱַ���������⣬�������jmp������ת
	jmp		L_KeyHTrigger_RunTimeMode			; Month/Hour��������
No_KeyHTrigger_RunTimeMode:
	cmp		#$40
	bne		No_KeyMTrigger_RunTimeMode
	jmp		L_KeyMTrigger_RunTimeMode			; Date/Min��������
No_KeyMTrigger_RunTimeMode:
	cmp		#$20
	bne		No_KeySTrigger_RunTimeMode
	jmp		L_KeySTrigger_RunTimeMode			; 12/24h & year����
No_KeySTrigger_RunTimeMode:
	cmp		#$10
	bne		L_KeyExit_RunTimeMode
	jmp		L_KeyBTrigger_RunTimeMode			; Backlight & SNZ����

L_KeyExit_RunTimeMode:
	rts

L_KeyMTrigger_RunTimeMode:						; ����ʱģʽ�£�M��H����ֻ����̰˯��һ������
L_KeyHTrigger_RunTimeMode:
	jsr		L_NoSnooze_CloseLoud
	rts

L_KeyBTrigger_RunTimeMode:
	smb3	Key_Flag							; ���⼤�ͬʱ����̰˯
	smb2	PB
	lda		#0									; ÿ�ΰ����ⶼ�����ü�ʱ
	sta		Backlight_Counter
	bbr2	Clock_Flag,L_KeyBTrigger_Exit		; �������������ģʽ�£��򲻻ᴦ��̰˯
	smb6	Clock_Flag							; ̰˯��������						
	smb3	Clock_Flag							; ����̰˯ģʽ

	lda		R_Snooze_Min						; ̰˯���ӵ�ʱ���5
	clc
	adc		#5
	cmp		#60
	bcs		L_Snooze_OverflowMin
	sta		R_Snooze_Min
	bra		L_KeyBTrigger_Exit
L_Snooze_OverflowMin:
	sec
	sbc		#60
	sta		R_Snooze_Min						; ����̰˯���ֵķ��ӽ�λ
	inc		R_Snooze_Hour
	lda		R_Snooze_Hour
	cmp		#24
	bcc		L_KeyBTrigger_Exit
	lda		#00									; ����̰˯Сʱ��λ
	sta		R_Snooze_Hour
L_KeyBTrigger_Exit:
	rts

L_KeySTrigger_RunTimeMode:
	bbs2	Clock_Flag,L_LoundSnz_Handle		; ��������ģʽ��̰˯ģʽ�����л�ʱ��ģʽ��ֻ������ֺ�̰˯
	bbs3	Clock_Flag,L_LoundSnz_Handle
	lda		Clock_Flag							; ÿ��һ�η�תclock_flag bit0״̬
	eor		#$01
	sta		Clock_Flag
	jsr		F_Display_Time
	jsr		F_Display_Alarm
L_LoundSnz_Handle:
	jsr		L_NoSnooze_CloseLoud				; ������ֺ�̰˯
	rts



; ��������ģʽ�İ�������
F_KeyTrigger_DateSetMode:
	bbs3	Timer_Flag,L_Key4Hz_DateSetMode		; �п����ֱ���ж�4Hz��־λ
	bbr1	Key_Flag,L_KeyScan_DateSetMode		; �״ΰ�������
	rmb1	Key_Flag
	lda		#$00
	sta		P_Temp
L_DelayTrigger_DateSetMode:						; ������ʱѭ���ñ�ǩ
	inc		P_Temp
	lda		P_Temp
	bne		L_DelayTrigger_DateSetMode			; �������
	lda		PA
	and		#$f0
	cmp		#$00
	bne		L_KeyYes_DateSetMode				; ����Ƿ��а�������
	bra		L_KeyExit_DateSetMode
	rts
L_KeyYes_DateSetMode:
	sta		PA_IO_Backup
	bra		L_KeyHandle_DateMode				; �״δ����������

L_Key4Hz_DateSetMode:
	bbr2	Key_Flag,L_Key4HzExit_DateSetMode
	rmb2	Key_Flag
L_KeyScan_DateSetMode:							; ����������
	bbr0	Key_Flag,L_KeyExit_DateSetMode		; û��ɨ����־ֱ���˳�

	jsr		F_QuikAdd_ScanReady					; ����Ϊ����
	jsr		F_Delay
	bbr4	Timer_Flag,L_Key4HzExit_DateSetMode	; 4Hz��־λ����ǰҲ�����а�������(�����)
	rmb4	Timer_Flag
	lda		PA
	and		#$f0
	cmp		PA_IO_Backup						; ����⵽�а�����״̬�仯���˳�����жϲ�����
	beq		L_4Hz_Count_DateSetMode
	bra		L_KeyExit_DateSetMode
	rts
L_4Hz_Count_DateSetMode:
	inc		QuickAdd_Counter
	lda		QuickAdd_Counter
	cmp		#24
	bcs		L_QuikAdd_DateSetMode
	rts											; ������ʱ��������1S���п��
L_QuikAdd_DateSetMode:
	smb3	Timer_Flag
	rmb2	Key_Flag

L_KeyHandle_DateMode:
	lda		PA									; �ж�4�ְ����������
	and		#$f0
	cmp		#$80
	bne		No_KeyHTrigger_DateSetMode			; ������תָ��Ѱַ���������⣬�������jmp������ת
	jmp		L_KeyHTrigger_DateSetMode			; Month��������
No_KeyHTrigger_DateSetMode:
	cmp		#$40
	bne		No_KeyMTrigger_DateSetMode
	jmp		L_KeyMTrigger_DateSetMode			; Date��������
No_KeyMTrigger_DateSetMode:
	cmp		#$20
	bne		No_KeySTrigger_DateSetMode
	jmp		L_KeySTrigger_DateSetMode			; year����
No_KeySTrigger_DateSetMode:
	cmp		#$10
	bne		L_KeyExit_DateSetMode
	jmp		L_KeyBTrigger_DateSetMode			; Backlight��������

L_KeyExit_DateSetMode:
	TMR1_OFF									; �رտ��8Hz��ʱ�Ķ�ʱ��
	rmb0	Key_Flag							; ����ر�־λ
	rmb3	Timer_Flag
	lda		#0									; ������ر���
	sta		QuickAdd_Counter
L_Key4HzExit_DateSetMode:
	jsr		F_QuikAdd_ScanReady					; �˳����ǰ����Ϊ����
	rts


L_KeyMTrigger_DateSetMode:
	jsr		F_QuikAdd_ScanReset					; �п�ӵ������Ҫ����IO��Ϊ����߱���©��
	jsr		F_Is_Leap_Year
	ldx		R_Date_Month						; �·�����Ϊ���������·�������
	dex											; ��ͷ��0��ʼ�����·��Ǵ�1��ʼ
	bbs0	Calendar_Flag,L_Leap_Year_Set		; ����������·�������
	lda		L_Table_Month_Common,x				; �����ƽ���·�������
	bra		L_Day_Juge_Set
L_Leap_Year_Set:
	lda		L_Table_Month_Leap,x
L_Day_Juge_Set:
	cmp		R_Date_Day
	bne		L_Day_Add_Set
	lda		#1
	sta		R_Date_Day							; �ս�λ�����»ص�1
	jsr		F_Display_Date						; ��ʾ�����������
	rts
L_Day_Add_Set:
	inc		R_Date_Day
	jsr		F_Display_Date						; ��ʾ�����������
	rts

L_KeyHTrigger_DateSetMode:
	jsr		F_QuikAdd_ScanReset					; �п�ӵ������Ҫ����IO��Ϊ����߱���©��
	lda		R_Date_Month
	cmp		#12
	bcc		L_Month_Juge
	lda		#1
	sta		R_Date_Month
	jsr		F_Display_Date
	rts
L_Month_Juge:
	inc		R_Date_Month						; �����·�
	jsr		F_Is_Leap_Year						; ����������·���������û��Խ��
	ldx		R_Date_Month						; �·�����Ϊ���������·�������
	dex											; ��ͷ��0��ʼ�����·��Ǵ�1��ʼ
	bbs0	Calendar_Flag,L_Leap_Year_Set1		; ����������·�������
	lda		L_Table_Month_Common,x				; �����ƽ���·�������
	bra		L_Day_Juge_Set1
L_Leap_Year_Set1:
	lda		L_Table_Month_Leap,x
L_Day_Juge_Set1:
	cmp		R_Date_Day
	bcs		L_Month_Add_Set
	lda		#1
	sta		R_Date_Day							; ��������͵�ǰ�·�����ƥ�䣬���ʼ������
L_Month_Add_Set:
	jsr		F_Display_Date
	rts

L_KeyBTrigger_DateSetMode:
	smb3	Key_Flag							; ���⼤��
	smb2	PB
	lda		#0
	sta		Backlight_Counter					; ÿ�ΰ����ⶼ�����ü�ʱ
	rts

L_KeySTrigger_DateSetMode:
	jsr		F_QuikAdd_ScanReset					; �п�ӵ������Ҫ����IO��Ϊ����߱���©��
	lda		R_Date_Year
	cmp		#99
	bcc		L_Year_Juge
	lda		#0
	sta		R_Date_Year
	jsr		L_DisDate_Year
	rts
L_Year_Juge:
	inc		R_Date_Year							; �������
	jsr		F_Is_Leap_Year						; ��������������������û��Խ��
	ldx		R_Date_Month						; �·�����Ϊ���������·�������
	dex											; ��ͷ��0��ʼ�����·��Ǵ�1��ʼ
	bbs0	Calendar_Flag,L_Leap_Year_Set2		; ����������·�������
	lda		L_Table_Month_Common,x				; �����ƽ���·�������
	bra		L_Day_Juge_Set2
L_Leap_Year_Set2:
	lda		L_Table_Month_Leap,x
L_Day_Juge_Set2:
	cmp		R_Date_Day
	bcs		L_Year_Add_Set
	lda		#1
	sta		R_Date_Day							; �������������ǰ�·����ֵ�����ʼ������
L_Year_Add_Set:
	jsr		L_DisDate_Year
	rts



; ʱ������ģʽ�İ�������
F_KeyTrigger_TimeSetMode:
	bbs3	Timer_Flag,L_Key4Hz_TimeSetMode		; �п����ֱ���ж�8Hz��־λ
	bbr1	Key_Flag,L_KeyScan_TimeSetMode		; �״ΰ�������
	rmb1	Key_Flag
	lda		#$00
	sta		P_Temp
L_DelayTrigger_TimeSetMode:						; ������ʱѭ���ñ�ǩ
	inc		P_Temp
	lda		P_Temp
	bne		L_DelayTrigger_TimeSetMode			; �������
	lda		PA
	and		#$f0
	cmp		#$00
	bne		L_KeyYes_TimeSetMode				; ����Ƿ��а�������
	bra		L_KeyExit_TimeSetMode
	rts
L_KeyYes_TimeSetMode:
	sta		PA_IO_Backup
	bra		L_KeyHandle_TimeSetMode				; �״δ����������

L_Key4Hz_TimeSetMode:
	bbr2	Key_Flag,L_Key4HzExit_TimeSetMode
	rmb2	Key_Flag
L_KeyScan_TimeSetMode:							; ����������
	bbr0	Key_Flag,L_KeyExit_TimeSetMode		; û��ɨ����־ֱ���˳�

	jsr		F_QuikAdd_ScanReady					; ����Ϊ����
	jsr		F_Delay								; ��ʱ���ɸ�ָ������
	bbr4	Timer_Flag,L_Key4HzExit_TimeSetMode	; 4Hz��־λ����ǰҲ�����а�������(�����)
	rmb4	Timer_Flag
	lda		PA
	and		#$f0
	cmp		PA_IO_Backup						; ����⵽�а�����״̬�仯���˳�����жϲ�����
	beq		L_4Hz_Count_TimeSetMode
	bra		L_KeyExit_TimeSetMode
	rts
L_4Hz_Count_TimeSetMode:
	inc		QuickAdd_Counter
	lda		QuickAdd_Counter
	cmp		#24
	bcs		L_QuikAdd_TimeSetMode
	rts											; ������ʱ��������1S���п��
L_QuikAdd_TimeSetMode:
	smb3	Timer_Flag
	rmb2	Key_Flag

L_KeyHandle_TimeSetMode:
	lda		PA									; �ж�4�ְ����������
	and		#$f0
	cmp		#$80
	bne		No_KeyHTrigger_TimeSetMode			; ������תָ��Ѱַ���������⣬�������jmp������ת
	jmp		L_KeyHTrigger_TimeSetMode			; Hour��������
No_KeyHTrigger_TimeSetMode:
	cmp		#$40
	bne		No_KeyMTrigger_TimeSetMode
	jmp		L_KeyMTrigger_TimeSetMode			; Min��������
No_KeyMTrigger_TimeSetMode:
	bbs3	Timer_Flag,L_KeyExit_TimeSetMode	; �����12hģʽ�л�����Ҫ���
	cmp		#$20
	bne		No_KeySTrigger_TimeSetMode
	jmp		L_KeySTrigger_TimeSetMode			; 12/24h����
No_KeySTrigger_TimeSetMode:
	cmp		#$10
	bne		L_KeyExit_TimeSetMode
	jmp		L_KeyBTrigger_TimeSetMode			; Backlight/SNZ��������

L_KeyExit_TimeSetMode:
	TMR1_OFF									; �رտ��8Hz��ʱ�Ķ�ʱ��
	rmb0	Key_Flag							; ����ر�־λ
	rmb3	Timer_Flag
	lda		#0									; ������ر���
	sta		QuickAdd_Counter
L_Key4HzExit_TimeSetMode:
	jsr		F_QuikAdd_ScanReady					; ����Ϊ����
	rts


L_KeyMTrigger_TimeSetMode:
	jsr		F_QuikAdd_ScanReset					; �п�ӵ������Ҫ����IO��Ϊ����߱���©��
	lda		#00
	sta		R_Time_Sec							; �����ӻ���S����
	inc		R_Time_Min
	lda		#59
	cmp		R_Time_Min
	bcs		L_MinSet_Juge
	lda		#00
	sta		R_Time_Min
L_MinSet_Juge:
	jsr		F_Display_Time
	rts
L_KeyHTrigger_TimeSetMode:
	jsr		F_QuikAdd_ScanReset					; �п�ӵ������Ҫ����IO��Ϊ����߱���©��
	inc		R_Time_Hour
	lda		#23
	cmp		R_Time_Hour
	bcs		L_HourSet_Juge
	lda		#00
	sta		R_Time_Hour
L_HourSet_Juge:
	jsr		F_Display_Time
	rts
L_KeyBTrigger_TimeSetMode:
	smb3	Key_Flag
	smb2	PB
	lda		#0
	sta		Backlight_Counter					; ÿ�ΰ����ⶼ�����ü�ʱ
	rts
L_KeySTrigger_TimeSetMode:
	lda		Clock_Flag
	eor		#0001B
	sta		Clock_Flag
	jsr		F_Display_Time
	jsr		F_Display_Alarm
	rts



; ��������ģʽ�İ�������
F_KeyTrigger_AlarmSetMode:
	bbs3	Timer_Flag,L_Key4Hz_AlarmSetMode	; �п����ֱ���ж�8Hz��־λ
	bbr1	Key_Flag,L_KeyScan_AlarmSetMode		; �״ΰ�������
	rmb1	Key_Flag
	lda		#$00
	sta		P_Temp
L_DelayTrigger_AlarmSetMode:					; ������ʱѭ���ñ�ǩ
	inc		P_Temp
	lda		P_Temp
	bne		L_DelayTrigger_AlarmSetMode			; �������
	lda		PA
	and		#$f0
	cmp		#$00
	bne		L_KeyYes_AlarmSetMode				; ����Ƿ��а�������
	bra		L_KeyExit_AlarmSetMode
	rts
L_KeyYes_AlarmSetMode:
	sta		PA_IO_Backup
	bra		L_KeyHandle_AlarmSetMode			; �״δ����������

L_Key4Hz_AlarmSetMode:
	bbr2	Key_Flag,L_Key4HzExit_AlarmSetMode
	rmb2	Key_Flag
L_KeyScan_AlarmSetMode:							; ����������
	bbr0	Key_Flag,L_KeyExit_AlarmSetMode		; û��ɨ����־ֱ���˳�

	jsr		F_QuikAdd_ScanReady					; ����Ϊ����
	jsr		F_Delay
	bbr4	Timer_Flag,L_Key4HzExit_AlarmSetMode; 8Hz��־λ����ǰҲ�����а�������(�����)
	rmb4	Timer_Flag
	lda		PA
	and		#$f0
	cmp		PA_IO_Backup						; ����⵽�а�����״̬�仯���˳�����жϲ�����
	beq		L_4Hz_Count_AlarmSetMode
	bra		L_KeyExit_AlarmSetMode
	rts
L_4Hz_Count_AlarmSetMode:
	inc		QuickAdd_Counter
	lda		QuickAdd_Counter
	cmp		#24
	bcs		L_QuikAdd_AlarmSetMode
	rts											; ������ʱ��������1S���п��
L_QuikAdd_AlarmSetMode:
	smb3	Timer_Flag
	rmb2	Key_Flag

L_KeyHandle_AlarmSetMode:
	lda		PA									; �ж�4�ְ����������
	and		#$f0
	cmp		#$80
	bne		No_KeyHTrigger_AlarmSetMode			; ������תָ��Ѱַ���������⣬�������jmp������ת
	jmp		L_KeyHTrigger_AlarmSetMode			; Hour��������
No_KeyHTrigger_AlarmSetMode:
	cmp		#$40
	bne		No_KeyMTrigger_AlarmSetMode
	jmp		L_KeyMTrigger_AlarmSetMode			; Min��������
No_KeyMTrigger_AlarmSetMode:
	bbs3	Timer_Flag,L_KeyExit_AlarmSetMode	; �����12hģʽ�л�����Ҫ���
	cmp		#$20
	bne		No_KeySTrigger_AlarmSetMode
	jmp		L_KeySTrigger_AlarmSetMode			; 12/24h����
No_KeySTrigger_AlarmSetMode:
	cmp		#$10
	bne		L_KeyExit_AlarmSetMode
	jmp		L_KeyBTrigger_AlarmSetMode			; Backlight��������

L_KeyExit_AlarmSetMode:
	TMR1_OFF									; �رտ��8Hz��ʱ�Ķ�ʱ��
	rmb0	Key_Flag							; ����ر�־λ
	rmb3	Timer_Flag
	lda		#0									; ������ر���
	sta		QuickAdd_Counter
L_Key4HzExit_AlarmSetMode:
	jsr		F_QuikAdd_ScanReady					; ����Ϊ����
	rts

L_KeyMTrigger_AlarmSetMode:
	jsr		F_QuikAdd_ScanReset					; �п�ӵ������Ҫ����IO��Ϊ����߱���©��
	inc		R_Alarm_Min
	lda		#59
	cmp		R_Alarm_Min
	bcs		L_AlarmMinSet_Juge
	lda		#00
	sta		R_Alarm_Min
L_AlarmMinSet_Juge:
	jsr		F_Display_Alarm
	rts

L_KeyHTrigger_AlarmSetMode:
	jsr		F_QuikAdd_ScanReset					; �п�ӵ������Ҫ����IO��Ϊ����߱���©��
	inc		R_Alarm_Hour
	lda		#23
	cmp		R_Alarm_Hour
	bcs		L_AlarmHourSet_Juge
	lda		#00
	sta		R_Alarm_Hour
L_AlarmHourSet_Juge:	
	jsr		F_Display_Alarm
	rts

L_KeyBTrigger_AlarmSetMode:
	smb3	Key_Flag
	smb2	PB
	lda		#0
	sta		Backlight_Counter					; ÿ�ΰ����ⶼ�����ü�ʱ
	rts

L_KeySTrigger_AlarmSetMode:
	lda		Clock_Flag
	eor		#0001B
	sta		Clock_Flag
	jsr		F_Display_Time
	jsr		F_Display_Alarm
	rts
