F_Display_Time:									; 调用显示函数显示当前时间
	jsr		L_DisTime_Min
	jsr		L_DisTime_Hour
	rts

L_DisTime_Min:
	lda		R_Time_Min
	tax
	lda		Table_DataDot,x
	pha
	and		#$0f
	ldx		#lcd_d3
	jsr		L_Dis_7Bit_DigitDot_Prog
	pla
	jsr		L_LSR_4Bit_Prog
	ldx		#lcd_d2
	jsr		L_Dis_7Bit_DigitDot_Prog
	rts	

L_DisTime_Hour:									; 显示小时
	bbr0	Clock_Flag,L_24hMode_Time
	lda		R_Time_Hour
	cmp		#12
	bcs		L_Time12h_PM
	ldx		#lcd_AM								; 12h模式AM需要灭PM、亮AM点
	jsr		F_DispSymbol
	ldx		#lcd_PM
	jsr		F_ClrpSymbol
	lda		R_Time_Hour							; 显示函数会改A值，重新取变量
	cmp		#0
	beq		L_Time_0Hour
	bra		L_Start_DisTime_Hour
L_Time12h_PM:
	ldx		#lcd_AM								; 12h模式PM需要灭AM、亮PM点
	jsr		F_ClrpSymbol
	ldx		#lcd_PM
	jsr		F_DispSymbol
	lda		R_Time_Hour							; 显示函数会改A值，重新取变量
	sec
	sbc		#12
	cmp		#0
	bne		L_Start_DisTime_Hour
L_Time_0Hour:									; 12h模式0点需要变成12点
	lda		#12
	bra		L_Start_DisTime_Hour

L_24hMode_Time:
	ldx		#lcd_AM								; 24h模式下需要灭AM、PM点
	jsr		F_ClrpSymbol
	ldx		#lcd_PM
	jsr		F_ClrpSymbol
	lda		R_Time_Hour
L_Start_DisTime_Hour:
	tax
	lda		Table_DataDot,x
	pha
	and		#$0f
	ldx		#lcd_d1
	jsr		L_Dis_7Bit_DigitDot_Prog
	pla
	and		#$f0
	jsr		L_LSR_4Bit_Prog
	ldx		#lcd_d0
	jsr		L_Dis_3Bit_DigitDot_Prog
	rts 

F_UnDisplay_Time:
	lda		#0
	ldx		#lcd_d0
	jsr		L_Dis_3Bit_DigitDot_Prog
	lda		#10
	ldx		#lcd_d1
	jsr		L_Dis_7Bit_DigitDot_Prog
	lda		#10
	ldx		#lcd_d2
	jsr		L_Dis_7Bit_DigitDot_Prog
	lda		#10
	ldx		#lcd_d3
	jsr		L_Dis_7Bit_DigitDot_Prog
	rts



; 显示日期函数
F_Display_Date:
	jsr		L_DisDate_Day
	jsr		L_DisDate_Month
	rts

L_DisDate_Day:
	ldx		R_Date_Day
	lda		Table_DataDot,x
	pha
	and		#$0f
	ldx		#lcd_d8
	jsr		L_Dis_7Bit_DigitDot_Prog
	pla
	jsr		L_LSR_4Bit_Prog
	ldx		#lcd_d9
	jsr		L_Dis_6Bit_DigitDot_Prog			; 日期的十位是6段
	rts

L_DisDate_Month:
	ldx		R_Date_Month
	lda		Table_DataDot,x
	pha
	and		#$0f
	ldx		#lcd_d10
	jsr		L_Dis_7Bit_DigitDot_Prog
	pla
	jsr		L_LSR_4Bit_Prog
	cmp		#$0									; 月份的十位只有1段，所以选择用symbol显示
	beq		No_Month_Tens
	ldx		#lcd_d11
	jsr		F_DispSymbol
	rts
No_Month_Tens:
	ldx		#lcd_d11
	jsr		F_ClrpSymbol
L_DisDate_Month_rts:
	rts

L_DisDate_Year:
	ldx		#00									; 20xx年的开头20是固定的
	lda		Table_DataDot,x						; 所以20固定会显示
	ldx		#lcd_d1
	jsr		L_Dis_7Bit_DigitDot_Prog
	ldx		#02
	lda		Table_DataDot,x
	ldx		#lcd_d0
	jsr		L_Dis_3Bit_DigitDot_Prog

	ldx		R_Date_Year							; 显示当前的年份
	lda		Table_DataDot,x
	pha
	and		#$0f
	ldx		#lcd_d3
	jsr		L_Dis_7Bit_DigitDot_Prog
	pla
	and		#$f0
	jsr		L_LSR_4Bit_Prog
	ldx		#lcd_d2
	jsr		L_Dis_7Bit_DigitDot_Prog
	rts

F_UnDisplay_Date:								; 闪烁时取消显示用的函数
	lda		#0
	ldx		#lcd_d0
	jsr		L_Dis_3Bit_DigitDot_Prog
	lda		#10
	ldx		#lcd_d1
	jsr		L_Dis_7Bit_DigitDot_Prog
	lda		#10
	ldx		#lcd_d2
	jsr		L_Dis_7Bit_DigitDot_Prog
	lda		#10
	ldx		#lcd_d3
	jsr		L_Dis_7Bit_DigitDot_Prog
	lda		#10
	ldx		#lcd_d8
	jsr		L_Dis_7Bit_DigitDot_Prog
	lda		#0
	ldx		#lcd_d9
	jsr		L_Dis_6Bit_DigitDot_Prog
	lda		#10
	ldx		#lcd_d10
	jsr		L_Dis_7Bit_DigitDot_Prog
	ldx		#lcd_d11
	jsr		F_ClrpSymbol
	rts


; 显示闹钟设定值函数
F_Display_Alarm:
	jsr		L_DisAlarm_Min
	jsr		L_DisAlarm_Hour
	rts

L_DisAlarm_Min:
	lda		R_Alarm_Min
	tax
	lda		Table_DataDot,x
	pha
	and		#$0F
	ldx		#lcd_d4
	jsr		L_Dis_7Bit_DigitDot_Prog
	pla
	jsr		L_LSR_4Bit_Prog
	ldx		#lcd_d5
	jsr		L_Dis_7Bit_DigitDot_Prog
	rts	

L_DisAlarm_Hour:								; 显示闹钟小时
	bbr0	Clock_Flag,L_24hMode_Alarm
	lda		R_Alarm_Hour
	cmp		#12
	bcs		L_Alarm12h_PM						
	ldx		#lcd_PM2							; 12h模式闹钟AM需要灭PM2
	jsr		F_ClrpSymbol
	lda		R_Alarm_Hour						; 显示函数会改A值，重新取变量
	cmp		#0
	beq		L_Alarm_0Hour
	bra		L_Start_DisAlarm_Hour
L_Alarm12h_PM:
	ldx		#lcd_PM2							; 12h模式闹钟PM需要亮PM2
	jsr		F_DispSymbol
	lda		R_Alarm_Hour						; 显示函数会改A值，重新取变量
	sec
	sbc		#12
	cmp		#0
	bne		L_Start_DisAlarm_Hour
L_Alarm_0Hour:									; 12h模式0点需要变成12点
	lda		#12
	bra		L_Start_DisAlarm_Hour

L_24hMode_Alarm:
	ldx		#lcd_PM2							; 24h模式闹钟需要灭PM2点
	jsr		F_ClrpSymbol
	lda		R_Alarm_Hour
L_Start_DisAlarm_Hour:
	tax
	lda		Table_DataDot,x
	pha
	and		#$0F
	ldx		#lcd_d6
	jsr		L_Dis_7Bit_DigitDot_Prog
	pla
	and		#$F0
	jsr		L_LSR_4Bit_Prog
	ldx		#lcd_d7
	jsr		L_Dis_3Bit_DigitDot_Prog
	rts

F_UnDisplay_Alarm:
	lda		#10
	ldx		#lcd_d4
	jsr		L_Dis_7Bit_DigitDot_Prog
	lda		#10
	ldx		#lcd_d5
	jsr		L_Dis_7Bit_DigitDot_Prog
	lda		#10
	ldx		#lcd_d6
	jsr		L_Dis_7Bit_DigitDot_Prog
	lda		#0
	ldx		#lcd_d7
	jsr		L_Dis_3Bit_DigitDot_Prog
	rts

;显示常亮的符号
F_Display_Symbol:
	ldx		#lcd_ALM
	jsr		F_DispSymbol
	ldx		#lcd_DotA
	jsr		F_DispSymbol
	ldx		#lcd_MD
	jsr		F_DispSymbol
	ldx		#lcd_SLH
	jsr		F_DispSymbol
	rts

F_UnDisplay_InDateMode:
	ldx		#lcd_AM
	jsr		F_ClrpSymbol
	ldx		#lcd_PM
	jsr		F_ClrpSymbol
	ldx		#lcd_DotC
	jsr		F_ClrpSymbol
	rts

F_Display_All:
	jsr		F_Display_Symbol
	jsr		F_Display_Date
	jsr		F_Display_Alarm
	jsr		F_Display_Time
	rts


F_SymbolRegulate:
	bbr1	Clock_Flag,L_No_Alarm
	ldx		#lcd_bell
	jsr		F_DispSymbol
	bbr3	Clock_Flag,L_Snz_Juge
	bbr2	Clock_Flag,L_Loud_Juge_Exit			; Zz常亮条件为Loud!=0 Snz!=1
L_Snz_Juge:
	ldx		#lcd_Zz
	jsr		F_DispSymbol
L_Loud_Juge_Exit:
	rts
L_No_Alarm:
	ldx		#lcd_Zz
	jsr		F_ClrpSymbol
	ldx		#lcd_bell
	jsr		F_ClrpSymbol
	rts


L_LSR_4Bit_Prog:
	clc
	ror		
	ror		
	ror		
	ror		
	and		#$0F
	rts


;================================================
;********************************************	
Table_DataDot:		; 对应显示的16进制
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
	.byte 	60h	;60
	.byte	61h	;61
	.byte	62h	;62
	.byte	63h	;63
	.byte	64h	;64
	.byte	65h	;65
	.byte	66h	;66
	.byte	67h	;67
	.byte	68h	;68
	.byte 	69h	;69
	.byte 	70h	;70
	.byte	71h	;71
	.byte	72h	;72
	.byte	73h	;73
	.byte	74h	;74
	.byte	75h	;75
	.byte	76h	;76
	.byte 	77h	;77
	.byte	78h	;78
	.byte	79h	;79
	.byte	80h	;30
	.byte	81h	;81
	.byte 	82h	;82
	.byte 	83h	;83
	.byte	84h	;84
	.byte	85h	;85
	.byte	86h	;86
	.byte	87h	;87
	.byte	88h	;88
	.byte	89h	;89
	.byte	90h	;90
	.byte	91h	;91
	.byte	92h	;92
	.byte 	93h	;93
	.byte	94h	;94
	.byte	95h	;95
	.byte	96h	;96
	.byte	97h	;97
	.byte 	98h	;98
	.byte 	99h	;99

; 12h模式专用Table
Table12h_DataDot:
	.byte	12h	;12
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