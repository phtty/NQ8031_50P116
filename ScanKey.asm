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
	ldx		#lcd_bell
	jsr		F_DispSymbol
	ldx		#lcd_Zz
	jsr		F_DispSymbol
	rts
Switch_Alarm_OFF:
	rmb1	Clock_Flag
	ldx		#lcd_bell
	jsr		F_ClrpSymbol
	ldx		#lcd_Zz
	jsr		F_ClrpSymbol
	jsr		L_NoSnooze_CloseLoud				; 如果有响闹和贪睡，则打断响闹和贪睡
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
	jsr		F_UnDisplay_InDateMode				; 进入日期模式后停止显示一些符号
	jsr		L_NoSnooze_CloseLoud				; 如果有响闹和贪睡，则打断响闹和贪睡
	rts
Switch_Time_Set_Mode:
	lda		#0100B
	sta		Sys_Status_Flag
	jsr		F_Display_All
	jsr		L_NoSnooze_CloseLoud				; 如果有响闹和贪睡，则打断响闹和贪睡
	rts
Switch_Alarm_Set_Mode:
	lda		#1000B
	sta		Sys_Status_Flag
	jsr		F_Display_All
	jsr		L_NoSnooze_CloseLoud				; 如果有响闹和贪睡，则打断响闹和贪睡
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
	and		#$f0
	cmp		#$80
	bne		No_KeyMTrigger_RunTimeMode			; 由于跳转指令寻址能力的问题，这里采用jmp进行跳转
	jmp		L_KeyMTrigger_RunTimeMode			; Date/Min单独触发
No_KeyMTrigger_RunTimeMode:
	cmp		#$40
	bne		No_KeyHTrigger_RunTimeMode
	jmp		L_KeyHTrigger_RunTimeMode			; Month/Hour单独触发
No_KeyHTrigger_RunTimeMode:
	cmp		#$20
	bne		No_KeyBTrigger_RunTimeMode
	jmp		L_KeyBTrigger_RunTimeMode			; Backlight & SNZ触发
No_KeyBTrigger_RunTimeMode:
	cmp		#$10
	bne		L_KeyExit_RunTimeMode
	jmp		L_KeySTrigger_RunTimeMode			; 12/24h & year触发

L_KeyExit_RunTimeMode:
	rts

L_KeyMTrigger_RunTimeMode:						; 在走时模式下，M、H键都只会打断贪睡这一个功能
L_KeyHTrigger_RunTimeMode:
	jsr		L_NoSnooze_CloseLoud
	rts

L_KeyBTrigger_RunTimeMode:
	smb3	Key_Flag							; 背光激活，同时启动贪睡
	smb3	PB
	lda		#0									; 每次按背光都会重置计时
	sta		Backlight_Counter
	bbr2	Clock_Flag,L_KeyBTrigger_Exit		; 如果不是在响闹模式下，则不会处理贪睡
	smb6	Clock_Flag							; 贪睡按键触发						
	smb3	Clock_Flag							; 进入贪睡模式

	lda		R_Snooze_Min						; 贪睡闹钟的时间加5
	clc
	adc		#5
	cmp		#60
	bcs		L_Snooze_OverflowMin
	sta		R_Snooze_Min
	bra		L_KeyBTrigger_Exit
L_Snooze_OverflowMin:
	sec
	sbc		#60
	sta		R_Snooze_Min						; 产生贪睡响闹的分钟进位
	inc		R_Snooze_Hour
	lda		R_Snooze_Hour
	cmp		#24
	bcc		L_KeyBTrigger_Exit
	lda		#00									; 产生贪睡小时进位
	sta		R_Snooze_Hour
L_KeyBTrigger_Exit:
	lda		R_Snooze_Hour
	lda		R_Snooze_Min
	rts

L_KeySTrigger_RunTimeMode:
	bbs2	Clock_Flag,L_LoundSnz_Handle		; 若有响闹模式或贪睡模式，则不切换时间模式，只打断响闹和贪睡
	bbs3	Clock_Flag,L_LoundSnz_Handle
	lda		Clock_Flag							; 每按一次翻转clock_flag bit0状态
	eor		#$01
	sta		Clock_Flag
	jsr		F_Display_Time
	jsr		F_Display_Alarm
L_LoundSnz_Handle:
	jsr		L_NoSnooze_CloseLoud				; 打断响闹和贪睡
	rts



; 日历设置模式的按键处理
F_KeyTrigger_DateSetMode:
	bbs3	Timer_Flag,L_Key8Hz_DateSetMode		; 有快加则直接判断8Hz标志位
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
	bne		L_KeyYes_DateSetMode				; 检测是否有按键触发
	bra		L_KeyExit_DateSetMode
	rts
L_KeyYes_DateSetMode:
	sta		PA_IO_Backup
	bra		L_KeyHandle_DateMode				; 首次触发处理结束

L_KeyScan_DateSetMode:							; 长按处理部分
	bbr0	Key_Flag,L_KeyExit_DateSetMode		; 没有扫键标志直接退出
L_Key8Hz_DateSetMode:
	bbr4	Timer_Flag,L_Key8HzExit_DateSetMode	; 8Hz标志位到来前也不进行按键处理(快加下)
	rmb4	Timer_Flag
	lda		PA
	and		#$f0
	cmp		PA_IO_Backup						; 若检测到有按键的状态变化则退出快加判断并结束
	beq		L_8Hz_Count_DateSetMode
	bra		L_KeyExit_DateSetMode
	rts
L_8Hz_Count_DateSetMode:
	inc		QuickAdd_Counter
	lda		QuickAdd_Counter
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
	jmp		L_KeyMTrigger_DateSetMode			; Date单独触发
No_KeyMTrigger_DateSetMode:
	cmp		#$40
	bne		No_KeyHTrigger_DateSetMode
	jmp		L_KeyHTrigger_DateSetMode			; Month单独触发
No_KeyHTrigger_DateSetMode:
	cmp		#$20
	bne		No_KeyBTrigger_DateSetMode
	jmp		L_KeyBTrigger_DateSetMode			; Backlight单独触发
No_KeyBTrigger_DateSetMode:
	cmp		#$10
	bne		L_KeyExit_DateSetMode
	jmp		L_KeySTrigger_DateSetMode			; year触发

L_KeyExit_DateSetMode:
	TMR1_OFF									; 关闭快加8Hz计时的定时器
	rmb0	Key_Flag							; 清相关标志位
	rmb3	Timer_Flag
	lda		#0									; 清理相关变量
	sta		QuickAdd_Counter
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
	jsr		F_Display_Date						; 显示调整后的日期
	rts
L_Day_Add_Set:
	inc		R_Date_Day
	jsr		F_Display_Date						; 显示调整后的日期
	rts

L_KeyHTrigger_DateSetMode:
	lda		R_Date_Month
	cmp		#12
	bcc		L_Month_Juge
	lda		#1
	sta		R_Date_Month
	jsr		F_Display_Date
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
	jsr		F_Display_Date
	rts

L_KeyBTrigger_DateSetMode:
	smb3	Key_Flag							; 背光激活
	smb3	PB
	lda		#0
	sta		Backlight_Counter					; 每次按背光都会重置计时
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
F_KeyTrigger_TimeSetMode:
	bbs3	Timer_Flag,L_Key8Hz_TimeSetMode		; 有快加则直接判断8Hz标志位
	bbr1	Key_Flag,L_KeyScan_TimeSetMode		; 首次按键触发
	rmb1	Key_Flag
	lda		#$00
	sta		P_Temp
L_DelayTrigger_TimeSetMode:						; 消抖延时循环用标签
	inc		P_Temp
	lda		P_Temp
	bne		L_DelayTrigger_TimeSetMode			; 软件消抖
	lda		PA
	and		#$f0
	cmp		#$00
	bne		L_KeyYes_TimeSetMode				; 检测是否有按键触发
	bra		L_KeyExit_TimeSetMode
	rts
L_KeyYes_TimeSetMode:
	sta		PA_IO_Backup
	bra		L_KeyHandle_TimeSetMode				; 首次触发处理结束

L_KeyScan_TimeSetMode:							; 长按处理部分
	bbr0	Key_Flag,L_KeyExit_TimeSetMode		; 没有扫键标志直接退出
L_Key8Hz_TimeSetMode:
	bbr4	Timer_Flag,L_Key8HzExit_TimeSetMode	; 8Hz标志位到来前也不进行按键处理(快加下)
	rmb4	Timer_Flag
	lda		PA
	and		#$f0
	cmp		PA_IO_Backup						; 若检测到有按键的状态变化则退出快加判断并结束
	beq		L_8Hz_Count_TimeSetMode
	bra		L_KeyExit_TimeSetMode
	rts
L_8Hz_Count_TimeSetMode:
	inc		QuickAdd_Counter
	lda		QuickAdd_Counter
	cmp		#12
	bcs		L_QuikAdd_TimeSetMode
	rts											; 长按计时，必须满1S才有快加
L_QuikAdd_TimeSetMode:
	smb3	Timer_Flag

L_KeyHandle_TimeSetMode:
	lda		PA									; 判断4种按键触发情况
	and		#$f0
	cmp		#$80
	bne		No_KeyMTrigger_TimeSetMode			; 由于跳转指令寻址能力的问题，这里采用jmp进行跳转
	jmp		L_KeyMTrigger_TimeSetMode			; Min单独触发
No_KeyMTrigger_TimeSetMode:
	cmp		#$40
	bne		No_KeyHTrigger_TimeSetMode
	jmp		L_KeyHTrigger_TimeSetMode			; Hour单独触发
No_KeyHTrigger_TimeSetMode:
	cmp		#$20
	bne		No_KeyBTrigger_TimeSetMode
	jmp		L_KeyBTrigger_TimeSetMode			; Backlight/SNZ单独触发
No_KeyBTrigger_TimeSetMode:
	cmp		#$10
	bne		L_KeyExit_TimeSetMode
	jmp		L_KeySTrigger_TimeSetMode			; 12/24h触发

L_KeyExit_TimeSetMode:
	TMR1_OFF									; 关闭快加8Hz计时的定时器
	rmb0	Key_Flag							; 清相关标志位
	rmb3	Timer_Flag
	lda		#0									; 清理相关变量
	sta		QuickAdd_Counter
L_Key8HzExit_TimeSetMode:
	rts


L_KeyMTrigger_TimeSetMode:
	lda		#00
	sta		R_Time_Sec							; 调时间会清S计数
	inc		R_Time_Min
	lda		#59
	cmp		R_Time_Min
	bcs		L_MinSet_Juge
	lda		#00
	sta		R_Time_Min
L_MinSet_Juge:
	jsr		F_Display_Time
	rts
L_KeyHTrigger_TimeSetMode:
	lda		#00
	sta		R_Time_Sec							; 调时间会清S计数
	inc		R_Time_Hour
	lda		#23
	cmp		R_Time_Hour
	bcs		L_HourSet_Juge
	lda		#00
	sta		R_Time_Hour
L_HourSet_Juge:
	jsr		F_Display_Time
	rts
L_KeyBTrigger_TimeSetMode:
	smb3	Key_Flag
	smb3	PB
	lda		#0
	sta		Backlight_Counter					; 每次按背光都会重置计时
	rts
L_KeySTrigger_TimeSetMode:
	lda		Clock_Flag
	eor		#0001B
	sta		Clock_Flag
	jsr		F_Display_Time
	jsr		F_Display_Alarm
	rts



; 闹钟设置模式的按键处理
F_KeyTrigger_AlarmSetMode:
	bbs3	Timer_Flag,L_Key8Hz_AlarmSetMode	; 有快加则直接判断8Hz标志位
	bbr1	Key_Flag,L_KeyScan_AlarmSetMode		; 首次按键触发
	rmb1	Key_Flag
	lda		#$00
	sta		P_Temp
L_DelayTrigger_AlarmSetMode:					; 消抖延时循环用标签
	inc		P_Temp
	lda		P_Temp
	bne		L_DelayTrigger_AlarmSetMode			; 软件消抖
	lda		PA
	and		#$f0
	cmp		#$00
	bne		L_KeyYes_AlarmSetMode				; 检测是否有按键触发
	bra		L_KeyExit_AlarmSetMode
	rts
L_KeyYes_AlarmSetMode:
	sta		PA_IO_Backup
	bra		L_KeyHandle_AlarmSetMode			; 首次触发处理结束

L_KeyScan_AlarmSetMode:							; 长按处理部分
	bbr0	Key_Flag,L_KeyExit_AlarmSetMode		; 没有扫键标志直接退出
L_Key8Hz_AlarmSetMode:
	bbr4	Timer_Flag,L_Key8HzExit_AlarmSetMode; 8Hz标志位到来前也不进行按键处理(快加下)
	rmb4	Timer_Flag
	lda		PA
	and		#$f0
	cmp		PA_IO_Backup						; 若检测到有按键的状态变化则退出快加判断并结束
	beq		L_8Hz_Count_AlarmSetMode
	bra		L_KeyExit_AlarmSetMode
	rts
L_8Hz_Count_AlarmSetMode:
	inc		QuickAdd_Counter
	lda		QuickAdd_Counter
	cmp		#12
	bcs		L_QuikAdd_AlarmSetMode
	rts											; 长按计时，必须满1S才有快加
L_QuikAdd_AlarmSetMode:
	smb3	Timer_Flag

L_KeyHandle_AlarmSetMode:
	lda		PA									; 判断4种按键触发情况
	and		#$f0
	cmp		#$80
	bne		No_KeyMTrigger_AlarmSetMode			; 由于跳转指令寻址能力的问题，这里采用jmp进行跳转
	jmp		L_KeyMTrigger_AlarmSetMode			; Min单独触发
No_KeyMTrigger_AlarmSetMode:
	cmp		#$40
	bne		No_KeyHTrigger_AlarmSetMode
	jmp		L_KeyHTrigger_AlarmSetMode			; Hour单独触发
No_KeyHTrigger_AlarmSetMode:
	cmp		#$20
	bne		No_KeyBTrigger_AlarmSetMode
	jmp		L_KeyBTrigger_AlarmSetMode			; Backlight单独触发
No_KeyBTrigger_AlarmSetMode:
	cmp		#$10
	bne		L_KeyExit_AlarmSetMode
	jmp		L_KeySTrigger_AlarmSetMode			; 12/24h触发

L_KeyExit_AlarmSetMode:
	TMR1_OFF									; 关闭快加8Hz计时的定时器
	rmb0	Key_Flag							; 清相关标志位
	rmb3	Timer_Flag
	lda		#0									; 清理相关变量
	sta		QuickAdd_Counter
L_Key8HzExit_AlarmSetMode:
	rts

L_KeyMTrigger_AlarmSetMode:
	inc		R_Alarm_Min
	lda		#59
	cmp		R_Alarm_Min
	bcs		L_AlarmMinSet_Juge
	lda		#00
	sta		R_Alarm_Min
L_AlarmMinSet_Juge:
	jsr		F_Display_Alarm
	rts

L_KeyHTrigger_AlarmSetMode:
	inc		R_Alarm_Hour
	lda		#23
	cmp		R_Alarm_Hour
	bcs		L_AlarmHourSet_Juge
	lda		#00
	sta		R_Alarm_Hour
L_AlarmHourSet_Juge:	
	jsr		F_Display_Alarm
	rts

L_KeyBTrigger_AlarmSetMode:
	smb3	Key_Flag
	smb3	PB
	lda		#0
	sta		Backlight_Counter					; 每次按背光都会重置计时
	rts

L_KeySTrigger_AlarmSetMode:
	lda		Clock_Flag
	eor		#0001B
	sta		Clock_Flag
	jsr		F_Display_Time
	jsr		F_Display_Alarm
	rts
