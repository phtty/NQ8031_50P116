F_Key_Trigger:
	bbs4	Timer_Flag,L_Quik_Add_1
	rmb0	Key_Flag
	bbr1	Key_Flag,L_Key_Wait					; �״ΰ�����������Ҫ����
	rmb1	Key_Flag							; ����״ΰ�������?
	LDA		#$00
	STA		P_Temp
L_Delay_Trigger:								; ������ʱѭ���ñ�ǩ
	inc		P_Temp
	lda		P_Temp
	bne		L_Delay_Trigger						; ��������

L_Key_Beep:
	lda		#10B								; ���ð�����ʾ������������
	sta		Beep_Serial
	lda		#$ef
	sta		TMR1
	bra		L_Quik_Add_1

L_Key_Wait:	
	lda		PA									; ����ʱ���ڿ�ӵ���ǰ��ֻ���?�ж���Ч�����Ƿ����?
	and		#$a4								; ���ر��ж�
	cmp		#$0
	beq		L_Quik_Add_2
	bne		L_Key_rts

L_Quik_Add_1:
	lda		PA									; �ж�4�ְ����������?
	and		#$A4
	cmp		#$04
	bne		No_KeyM_Trigger						; ������תѰַ���������⣬�������jmp������ת
	rmb0	Overflow_Flag						; ��һ�ΰ�������������ʱ������������?
	jmp		L_KeyM_Trigger						; M��������
No_KeyM_Trigger:
	cmp		#$20
	bne		No_KeyS_Trigger
	rmb0	Overflow_Flag
	jmp		L_KeyS_Trigger						; S��������
No_KeyS_Trigger:
	bbs4	Timer_Flag,L_Quik_Add_2				; C������ms��������Ҫ���?
	cmp		#$80
	bne		No_KeyC_Trigger
	jmp		L_KeyC_Trigger						; C��������
No_KeyC_Trigger:
	cmp		#$24
	bne		L_Quik_Add_2
	rmb0	Overflow_Flag
	jmp		L_KeyMS_Trigger						; M��Sͬʱ����

L_Quik_Add_2:
	DIS_LCD_IRQ
	rmb4	Timer_Flag							; ������Ч������ϣ��������ӱ�־�?
	rmb6	Timer_Flag
	lda		#$0
	sta		Counter_4Hz							; �������������������Ч��������?

L_Key_rts:
	rts									


L_KeyM_Trigger:
	smb2	Timer_Flag							; ������ʾ��
	; ������������ʱ̬�����������������״�?���򰴼�������Ч
	bbs3	Sys_Status_Flag,L_KeyM_Pause		; ������̬ͣ���ʼ�?����״̬����ı�?
	bbs0	Sys_Status_Flag,L_KeyM_Pause
	bbs4	Sys_Status_Flag,L_KeyM_Finish
	rts
	; ������ʼ̬����̬ͣ�����?
L_KeyM_Pause:
	lda		#1100B
	sta		Sys_Status_Flag
	inc		R_Time_Min
	lda		R_Time_Min
	sta		R_SetTime_Min						; M��ÿ����Ч������һ�ε���ʱ��ֵ
	cmp		#100
	beq		L_Reset_Min
	jsr		L_DisTimer_Min
	rts

L_Reset_Min:
	lda		#$0
	sta		R_Time_Min
	jsr		L_DisTimer_Min
	rts

; ��������ʱ����?�����?
L_KeyM_Finish:
	lda		R_SetTime_Min						; ��������Ϊ����ʱ��ʼֵ
	sta		R_Time_Min
	lda		R_SetTime_Sec
	sta		R_Time_Sec
	jsr		F_Display_Time
	lda		#1100B								; ״̬�л�Ϊ����ʱ��̬ͣ
	sta		Sys_Status_Flag
	TMR1_OFF
	rmb7	TMRC
	rts


L_KeyS_Trigger:
	smb2	Timer_Flag							; ������ʾ��
	; ������������ʱ̬�����������������״�?���򰴼�������Ч
	bbs3	Sys_Status_Flag,L_KeyS_Pause		; ������̬ͣ���ʼ�?����״̬����ı�?
	bbs0	Sys_Status_Flag,L_KeyS_Pause
	bbs4	Sys_Status_Flag,L_KeyS_Finish
	rts
	; ������ʼ̬����̬ͣ�����?
L_KeyS_Pause:
	lda		#1100B
	sta		Sys_Status_Flag						; �л�Ϊ����ʱ��̬ͣ
	
	inc		R_Time_Sec
	lda		R_Time_Sec
	sta		R_SetTime_Sec						; ÿ��S����Ч���ᴥ��һ�ε���ʱ��ֵ�ĸ���
	cmp		#60
	beq		L_Reset_Sec
	jsr		L_DisTimer_Sec
	rts

L_Reset_Sec:									; 60�����ص�0
	lda		#$0
	sta		R_Time_Sec
	jsr		L_DisTimer_Sec
	rts

; ��������ʱ����?�����?
L_KeyS_Finish:
	lda		R_SetTime_Min						; ��������Ϊ����ʱ��ʼֵ
	sta		R_Time_Min
	lda		R_SetTime_Sec
	sta		R_Time_Sec
	jsr		F_Display_Time
	lda		#1100B								; ״̬�л�Ϊ����ʱ��̬ͣ
	sta		Sys_Status_Flag
	TMR1_OFF
	rmb7	TMRC
	rts


L_KeyC_Trigger:
	smb2	Timer_Flag							; ������ʾ��

	bbs4	Sys_Status_Flag,L_KeyC_Finish		; ����ʱ����?����
	bbs0	Overflow_Flag,L_KeyC_Overflow		; ����ʱ���ʱ���⴦��?
	lda		Sys_Status_Flag						; ������������ʱ̬����תΪ��Ӧ��̬ͣ
	cmp		#$02
	beq		L_KeyC_PosDes
	cmp		#$04
	beq		L_KeyC_PosDes

	bbs3	Sys_Status_Flag,L_KeyC_Pause		; ������������ʱ��̬ͣ����תΪ��Ӧ��ʱ̬
	; ������ʼ̬�����?
	lda		#$02								; ��������ʱ̬
	sta		Sys_Status_Flag
	lda		#$00
	sta		Frame_Counter
	sta		Frame_Flag
	TMR2_ON
	TMR0_ON
	smb0	Timer_Flag
	rts

	; ����������ʱ�е����?
L_KeyC_PosDes:
	smb3	Sys_Status_Flag						; ������������ʱ��̬ͣ
	jsr		F_Display_Time
	TMR2_OFF									; �ص������ʱ��֡���?
	TMR0_OFF
	rts

	; ������̬ͣ�����?
L_KeyC_Pause:
	rmb3	Sys_Status_Flag						; �˳���̬ͣ
	jsr		Init_Frame_Count					; ��ʼ��FrameCount

	TMR2_ON										; �������������ʱ��֡���?
	TMR0_ON
	rts

L_KeyC_Finish:
	lda		R_SetTime_Min						; ��������Ϊ����ʱ��ʼֵ
	sta		R_Time_Min
	lda		R_SetTime_Sec
	sta		R_Time_Sec
	jsr		F_Display_Time
	lda		#1100B								; ״̬�л�Ϊ����ʱ��̬ͣ
	sta		Sys_Status_Flag
	TMR1_OFF
	rmb7	TMRC
	rts

L_KeyC_Overflow:								; ���������ʱ��ɺ�C
	rmb0	Overflow_Flag						; ��������м������ص���ʼ�?
	lda		#00
	sta		R_Time_Min
	sta		R_Time_Sec
	lda		#01
	sta		Sys_Status_Flag



L_KeyMS_Trigger:
	lda		#$0									; �ص���ʼ̬��ȫ������
	sta		R_Time_Sec
	sta		R_Time_Min
	sta		Key_Flag
	sta		Sys_Status_Flag
	smb0	Sys_Status_Flag
	sta		Frame_Flag							; ��λ��ر�־�?
	rmb0	Timer_Flag
	rmb7	Timer_Flag
	sta		TMR2								; �رհ����ʱ������ռĴ���
	TMR2_OFF
	TMR0_OFF

	smb2	Timer_Flag							; ������ʾ����־λ
	jsr		F_Display_Time
	rts

Init_Frame_Count:
	lda		#$00
	sta		Frame_Flag							; ��λ��ر�־�?
	rmb0	Timer_Flag
	rmb7	Timer_Flag
	bbs1	Sys_Status_Flag, Pos_Frame_Count	; ����Ŀǰ��ʱ״̬��ʼ��֡����
	lda		#$08
	sta		Frame_Counter
	rts
Pos_Frame_Count:
	lda		#$00
	sta		Frame_Counter
	rts
