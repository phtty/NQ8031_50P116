F_Calendar_Add:
	smb1	Calendar_Flag
	jsr		F_Is_Leap_Year
	ldx		R_Date_Month						; 月份数作为索引，查表
	dex
	bbs0	Calendar_Flag,L_Leap_Year			; 如果是闰年，查闰年月份天数表
	lda		L_Table_Month_Common,x				; 否则查平年月份天数表
	bra		L_Day_Juge
L_Leap_Year:
	lda		L_Table_Month_Leap,x
L_Day_Juge:
	cmp		R_Date_Day
	bne		L_Day_Add			
	lda		#1
	sta		R_Date_Day							; 日进位发生
	lda		R_Date_Month
	cmp		#12									; 若是月份到已经计到12
	beq		L_Year_Add							; 月份进位
	inc		R_Date_Month						; 月份正常加
	rts

L_Day_Add:
	inc		R_Date_Day
	rts
	
L_Year_Add:
	lda		#1
	sta		R_Date_Month
	lda		R_Date_Year
	cmp		#99									; 年份走到2099
	beq		L_Reload_Year						; 则下一年回到2000
	inc		R_Date_Year
	rts
L_Reload_Year:
	lda		#0
	sta		R_Date_Year
	rts
	
; 判断平闰年函数
F_Is_Leap_Year:
	lda		R_Date_Year
	and		#0011B								; 取最后两位
	beq		L_Set_LeapYear_Flag					; 若都为0则能被4整除
	rmb0	Calendar_Flag
	rts
L_Set_LeapYear_Flag:
	smb0	Calendar_Flag
	rts


F_DisCalendar_Set:
	bbs0	Key_Flag,L_KeyTrigger_NoBlink_Date	; 有按键时不闪烁
	bbs0	Timer_Flag,L_Blink_Date				; 没有半S标志不闪烁
	rts
L_Blink_Date:
	rmb0	Timer_Flag							; 清半S标志
	bbs1	Timer_Flag,L_Date_Clear				; 有1S标志时灭
L_KeyTrigger_NoBlink_Date:
	jsr		L_DisDate_Year
	jsr		F_Display_Date
	rts	
L_Date_Clear:
	rmb1	Timer_Flag
	jsr		F_UnDisplay_Date
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