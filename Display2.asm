F_Display_Time2:								; 调用显示函数显示当前时间
	jsr		L_DisTime_Min2
	jsr		L_DisTime_Hour2
	rts

L_DisTime_Min2:
	ldx		R_Time_Min
	lda		Table_DataDot2,x
	pha
	and		#$0f
	ldx		#lcd2_d3
	jsr		L_Dis_7Bit_DigitDot_Prog2
	pla
	jsr		L_LSR_4Bit_Prog2
	ldx		#lcd2_d2
	jsr		L_Dis_6Bit_DigitDot_Prog2
	rts	

L_DisTime_Hour2:								; 显示小时
	lda		R_Time_Hour
	cmp		#12
	bcs		L_Time12h_PM2
	ldx		#lcd2_PM							; 12h模式AM需要灭PM
	jsr		F_ClrpSymbol2
	lda		R_Time_Hour							; 显示函数会改A值，重新取变量
	cmp		#0
	beq		L_Time_0Hour2
	bra		L_Start_DisTime_Hour2
L_Time12h_PM2:
	ldx		#lcd2_PM							; 12h模式PM需要亮PM点
	jsr		F_DispSymbol2
	lda		R_Time_Hour							; 显示函数会改A值，重新取变量
	sec
	sbc		#12
	cmp		#0
	bne		L_Start_DisTime_Hour2
L_Time_0Hour2:									; 12h模式0点需要变成12点
	lda		#12
L_Start_DisTime_Hour2:
	tax
	lda		Table_DataDot2,x
	pha
	and		#$0f
	ldx		#lcd2_d1
	jsr		L_Dis_7Bit_DigitDot_Prog2
	pla
	and		#$f0
	jsr		L_LSR_4Bit_Prog2
	cmp		#0
	beq		L_TimeHour_0
	ldx		#lcd2_d0
	jsr		F_DispSymbol2
	bra		L_TimeHour_Exit
L_TimeHour_0:
	ldx		#lcd2_d0
	jsr		F_ClrpSymbol2
L_TimeHour_Exit:
	rts



; 显示闹钟设定值函数
F_Display_Alarm2:
	jsr		L_DisAlarm_Min2
	jsr		L_DisAlarm_Hour2
	rts

L_DisAlarm_Min2:
	ldx		R_Alarm_Min
	lda		Table_DataDot2,x
	pha
	and		#$0f
	ldx		#lcd2_d3
	jsr		L_Dis_7Bit_DigitDot_Prog2
	pla
	jsr		L_LSR_4Bit_Prog2
	ldx		#lcd2_d2
	jsr		L_Dis_6Bit_DigitDot_Prog2
	rts	

L_DisAlarm_Hour2:								; 显示闹钟小时
	lda		R_Alarm_Hour
	cmp		#12
	bcs		L_Alarm12h_PM2
	ldx		#lcd2_PM							; 12h模式闹钟AM需要灭PM2
	jsr		F_ClrpSymbol2
	lda		R_Alarm_Hour						; 显示函数会改A值，重新取变量
	cmp		#0
	beq		L_Alarm_0Hour2
	bra		L_Start_DisAlarm_Hour2
L_Alarm12h_PM2:
	ldx		#lcd2_PM							; 12h模式闹钟PM需要亮PM2
	jsr		F_DispSymbol2
	lda		R_Alarm_Hour						; 显示函数会改A值，重新取变量
	sec
	sbc		#12
	cmp		#0
	bne		L_Start_DisAlarm_Hour2
L_Alarm_0Hour2:									; 12h模式0点需要变成12点
	lda		#12
L_Start_DisAlarm_Hour2:
	tax
	lda		Table_DataDot2,x
	pha
	and		#$0f
	ldx		#lcd2_d1
	jsr		L_Dis_7Bit_DigitDot_Prog2
	pla
	and		#$f0
	jsr		L_LSR_4Bit_Prog2
	cmp		#0
	beq		L_AlarmHour_0
	ldx		#lcd2_d0
	jsr		F_DispSymbol2
	bra		L_AlarmHour_Exit
L_AlarmHour_0:
	ldx		#lcd2_d0
	jsr		F_ClrpSymbol2
L_AlarmHour_Exit:
	rts



;显示常亮的符号
F_Display_Symbol2:
	ldx		#lcd2_DotC
	jsr		F_DispSymbol2
	rts


F_SymbolRegulate2:
	bbr1	Clock_Flag,L_No_Alarm2
	ldx		#lcd2_bell
	jsr		F_DispSymbol2
	bbs2	Clock_Flag,L_Loud_Juge_Exit2		; Loud==1: exit
	bbs3	Clock_Flag,L_Loud_Juge_Exit2		; Snooze==1: exit
	ldx		#lcd2_Zz							; Zz常亮条件
	jsr		F_DispSymbol2						; Loud==0 && Alarm==0
L_Loud_Juge_Exit2
	rts
L_No_Alarm2:
	ldx		#lcd2_Zz
	jsr		F_ClrpSymbol2
	ldx		#lcd2_bell
	jsr		F_ClrpSymbol2
	rts


L_LSR_4Bit_Prog2:
	clc
	ror		
	ror		
	ror		
	ror		
	and		#$0F
	rts


;================================================
;********************************************	
Table_DataDot2:		; 对应显示的16进制
	.byte 	00h	;0
	.byte 	01h	;1
	.byte	02h	;2
	.byte	03h	;3
	.byte	04h	;4
	.byte	05h	;5
	.byte	06h	;6
	.byte	07h	;7
	.byte	08h	;8
	.byte	09h	;9
	.byte	10h	;10
	.byte 	11h	;11
	.byte	12h	;12
	.byte	13h	;13
	.byte	14h	;14
	.byte	15h	;15
	.byte 	16h	;16
	.byte 	17h	;17
	.byte	18h	;18
	.byte	19h	;19
	.byte	20h	;20
	.byte	21h	;21
	.byte	22h	;22
	.byte	23h	;23
	.byte	24h	;24
	.byte	25h	;25
	.byte	26h	;26
	.byte 	27h	;27
	.byte	28h	;28
	.byte	29h	;29
	.byte	30h	;30
	.byte	31h	;31
	.byte 	32h	;32
	.byte 	33h	;33
	.byte	34h	;34
	.byte	35h	;35
	.byte	36h	;36
	.byte	37h	;37
	.byte	38h	;38
	.byte	39h	;39
	.byte	40h	;40
	.byte	41h	;41
	.byte	42h	;42
	.byte 	43h	;43
	.byte	44h	;44
	.byte	45h	;45
	.byte	46h	;46
	.byte	47h	;47
	.byte 	48h	;48
	.byte 	49h	;49
	.byte	50h	;50
	.byte	51h	;51
	.byte	52h	;52
	.byte	53h	;53
	.byte	54h	;54
	.byte	55h	;55
	.byte	56h	;56
	.byte	57h	;57
	.byte	58h	;58
	.byte 	59h	;59
