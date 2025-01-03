F_Test_Mode:
	jsr		F_FillScreen
	TMR0_ON
	lda		#00
	sta		P_Temp
	smb4	Clock_Flag							;配置为持续响铃模式
	smb0	Test_Flag

L_Test_Loop:
	bbr6	Timer_Flag,L_No_Test_16Hz
	inc		P_Temp
L_No_Test_16Hz:
	jsr		F_Louding
	lda		P_Temp
	cmp		#28
	bcs		L_Test_Over
	bra		L_Test_Loop
L_Test_Over:
	TMR0_OFF
	rmb4	Clock_Flag
	rmb0	Test_Flag
	rmb0	SYSCLK
	rts


F_Test_Mode2:
	jsr		F_FillScreen
	TMR0_ON
	lda		#00
	sta		P_Temp
	rmb4	Clock_Flag							;配置为序列响铃模式
	smb0	Test_Flag
	lda		#4
	sta		Beep_Serial

L_Test_Loop2:
	bbr6	Timer_Flag,L_No_Test_16Hz2
	inc		P_Temp
L_No_Test_16Hz2:
	jsr		F_Louding2
	lda		P_Temp
	cmp		#28
	bcs		L_Test_Over2
	bra		L_Test_Loop2
L_Test_Over2:
	TMR0_OFF
	rmb0	SYSCLK
	rmb0	Test_Flag
	rts