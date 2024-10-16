F_Backlight:
	bbr3	Key_Flag,L_Backlight_Exit
	bbr5	Timer_Flag,L_Backlight_Exit

	rmb5	Timer_Flag
	lda		CC3
	cmp		#6
	bcs		L_Backlight_Stop
	inc		CC3
	bra		L_Backlight_Exit
L_Backlight_Stop:
	lda		#0
	sta		CC3
	rmb3	Key_Flag
	rmb3	PB
L_Backlight_Exit:
	rts
