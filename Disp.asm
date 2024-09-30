;===========================================================
; LCD_RamAddr		.equ	0200H
;===========================================================
F_FillScreen:
	lda		#$ff
	bne		L_FillLcd
F_ClearScreen:
	lda		#0
L_FillLcd:
	sta		$1800
	sta		$1801
	sta		$1804
	sta		$1805
	sta		$1806
	sta		$1807
	sta		$180A
	sta		$180B
	sta		$180C
	sta		$180D
	sta		$1810
	sta		$1811
	sta		$1812
	sta		$1813
	sta		$1816
	sta		$1817
	sta		$1818
	sta		$1819
	sta		$181C
	sta		$181D
	sta		$181E
	sta		$181F
	sta		$1822
	sta		$1823

	rts
;===========================================================
;@brief		显示完整的一个数字
;@para:		A = 0~9
;			X = offset	
;@impact:	P_Temp，P_Temp+1，P_Temp+2，P_Temp+3, P_Temp+4, P_Temp+5, X，A
;===========================================================
L_Dis_7Bit_DigitDot_Prog:
	stx		P_Temp+3					; 偏移量暂存进P_Temp+3, 腾出X来做变址寻址
	sta		P_Temp						; 将显示的数字转换为内存偏移量

	tax
	lda		Table_Digit_7bit,X			; 将显示的数字通过查表找到对应的段码存进A
	sta		P_Temp						; 暂存段码值到P_Temp

	ldx		P_Temp+3					; 将偏移量取回
	stx		P_Temp+3					; 暂存偏移量到P_Temp+3
	lda		#7
	sta		P_Temp+4					; 设置显示段数为7
L_Judge_Dis_7Bit_DigitDot:				; 显示循环的开始
	ldx		P_Temp+3					; 取回偏移量作为索引
	lda		Lcd_bit,X					; 查表定位目标段的bit位
	sta		P_Temp+5	
	lda		Lcd_byte,X					; 查表定位目标段的显存地址
	tax
	ror		P_Temp						; 循环右移取得目标段是亮或者灭
	bcc		L_CLR_7bit					; 当前段的值若是0则进清点子程序
	lda		LCD_RamAddr,X				; 将目标段的显存的特定bit位置1来打亮
	ora		P_Temp+5
	sta		LCD_RamAddr,X
	bra		L_Inc_Dis_Index_Prog		; 跳转到显示索引增加的子程序。
L_CLR_7bit:	
	lda		LCD_RamAddr,X				; 加载LCD RAM的地址
	ora		P_Temp+5					; 将COM和SEG信息与LCD RAM地址进行逻辑或操作
	eor		P_Temp+5					; 进行异或操作，用于清除对应的段。
	sta		LCD_RamAddr,X				; 将结果写回LCD RAM，清除对应位置。
L_Inc_Dis_Index_Prog:
	inc		P_Temp+3					; 递增偏移量，处理下一个段
	dec		P_Temp+4					; 递减剩余要显示的段数
	bne		L_Judge_Dis_7Bit_DigitDot	; 剩余段数为0则返回
	rts


; 6bit数显
L_Dis_6Bit_DigitDot_Prog:
	stx		P_Temp+3					; 偏移量暂存进P_Temp+3, 腾出X来做变址寻址
	sta		P_Temp						; 将显示的数字转换为内存偏移量

	tax
	lda		Table_Digit_6bit,X			; 将显示的数字通过查表找到对应的段码存进A
	sta		P_Temp						; 暂存段码值到P_Temp

	ldx		P_Temp+3					; 将偏移量取回
	stx		P_Temp+3					; 暂存偏移量到P_Temp+3
	lda		#6
	sta		P_Temp+4					; 设置显示段数为6
L_Judge_Dis_6Bit_DigitDot				; 显示循环的开始
	ldx		P_Temp+3					; 取回偏移量作为索引
	lda		Lcd_bit,X					; 查表定位目标段的bit位
	sta		P_Temp+5	
	lda		Lcd_byte,X					; 查表定位目标段的显存地址
	tax
	ror		P_Temp						; 循环右移取得目标段是亮或者灭
	bcc		L_CLR_6bit					; 当前段的值若是0则进清点子程序
	lda		LCD_RamAddr,X				; 将目标段的显存的特定bit位置1来打亮
	ora		P_Temp+5
	sta		LCD_RamAddr,X
	bra		L_Inc_Dis_Index_Prog_6bit	; 跳转到显示索引增加的子程序。
L_CLR_6bit:	
	lda		LCD_RamAddr,X				; 加载LCD RAM的地址
	ora		P_Temp+5					; 将COM和SEG信息与LCD RAM地址进行逻辑或操作
	eor		P_Temp+5					; 进行异或操作，用于清除对应的段。
	sta		LCD_RamAddr,X				; 将结果写回LCD RAM，清除对应位置。
L_Inc_Dis_Index_Prog_6bit:
	inc		P_Temp+3					; 递增偏移量，处理下一个段
	dec		P_Temp+4					; 递减剩余要显示的段数
	bne		L_Judge_Dis_6Bit_DigitDot	; 剩余段数为0则返回
	rts

; 3bit数显
L_Dis_3Bit_DigitDot_Prog:
	stx		P_Temp+3					; 偏移量暂存进P_Temp+3, 腾出X来做变址寻址
	sta		P_Temp						; 将显示的数字转换为内存偏移量

	tax
	lda		Table_Digit_3bit,X			; 将显示的数字通过查表找到对应的段码存进A
	sta		P_Temp						; 暂存段码值到P_Temp

	ldx		P_Temp+3					; 将偏移量取回
	stx		P_Temp+3					; 暂存偏移量到P_Temp+3
	lda		#3
	sta		P_Temp+4					; 设置显示段数为3
L_Judge_Dis_3Bit_DigitDot				; 显示循环的开始
	ldx		P_Temp+3					; 取回偏移量作为索引
	lda		Lcd_bit,X					; 查表定位目标段的bit位
	sta		P_Temp+5	
	lda		Lcd_byte,X					; 查表定位目标段的显存地址
	tax
	ror		P_Temp						; 循环右移取得目标段是亮或者灭
	bcc		L_CLR_6bit					; 当前段的值若是0则进清点子程序
	lda		LCD_RamAddr,X				; 将目标段的显存的特定bit位置1来打亮
	ora		P_Temp+5
	sta		LCD_RamAddr,X
	bra		L_Inc_Dis_Index_Prog_3bit	; 跳转到显示索引增加的子程序。
L_CLR_3bit:
	lda		LCD_RamAddr,X				; 加载LCD RAM的地址
	ora		P_Temp+5					; 将COM和SEG信息与LCD RAM地址进行逻辑或操作
	eor		P_Temp+5					; 进行异或操作，用于清除对应的段。
	sta		LCD_RamAddr,X				; 将结果写回LCD RAM，清除对应位置。
L_Inc_Dis_Index_Prog_3bit:
	inc		P_Temp+3					; 递增偏移量，处理下一个段
	dec		P_Temp+4					; 递减剩余要显示的段数
	bne		L_Judge_Dis_3Bit_DigitDot	; 剩余段数为0则返回
	rts

;-----------------------------------------
;@brief:	单独的画点、清点函数,一般用于MS显示
;@para:		X = offset
;@impact:	A, X, P_Temp+2
;-----------------------------------------
F_DispSymbol:
	jsr		F_DispSymbol_Com
	sta		LCD_RamAddr,X				; 画点
	rts

F_ClrpSymbol:
	jsr		F_DispSymbol_Com			; 清点
	eor		P_Temp+2
	sta		LCD_RamAddr,X
	rts

F_DispSymbol_Com:
	lda		Lcd_bit,X					; 查表得知目标段的bit位
	sta		P_Temp+2	
	lda		Lcd_byte,X					; 查表得知目标段的地址
	tax
	lda		LCD_RamAddr,X				; 将目标段的显存的特定bit位置1来打亮
	ora		P_Temp+2
	rts


;============================================================

Table_Digit_7bit:
	.byte $3f	; 0
	.byte $06	; 1
	.byte $5b	; 2
	.byte $4f	; 3
	.byte $66	; 4
	.byte $6d	; 5
	.byte $7d	; 6
	.byte $07	; 7
	.byte $7f	; 8
	.byte $6f	; 9

Table_Digit_6bit:
	.byte $00	; 0
	.byte $06	; 1
	.byte $3b	; 2
	.byte $2f	; 3

Table_Digit_3bit:
	.byte $00	; 0
	.byte $06	; 1
	.byte $03	; 2