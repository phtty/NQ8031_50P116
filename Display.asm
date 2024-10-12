F_Display_Time:
    ; 调用显示函数显示当前时间
    jsr 	L_DisTime_Min
    jsr 	L_DisTime_Hour
    rts

L_DisTime_Min:
	lda		R_Time_Min
	tax
	lda		Table_DataDot,X
	pha
	and		#$0F
	ldx		#lcd_d3
	jsr		L_Dis_7Bit_DigitDot_Prog
	pla
	jsr		L_ROR_4Bit_Prog
	ldx		#lcd_d2
	jsr		L_Dis_7Bit_DigitDot_Prog
	rts	

L_DisTime_Hour:									; 显示小时
	lda		R_Time_Hour
	bbr0	Clock_Flag, L_24h_Mode				; 24h模式处理
	cmp		#13									; 12h处理
	bcs		L_ClockPM							; 判断是PM还是AM
	pha
	ldx		#lcd_AM
	jsr		F_DispSymbol
	pla
	bra		L_24h_Mode
L_ClockPM:
	sec
	sbc		#12
	pha
	ldx		#lcd_PM
	jsr		F_DispSymbol
	pla
L_24h_Mode:
	bbs0	Clock_Flag,L_Start_DisHour			; 12h模式不能熄灭AM、PM标识
	pha
	ldx		#lcd_AM
	jsr		F_ClrpSymbol						; 24h模式需要熄掉AM、PM标识
	ldx		#lcd_PM
	jsr		F_ClrpSymbol
	pla
	cmp		#24
	bcc		L_Start_DisHour
	lda		#0
L_Start_DisHour:
	tax
	lda		Table_DataDot,X
	pha
	and		#$0F
	ldx		#lcd_d1
	jsr		L_Dis_7Bit_DigitDot_Prog
	pla
	and		#$F0
	jsr		L_ROR_4Bit_Prog
	ldx		#lcd_d0
	jsr		L_Dis_3Bit_DigitDot_Prog
L_DisTime_Hour_rts:
	rts 



; 显示日期函数
F_Display_Date:
	jsr		L_DisDate_Day
	jsr		L_DisDate_Month
	rts

L_DisDate_Day:
	lda		R_Date_Day
	tax
	lda		Table_DataDot,X
	pha
	and		#$0F
	ldx		#lcd_d8
	jsr		L_Dis_7Bit_DigitDot_Prog
	pla
	jsr		L_ROR_4Bit_Prog
	ldx		#lcd_d9
	jsr		L_Dis_6Bit_DigitDot_Prog			; 日期的十位是6段
	rts

L_DisDate_Month:
	lda		R_Date_Month
	tax
	lda		Table_DataDot,X
	pha
	and		#$0F
	ldx		#lcd_d10
	jsr		L_Dis_7Bit_DigitDot_Prog
	pla
	jsr		L_ROR_4Bit_Prog
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


; 显示闹钟设定值函数
F_Display_Alarm:
	jsr		L_DisAlarm_Min
	jsr		L_DisAlarm_Hour
	rts

L_DisAlarm_Min:
	lda		R_Alarm_Min
	tax
	lda		Table_DataDot,X
	pha
	and		#$0F
	ldx		#lcd_d4
	jsr		L_Dis_7Bit_DigitDot_Prog
	pla
	jsr		L_ROR_4Bit_Prog
	ldx		#lcd_d5
	jsr		L_Dis_7Bit_DigitDot_Prog
	rts	

L_DisAlarm_Hour:								; 显示闹钟小时
	lda		R_Alarm_Hour
	bbr0	Clock_Flag, L_24h_Mode_Alarm
	cmp		#13
	bcc		L_24h_Mode_Alarm
	sec
	sbc		#12
	pha
	ldx		#lcd_PM2
	jsr		F_DispSymbol
	pla
L_24h_Mode_Alarm:
	bbs0	Clock_Flag,L_Start_DisAlarm_Hour
	pha
	ldx		#lcd_PM2
	jsr		F_ClrpSymbol						; 24h模式需要熄掉AM、PM标识
	pla
	cmp		#24
	bcc		L_Start_DisAlarm_Hour
	lda		#0
L_Start_DisAlarm_Hour:
	tax
	lda		Table_DataDot,X
	pha
	and		#$0F
	ldx		#lcd_d6
	jsr		L_Dis_7Bit_DigitDot_Prog
	pla
	and		#$F0
	jsr		L_ROR_4Bit_Prog
	ldx		#lcd_d7
	jsr		L_Dis_3Bit_DigitDot_Prog
L_DisAlarm_Hour_rts:
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


F_Display_All:
	jsr		F_Display_Symbol
	jsr		F_Display_Date
	jsr		F_Display_Alarm
	jsr		F_Display_Time
	rts


L_ROR_4Bit_Prog:
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
