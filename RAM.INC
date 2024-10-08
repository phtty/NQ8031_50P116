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
Counter_4Hz				DS		1
Counter_16Hz			DS		1

CC1						DS		1
CC2						DS		1

Clock_Flag				DS		1
;bit0 = 1 12h模式

Timer_Flag				DS		1

Sys_Status_Flag			DS		1


Key_Flag				DS		1
;bit0 = 1 扫键标志位
;bit1 = 1 首次触发
;bit2 = 1 按键处理

P_PA_IO_Backup      	DS	1	;B
P_PA_Backup         	DS	1	;C
P_PA_WAKE_Backup		DS	1	;D
P_PC_IO_Backup      	DS	1	;E
P_PC_Backup         	DS	1	;F
;---------------------------------------
Time_Str_Addr	EQU		$
R_Time_Sec				DS	1	;时间秒
R_Time_Min				DS	1	;时间分
R_Time_Hour				DS	1	;时间小时
R_Alarm_Min				DS	1	;闹钟分钟
R_Alarm_Hour			DS	1	;闹钟小时
R_Date_Day				DS	1	;日期
R_Date_Month			DS	1	;月份
R_Date_Year				DS	1	;年份

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

