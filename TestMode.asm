F_Test_Mode:
	jsr		F_FillScreen
	TMR0_ON
	lda		#00
	sta		P_Temp
	smb4	Clock_Flag							;配置为持续响铃模式

L_Test_Loop:
	bbr6	Timer_Flag,L_No_Test_16Hz
	inc		P_Temp
L_No_Test_16Hz:
	jsr		F_Louding
	lda		P_Temp
	cmp		#32
	bcs		L_Test_Over
	bra		L_Test_Loop
L_Test_Over:
	TMR0_OFF
	rmb4	Clock_Flag
	rts

F_Test_Mode2:
	jsr		F_FillScreen
	TMR0_ON
	lda		#00
	sta		P_Temp

L_Test_Loop2:
	bbr6	Timer_Flag,L_No_Test_16Hz2
	inc		P_Temp
L_No_Test_16Hz2:
	lda		P_Temp
	cmp		#32
	bcs		L_Test_Over
	bra		L_Test_Loop
L_Test_Over2:
	TMR0_OFF
	rts