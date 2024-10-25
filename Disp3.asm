; 显示星期的第1个字母
L_Dis_14Bit_DigitDot_Prog3:
	stx		P_Temp+2					; 偏移量暂存进P_Temp+2, 腾出X来做变址寻址

	clc
	rol									; 乘以2得到正确的偏移量
	tax
	lda		Table_Digit_14bit,x			; 将显示的数字通过查表找到对应的段码存进A
	sta		P_Temp+1					; 暂存段码值到P_Temp、P_Temp+1
	inx
	lda		Table_Digit_14bit,x
	sta		P_Temp

	lda		#14
	sta		P_Temp+3					; 设置显示段数为14
L_Judge_Dis_14Bit_DigitDot3:			; 显示循环的开始
	ldx		P_Temp+2					; 表头偏移量->X
	lda		Lcd3_bit,x					; 查表定位目标段的bit位
	sta		P_Temp+4					; bit位->P_Temp+4
	lda		Lcd3_byte,x					; 查表定位目标段的显存地址
	tax									; 显存地址偏移->X
	ror		P_Temp						; 循环右移取得目标段是亮或者灭
	ror		P_Temp+1
	bcc		L_CLR_14bit3				; 当前段的值若是0则进清点子程序
	lda		LCD_RamAddr,x				; 将目标段的显存的特定bit位置1来打亮
	ora		P_Temp+4
	sta		LCD_RamAddr,x
	bra		L_Inc_Dis_Index_Prog_14bit3	; 跳转到显示索引增加的子程序。
L_CLR_14bit3:	
	lda		LCD_RamAddr,x				; 加载LCD RAM的地址
	ora		P_Temp+4					; 将COM和SEG信息与LCD RAM地址进行逻辑或操作
	eor		P_Temp+4					; 进行异或操作，用于清除对应的段。
	sta		LCD_RamAddr,x				; 将结果写回LCD RAM，清除对应位置。
L_Inc_Dis_Index_Prog_14bit3:
	inc		P_Temp+2					; 递增偏移量，处理下一个段
	dec		P_Temp+3					; 递减剩余要显示的段数
	bne		L_Judge_Dis_14Bit_DigitDot3	; 剩余段数为0则返回
	rts

; 显示星期的第3个字母
L_Dis_12Bit_DigitDot_Prog3:
	stx		P_Temp+2					; 偏移量暂存进P_Temp+2, 腾出X来做变址寻址

	clc
	rol									; 乘以2得到正确的偏移量
	tax
	lda		Table_Digit_12bit,x			; 将显示的数字通过查表找到对应的段码存进A
	sta		P_Temp+1					; 暂存段码值到P_Temp、P_Temp+1
	inx
	lda		Table_Digit_12bit,x
	sta		P_Temp

	lda		#12
	sta		P_Temp+3					; 设置显示段数为12
L_Judge_Dis_12Bit_DigitDot3:				; 显示循环的开始
	ldx		P_Temp+2					; 表头偏移量->X
	lda		Lcd3_bit,x					; 查表定位目标段的bit位
	sta		P_Temp+4					; bit位->P_Temp+4
	lda		Lcd3_byte,x					; 查表定位目标段的显存地址
	tax									; 显存地址偏移->X
	ror		P_Temp						; 循环右移取得目标段是亮或者灭
	ror		P_Temp+1
	bcc		L_CLR_12bit3				; 当前段的值若是0则进清点子程序
	lda		LCD_RamAddr,x				; 将目标段的显存的特定bit位置1来打亮
	ora		P_Temp+4
	sta		LCD_RamAddr,x
	bra		L_Inc_Dis_Index_Prog_12bit3	; 跳转到显示索引增加的子程序。
L_CLR_12bit3:	
	lda		LCD_RamAddr,x				; 加载LCD RAM的地址
	ora		P_Temp+4					; 将COM和SEG信息与LCD RAM地址进行逻辑或操作
	eor		P_Temp+4					; 进行异或操作，用于清除对应的段。
	sta		LCD_RamAddr,x				; 将结果写回LCD RAM，清除对应位置。
L_Inc_Dis_Index_Prog_12bit3:
	inc		P_Temp+2					; 递增偏移量，处理下一个段
	dec		P_Temp+3					; 递减剩余要显示的段数
	bne		L_Judge_Dis_12Bit_DigitDot3	; 剩余段数为0则返回
	rts

; 显示星期的第2个字母
L_Dis_9Bit_DigitDot_Prog3:
	stx		P_Temp+2					; 偏移量暂存进P_Temp+2, 腾出X来做变址寻址

	clc
	rol									; 乘以2得到正确的偏移量
	tax
	lda		Table_Digit_9bit,x			; 将显示的数字通过查表找到对应的段码存进A
	sta		P_Temp+1					; 暂存段码值到P_Temp、P_Temp+1
	inx
	lda		Table_Digit_9bit,x
	sta		P_Temp

	lda		#9
	sta		P_Temp+3					; 设置显示段数为9
L_Judge_Dis_9Bit_DigitDot3:				; 显示循环的开始
	ldx		P_Temp+2					; 表头偏移量->X
	lda		Lcd3_bit,x					; 查表定位目标段的bit位
	sta		P_Temp+4					; bit位->P_Temp+4
	lda		Lcd3_byte,x					; 查表定位目标段的显存地址
	tax									; 显存地址偏移->X
	ror		P_Temp						; 循环右移取得目标段是亮或者灭
	ror		P_Temp+1
	bcc		L_CLR_9bit3					; 当前段的值若是0则进清点子程序
	lda		LCD_RamAddr,x				; 将目标段的显存的特定bit位置1来打亮
	ora		P_Temp+4
	sta		LCD_RamAddr,x
	bra		L_Inc_Dis_Index_Prog_9bit3	; 跳转到显示索引增加的子程序。
L_CLR_9bit3:	
	lda		LCD_RamAddr,x				; 加载LCD RAM的地址
	ora		P_Temp+4					; 将COM和SEG信息与LCD RAM地址进行逻辑或操作
	eor		P_Temp+4					; 进行异或操作，用于清除对应的段。
	sta		LCD_RamAddr,x				; 将结果写回LCD RAM，清除对应位置。
L_Inc_Dis_Index_Prog_9bit3:
	inc		P_Temp+2					; 递增偏移量，处理下一个段
	dec		P_Temp+3					; 递减剩余要显示的段数
	bne		L_Judge_Dis_9Bit_DigitDot3	; 剩余段数为0则返回
	rts

;===========================================================
;@brief		显示完整的一个数字
;@para:		A = 0~9
;			X = offset	
;@impact:	P_Temp，P_Temp+1，P_Temp+2，P_Temp+3, X，A
;===========================================================
L_Dis_7Bit_DigitDot_Prog3:
	stx		P_Temp+1					; 偏移量暂存进P_Temp+3, 腾出X来做变址寻址
	sta		P_Temp						; 将显示的数字转换为内存偏移量

	tax
	lda		Table_Digit_7bit,x			; 将显示的数字通过查表找到对应的段码存进A
	sta		P_Temp						; 暂存段码值到P_Temp

	ldx		P_Temp+1					; 将偏移量取回
	stx		P_Temp+1					; 暂存偏移量到P_Temp+3
	lda		#7
	sta		P_Temp+2					; 设置显示段数为7
L_Judge_Dis_7Bit_DigitDot3:				; 显示循环的开始
	ldx		P_Temp+1					; 取回偏移量作为索引
	lda		Lcd3_bit,x					; 查表定位目标段的bit位
	sta		P_Temp+3	
	lda		Lcd3_byte,x					; 查表定位目标段的显存地址
	tax
	ror		P_Temp						; 循环右移取得目标段是亮或者灭
	bcc		L_CLR_7bit3					; 当前段的值若是0则进清点子程序
	lda		LCD_RamAddr,x				; 将目标段的显存的特定bit位置1来打亮
	ora		P_Temp+3
	sta		LCD_RamAddr,x
	bra		L_Inc_Dis_Index_Prog_7bit3	; 跳转到显示索引增加的子程序。
L_CLR_7bit3:	
	lda		LCD_RamAddr,x				; 加载LCD RAM的地址
	ora		P_Temp+3					; 将COM和SEG信息与LCD RAM地址进行逻辑或操作
	eor		P_Temp+3					; 进行异或操作，用于清除对应的段。
	sta		LCD_RamAddr,x				; 将结果写回LCD RAM，清除对应位置。
L_Inc_Dis_Index_Prog_7bit3:
	inc		P_Temp+1					; 递增偏移量，处理下一个段
	dec		P_Temp+2					; 递减剩余要显示的段数
	bne		L_Judge_Dis_7Bit_DigitDot3	; 剩余段数为0则返回
	rts


; 6bit数显	lcd_d9
L_Dis_6Bit_DigitDot_Prog3:
	stx		P_Temp+1					; 偏移量暂存进P_Temp+3, 腾出X来做变址寻址
	sta		P_Temp						; 将显示的数字转换为内存偏移量

	tax
	lda		Table_Digit_6bit,x			; 将显示的数字通过查表找到对应的段码存进A
	sta		P_Temp						; 暂存段码值到P_Temp

	ldx		P_Temp+1					; 将偏移量取回
	stx		P_Temp+1					; 暂存偏移量到P_Temp+3
	lda		#6
	sta		P_Temp+2					; 设置显示段数为6
L_Judge_Dis_6Bit_DigitDot3				; 显示循环的开始
	ldx		P_Temp+1					; 取回偏移量作为索引
	lda		Lcd3_bit,x					; 查表定位目标段的bit位
	sta		P_Temp+3	
	lda		Lcd3_byte,x					; 查表定位目标段的显存地址
	tax
	ror		P_Temp						; 循环右移取得目标段是亮或者灭
	bcc		L_CLR_6bit3					; 当前段的值若是0则进清点子程序
	lda		LCD_RamAddr,x				; 将目标段的显存的特定bit位置1来打亮
	ora		P_Temp+3
	sta		LCD_RamAddr,x
	bra		L_Inc_Dis_Index_Prog_6bit3	; 跳转到显示索引增加的子程序。
L_CLR_6bit3:	
	lda		LCD_RamAddr,x				; 加载LCD RAM的地址
	ora		P_Temp+3					; 将COM和SEG信息与LCD RAM地址进行逻辑或操作
	eor		P_Temp+3					; 进行异或操作，用于清除对应的段。
	sta		LCD_RamAddr,x				; 将结果写回LCD RAM，清除对应位置。
L_Inc_Dis_Index_Prog_6bit3:
	inc		P_Temp+1					; 递增偏移量，处理下一个段
	dec		P_Temp+2					; 递减剩余要显示的段数
	bne		L_Judge_Dis_6Bit_DigitDot3	; 剩余段数为0则返回
	rts

; 3bit数显 lcd_d0&lcd_d7
L_Dis_4Bit_DigitDot_Prog3:
	stx		P_Temp+1					; 偏移量暂存进P_Temp+3, 腾出X来做变址寻址
	sta		P_Temp						; 将显示的数字转换为内存偏移量

	tax
	lda		Table_Digit_4bit,x			; 将显示的数字通过查表找到对应的段码存进A
	sta		P_Temp						; 暂存段码值到P_Temp

	ldx		P_Temp+1					; 将偏移量取回
	stx		P_Temp+1					; 暂存偏移量到P_Temp+3
	lda		#4
	sta		P_Temp+2					; 设置显示段数为3
L_Judge_Dis_4Bit_DigitDot3				; 显示循环的开始
	ldx		P_Temp+1					; 取回偏移量作为索引
	lda		Lcd3_bit,x					; 查表定位目标段的bit位
	sta		P_Temp+3	
	lda		Lcd3_byte,x					; 查表定位目标段的显存地址
	tax
	ror		P_Temp						; 循环右移取得目标段是亮或者灭
	bcc		L_CLR_4bit3					; 当前段的值若是0则进清点子程序
	lda		LCD_RamAddr,x				; 将目标段的显存的特定bit位置1来打亮
	ora		P_Temp+3
	sta		LCD_RamAddr,x
	bra		L_Inc_Dis_Index_Prog_4bit3	; 跳转到显示索引增加的子程序
L_CLR_4bit3:
	lda		LCD_RamAddr,x				; 加载LCD RAM的地址
	ora		P_Temp+3					; 将COM和SEG信息与LCD RAM地址进行逻辑或操作
	eor		P_Temp+3					; 进行异或操作，用于清除对应的段
	sta		LCD_RamAddr,x				; 将结果写回LCD RAM，清除对应位置
L_Inc_Dis_Index_Prog_4bit3:
	inc		P_Temp+1					; 递增偏移量，处理下一个段
	dec		P_Temp+2					; 递减剩余要显示的段数
	bne		L_Judge_Dis_4Bit_DigitDot3	; 剩余段数为0则返回
	rts

; 3bit数显 lcd_d0&lcd_d7
L_Dis_3Bit_DigitDot_Prog3:
	stx		P_Temp+1					; 偏移量暂存进P_Temp+3, 腾出X来做变址寻址
	sta		P_Temp						; 将显示的数字转换为内存偏移量

	tax
	lda		Table_Digit_3bit,x			; 将显示的数字通过查表找到对应的段码存进A
	sta		P_Temp						; 暂存段码值到P_Temp

	ldx		P_Temp+1					; 将偏移量取回
	stx		P_Temp+1					; 暂存偏移量到P_Temp+3
	lda		#3
	sta		P_Temp+2					; 设置显示段数为3
L_Judge_Dis_3Bit_DigitDot3				; 显示循环的开始
	ldx		P_Temp+1					; 取回偏移量作为索引
	lda		Lcd3_bit,x					; 查表定位目标段的bit位
	sta		P_Temp+3	
	lda		Lcd3_byte,x					; 查表定位目标段的显存地址
	tax
	ror		P_Temp						; 循环右移取得目标段是亮或者灭
	bcc		L_CLR_3bit3					; 当前段的值若是0则进清点子程序
	lda		LCD_RamAddr,x				; 将目标段的显存的特定bit位置1来打亮
	ora		P_Temp+3
	sta		LCD_RamAddr,x
	bra		L_Inc_Dis_Index_Prog_3bit3	; 跳转到显示索引增加的子程序
L_CLR_3bit3:
	lda		LCD_RamAddr,x				; 加载LCD RAM的地址
	ora		P_Temp+3					; 将COM和SEG信息与LCD RAM地址进行逻辑或操作
	eor		P_Temp+3					; 进行异或操作，用于清除对应的段
	sta		LCD_RamAddr,x				; 将结果写回LCD RAM，清除对应位置
L_Inc_Dis_Index_Prog_3bit3:
	inc		P_Temp+1					; 递增偏移量，处理下一个段
	dec		P_Temp+2					; 递减剩余要显示的段数
	bne		L_Judge_Dis_3Bit_DigitDot3	; 剩余段数为0则返回
	rts

;-----------------------------------------
;@brief:	单独的画点、清点函数,一般用于MS显示
;@para:		X = offset
;@impact:	A, X, P_Temp+2
;-----------------------------------------
F_DispSymbol3:
	jsr		F_DispSymbol_Com3
	sta		LCD_RamAddr,x				; 画点
	rts

F_ClrpSymbol3:
	jsr		F_DispSymbol_Com3			; 清点
	eor		P_Temp+2
	sta		LCD_RamAddr,x
	rts

F_DispSymbol_Com3:
	lda		Lcd3_bit,x					; 查表得知目标段的bit位
	sta		P_Temp+2
	lda		Lcd3_byte,x					; 查表得知目标段的地址
	tax
	lda		LCD_RamAddr,x				; 将目标段的显存的特定bit位置1来打亮
	ora		P_Temp+2
	rts
