; 拨键只发生状态变化，不需要处理额外内容
F_Switch_Scan:									; 拨键部分需要扫描处理
	lda		PC
	cmp		PC_IO_Backup						; 判断IO口状态是否与上次相同
	bne		L_Switch_Delay						; 如果不同说明拨键状态有改变，进消抖
	rts
L_Switch_Delay:
	lda		#$00
	sta		P_Temp
L_Delay_S:										; 消抖延时循环用标签
	inc		P_Temp
	lda		P_Temp
	bne		L_Delay_S							; 软件消抖

	lda		PC_IO_Backup
	cmp		PC
	bne		L_Switched
	rts
L_Switched:										; 检测到IO口状态与上次的不同，则进入拨键处理
	lda		PC
	sta		PC_IO_Backup						; 更新保存的IO口状态

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
	jsr		F_Display_All
	rts
Switch_Date_Set_Mode:
	lda		#0010B
	sta		Sys_Status_Flag
	jsr		F_Display_Alarm
	jsr		F_Display_Date
	ldx		#lcd_DotC
	jsr		F_ClrpSymbol
	rts
Switch_Time_Set_Mode:
	lda		#0100B
	sta		Sys_Status_Flag
	jsr		F_Display_All
	rts
Switch_Alarm_Set_Mode:
	lda		#1000B
	sta		Sys_Status_Flag
	jsr		F_Display_All
	rts



; 正常走时模式的按键处理
F_KeyTrigger_RunTimeMode:
	bbs0	Key_Flag,L_KeyTrigger_RunTimeMode
	rts
L_KeyTrigger_RunTimeMode:
	rmb0	Key_Flag
	TMR1_OFF									; 没有快加功能不需要开Timer1的8Hz计时
	lda		#$00
	sta		P_Temp
L_DelayTrigger_RunTimeMode:						; 消抖延时循环用标签
	inc		P_Temp
	lda		P_Temp
	bne		L_DelayTrigger_RunTimeMode			; 软件消抖

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
	smb3	Key_Flag							; 背光激活，同时启动贪睡
	smb3	Clock_Flag
	rts
L_KeySTrigger_RunTimeMode:
	lda		Clock_Flag							; 每按一次翻转clock_flag bit0状态
	eor		#$01
	sta		Clock_Flag
	jsr		F_Display_Time
	jsr		F_Display_Alarm
	rts


; 日历设置模式的按键处理
F_KeyTrigger_DateSetMode:
	bbs3	Timer_Flag,L_Key8Hz_DataSetMode		; 有快加则直接判断8Hz标志位
	bbr1	Key_Flag,L_KeyScan_DateSetMode		; 首次按键触发
	rmb1	Key_Flag
	lda		#$00
	sta		P_Temp
L_DelayTrigger_DateSetMode:						; 消抖延时循环用标签
	inc		P_Temp
	lda		P_Temp
	bne		L_DelayTrigger_DateSetMode			; 软件消抖
	lda		PA
	and		#$f0
	cmp		#$00
	bne		L_KeyYes_DataSetMode				; 检测是否有按键触发
	bra		L_KeyExit_DateSetMode
	rts
L_KeyYes_DataSetMode:
	sta		PA_IO_Backup
	bra		L_KeyHandle_DateMode				; 首次触发处理结束

L_KeyScan_DateSetMode:							; 长按处理部分
	bbr0	Key_Flag,L_KeyExit_DateSetMode		; 没有扫键标志直接退出
L_Key8Hz_DataSetMode:
	bbr4	Timer_Flag,L_Key8HzExit_DateSetMode	; 8Hz标志位到来前也不进行按键处理(快加下)
	rmb4	Timer_Flag
	lda		PA
	and		#$f0
	cmp		PA_IO_Backup						; 若检测到有按键的状态变化则退出快加判断并结束
	beq		L_8Hz_Count_DateSetMode
	bra		L_KeyExit_DateSetMode
	rts
L_8Hz_Count_DateSetMode:
	inc		CC2
	lda		CC2
	cmp		#12
	bcs		L_QuikAdd_DateSetMode
	rts											; 长按计时，必须满1S才有快加
L_QuikAdd_DateSetMode:
	smb3	Timer_Flag

L_KeyHandle_DateMode:
	lda		PA									; 判断4种按键触发情况
	and		#$f0
	cmp		#$80
	bne		No_KeyMTrigger_DateSetMode			; 由于跳转指令寻址能力的问题，这里采用jmp进行跳转
	jmp		L_KeyMTrigger_DateSetMode			; Min/Date单独触发
No_KeyMTrigger_DateSetMode:
	cmp		#$40
	bne		No_KeyHTrigger_DateSetMode
	jmp		L_KeyHTrigger_DateSetMode			; Hour/Month单独触发
No_KeyHTrigger_DateSetMode:
	cmp		#$20
	bne		No_KeyBTrigger_DateSetMode
	jmp		L_KeyBTrigger_DateSetMode			; Backlight/SNZ单独触发
No_KeyBTrigger_DateSetMode:
	cmp		#$10
	bne		L_KeyExit_DateSetMode
	jmp		L_KeySTrigger_DateSetMode			; 12/24h & year触发

L_KeyExit_DateSetMode:
	TMR1_OFF									; 关闭快加8Hz计时的定时器
	rmb0	Key_Flag							; 清相关标志位
	rmb3	Timer_Flag
	lda		#0									; 清理相关变量
	sta		CC2
L_Key8HzExit_DateSetMode:
	rts									

L_KeyMTrigger_DateSetMode:
	jsr		F_Is_Leap_Year
	ldx		R_Date_Month						; 月份数作为索引，查月份天数表
	dex											; 表头从0开始，而月份是从1开始
	bbs0	Calendar_Flag,L_Leap_Year_Set		; 闰年查闰年月份天数表
	lda		L_Table_Month_Common,x				; 否则查平年月份天数表
	bra		L_Day_Juge_Set
L_Leap_Year_Set:
	lda		L_Table_Month_Leap,x
L_Day_Juge_Set:
	cmp		R_Date_Day
	bne		L_Day_Add_Set
	lda		#1
	sta		R_Date_Day							; 日进位，重新回到1
	jsr		L_DisDate_Day						; 显示调整后的日期
	rts
L_Day_Add_Set:
	inc		R_Date_Day
	jsr		L_DisDate_Day						; 显示调整后的日期
	rts

L_KeyHTrigger_DateSetMode:
	lda		R_Date_Month
	cmp		#12
	bcc		L_Month_Juge
	lda		#1
	sta		R_Date_Month
	jsr		L_DisDate_Month
	rts
L_Month_Juge:
	inc		R_Date_Month						; 调整月份
	jsr		F_Is_Leap_Year						; 检查调整后的月份里日期有没有越界
	ldx		R_Date_Month						; 月份数作为索引，查月份天数表
	dex											; 表头从0开始，而月份是从1开始
	bbs0	Calendar_Flag,L_Leap_Year_Set1		; 闰年查闰年月份天数表
	lda		L_Table_Month_Common,x				; 否则查平年月份天数表
	bra		L_Day_Juge_Set1
L_Leap_Year_Set1:
	lda		L_Table_Month_Leap,x
L_Day_Juge_Set1:
	cmp		R_Date_Day
	bcs		L_Month_Add_Set
	lda		#1
	sta		R_Date_Day							; 日期如果和当前月份数不匹配，则初始化日期
L_Month_Add_Set:
	jsr		L_DisDate_Month
	rts

L_KeyBTrigger_DateSetMode:
	smb3	Key_Flag							; 背光激活
	smb3	PB
	rts

L_KeySTrigger_DateSetMode:
	lda		R_Date_Year
	cmp		#99
	bcc		L_Year_Juge
	lda		#0
	sta		R_Date_Year
	jsr		L_DisDate_Year
	rts
L_Year_Juge:
	inc		R_Date_Year							; 调整年份
	jsr		F_Is_Leap_Year						; 检查调整后的年份里日期有没有越界
	ldx		R_Date_Month						; 月份数作为索引，查月份天数表
	dex											; 表头从0开始，而月份是从1开始
	bbs0	Calendar_Flag,L_Leap_Year_Set2		; 闰年查闰年月份天数表
	lda		L_Table_Month_Common,x				; 否则查平年月份天数表
	bra		L_Day_Juge_Set2
L_Leap_Year_Set2:
	lda		L_Table_Month_Leap,x
L_Day_Juge_Set2:
	cmp		R_Date_Day
	bcs		L_Year_Add_Set
	lda		#1
	sta		R_Date_Day							; 日期如果超过当前月份最大值，则初始化日期
L_Year_Add_Set:
	jsr		L_DisDate_Year
	rts


; 时间设置模式的按键处理
F_KeyTrigger_TimeSet_Mode:
	bbs3	Timer_Flag,L_QuikAdd1_TimeSet_Mode
	rmb0	Key_Flag
	bbr1	Key_Flag,L_KeyWait_TimeSet_Mode		; 首次按键触发需要消抖
	rmb1	Key_Flag							; 清除首次按键触发标志位
	lda		#$00
	sta		P_Temp
L_DelayTrigger_TimeSet_Mode:					; 消抖延时循环用标签
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
	rmb3	Timer_Flag							; 若无有效按键组合，则清掉快加标志位

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
	bbs3	Timer_Flag,L_QuikAdd1_AlarmSet_Mode
	rmb0	Key_Flag
	bbr1	Key_Flag,L_KeyWait_AlarmSet_Mode	; 首次按键触发需要消抖
	rmb1	Key_Flag							; 清除首次按键触发标志位
	lda		#$00
	sta		P_Temp
L_DelayTrigger_AlarmSet_Mode:					; 消抖延时循环用标签
	inc		P_Temp
	lda		P_Temp
	bne		L_DelayTrigger_AlarmSet_Mode		; 软件消抖
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
	bne		No_KeyMTrigger_AlarmSet_Mode		; 由于跳转指令寻址能力的问题，这里采用jmp进行跳转
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
	rmb3	Timer_Flag							; 若无有效按键组合，则清掉快加标志位

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