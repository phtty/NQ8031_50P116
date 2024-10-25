.Kdata
;***************************************
; RAM Address
;***************************************
RamStarAddr		EQU		1800H			;RAM的开始地址
LCD_RamAddr		EQU		RamStarAddr		;LCD RAM的地址
Time_Addr		EQU		RamStarAddr+Time_Str_Addr-Page0RamStarAddr ;事件相关数据的地址


;***************************************
;Time_Addr		EUQ		B0H
;***************************************
.PAGE0     ;page 0的内存布局
;***************************************
;	ORG	0098H
;---------------------------------------------------------------------
	ORG	0080H
Page0RamStarAddr		EQU		$
LCDRAM					DS		6*6

R_Int_Backup			DS		1

Counter_1Hz				DS		1
Counter_16Hz			DS		1

QuickAdd_Counter		DS		1
Backlight_Counter		DS		1
AlarmLoud_Counter		DS		1

Calendar_Flag			DS		1
;bit0 = 1 闰年
;bit1 = 1 增日期

Clock_Flag				DS		1
;bit0 = 1 12h模式
;bit1 = 1 闹钟开启模式
;bit2 = 1 响闹模式
;bit3 = 1 贪睡模式
;bit4 = 1 持续响铃模式; 0 序列响铃模式
;bit5	  上次的响闹模式，判断是响闹结束还是未响闹
;bit6 = 1 贪睡按键触发导致的响闹结束

Timer_Flag				DS		1
;bit0 = 1 Timer2 半S计时
;bit1 = 1 Timer2 1S计时
;bit2 = 1 增S标志
;bit3 = 1 快加标志
;bit4 = 1 Timer1 8Hz计时
;bit5 = 1 Timer2 背光1S计时
;bit6 = 1 Timer0 16Hz标志
;bit7 = 1 Timer2 响铃1S计时

Sys_Status_Flag			DS		1
;bit0 = 1 正常走时
;bit1 = 1 设置日历
;bit2 = 1 设置时间
;bit3 = 1 设置闹钟

Key_Flag				DS		1
;bit0 = 1 扫键标志位
;bit1 = 1 首次触发
;bit2 = 1 按键处理
;bit3 = 1 背光激活

Beep_Serial				DS		1
;响铃序列

PA_IO_Backup         	DS		1
PC_IO_Backup      		DS		1
;---------------------------------------
Time_Str_Addr	EQU		$
R_Time_Sec				DS		1	;时间秒
R_Time_Min				DS		1	;时间分
R_Time_Hour				DS		1	;时间小时
R_Date_Day				DS		1	;日期，从1开始
R_Date_Month			DS		1	;月份，从1开始
R_Date_Year				DS		1	;年份，由于只计2000-2099，所以由0-99代替
R_Date_Week				DS		1	;星期数，从1开始
R_Alarm_Min				DS		1	;闹钟分钟
R_Alarm_Hour			DS		1	;闹钟小时
R_Snooze_Min			DS		1	;贪睡闹钟分钟
R_Snooze_Hour			DS		1	;贪睡闹钟小时

;---------------------------------------       
P_Temp					DS	16	
;---------------------------------------
;---------------------------------------
;***************************************
.ENDS
;***************************************
.Udata
;---------------------------------------
	ORG		1880H
;---------------------------------------
;---------------------------------------
.ENDS

