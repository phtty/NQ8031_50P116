; 方块时钟（星期）状态机

MainLoop3:										; MODE1的状态机
	jsr		F_Time_Run							; 走时全局生效
	jsr		F_Switch_Scan3						; 拨键扫描全局生效
	jsr		F_Backlight							; 背光全局生效
	jsr		F_Louding							; 响铃处理全局生效
	jsr		F_SymbolRegulate3

Status_Juge3:
	bbs0	Sys_Status_Flag,Status_Runtime3
	bbs1	Sys_Status_Flag,Status_Calendar_Set3
	bbs2	Sys_Status_Flag,Status_Time_Set3
	bbs3	Sys_Status_Flag,Status_Alarm_Set3
	bra		MainLoop3
Status_Runtime3:
	jsr		F_KeyTrigger_RunTimeMode3			; RunTime模式下按键逻辑
	jsr		F_DisTime_Run3
	jsr		F_Alarm_Handler						; 只在RunTime模式下才会响闹
	bbs7	TMRC,L_InBeep_NoHalt_Runtime3
	sta		HALT
L_InBeep_NoHalt_Runtime3:
	bra		MainLoop3
Status_Calendar_Set3:
	jsr		F_KeyTrigger_DateSetMode3			; DateSet模式下按键逻辑
	jsr		F_DisCalendar_Set3
	bbs7	TMRC,L_InBeep_NoHalt_Calendar_Set3
	sta		HALT
L_InBeep_NoHalt_Calendar_Set3:
	bra		MainLoop3
Status_Time_Set3:
	jsr		F_KeyTrigger_TimeSetMode3			; TimeSet模式下按键逻辑
	jsr		F_DisTime_Set3
	bbs7	TMRC,L_InBeep_NoHalt_Time_Set3
	sta		HALT
L_InBeep_NoHalt_Time_Set3:
	bra		MainLoop3
Status_Alarm_Set3:
	jsr		F_KeyTrigger_AlarmSetMode3			; AlarmSet模式下按键逻辑
	jsr		F_DisAlarm_Set3
	bbs7	TMRC,L_InBeep_NoHalt_Alarm_Set3
	sta		HALT
L_InBeep_NoHalt_Alarm_Set3:
	bra		MainLoop3
