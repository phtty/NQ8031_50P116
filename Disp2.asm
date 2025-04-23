;===========================================================
;@brief		显示完整的一个数字
;@para:		A = 0~9
;			X = offset	
;@impact:	P_Temp，P_Temp+1，P_Temp+2，P_Temp+3, P_Temp+4, P_Temp+5, X，A
;===========================================================
L_Dis_7Bit_DigitDot_Prog2:
	stx		P_Temp+3					; 偏移量暂存进P_Temp+3, 腾出X来做变址寻址
	sta		P_Temp						; 将显示的数字转换为内存偏移量

	tax
	lda		Table_Digit_7bit2,x			; 将显示的数字通过查表找到对应的段码存进A
	sta		P_Temp						; 暂存段码值到P_Temp

	ldx		P_Temp+3					; 将偏移量取回
	stx		P_Temp+3					; 暂存偏移量到P_Temp+3
	lda		#7
	sta		P_Temp+4					; 设置显示段数为7
L_Judge_Dis_7Bit_DigitDot2:				; 显示循环的开始
	ldx		P_Temp+3					; 取回偏移量作为索引
	lda		Lcd_bit2,x					; 查表定位目标段的bit位
	sta		P_Temp+5	
	lda		Lcd_byte2,x					; 查表定位目标段的显存地址
	tax
	ror		P_Temp						; 循环右移取得目标段是亮或者灭
	bcc		L_CLR_7bit2					; 当前段的值若是0则进清点子程序
	lda		LCD_RamAddr,x				; 将目标段的显存的特定bit位置1来打亮
	ora		P_Temp+5
	sta		LCD_RamAddr,x
	bra		L_Inc_Dis_Index_Prog2		; 跳转到显示索引增加的子程序。
L_CLR_7bit2:	
	lda		LCD_RamAddr,x				; 加载LCD RAM的地址
	ora		P_Temp+5					; 将COM和SEG信息与LCD RAM地址进行逻辑或操作
	eor		P_Temp+5					; 进行异或操作，用于清除对应的段。
	sta		LCD_RamAddr,x				; 将结果写回LCD RAM，清除对应位置。
L_Inc_Dis_Index_Prog2:
	inc		P_Temp+3					; 递增偏移量，处理下一个段
	dec		P_Temp+4					; 递减剩余要显示的段数
	bne		L_Judge_Dis_7Bit_DigitDot2	; 剩余段数为0则返回
	rts


; 6bit数显	lcd_d2
L_Dis_6Bit_DigitDot_Prog2:
	stx		P_Temp+3					; 偏移量暂存进P_Temp+3, 腾出X来做变址寻址
	sta		P_Temp						; 将显示的数字转换为内存偏移量

	tax
	lda		Table_Digit_6bit2,x			; 将显示的数字通过查表找到对应的段码存进A
	sta		P_Temp						; 暂存段码值到P_Temp

	ldx		P_Temp+3					; 将偏移量取回
	stx		P_Temp+3					; 暂存偏移量到P_Temp+3
	lda		#6
	sta		P_Temp+4					; 设置显示段数为6
L_Judge_Dis_6Bit_DigitDot2				; 显示循环的开始
	ldx		P_Temp+3					; 取回偏移量作为索引
	lda		Lcd_bit2,x					; 查表定位目标段的bit位
	sta		P_Temp+5	
	lda		Lcd_byte2,x					; 查表定位目标段的显存地址
	tax
	ror		P_Temp						; 循环右移取得目标段是亮或者灭
	bcc		L_CLR_6bit2					; 当前段的值若是0则进清点子程序
	lda		LCD_RamAddr,x				; 将目标段的显存的特定bit位置1来打亮
	ora		P_Temp+5
	sta		LCD_RamAddr,x
	bra		L_Inc_Dis_Index_Prog_6bit2	; 跳转到显示索引增加的子程序。
L_CLR_6bit2:	
	lda		LCD_RamAddr,x				; 加载LCD RAM的地址
	ora		P_Temp+5					; 将COM和SEG信息与LCD RAM地址进行逻辑或操作
	eor		P_Temp+5					; 进行异或操作，用于清除对应的段。
	sta		LCD_RamAddr,x				; 将结果写回LCD RAM，清除对应位置。
L_Inc_Dis_Index_Prog_6bit2:
	inc		P_Temp+3					; 递增偏移量，处理下一个段
	dec		P_Temp+4					; 递减剩余要显示的段数
	bne		L_Judge_Dis_6Bit_DigitDot2	; 剩余段数为0则返回
	rts

;-----------------------------------------
;@brief:	单独的画点、清点函数,一般用于MS显示
;@para:		X = offset
;@impact:	A, X, P_Temp+2
;-----------------------------------------
F_DispSymbol2:
	jsr		F_DispSymbol_Com2
	sta		LCD_RamAddr,x				; 画点
	rts

F_ClrpSymbol2:
	jsr		F_DispSymbol_Com2			; 清点
	eor		P_Temp+2
	sta		LCD_RamAddr,x
	rts

F_DispSymbol_Com2:
	lda		Lcd_bit2,x					; 查表得知目标段的bit位
	sta		P_Temp+2
	lda		Lcd_byte2,x					; 查表得知目标段的地址
	tax
	lda		LCD_RamAddr,x				; 将目标段的显存的特定bit位置1来打亮
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
