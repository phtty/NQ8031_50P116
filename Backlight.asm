F_Backlight:
	bbr3	Key_Flag,L_Backlight_Exit
	bbr5	Timer_Flag,L_Backlight_Exit

	rmb5	Timer_Flag
	lda		Backlight_Counter
	cmp		#6
	bcs		L_Backlight_Stop
	inc		Backlight_Counter
	bra		L_Backlight_Exit
L_Backlight_Stop:
	lda		#0
	sta		Backlight_Counter
	rmb3	Key_Flag
	rmb2	PB
L_Backlight_Exit:
	rts


F_Backlight2:
	bbr3	Key_Flag,L_Backlight_Exit2
	bbr5	Timer_Flag,L_Backlight_Exit2

	rmb5	Timer_Flag
	lda		Backlight_Counter
	cmp		#6
	bcs		L_Backlight_Stop2
	inc		Backlight_Counter
	bra		L_Backlight_Exit2
L_Backlight_Stop2:
	lda		#0
	sta		Backlight_Counter
	rmb3	Key_Flag
	rmb3	PB
L_Backlight_Exit2:
	rts