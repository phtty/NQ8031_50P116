;===========================================================
;@brief		��ʾ������һ������
;@para:		A = 0~9
;			X = offset	
;@impact:	P_Temp��P_Temp+1��P_Temp+2��P_Temp+3, P_Temp+4, P_Temp+5, X��A
;===========================================================
L_Dis_7Bit_DigitDot_Prog2:
	stx		P_Temp+3					; ƫ�����ݴ��P_Temp+3, �ڳ�X������ַѰַ
	sta		P_Temp						; ����ʾ������ת��Ϊ�ڴ�ƫ����

	tax
	lda		Table_Digit_7bit2,x			; ����ʾ������ͨ������ҵ���Ӧ�Ķ�����A
	sta		P_Temp						; �ݴ����ֵ��P_Temp

	ldx		P_Temp+3					; ��ƫ����ȡ��
	stx		P_Temp+3					; �ݴ�ƫ������P_Temp+3
	lda		#7
	sta		P_Temp+4					; ������ʾ����Ϊ7
L_Judge_Dis_7Bit_DigitDot2:				; ��ʾѭ���Ŀ�ʼ
	ldx		P_Temp+3					; ȡ��ƫ������Ϊ����
	lda		Lcd_bit2,x					; ���λĿ��ε�bitλ
	sta		P_Temp+5	
	lda		Lcd_byte2,x					; ���λĿ��ε��Դ��ַ
	tax
	ror		P_Temp						; ѭ������ȡ��Ŀ�������������
	bcc		L_CLR_7bit2					; ��ǰ�ε�ֵ����0�������ӳ���
	lda		LCD_RamAddr,x				; ��Ŀ��ε��Դ���ض�bitλ��1������
	ora		P_Temp+5
	sta		LCD_RamAddr,x
	bra		L_Inc_Dis_Index_Prog2		; ��ת����ʾ�������ӵ��ӳ���
L_CLR_7bit2:	
	lda		LCD_RamAddr,x				; ����LCD RAM�ĵ�ַ
	ora		P_Temp+5					; ��COM��SEG��Ϣ��LCD RAM��ַ�����߼������
	eor		P_Temp+5					; ���������������������Ӧ�ĶΡ�
	sta		LCD_RamAddr,x				; �����д��LCD RAM�������Ӧλ�á�
L_Inc_Dis_Index_Prog2:
	inc		P_Temp+3					; ����ƫ������������һ����
	dec		P_Temp+4					; �ݼ�ʣ��Ҫ��ʾ�Ķ���
	bne		L_Judge_Dis_7Bit_DigitDot2	; ʣ�����Ϊ0�򷵻�
	rts


; 6bit����	lcd_d2
L_Dis_6Bit_DigitDot_Prog2:
	stx		P_Temp+3					; ƫ�����ݴ��P_Temp+3, �ڳ�X������ַѰַ
	sta		P_Temp						; ����ʾ������ת��Ϊ�ڴ�ƫ����

	tax
	lda		Table_Digit_6bit2,x			; ����ʾ������ͨ������ҵ���Ӧ�Ķ�����A
	sta		P_Temp						; �ݴ����ֵ��P_Temp

	ldx		P_Temp+3					; ��ƫ����ȡ��
	stx		P_Temp+3					; �ݴ�ƫ������P_Temp+3
	lda		#6
	sta		P_Temp+4					; ������ʾ����Ϊ6
L_Judge_Dis_6Bit_DigitDot2				; ��ʾѭ���Ŀ�ʼ
	ldx		P_Temp+3					; ȡ��ƫ������Ϊ����
	lda		Lcd_bit2,x					; ���λĿ��ε�bitλ
	sta		P_Temp+5	
	lda		Lcd_byte2,x					; ���λĿ��ε��Դ��ַ
	tax
	ror		P_Temp						; ѭ������ȡ��Ŀ�������������
	bcc		L_CLR_6bit2					; ��ǰ�ε�ֵ����0�������ӳ���
	lda		LCD_RamAddr,x				; ��Ŀ��ε��Դ���ض�bitλ��1������
	ora		P_Temp+5
	sta		LCD_RamAddr,x
	bra		L_Inc_Dis_Index_Prog_6bit2	; ��ת����ʾ�������ӵ��ӳ���
L_CLR_6bit2:	
	lda		LCD_RamAddr,x				; ����LCD RAM�ĵ�ַ
	ora		P_Temp+5					; ��COM��SEG��Ϣ��LCD RAM��ַ�����߼������
	eor		P_Temp+5					; ���������������������Ӧ�ĶΡ�
	sta		LCD_RamAddr,x				; �����д��LCD RAM�������Ӧλ�á�
L_Inc_Dis_Index_Prog_6bit2:
	inc		P_Temp+3					; ����ƫ������������һ����
	dec		P_Temp+4					; �ݼ�ʣ��Ҫ��ʾ�Ķ���
	bne		L_Judge_Dis_6Bit_DigitDot2	; ʣ�����Ϊ0�򷵻�
	rts

;-----------------------------------------
;@brief:	�����Ļ��㡢��㺯��,һ������MS��ʾ
;@para:		X = offset
;@impact:	A, X, P_Temp+2
;-----------------------------------------
F_DispSymbol2:
	jsr		F_DispSymbol_Com2
	sta		LCD_RamAddr,x				; ����
	rts

F_ClrpSymbol2:
	jsr		F_DispSymbol_Com2			; ���
	eor		P_Temp+2
	sta		LCD_RamAddr,x
	rts

F_DispSymbol_Com2:
	lda		Lcd_bit2,x					; ����֪Ŀ��ε�bitλ
	sta		P_Temp+2
	lda		Lcd_byte2,x					; ����֪Ŀ��εĵ�ַ
	tax
	lda		LCD_RamAddr,x				; ��Ŀ��ε��Դ���ض�bitλ��1������
	ora		P_Temp+2
	rts


;============================================================

Table_Digit_7bit2:
	.byte	$3f	; 0
	.byte	$06	; 1
	.byte	$5b	; 2
	.byte	$4f	; 3
	.byte	$66	; 4
	.byte	$6d	; 5
	.byte	$7d	; 6
	.byte	$07	; 7
	.byte	$7f	; 8
	.byte	$6f	; 9
	.byte	$00	; undisplay

Table_Digit_6bit2:
	.byte	$1f	; 0
	.byte	$06	; 1
	.byte	$2b	; 2
	.byte	$27	; 3
	.byte	$36	; 4
	.byte	$35	; 5
	.byte	$00	; undisplay
