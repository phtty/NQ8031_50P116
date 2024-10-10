F_Display_Time:
    ; 调用显示函数显示当前时间
	jsr 	F_ClearScreen
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
	bbr0	Clock_Flag,L_Start_DisHour
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
	cmp		#0
	beq		L_DisTime_Hour_rts
	ldx		#lcd_d0
	jsr		L_Dis_3Bit_DigitDot_Prog
L_DisTime_Hour_rts:
	rts 

L_DisTime_Date:


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
	.BYTE 	00h	;0
	.BYTE 	01h	;1
	.BYTE	02h	;2
	.BYTE	03h	;3
	.BYTE	04h	;4
	.BYTE	05h	;5
	.BYTE	06h	;6
	.BYTE	07h	;7
	.BYTE	08h	;8
	.BYTE	09h	;9
	.BYTE	10h	;10
	.BYTE 	11h	;11
	.BYTE	12h	;12
	.BYTE	13h	;13
	.BYTE	14h	;14
	.BYTE	15h	;15
	.BYTE 	16h	;16
	.BYTE 	17h	;17
	.BYTE	18h	;18
	.BYTE	19h	;19
	.BYTE	20h	;20
	.BYTE	21h	;21
	.BYTE	22h	;22
	.BYTE	23h	;23
	.BYTE	24h	;24
	.BYTE	25h	;25
	.BYTE	26h	;26
	.BYTE 	27h	;27
	.BYTE	28h	;28
	.BYTE	29h	;29
	.BYTE	30h	;30
	.BYTE	31h	;31
	.BYTE 	32h	;32
	.BYTE 	33h	;33
	.BYTE	34h	;34
	.BYTE	35h	;35
	.BYTE	36h	;36
	.BYTE	37h	;37
	.BYTE	38h	;38
	.BYTE	39h	;39
	.BYTE	40h	;40
	.BYTE	41h	;41
	.BYTE	42h	;42
	.BYTE 	43h	;43
	.BYTE	44h	;44
	.BYTE	45h	;45
	.BYTE	46h	;46
	.BYTE	47h	;47
	.BYTE 	48h	;48
	.BYTE 	49h	;49
	.BYTE	50h	;50
	.BYTE	51h	;51
	.BYTE	52h	;52
	.BYTE	53h	;53
	.BYTE	54h	;54
	.BYTE	55h	;55
	.BYTE	56h	;56
	.BYTE	57h	;57
	.BYTE	58h	;58
	.BYTE 	59h	;59
	.BYTE 	60h	;60
