F_Beep_Manage:
	TMR1_ON
	
	bbr5	Timer_Flag,L_Beep_rts			; ����ĳ����ͼ������1/32��
	rmb5	Timer_Flag						; ���1/32���־λ

	lda		Beep_Serial						; ��������ȫΪ0���������
	cmp		#$0
	beq		L_Beep_Over
	
	bbr0	Beep_Serial,L_No_Beep			; �ж��������е�1λ��Ϊ1���죬Ϊ0�Ͳ���
	smb7	TMRC
	clc
	ror		Beep_Serial
	ror		Beep_Serial+1

	bra		L_Beep_rts

L_No_Beep:
	rmb7	TMRC
	clc
	ror		Beep_Serial
	ror		Beep_Serial+1

L_Beep_rts:
	rts

L_Beep_Over:								; �رն�ʱ���ͷ����������λ��Ӧ��־λ
	TMR1_OFF
	rmb7	TMRC
	rmb2	Timer_Flag
	rmb3	Timer_Flag
	rts
