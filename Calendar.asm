F_Calendar_Add:
	jsr		F_Is_Leap_Year
	ldx		R_Date_Month					; 月份数作为索引，查表
	dex
	bbs0	Calendar_Flag,L_Leap_Year		; 如果是闰年，查闰年月份天数表
	lda		L_Table_Month_Common,x			; 否则查平年月份天数表
	bra		L_Day_Juge
L_Leap_Year:
	lda		L_Table_Month_Leap,x
L_Day_Juge:
	cmp		R_Date_Day
	bne		L_Day_Add			
	lda		#1
	sta		R_Date_Day						; 日进位
	lda		R_Date_Month
	cmp		#12								; 若是月份到已经计到12
	beq		L_Year_Add						; 月份进位
	inc		R_Date_Month					; 月份正常加
	jsr		F_Display_Date
	rts

L_Day_Add:
	inc		R_Date_Day
	jsr		L_DisDate_Day
	rts
	
L_Year_Add:
	lda		#1
	sta		R_Date_Month
	lda		R_Date_Year
	cmp		#99								; 年份走到2099
	beq		L_Reload_Year					; 则下一年回到2000
	inc		R_Date_Year
	jsr		F_Display_Date
	rts
L_Reload_Year:
	lda		#0
	sta		R_Date_Year
	jsr		L_DisDate_Day
	rts
	
; 判断平闰年函数
F_Is_Leap_Year:
	lda		R_Date_Year
	and		#0011B							; 取最后两位
	beq		L_Set_LeapYear_Flag				; 若为0则能被4整除
	rmb0	Calendar_Flag
	rts
L_Set_LeapYear_Flag:
	smb0	Calendar_Flag
	rts

; 平年的每月份天数表
L_Table_Month_Common:
	.byte	31	; January
	.byte	28	; February
	.byte	31	; March
	.byte	30	; April
	.byte	31	; May
	.byte	30	; June
	.byte	31	; July
	.byte	31	; August
	.byte	30	; September
	.byte	31	; October
	.byte	30	; November
	.byte	31	; December

; 闰年的每月份天数表
L_Table_Month_Leap:
	.byte	31	; January
	.byte	29	; February
	.byte	31	; March
	.byte	30	; April
	.byte	31	; May
	.byte	30	; June
	.byte	31	; July
	.byte	31	; August
	.byte	30	; September
	.byte	31	; October
	.byte	30	; November
	.byte	31	; December