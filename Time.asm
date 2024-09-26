F_Sec_Pos_Counter:
	lda		Timer_Flag
	and		#$81
	cmp		#$81								; ��������Ҫͬʱ�����а������16Hz��־
	beq		Count_Start_Pos
	rts

Count_Start_Pos:
	lda		Frame_Flag
	inc		Frame_Counter
	lda		R_Time_Sec
	cmp		#59
	bne		Set_CarryFlag_Out
	smb2	Frame_Flag							; �ý�(��)λ������־
Set_CarryFlag_Out:
	bbr2	Frame_Flag,Carry_Out				; �ж��Ƿ���ڷ��ӽ�λ
	bra		L_CarryToMin
Carry_Out:
	jsr		F_DisFrame_Sec_d4					; sec��λ��ʱ����

	lda		R_Time_Sec							; ���secʮλ���޽�λ
	clc
	adc		#$01								; �ж���1S�費��Ҫ��ʮλ
	jsr		F_DivideBy10
	cmp		#0									; ��Ϊ0��һ����ʮλ��ʮλ����ʱ
	beq		L_Sec_D3_Out
	lda		P_Temp								; ������Ϊ0Ҳ������ʮλ
	cmp		#0
	bne		L_Sec_D3_Out

	jsr		F_DisFrame_Sec_d3					; secʮλ��ʱ����

L_Sec_D3_Out:
	lda		Frame_Counter
	cmp		#$08
	beq		L_Sec_Pos_Out
	
	ldx		#lcd_MS
	jsr		F_ClrpSymbol

	rmb7	Timer_Flag							; ��16Hz�������ظ�������

	rts

L_Sec_Pos_Out:
	rmb0	Timer_Flag							; �������꼴Ϊ���S
	rmb7	Timer_Flag							; �����ر�־λ����������
	inc		R_Time_Sec							; ������ڶ�����ɲ��ֱ�ֻ֤��1��
	ldx		#lcd_MS
	jsr		F_DispSymbol
	lda		#0
	sta		Frame_Counter

L_Sec_Pos_rts:
	rts

L_CarryToMin:
	smb2	Frame_Flag

	lda		R_Time_Min
	cmp		#99
	beq		L_Time_Overflow						; �Ƶ�99:59ֹͣ

	jsr		F_DisFrame_Sec_d4					; Sec��λ��ʱ
	jsr		F_DisFrame_Sec_d3					; Secʮλ��ʱ
	jsr		F_DisFrame_Min_d2					; Min��λ��ʱ

	lda		R_Time_Min							; ���Minʮλ���޽�λ
	clc
	adc		#$01								; �ж���1Min�費��Ҫ��ʮλ
	jsr		F_DivideBy10						; ��10�ж�ʮλ�Ƿ���Ҫ����
	cmp		#0
	beq		L_Min_D1_Out_Pos
	lda		P_Temp
	cmp		#0
	bne		L_Min_D1_Out_Pos

	jsr		F_DisFrame_Min_d1					; Minʮλ��ʱ����

L_Min_D1_Out_Pos:
	lda		Frame_Counter
	cmp		#$08
	beq		L_Min_Pos_Out
	ldx		#lcd_MS
	jsr		F_ClrpSymbol
	rts

L_Min_Pos_Out:
	rmb2	Frame_Flag							; ��λ�����������
	rmb0	Timer_Flag							; �����صı�־λ
	rmb7	Timer_Flag

	lda		#$00
	sta		R_Time_Sec							; �������
	inc		R_Time_Min							; ����

	ldx		#lcd_MS
	jsr		F_DispSymbol
	lda		#0
	sta		Frame_Counter
	rts

L_Time_Overflow:
	lda		#$1100B								; ����ʱ�����ص�����ʱ��ͣ
	sta		Sys_Status_Flag
	TMR0_OFF									; ��̬ͣ����Ҫʱ��
	TMR2_OFF
	lda		#99
	sta		R_Time_Min
	lda		#59
	sta		R_Time_Sec

	smb0	Overflow_Flag						; ��λ����ʱ�����־λ

	lda		#$00
	sta		Frame_Flag							; ��λ��ر�־λ
	rmb0	Timer_Flag
	rmb7	Timer_Flag

	jsr		F_Display_Time
	rts


F_DivideBy10:
	ldx		#0									; ��ʼ��X�Ĵ���Ϊ0
	sta		P_Temp								; ��ʱ��������
DivideBy10:
	cmp		#10									; ���A�Ƿ���ڵ���10
	bcc		Done								; ���AС��10����תDone
	sec											; ���ý�λ��׼������
	sbc		#10									; A=A-10
	inx											; X=X+1������
	bra		DivideBy10							; ���û�н�λ�ͼ���ѭ��
Done:
	sta		P_Temp								; ����
	txa
	rts






; ����ʱ����
F_Sec_Des_Counter:
	bbs0	Timer_Flag, Is_Frame_Come_Des		; ����Ϊ1ʱ���ж�֡��ʱ
	rts
; �ж��Ƿ���Ҫ��ʱ�����ǵ����Ķ���֡
Is_Frame_Come_Des:
	bbr1	Timer_Flag,Add_Sec_Out_Des			; ����ʱ��־���ʱ
	dec		R_Time_Sec
	rmb1	Timer_Flag							; ������8֡������ֻ��һ��
; û��16Hz�򲻽�����
Add_Sec_Out_Des:
	bbs7	Timer_Flag, Count_Start_Des
	rts

Count_Start_Des:
	dec		Frame_Counter						; ֡����
	lda		R_Time_Sec							; �ж��Ƿ���ڷ��ӽ�λ
	clc
	adc		#$01
	cmp		#$00
	bne		Set_BorrowFlag_Out					; �ý�(��)λ������־
	smb2	Frame_Flag
Set_BorrowFlag_Out:
	bbr2	Frame_Flag,Borrow_Out
	bra		L_BorrowToMin
Borrow_Out:
	jsr		F_DisFrame_Sec_d4					; sec��λ��ʱ����

	lda		R_Time_Sec							; ���secʮλ���޽�λ
	clc
	adc		#$01								; �ȼ����ٽ��������貹��1��
	jsr		F_DivideBy10
	cmp		#0									; ��Ϊ0��һ����ʮλ��ʮλ����ʱ
	beq		L_Sec_D3_Out_Des
	lda		P_Temp								; ������Ϊ0Ҳ������ʮλ
	cmp		#0
	bne		L_Sec_D3_Out_Des

	jsr		F_DisFrame_Sec_d3					; secʮλ��ʱ����


L_Sec_D3_Out_Des:
	lda		Frame_Counter						; ��8֡����֡����
	cmp		#$0
	beq		L_Sec_Des_Out

	ldx		#lcd_MS
	jsr		F_ClrpSymbol						; û���궯����Ϩ��MS

	rmb7	Timer_Flag							; ��16Hz�������ظ�������

	rts

L_Sec_Des_Out:
	rmb0	Timer_Flag							; �������꼴Ϊ���S
	rmb7	Timer_Flag							; ͬ����16Hz
	ldx		#lcd_MS								; ��MS������֡����
	jsr		F_DispSymbol
	lda		#$8
	sta		Frame_Counter

L_Sec_Des_rts:
	rts

L_BorrowToMin:
	smb2	Frame_Flag
	bbs1	Frame_Flag,Dec_Once_Min				; ��λ���ӣ�����8֡������ֻ��1��
	dec		R_Time_Min
	lda		#59
	sta		R_Time_Sec
	smb1	Frame_Flag
Dec_Once_Min:
	lda		R_Time_Min
	clc
	adc		#$01
	cmp		#$00
	beq		L_Time_Stop							; �Ƶ�00:00ֹͣ

	jsr		F_DisFrame_Sec_d4					; Sec��λ��ʱ
	jsr		F_DisFrame_Sec_d3					; Secʮλ��ʱ
	jsr		F_DisFrame_Min_d2					; Min��λ��ʱ

	lda		R_Time_Min							; ���Minʮλ���޽�λ
	clc
	adc		#$01
	jsr		F_DivideBy10						; ��10�ж�ʮλ�Ƿ���Ҫ����
	cmp		#0
	beq		L_Min_D1_Out_Des
	lda		P_Temp
	cmp		#0
	bne		L_Min_D1_Out_Des

	jsr		F_DisFrame_Min_d1					; Minʮλ��ʱ����

L_Min_D1_Out_Des:
	lda		Frame_Counter						; �ж�����Ϩ��MS
	cmp		#$0
	beq		L_Min_Des_Out
	ldx		#lcd_MS
	jsr		F_ClrpSymbol
	rts

L_Min_Des_Out:
	rmb1	Frame_Flag							; ���ֱ�־λ
	rmb2	Frame_Flag							; ��(��)λ��־λ
	ldx		#lcd_MS								; ����֡����
	jsr		F_DispSymbol						; �޶�������MS
	lda		#$8
	sta		Frame_Counter
	rts

L_Time_Stop:
	lda		#10000B								; ����ʱ�������뵹��ʱ���̬��������
	sta		Sys_Status_Flag
	TMR0_OFF									; �Ȳ���Time2������ʱ���̬Ҳ��Ҫ������30S
	
	lda		#$00
	sta		Frame_Flag							; ��λ��ر�־λ
	sta		R_Time_Min
	sta		R_Time_Sec
	rmb0	Timer_Flag
	rmb7	Timer_Flag

	jsr		F_Display_Time
	rts


F_Des_Counter_Finish:
	bbs0	Timer_Flag,Beep_Start				; ÿ��1���һ��
	rts
Beep_Start:
	lda		CC2
	cmp		#29
	beq		Finish_Time_Out

	lda		#01001001B							; ������������
	sta		Beep_Serial
	lda		#10B
	sta		Beep_Serial+1

	smb3	Timer_Flag							; ��ʱ��������־λ
	rmb0	Timer_Flag							; ��1���־��ֹ�ظ�����
	inc		CC2
	rts

Finish_Time_Out:
	lda		R_SetTime_Min						; ��������Ϊ����ʱ��ʼֵ
	sta		R_Time_Min
	lda		R_SetTime_Sec
	sta		R_Time_Sec
	lda		#1100B								; ״̬�л�Ϊ����ʱ��̬ͣ
	sta		Sys_Status_Flag
	rmb7	TMRC
	TMR1_OFF
	TMR2_OFF
	lda		#00
	sta		CC2

	rts