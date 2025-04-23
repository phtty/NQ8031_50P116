; 拨键只发生状态变化，不需要处理额外内容
F_Switch_Scan3:									; 拨键部分需要扫描处理
	jsr		F_SwitchPort_ScanReady
	jsr		F_Delay
	lda		PC
	cmp		PC_IO_Backup						; 判断IO口状态是否与上次相同
	bne		L_Switch_Delay3						; 如果不同说明拨键状态有改变，进消抖
	jsr		F_SwitchPort_ScanReset				; 避免漏电
	rts
L_Switch_Delay3:
	lda		#$00
	sta		P_Temp
L_Delay_S3:										; 消抖延时循环用标签
	inc		P_Temp
	lda		P_Temp
	bne		L_Delay_S3							; 软件消抖

	lda		PC_IO_Backup
	cmp		PC
	bne		L_Switched3

	jsr		F_SwitchPort_ScanReset				; 避免漏电
	rts
L_Switched3:									; 检测到IO口状态与上次的不同，则进入拨键处理
	lda		PC
	sta		PC_IO_Backup						; 更新保存的IO口状态

	and		#$04
	cmp		#$04
	bne		Alarm_OFF3
	jsr		Switch_Alarm_ON3
	bra		Alarm_ON3
Alarm_OFF3:
	jsr		Switch_Alarm_OFF3
	bra		Sys_Mode_Process3
Alarm_ON3:
	jsr		Switch_Alarm_ON3
Sys_Mode_Process3:
	lda		PC
	and		#$38
	cmp		#$00
	bne		No_Runtime_Mode3
	jmp		Switch_Runtime_Mode3
No_Runtime_Mode3:
	lda		PC
	and		#$08
	cmp		#$08
	bne		No_Date_Set_Mode3
	jmp		Switch_Date_Set_Mode3
No_Date_Set_Mode3:
	lda		PC
	and		#$10
	cmp		#$10
	bne		No_Time_Set_Mode3
	jmp		Switch_Time_Set_Mode3
No_Time_Set_Mode3:
	lda		PC
	and		#$20
	cmp		#$20
	bne		No_Alarm_Set_Mode3
	jmp		Switch_Alarm_Set_Mode3
No_Alarm_Set_Mode3:
	jsr		F_SwitchPort_ScanReset				; 避免漏电
	rts 

; 闹钟开启或关闭拨键处理
Switch_Alarm_ON3:
	smb1	Clock_Flag
	ldx		#lcd3_bell
	jsr		F_DispSymbol3
	ldx		#lcd3_Zz
	jsr		F_DispSymbol3
	rts
Switch_Alarm_OFF3:
	rmb1	Clock_Flag
	ldx		#lcd3_bell
	jsr		F_ClrpSymbol3
	ldx		#lcd3_Zz
	jsr		F_ClrpSymbol3
	jsr		L_NoSnooze_CloseLoud				; 打断响闹和贪睡
	rts

; 四种模式切换的拨键处理
Switch_Runtime_Mode3:
	lda		#0001B
	sta		Sys_Status_Flag
	jsr		F_Display_All3
	jsr		F_SwitchPort_ScanReset				; 避免漏电
	rts
Switch_Date_Set_Mode3:
	lda		#0010B
	sta		Sys_Status_Flag
	jsr		L_DisDate_Year3
	jsr		F_Display_Date3
	jsr		F_UnDisplay_InDateMode3				; 进入日期模式后停止显示一些符号
	jsr		L_NoSnooze_CloseLoud				; 打断响闹和贪睡
	jsr		F_SwitchPort_ScanReset				; 避免漏电
	rts
Switch_Time_Set_Mode3:
	lda		#0100B
	sta		Sys_Status_Flag
	jsr		F_Display_All3
	jsr		L_NoSnooze_CloseLoud				; 打断响闹和贪睡
	jsr		F_SwitchPort_ScanReset				; 避免漏电
	rts
Switch_Alarm_Set_Mode3:
	lda		#1000B
	sta		Sys_Status_Flag
	jsr		F_Display_Alarm3
	jsr		F_Display_Date3
	ldx		#lcd3_ALM
	jsr		F_DispSymbol3
	jsr		L_NoSnooze_CloseLoud				; 打断响闹和贪睡
	jsr		F_SwitchPort_ScanReset				; 避免漏电
	rts



; 正常走时模式的按键处理
F_KeyTrigger_RunTimeMode3:
	bbs0	Key_Flag,L_KeyTrigger_RunTimeMode3
	rts
L_KeyTrigger_RunTimeMode3:
	rmb0	Key_Flag
	TMR1_OFF									; 没有快加功能不需要开Timer1的8Hz计时
	lda		#$00
	sta		P_Temp
L_DelayTrigger_RunTimeMode3:					; 消抖延时循环用标签
	inc		P_Temp
	lda		P_Temp
	bne		L_DelayTrigger_RunTimeMode3			; 软件消抖

	lda		PA									; 正常走时模式下只对2个按键有响应
	and		#$f0
	cmp		#$80
	bne		No_KeyHTrigger_RunTimeMode3			; 由于跳转指令寻址能力的问题，这里采用jmp进行跳转
	jmp		L_KeyHTrigger_RunTimeMode3			; Month/Hour单独触发
No_KeyHTrigger_RunTimeMode3:
	cmp		#$40
	bne		No_KeyMTrigger_RunTimeMode3
	jmp		L_KeyMTrigger_RunTimeMode3			; Date/Min单独触发
No_KeyMTrigger_RunTimeMode3:
	cmp		#$20
	bne		No_KeySTrigger_RunTimeMode3
	jmp		L_KeySTrigger_RunTimeMode3			; 12/24h & year触发
No_KeySTrigger_RunTimeMode3:
	cmp		#$10
	bne		L_KeyExit_RunTimeMode3
	jmp		L_KeyBTrigger_RunTimeMode3			; Backlight & SNZ触发

L_KeyExit_RunTimeMode3:
	rts

L_KeyMTrigger_RunTimeMode3:						; 在走时模式下，M、H键都只会打断贪睡这一个功能
L_KeyHTrigger_RunTimeMode3:
	jsr		L_NoSnooze_CloseLoud
	rts

L_KeyBTrigger_RunTimeMode3:
	smb3	Key_Flag							; 背光激活，同时启动贪睡
	smb2	PB
	lda		#0									; 每次按背光都会重置计时
	sta		Backlight_Counter
	bbr2	Clock_Flag,L_KeyBTrigger_Exit3		; 如果不是在响闹模式下，则不会处理贪睡
	smb6	Clock_Flag							; 贪睡按键触发						
	smb3	Clock_Flag							; 进入贪睡模式

	lda		R_Snooze_Min						; 贪睡闹钟的时间加5
	clc
	adc		#5
	cmp		#60
	bcs		L_Snooze_OverflowMin3
	sta		R_Snooze_Min
	bra		L_KeyBTrigger_Exit3
L_Snooze_OverflowMin3:
	sec
	sbc		#60
	sta		R_Snooze_Min						; 产生贪睡响闹的分钟进位
	inc		R_Snooze_Hour
	lda		R_Snooze_Hour
	cmp		#24
	bcc		L_KeyBTrigger_Exit3
	lda		#00									; 产生贪睡小时进位
	sta		R_Snooze_Hour
L_KeyBTrigger_Exit3:
	rts

L_KeySTrigger_RunTimeMode3:
	bbs2	Clock_Flag,L_LoundSnz_Handle3		; 若有响闹模式或贪睡模式，则不切换时间模式，只打断响闹和贪睡
	bbs3	Clock_Flag,L_LoundSnz_Handle3
	lda		Clock_Flag							; 每按一次翻转clock_flag bit0状态
	eor		#$01
	sta		Clock_Flag
	jsr		F_Display_Time3
L_LoundSnz_Handle3:
	jsr		L_NoSnooze_CloseLoud				; 打断响闹和贪睡
	rts



; 日历设置模式的按键处理
F_KeyTrigger_DateSetMode3:
	bbs3	Timer_Flag,L_Key4Hz_DateSetMode3	; 有快加则直接判断4Hz标志位
	bbr1	Key_Flag,L_KeyScan_DateSetMode3		; 首次按键触发
	rmb1	Key_Flag
	lda		#$00
	sta		P_Temp
L_DelayTrigger_DateSetMode3:					; 消抖延时循环用标签
	inc		P_Temp
	lda		P_Temp
	bne		L_DelayTrigger_DateSetMode3			; 软件消抖
	lda		PA
	and		#$f0
	cmp		#$00
	bne		L_KeyYes_DateSetMode3				; 检测是否有按键触发
	bra		L_KeyExit_DateSetMode3
	rts
L_KeyYes_DateSetMode3:
	sta		PA_IO_Backup
	bra		L_KeyHandle_DateMode3				; 首次触发处理结束

L_Key4Hz_DateSetMode3:
	bbr2	Key_Flag,L_Key4HzExit_DateSetMode3
	rmb2	Key_Flag
L_KeyScan_DateSetMode3:							; 长按处理部分
	bbr0	Key_Flag,L_KeyExit_DateSetMode3		; 没有扫键标志直接退出

	jsr		F_QuikAdd_ScanReady					; 配置为输入
	jsr		F_Delay
	bbr4	Timer_Flag,L_Key4HzExit_DateSetMode3; 8Hz标志位到来前也不进行按键处理(快加下)
	rmb4	Timer_Flag
	lda		PA
	and		#$f0
	cmp		PA_IO_Backup						; 若检测到有按键的状态变化则退出快加判断并结束
	beq		L_4Hz_Count_DateSetMode3
	bra		L_KeyExit_DateSetMode3
	rts
L_4Hz_Count_DateSetMode3:
	inc		QuickAdd_Counter
	lda		QuickAdd_Counter
	cmp		#24
	bcs		L_QuikAdd_DateSetMode3
	rts											; 长按计时，必须满1S才有快加
L_QuikAdd_DateSetMode3:
	smb3	Timer_Flag
	rmb2	Key_Flag

L_KeyHandle_DateMode3:
	lda		PA									; 判断4种按键触发情况
	and		#$f0
	cmp		#$80
	bne		No_KeyHTrigger_DateSetMode3			; 由于跳转指令寻址能力的问题，这里采用jmp进行跳转
	jmp		L_KeyHTrigger_DateSetMode3			; Month单独触发
No_KeyHTrigger_DateSetMode3:
	cmp		#$40
	bne		No_KeyMTrigger_DateSetMode3
	jmp		L_KeyMTrigger_DateSetMode3			; Date单独触发
No_KeyMTrigger_DateSetMode3:
	cmp		#$20
	bne		No_KeySTrigger_DateSetMode3
	jmp		L_KeySTrigger_DateSetMode3			; year触发
No_KeySTrigger_DateSetMode3:
	cmp		#$10
	bne		L_KeyExit_DateSetMode3
	jmp		L_KeyBTrigger_DateSetMode3			; Backlight单独触发

L_KeyExit_DateSetMode3:
	TMR1_OFF									; 关闭快加8Hz计时的定时器
	rmb0	Key_Flag							; 清相关标志位
	rmb3	Timer_Flag
	lda		#0									; 清理相关变量
	sta		QuickAdd_Counter
L_Key4HzExit_DateSetMode3:
	jsr		F_QuikAdd_ScanReady					; 配置为输入
	rts


L_KeyMTrigger_DateSetMode3:
	jsr		F_QuikAdd_ScanReset					; 有快加的情况需要重置IO口为输出高避免漏电
	jsr		F_Is_Leap_Year
	ldx		R_Date_Month						; 月份数作为索引，查月份天数表
	dex											; 表头从0开始，而月份是从1开始
	bbs0	Calendar_Flag,L_Leap_Year_Set3		; 闰年查闰年月份天数表
	lda		L_Table_Month_Common,x				; 否则查平年月份天数表
	bra		L_Day_Juge_Set3
L_Leap_Year_Set3:
	lda		L_Table_Month_Leap,x
L_Day_Juge_Set3:
	cmp		R_Date_Day
	bne		L_Day_Add_Set3
	lda		#1
	sta		R_Date_Day							; 日进位，重新回到1
	jsr		F_Display_Date3						; 显示调整后的日期
	rts
L_Day_Add_Set3:
	inc		R_Date_Day
	jsr		F_Display_Date3						; 显示调整后的日期
	rts

L_KeyHTrigger_DateSetMode3:
	jsr		F_QuikAdd_ScanReset					; 有快加的情况需要重置IO口为输出高避免漏电
	lda		R_Date_Month
	cmp		#12
	bcc		L_Month_Juge3
	lda		#1
	sta		R_Date_Month
	jsr		F_Display_Date3
	rts
L_Month_Juge3:
	inc		R_Date_Month						; 调整月份
	jsr		F_Is_Leap_Year						; 检查调整后的月份里日期有没有越界
	ldx		R_Date_Month						; 月份数作为索引，查月份天数表
	dex											; 表头从0开始，而月份是从1开始
	bbs0	Calendar_Flag,L_Leap_Year_Set13		; 闰年查闰年月份天数表
	lda		L_Table_Month_Common,x				; 否则查平年月份天数表
	bra		L_Day_Juge_Set13
L_Leap_Year_Set13:
	lda		L_Table_Month_Leap,x
L_Day_Juge_Set13:
	cmp		R_Date_Day
	bcs		L_Month_Add_Set3
	lda		#1
	sta		R_Date_Day							; 日期如果和当前月份数不匹配，则初始化日期
L_Month_Add_Set3:
	jsr		F_Display_Date3
	rts

L_KeyBTrigger_DateSetMode3:
	smb3	Key_Flag							; 背光激活
	smb2	PB
	lda		#0
	sta		Backlight_Counter					; 每次按背光都会重置计时
	rts

L_KeySTrigger_DateSetMode3:
	jsr		F_QuikAdd_ScanReset					; 有快加的情况需要重置IO口为输出高避免漏电
	lda		R_Date_Year
	cmp		#99
	bcc		L_Year_Juge3
	lda		#0
	sta		R_Date_Year
	jsr		L_DisDate_Year3
	rts
L_Year_Juge3:
	inc		R_Date_Year							; 调整年份
	jsr		F_Is_Leap_Year						; 检查调整后的年份里日期有没有越界
	ldx		R_Date_Month						; 月份数作为索引，查月份天数表
	dex											; 表头从0开始，而月份是从1开始
	bbs0	Calendar_Flag,L_Leap_Year_Set23		; 闰年查闰年月份天数表
	lda		L_Table_Month_Common,x				; 否则查平年月份天数表
	bra		L_Day_Juge_Set23
L_Leap_Year_Set23:
	lda		L_Table_Month_Leap,x
L_Day_Juge_Set23:
	cmp		R_Date_Day
	bcs		L_Year_Add_Set3
	lda		#1
	sta		R_Date_Day							; 日期如果超过当前月份最大值，则初始化日期
L_Year_Add_Set3:
	jsr		L_DisDate_Year3
	rts



; 时间设置模式的按键处理
F_KeyTrigger_TimeSetMode3:
	bbs3	Timer_Flag,L_Key4Hz_TimeSetMode3	; 有快加则直接判断8Hz标志位
	bbr1	Key_Flag,L_KeyScan_TimeSetMode3		; 首次按键触发
	rmb1	Key_Flag
	lda		#$00
	sta		P_Temp
L_DelayTrigger_TimeSetMode3:					; 消抖延时循环用标签
	inc		P_Temp
	lda		P_Temp
	bne		L_DelayTrigger_TimeSetMode3			; 软件消抖
	lda		PA
	and		#$f0
	cmp		#$00
	bne		L_KeyYes_TimeSetMode3				; 检测是否有按键触发
	bra		L_KeyExit_TimeSetMode3
	rts
L_KeyYes_TimeSetMode3:
	sta		PA_IO_Backup
	bra		L_KeyHandle_TimeSetMode3			; 首次触发处理结束

L_Key4Hz_TimeSetMode3:
	bbr2	Key_Flag,L_Key4HzExit_TimeSetMode3
	rmb2	Key_Flag
L_KeyScan_TimeSetMode3:							; 长按处理部分
	bbr0	Key_Flag,L_KeyExit_TimeSetMode3		; 没有扫键标志直接退出

	jsr		F_QuikAdd_ScanReady					; 配置为输入
	jsr		F_Delay
	bbr4	Timer_Flag,L_Key4HzExit_TimeSetMode3; 8Hz标志位到来前也不进行按键处理(快加下)
	rmb4	Timer_Flag
	lda		PA
	and		#$f0
	cmp		PA_IO_Backup						; 若检测到有按键的状态变化则退出快加判断并结束
	beq		L_4Hz_Count_TimeSetMode3
	bra		L_KeyExit_TimeSetMode3
	rts
L_4Hz_Count_TimeSetMode3:
	inc		QuickAdd_Counter
	lda		QuickAdd_Counter
	cmp		#24
	bcs		L_QuikAdd_TimeSetMode3
	rts											; 长按计时，必须满1S才有快加
L_QuikAdd_TimeSetMode3:
	smb3	Timer_Flag
	rmb2	Key_Flag

L_KeyHandle_TimeSetMode3:
	lda		PA									; 判断4种按键触发情况
	and		#$f0
	cmp		#$80
	bne		No_KeyHTrigger_TimeSetMode3			; 由于跳转指令寻址能力的问题，这里采用jmp进行跳转
	jmp		L_KeyHTrigger_TimeSetMode3			; Hour单独触发
No_KeyHTrigger_TimeSetMode3:
	cmp		#$40
	bne		No_KeyMTrigger_TimeSetMode3
	jmp		L_KeyMTrigger_TimeSetMode3			; Min单独触发
No_KeyMTrigger_TimeSetMode3:
	bbs3	Timer_Flag,L_KeyExit_TimeSetMode3	; 背光和12h模式切换不需要快加
	cmp		#$20
	bne		No_KeySTrigger_TimeSetMode3
	jmp		L_KeySTrigger_TimeSetMode3			; 12/24h触发
No_KeySTrigger_TimeSetMode3:
	cmp		#$10
	bne		L_KeyExit_TimeSetMode3
	jmp		L_KeyBTrigger_TimeSetMode3			; Backlight/SNZ单独触发

L_KeyExit_TimeSetMode3:
	TMR1_OFF									; 关闭快加8Hz计时的定时器
	rmb0	Key_Flag							; 清相关标志位
	rmb3	Timer_Flag
	lda		#0									; 清理相关变量
	sta		QuickAdd_Counter
L_Key4HzExit_TimeSetMode3:
	jsr		F_QuikAdd_ScanReady					; 配置为输入
	rts


L_KeyMTrigger_TimeSetMode3:
	jsr		F_QuikAdd_ScanReset					; 有快加的情况需要重置IO口为输出高避免漏电
	lda		#00
	sta		R_Time_Sec							; 调分钟会清S计数
	inc		R_Time_Min
	lda		#59
	cmp		R_Time_Min
	bcs		L_MinSet_Juge3
	lda		#00
	sta		R_Time_Min
L_MinSet_Juge3:
	jsr		F_Display_Time3

	rts
L_KeyHTrigger_TimeSetMode3:
	jsr		F_QuikAdd_ScanReset					; 有快加的情况需要重置IO口为输出高避免漏电
	inc		R_Time_Hour
	lda		#23
	cmp		R_Time_Hour
	bcs		L_HourSet_Juge3
	lda		#00
	sta		R_Time_Hour
L_HourSet_Juge3:
	jsr		F_Display_Time3

	rts
L_KeyBTrigger_TimeSetMode3:
	smb3	Key_Flag
	smb2	PB
	lda		#0
	sta		Backlight_Counter					; 每次按背光都会重置计时
	rts
L_KeySTrigger_TimeSetMode3:
	lda		Clock_Flag
	eor		#0001B
	sta		Clock_Flag
	jsr		F_Display_Time3

	rts



; 闹钟设置模式的按键处理
F_KeyTrigger_AlarmSetMode3:
	bbs3	Timer_Flag,L_Key4Hz_AlarmSetMode3	; 有快加则直接判断8Hz标志位
	bbr1	Key_Flag,L_KeyScan_AlarmSetMode3	; 首次按键触发
	rmb1	Key_Flag
	lda		#$00
	sta		P_Temp
L_DelayTrigger_AlarmSetMode3:					; 消抖延时循环用标签
	inc		P_Temp
	lda		P_Temp
	bne		L_DelayTrigger_AlarmSetMode3		; 软件消抖
	lda		PA
	and		#$f0
	cmp		#$00
	bne		L_KeyYes_AlarmSetMode3				; 检测是否有按键触发
	bra		L_KeyExit_AlarmSetMode3
	rts
L_KeyYes_AlarmSetMode3:
	sta		PA_IO_Backup
	bra		L_KeyHandle_AlarmSetMode3			; 首次触发处理结束

L_Key4Hz_AlarmSetMode3:
	bbr2	Key_Flag,L_Key4HzExit_AlarmSetMode3
	rmb2	Key_Flag
L_KeyScan_AlarmSetMode3:						; 长按处理部分
	bbr0	Key_Flag,L_KeyExit_AlarmSetMode3	; 没有扫键标志直接退出

	jsr		F_QuikAdd_ScanReady					; 配置为输入
	jsr		F_Delay
	bbr4	Timer_Flag,L_Key4HzExit_AlarmSetMode3; 8Hz标志位到来前也不进行按键处理(快加下)
	rmb4	Timer_Flag
	lda		PA
	and		#$f0
	cmp		PA_IO_Backup						; 若检测到有按键的状态变化则退出快加判断并结束
	beq		L_4Hz_Count_AlarmSetMode3
	bra		L_KeyExit_AlarmSetMode3
	rts
L_4Hz_Count_AlarmSetMode3:
	inc		QuickAdd_Counter
	lda		QuickAdd_Counter
	cmp		#24
	bcs		L_QuikAdd_AlarmSetMode3
	rts											; 长按计时，必须满1S才有快加
L_QuikAdd_AlarmSetMode3:
	smb3	Timer_Flag
	rmb2	Key_Flag

L_KeyHandle_AlarmSetMode3:
	lda		PA									; 判断4种按键触发情况
	and		#$f0
	cmp		#$80
	bne		No_KeyHTrigger_AlarmSetMode3		; 由于跳转指令寻址能力的问题，这里采用jmp进行跳转
	jmp		L_KeyHTrigger_AlarmSetMode3			; Hour单独触发
No_KeyHTrigger_AlarmSetMode3:
	cmp		#$40
	bne		No_KeyMTrigger_AlarmSetMode3
	jmp		L_KeyMTrigger_AlarmSetMode3			; Min单独触发
No_KeyMTrigger_AlarmSetMode3:
	bbs3	Timer_Flag,L_KeyExit_AlarmSetMode3	; 背光和12h模式切换不需要快加
	cmp		#$20
	bne		No_KeySTrigger_AlarmSetMode3
	jmp		L_KeySTrigger_AlarmSetMode3			; 12/24h触发
No_KeySTrigger_AlarmSetMode3:
	cmp		#$10
	bne		L_KeyExit_AlarmSetMode3
	jmp		L_KeyBTrigger_AlarmSetMode3			; Backlight单独触发

L_KeyExit_AlarmSetMode3:
	TMR1_OFF									; 关闭快加8Hz计时的定时器
	rmb0	Key_Flag							; 清相关标志位
	rmb3	Timer_Flag
	lda		#0									; 清理相关变量
	sta		QuickAdd_Counter
L_Key4HzExit_AlarmSetMode3:
	jsr		F_QuikAdd_ScanReady					; 配置为输入
	rts

L_KeyMTrigger_AlarmSetMode3:
	jsr		F_QuikAdd_ScanReset					; 有快加的情况需要重置IO口为输出高避免漏电
	inc		R_Alarm_Min
	lda		#59
	cmp		R_Alarm_Min
	bcs		L_AlarmMinSet_Juge3
	lda		#00
	sta		R_Alarm_Min
L_AlarmMinSet_Juge3:
	jsr		F_Display_Alarm3
	rts

L_KeyHTrigger_AlarmSetMode3:
	jsr		F_QuikAdd_ScanReset					; 有快加的情况需要重置IO口为输出高避免漏电
	inc		R_Alarm_Hour
	lda		#23
	cmp		R_Alarm_Hour
	bcs		L_AlarmHourSet_Juge3
	lda		#00
	sta		R_Alarm_Hour
L_AlarmHourSet_Juge3:	
	jsr		F_Display_Alarm3
	rts
L_KeyBTrigger_AlarmSetMode3:
	smb3	Key_Flag
	smb2	PB
	lda		#0
	sta		Backlight_Counter					; 每次按背光都会重置计时
	rts
L_KeySTrigger_AlarmSetMode3:
	lda		Clock_Flag
	eor		#0001B
	sta		Clock_Flag
	jsr		F_Display_Alarm3
	rts
