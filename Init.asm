F_Init_SystemRam_Prog:							; ϵͳ��ʼ��
	lda		#0
	sta		Counter_1Hz
	sta		Counter_4Hz
	sta		Counter_16Hz
	sta		Key_Flag
	sta		Timer_Flag
	sta		Clock_Flag
	sta		Calendar_Flag
	sta		Test_Flag
	sta		AlarmLoud_Counter					; �׶����ּ���
	sta		QuickAdd_Counter					; ��ӱ�־�ļ���
	sta		Backlight_Counter
	sta		CC0

	lda		#01
	sta		Sys_Status_Flag

	lda		#00
	sta		R_Time_Hour
	lda		#00
	sta		R_Time_Min
	lda		#00
	sta		R_Time_Sec

	lda		#06
	sta		R_Alarm_Hour
	lda		#00
	sta		R_Alarm_Min

	lda		#01
	sta		R_Date_Day
	lda		#01
	sta		R_Date_Month
	lda		#24
	sta		R_Date_Year
	lda		#00
	sta		R_Date_Week

	rts


F_LCD_Init:
	LCD_C_TYPE
	LCD_ENCH_EN
	LCD_4COM
	LCD_DRIVE_8
	smb2	LCDCTRL
	smb3	LCDCTRL

	PC67_SEG									; ����IO��ΪSEG��ģʽ
	PD03_SEG
	PD47_SEG

	LCD_ON
	jsr		F_ClearScreen						; ����

	rts


F_Port_Init:
	lda		#$f0
	sta		PA_WAKE
	lda		#$f0
	sta		PA_DIR
	lda		#$f0								; PA�ڳ�ʼ����Ϊ��������
	sta		PA
	EN_PA_IRQ									; ��PA���ⲿ�ж�

	lda		PB
	and		#$f3
	sta		PB
	rmb2	PB_TYPE
	rmb3	PB_TYPE
	PB2_PB2_COMS								; PB2�����������
	
	lda		PC_SEG								; ����PC0~5Ϊ��ͨIO��
	and		#$e0
	sta		PC_SEG
	lda		PC_DIR								; PC2~5���������룬PC0��1����ѡ
	ora		#$3f
	sta		PC_DIR
	lda		PC									; PC0~5����Ϊ����
	ora		#$3f
	sta		PC

	lda		#$00
	sta		PC_IO_Backup

	rts


F_Timer_Init:
	TMR0_CLK_FSUB								; TIM0ʱ��ԴFsub(32768Hz)
	TMR1_CLK_512Hz								; TIM1ʱ��ԴFsub/64(512Hz)
	DIV_512HZ									; TIM2ʱ��ԴDIV��Ƶ

	lda		#$0									; ��װ�ؼ�������Ϊ0
	sta		TMR0
	sta		TMR2

	lda		#$e0								; 8Hzһ���ж�
	sta		TMR1

	rmb6	DIVC								; �رն�ʱ��ͬ��

	EN_TMR1_IRQ									; ����ʱ���ж�
	EN_TMR2_IRQ
	EN_TMR0_IRQ
	TMR0_OFF
	TMR1_OFF
	TMR2_ON

	DIS_LCD_IRQ

	rts


F_Beep_Init:
	PB3_PB3_COMS								; PN(PB3)��ʼ����IO���������©��
	rmb3	PB

	rmb2    DIVC								; ���÷�������Ƶ��(ռ�ձ�3/4)
    rmb3    DIVC
	rmb7	DIVC
	rmb1	AUDCR								; ����BPλ��ѡ��AUD����ʱ��ģʽ������ѡ��TONEģʽ				
	lda		#$ff
	sta		AUD0								; TONEģʽ����ʵAUD0û��

	rts


F_Beep_Init2:
	PB2_PB2_COMS								; PP(PB2)��ʼ����IO���������©��
	rmb2	PB

	rmb2	DIVC								; ���÷�������Ƶ��(ռ�ձ�3/4)
	rmb3	DIVC
	rmb7	DIVC
	rmb1	AUDCR								; ����BPλ��ѡ��AUD����ʱ��ģʽ������ѡ��TONEģʽ				
	lda		#$ff
	sta		AUD0

	rts

F_Port_Init2:
	lda		#$fc
	sta		PA_WAKE
	lda		#$fc
	sta		PA_DIR
	lda		#$fc
	sta		PA
	EN_PA_IRQ									; ��PA���ⲿ�ж�

	PB3_PB3_COMS								; PB3�����������
	
	lda		PC_SEG								; ����PC0~5Ϊ��ͨIO��
	and		#$e0
	sta		PC_SEG
	lda		PC_DIR								; PC0/2~5����������
	and		#$c0
	sta		PC_DIR
	lda		PC									; PC0/2~5����Ϊ����
	and		#$c0
	sta		PC

	lda		#$00
	sta		PC_IO_Backup

	rts

F_LCD_Init2:
	LCD_OFF
	LCD_3COM
	LCD_ON

	jsr		F_ClearScreen						; ����

	rts


F_BoundPort_Reset:
	rmb0	PC_DIR
	rmb1	PC_DIR
	smb0	PC									; ��ѡ��ɺ����ó�����߱���©��
	smb1	PC
	rts


F_SwitchPort_ScanReady:
	lda		PC_DIR
	ora		#$3c
	sta		PC_DIR
	lda		PC									; PC2~5����Ϊ����
	ora		#$3c
	sta		PC
	rts

F_SwitchPort_ScanReset:
	lda		PC_DIR
	and		#$c3
	sta		PC_DIR
	lda		PC									; PC2~5����Ϊ����
	ora		#$3c
	sta		PC
	rts

F_QuikAdd_ScanReady:							; PA������Ϊ��������
	bbs3	Timer_Flag,L_QuikAdd_ScanReady
	rts
L_QuikAdd_ScanReady:
	CLR_PA_IRQ_FLAG
	EN_PA_IRQ
	lda		#$f0
	sta		PA_DIR
	lda		#$f0
	sta		PA
	rts

F_QuikAdd_ScanReset:							; PA������Ϊ�����
	bbs3	Timer_Flag,L_QuikAdd_ScanReset
	rts
L_QuikAdd_ScanReset:
	DIS_PA_IRQ
	lda		#$00
	sta		PA_DIR
	lda		#$f0
	sta		PA
	rts

F_QuikAdd_ScanReady2:
	bbs3	Timer_Flag,L_QuikAdd_ScanReady2
	rts
L_QuikAdd_ScanReady2:
	CLR_PA_IRQ_FLAG
	EN_PA_IRQ
	lda		#$fc
	sta		PA_DIR
	lda		#$fc
	sta		PA
	rts

F_QuikAdd_ScanReset2:
	bbs3	Timer_Flag,L_QuikAdd_ScanReset2
	rts
L_QuikAdd_ScanReset2:
	DIS_PA_IRQ
	lda		#$00
	sta		PA_DIR
	lda		#$00
	sta		PA
	lda		Timer_Flag
	rts

F_Delay:
	lda		#$f5
	sta		P_Temp
L_Delay_f5:										; ��ʱѭ���ñ�ǩ
	inc		P_Temp
	lda		P_Temp
	bne		L_Delay_f5
	rts

L_KeyDelay_1:
	lda		#0
	sta		P_Temp+1
DelayLoop_1:
	inc		P_Temp+1
	bne		DelayLoop_1
	
	rts

L_KeyDelay:
	lda		#0
	sta		P_Temp
DelayLoop:
	jsr		L_KeyDelay_1
	inc		P_Temp
	lda		P_Temp
	cmp		#10
	bcc		DelayLoop
	
	rts