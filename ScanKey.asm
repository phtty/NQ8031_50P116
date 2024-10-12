F_Key_Trigger:									; 按键部分处理
	bbs4	Timer_Flag,L_Quik_Add_1
	rmb0	Key_Flag
	bbr1	Key_Flag,L_Key_Wait					; 首次按键触发需要消抖
	rmb1	Key_Flag							; 清除首次按键触发标志位
	lda		#$00
	sta		P_Temp
L_Delay_Trigger:								; 消抖延时循环用标签
	inc		P_Temp
	lda		P_Temp
	bne		L_Delay_Trigger						; 软件消抖
	bra		L_Quik_Add_1

L_Key_Wait:	
	lda		PA									; 长按时，在快加到来前，只需要判断有效按键是否存在
	and		#$a4								; 并关闭中断
	cmp		#$0
	beq		L_Quik_Add_2
	bne		L_Key_rts

L_Quik_Add_1:
	lda		PA									; 判断4种按键触发情况
	and		#$F0
	cmp		#$80
	bne		No_KeyM_Trigger						; 由于跳转指令寻址能力的问题，这里采用jmp进行跳转
	jmp		L_KeyM_Trigger						; Min/Date单独触发
No_KeyM_Trigger:
	cmp		#$40
	bne		No_KeyH_Trigger
	jmp		L_KeyH_Trigger						; Hour/Month单独触发
No_KeyH_Trigger:
	cmp		#$20
	bne		No_KeyB_Trigger
	jmp		L_KeyB_Trigger						; Backlight/SNZ单独触发
No_KeyB_Trigger:
	cmp		#$10
	bne		L_Quik_Add_2
	jmp		L_KeyS_Trigger						; 12/24h & year触发

L_Quik_Add_2:
	DIS_LCD_IRQ
	rmb4	Timer_Flag							; 若无有效按键组合，则清掉快加标志位
	rmb6	Timer_Flag
	lda		#$0
	sta		Counter_4Hz							; 非以上四种情况则属无效按键触发

L_Key_rts:
	rts									


L_KeyM_Trigger:
	rts
L_KeyH_Trigger:
	rts
L_KeyB_Trigger:
	rts
L_KeyS_Trigger:
	rts


; 拨键只发生状态变化，不需要处理额外内容
F_Switch_Scan:									; 拨键部分需要扫描处理
	lda		PC
	cmp		P_PC_IO_Backup						; 判断IO口状态是否与上次相同
	bne		L_Switch_Delay						; 如果不同说明拨键状态有改变，进消抖
	rts
L_Switch_Delay:
	lda		#$00
	sta		P_Temp
L_Delay_S:										; 消抖延时循环用标签
	inc		P_Temp
	lda		P_Temp
	bne		L_Delay_S							; 软件消抖

	lda		P_PC_IO_Backup
	cmp		PC
	bne		L_Switched
	rts
L_Switched:										; 检测到IO口状态与上次的不同，则进入拨键处理
	lda		PC
	sta		P_PC_IO_Backup						; 更新保存的IO口状态

	and		#$04
	cmp		#$04
	bne		Alarm_OFF
	jsr		Switch_Alarm_ON
	bra		Alarm_ON
Alarm_OFF:
	jsr		Switch_Alarm_OFF
	bra		Sys_Mode_Process
Alarm_ON:
	jsr		Switch_Alarm_ON
Sys_Mode_Process:
	lda		PC
	and		#$38
	cmp		#$00
	bne		No_Runtime_Mode
	jmp		Switch_Runtime_Mode
No_Runtime_Mode:
	lda		PC
	and		#$08
	cmp		#$08
	bne		No_Date_Set_Mode
	jmp		Switch_Date_Set_Mode
No_Date_Set_Mode:
	lda		PC
	and		#$10
	cmp		#$10
	bne		No_Time_Set_Mode
	jmp		Switch_Time_Set_Mode
No_Time_Set_Mode:
	lda		PC
	and		#$20
	cmp		#$20
	bne		No_Alarm_Set_Mode
	jmp		Switch_Alarm_Set_Mode
No_Alarm_Set_Mode:

	rts 

; 闹钟开启或关闭拨键处理
Switch_Alarm_ON:
	smb1	Clock_Flag
	rts
Switch_Alarm_OFF:
	rmb1	Clock_Flag
	rts

Switch_Runtime_Mode:
	lda		#0001B
	sta		Sys_Status_Flag
	rts
Switch_Date_Set_Mode:
	lda		#0010B
	sta		Sys_Status_Flag
	rts
Switch_Time_Set_Mode:
	lda		#0100B
	sta		Sys_Status_Flag
	rts
Switch_Alarm_Set_Mode:
	lda		#1000B
	sta		Sys_Status_Flag
	rts
