
; ��Բʱ��״̬��

MainLoop2:
	jsr		F_Time_Run2							; ��ʱȫ����Ч
	jsr		F_Louding2							; ���崦��ȫ����Ч
	jsr		F_Backlight2						; ����ȫ����Ч
	jsr		F_SymbolRegulate2

Status_Juge2:
	bbs0	Sys_Status_Flag,Status_Runtime2
	bbs2	Sys_Status_Flag,Status_Time_Set2
	bbs3	Sys_Status_Flag,Status_Alarm_Set2
	bra		MainLoop2
Status_Runtime2:
	jsr		F_KeyTrigger_RunTimeMode2			; ��ʱģʽ�µİ����߼�
	jsr		F_DisTime_Run2
	jsr		F_Alarm_Handler2
	bbs7	TMRC,L_InBeep_NoHalt_Runtime2
	sta		HALT
L_InBeep_NoHalt_Runtime2:
	bra		MainLoop2
Status_Time_Set2:
	jsr		F_KeyTrigger_TimeSetMode2			; TimeSetģʽ�°����߼�
	jsr		F_DisTime_Set2
	jsr		F_Alarm_Handler2
	jsr		F_Is_KeyTKeep						; �ж�T���Ƿ񱣳ְ���
	sta		HALT
	bra		MainLoop2
Status_Alarm_Set2:
	jsr		F_KeyTrigger_AlarmSetMode2			; AlarmSetģʽ�°����߼�
	jsr		F_DisAlarm_Set2
	jsr		F_Alarm_Handler2
	jsr		F_Is_KeyAKeep						; �ж�A���Ƿ񱣳ְ���
	sta		HALT
	bra		MainLoop2


F_MODE0_Init:
	lda		#12
	sta		R_Time_Hour
	smb1	Clock_Flag
	rts
