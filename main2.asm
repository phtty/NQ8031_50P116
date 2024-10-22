L_MODE2:
	jsr		F_LCD_Init2
	cli											; 开总中断

	; test Code
	jsr		F_Display_Symbol2
	jsr		F_Display_Time2


;***********************************************************************
;***********************************************************************
MainLoop2:
	jsr		F_Time_Run2							; 走时全局生效
	jsr		F_Louding2							; 响铃处理全局生效
	jsr		F_Backlight							; 背光全局生效
	jsr		F_SymbolRegulate2
	;lda		#$ff
	;sta		HALT
Status_Juge2:
	bbs0	Sys_Status_Flag,Status_Runtime2
	bbs2	Sys_Status_Flag,Status_Time_Set2
	bbs3	Sys_Status_Flag,Status_Alarm_Set2
	bra		MainLoop2
Status_Runtime2:
	jsr		F_KeyTrigger_RunTimeMode2			; 走时模式下的按键逻辑
	jsr		F_DisTime_Run2
	jsr		F_Alarm_Handler2					; 只在RunTime模式下才会响闹
	bra		MainLoop2
Status_Time_Set2:
	jsr		F_Is_KeyTKeep						; 优先判断T键是否保持按下
	jsr		F_KeyTrigger_TimeSetMode2			; TimeSet模式下按键逻辑
	jsr		F_DisTime_Set2
	bra		MainLoop2
Status_Alarm_Set2:
	jsr		F_Is_KeyAKeep						; 优先判断A键是否保持按下
	jsr		F_KeyTrigger_AlarmSetMode2			; AlarmSet模式下按键逻辑
	jsr		F_DisAlarm_Set2
	bra		MainLoop2
	