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

; 四种模式切换的拨键处理
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



; 正常走时模式的按键处理
F_KeyTrigger_RunTimeMode:
	rmb0	Key_Flag
	bbr1	Key_Flag,L_KeyWait_RunTimeMode		; 首次按键触发需要消抖
	rmb1	Key_Flag							; 清除首次按键触发标志位
	lda		#$00
	sta		P_Temp
L_DelayTrigger_RunTimeMode:						; 消抖延时循环用标签
	inc		P_Temp
	lda		P_Temp
	bne		L_DelayTrigger_RunTimeMode			; 软件消抖

L_KeyWait_RunTimeMode:
	lda		PA									; 正常走时模式下只对2个按键有响应
	and		#$30
	cmp		#$20
	bne		No_KeyBTrigger_RunTimeMode			; 由于跳转指令寻址能力的问题，这里采用jmp进行跳转
	jmp		L_KeyBTrigger_RunTimeMode			; Backlight & SNZ触发
No_KeyBTrigger_RunTimeMode:
	cmp		#$10
	bne		L_KeyExit_RunTimeMode
	jmp		L_KeySTrigger_RunTimeMode			; 12/24h & year触发

L_KeyExit_RunTimeMode:
	rts									

L_KeyBTrigger_RunTimeMode:
	rts
L_KeySTrigger_RunTimeMode:
	rts


; 日历设置模式的按键处理
F_KeyTrigger_DateSet_Mode:
	bbs2	Timer_Flag,L_QuikAdd1_DateSet_Mode
	rmb0	Key_Flag
	bbr1	Key_Flag,L_KeyWait_DateSet_Mode		; 首次按键触发需要消抖
	rmb1	Key_Flag							; 清除首次按键触发标志位
	lda		#$00
	sta		P_Temp
L_DelayTrigger_DateSet_Mode:						; 消抖延时循环用标签
	inc		P_Temp
	lda		P_Temp
	bne		L_DelayTrigger_DateSet_Mode			; 软件消抖
	bra		L_QuikAdd1_DateSet_Mode

L_KeyWait_DateSet_Mode:	
	lda		PA									; 长按时，在快加到来前，只需要判断有效按键是否存在
	and		#$a4								; 并关闭中断
	cmp		#$0
	beq		L_QuikAdd2_DateSet_Mode
	bne		L_KeyExit_DateSet_Mode

L_QuikAdd1_DateSet_Mode:
	lda		PA									; 判断4种按键触发情况
	and		#$F0
	cmp		#$80
	bne		No_KeyMTrigger_DateSet_Mode			; 由于跳转指令寻址能力的问题，这里采用jmp进行跳转
	jmp		L_KeyMTrigger_DateSet_Mode			; Min/Date单独触发
No_KeyMTrigger_DateSet_Mode:
	cmp		#$40
	bne		No_KeyHTrigger_DateSet_Mode
	jmp		L_KeyHTrigger_DateSet_Mode			; Hour/Month单独触发
No_KeyHTrigger_DateSet_Mode:
	cmp		#$20
	bne		No_KeyBTrigger_DateSet_Mode
	jmp		L_KeyBTrigger_DateSet_Mode			; Backlight/SNZ单独触发
No_KeyBTrigger_DateSet_Mode:
	cmp		#$10
	bne		L_QuikAdd2_DateSet_Mode
	jmp		L_KeySTrigger_DateSet_Mode			; 12/24h & year触发

L_QuikAdd2_DateSet_Mode:
	TMR1_OFF
	rmb2	Timer_Flag							; 若无有效按键组合，则清掉快加标志位

L_KeyExit_DateSet_Mode:
	rts									

L_KeyMTrigger_DateSet_Mode:
	rts
L_KeyHTrigger_DateSet_Mode:
	rts
L_KeyBTrigger_DateSet_Mode:
	rts
L_KeySTrigger_DateSet_Mode:
	rts


; 时间设置模式的按键处理
F_KeyTrigger_TimeSet_Mode:
	bbs2	Timer_Flag,L_QuikAdd1_TimeSet_Mode
	rmb0	Key_Flag
	bbr1	Key_Flag,L_KeyWait_TimeSet_Mode		; 首次按键触发需要消抖
	rmb1	Key_Flag							; 清除首次按键触发标志位
	lda		#$00
	sta		P_Temp
L_DelayTrigger_TimeSet_Mode:						; 消抖延时循环用标签
	inc		P_Temp
	lda		P_Temp
	bne		L_DelayTrigger_TimeSet_Mode			; 软件消抖
	bra		L_QuikAdd1_TimeSet_Mode

L_KeyWait_TimeSet_Mode:	
	lda		PA									; 长按时，在快加到来前，只需要判断有效按键是否存在
	and		#$a4								; 并关闭中断
	cmp		#$0
	beq		L_QuikAdd2_TimeSet_Mode
	bne		L_KeyExit_TimeSet_Mode

L_QuikAdd1_TimeSet_Mode:
	lda		PA									; 判断4种按键触发情况
	and		#$F0
	cmp		#$80
	bne		No_KeyMTrigger_TimeSet_Mode			; 由于跳转指令寻址能力的问题，这里采用jmp进行跳转
	jmp		L_KeyMTrigger_TimeSet_Mode			; Min/Date单独触发
No_KeyMTrigger_TimeSet_Mode:
	cmp		#$40
	bne		No_KeyHTrigger_TimeSet_Mode
	jmp		L_KeyHTrigger_TimeSet_Mode			; Hour/Month单独触发
No_KeyHTrigger_TimeSet_Mode:
	cmp		#$20
	bne		No_KeyBTrigger_TimeSet_Mode
	jmp		L_KeyBTrigger_TimeSet_Mode			; Backlight/SNZ单独触发
No_KeyBTrigger_TimeSet_Mode:
	cmp		#$10
	bne		L_QuikAdd2_TimeSet_Mode
	jmp		L_KeySTrigger_TimeSet_Mode			; 12/24h & year触发

L_QuikAdd2_TimeSet_Mode:
	TMR1_OFF
	rmb2	Timer_Flag							; 若无有效按键组合，则清掉快加标志位

L_KeyExit_TimeSet_Mode:
	rts									

L_KeyMTrigger_TimeSet_Mode:
	rts
L_KeyHTrigger_TimeSet_Mode:
	rts
L_KeyBTrigger_TimeSet_Mode:
	rts
L_KeySTrigger_TimeSet_Mode:
	rts


; 闹钟设置模式的按键处理
F_KeyTrigger_AlarmSet_Mode:
	bbs2	Timer_Flag,L_QuikAdd1_AlarmSet_Mode
	rmb0	Key_Flag
	bbr1	Key_Flag,L_KeyWait_AlarmSet_Mode		; 首次按键触发需要消抖
	rmb1	Key_Flag							; 清除首次按键触发标志位
	lda		#$00
	sta		P_Temp
L_DelayTrigger_AlarmSet_Mode:						; 消抖延时循环用标签
	inc		P_Temp
	lda		P_Temp
	bne		L_DelayTrigger_AlarmSet_Mode			; 软件消抖
	bra		L_QuikAdd1_AlarmSet_Mode

L_KeyWait_AlarmSet_Mode:	
	lda		PA									; 长按时，在快加到来前，只需要判断有效按键是否存在
	and		#$a4								; 并关闭中断
	cmp		#$0
	beq		L_QuikAdd2_AlarmSet_Mode
	bne		L_KeyExit_AlarmSet_Mode

L_QuikAdd1_AlarmSet_Mode:
	lda		PA									; 判断4种按键触发情况
	and		#$F0
	cmp		#$80
	bne		No_KeyMTrigger_AlarmSet_Mode			; 由于跳转指令寻址能力的问题，这里采用jmp进行跳转
	jmp		L_KeyMTrigger_AlarmSet_Mode			; Min/Date单独触发
No_KeyMTrigger_AlarmSet_Mode:
	cmp		#$40
	bne		No_KeyHTrigger_AlarmSet_Mode
	jmp		L_KeyHTrigger_AlarmSet_Mode			; Hour/Month单独触发
No_KeyHTrigger_AlarmSet_Mode:
	cmp		#$20
	bne		No_KeyBTrigger_AlarmSet_Mode
	jmp		L_KeyBTrigger_AlarmSet_Mode			; Backlight/SNZ单独触发
No_KeyBTrigger_AlarmSet_Mode:
	cmp		#$10
	bne		L_QuikAdd2_AlarmSet_Mode
	jmp		L_KeySTrigger_AlarmSet_Mode			; 12/24h & year触发

L_QuikAdd2_AlarmSet_Mode:
	TMR1_OFF
	rmb2	Timer_Flag							; 若无有效按键组合，则清掉快加标志位

L_KeyExit_AlarmSet_Mode:
	rts									

L_KeyMTrigger_AlarmSet_Mode:
	rts
L_KeyHTrigger_AlarmSet_Mode:
	rts
L_KeyBTrigger_AlarmSet_Mode:
	rts
L_KeySTrigger_AlarmSet_Mode:
	rts