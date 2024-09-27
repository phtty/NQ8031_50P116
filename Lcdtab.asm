;--------COM------------
c0		.equ	0
c1		.equ	1
c2		.equ	2
c3		.equ	3
c4		.equ	4
c5		.equ	5
;;--------SEG------------
s44		.equ	44
s43		.equ	43
s42		.equ	42
s41		.equ	41
s40		.equ	40
s15		.equ	15
s14		.equ	14
s13		.equ	13
s12		.equ	12
s11		.equ	11
s10		.equ	10
s9		.equ	9
s8		.equ	8
s7		.equ	7
s6		.equ	6
s5		.equ	5
s4		.equ	4
s3		.equ	3
s2		.equ	2
s1		.equ	1
s0		.equ	0


MS_dot .equ	1


.MACRO  db_c_s	com,seg
          .BYTE com*6+seg/8
.ENDMACRO

.MACRO  db_c_y	com,seg
	      .BYTE 1.shl.(seg-seg/8*8)
.ENDMACRO

Lcd_byte:							;段码<==>SEG/COM表
lcd_table1:
lcd_d1 .equ	lcd_table1-lcd_table1
	db_c_s	c3,s3					;1a
	db_c_s	c2,s3					;1b
	db_c_s	c1,s3					;1c
	db_c_s	c0,s3					;1d
	db_c_s	c0,s2					;1e
	db_c_s	c2,s2					;1f
	db_c_s	c1,s2					;1g

lcd_d2	.equ lcd_d1+7
	db_c_s	c3,s6					;2a
	db_c_s	c2,s6					;2b
	db_c_s	c1,s6					;2c
	db_c_s	c0,s6					;2d
	db_c_s	c0,s5					;2e
	db_c_s	c2,s5					;2f
	db_c_s	c1,s5					;2g

lcd_d3	.equ lcd_d2+7
	db_c_s	c3,s8					;3a
	db_c_s	c2,s8					;3b
	db_c_s	c1,s8					;3c
	db_c_s	c0,s8					;3d
	db_c_s	c0,s7					;3e
	db_c_s	c2,s7					;3f
	db_c_s	c1,s7					;3g

lcd_d4	.equ lcd_d3+7
	db_c_s	c3,s9					;4a
	db_c_s	c2,s9					;4b
	db_c_s	c1,s9					;4c
	db_c_s	c0,s9					;4d
	db_c_s	c0,s10					;4e
	db_c_s	c2,s10					;4f
	db_c_s	c1,s10					;4g

lcd_d5	.equ lcd_d4+7
	db_c_s	c3,s11					;5a
	db_c_s	c2,s11					;5b
	db_c_s	c1,s11					;5c
	db_c_s	c0,s11					;5d
	db_c_s	c0,s12					;5e
	db_c_s	c2,s12					;5f
	db_c_s	c1,s12					;5g

lcd_d6	.equ lcd_d5+7
	db_c_s	c3,s13					;6a
	db_c_s	c2,s13					;6b
	db_c_s	c1,s13					;6c
	db_c_s	c0,s13					;6d
	db_c_s	c0,s14					;6e
	db_c_s	c2,s14					;6f
	db_c_s	c1,s14					;6g

lcd_d7	.equ lcd_d6+7
	db_c_s	c3,s16					;7a
	db_c_s	c2,s16					;7b
	db_c_s	c1,s16					;7c
	db_c_s	c0,s16					;7d
	db_c_s	c0,s17					;7e
	db_c_s	c2,s17					;7f
	db_c_s	c1,s17					;7g

lcd_d8	.equ lcd_d7+7
	db_c_s	c3,s18					;8a
	db_c_s	c2,s18					;8b
	db_c_s	c1,s18					;8c
	db_c_s	c0,s18					;8d
	db_c_s	c0,s19					;8e
	db_c_s	c1,s19					;8g

lcd_d9	.equ lcd_d8+6
	db_c_s	c3,s20					;9a
	db_c_s	c2,s20					;9b
	db_c_s	c1,s20					;9c
	db_c_s	c0,s20					;9d
	db_c_s	c0,s21					;9e
	db_c_s	c2,s21					;9f
	db_c_s	c1,s21					;9g

lcd_d10	.equ lcd_d9+7
	db_c_s	c1,s1					;10aced
	db_c_s	c2,s1					;10b
	db_c_s	c0,s1					;10c

lcd_d11	.equ lcd_d10+3
	db_c_s	c1,s16					;11aced
	db_c_s	c2,s16					;11b
	db_c_s	c0,s16					;11c

lcd_dot:
lcd_AM .equ lcd_dot-lcd_table1
	db_c_s	c1,s0					;AM
lcd_PM .equ lcd_AM+1
	db_c_s	c0,s0					;PM
lcd_Bell .equ lcd_PM+1
	db_c_s	c2,s4					;Bell
lcd_DotC .equ lcd_Bell+1
	db_c_s	c1,s4					;DotC
lcd_Zz .equ lcd_DotC+1
	db_c_s	c0,s4					;Zz
lcd_Mo .equ lcd_Zz+1
	db_c_s	c3,s17					;Mo
lcd_Da .equ lcd_Mo+1
	db_c_s	c0,s4					;Da
lcd_Alm .equ lcd_Da+1
	db_c_s	c0,s4					;Alm
lcd_DotA .equ lcd_Alm+1
	db_c_s	c0,s4					;DotA
lcd_Slh	.equ lcd_DotA+1
	db_c_s	c0,s4					;Slh
lcd_T9	.equ lcd_slh+1
	db_c_s	c0,s4					;T9


;==========================================================
;==========================================================

Lcd_bit:
	db_c_y	c4,s0					;A1
	db_c_y	c4,s1					;A2
	db_c_y	c4,s2					;A3
	db_c_y	c3,s0					;A4
	db_c_y	c3,s1					;A5
	db_c_y	c4,s3					;A6
	db_c_y	c2,s0					;A7
	db_c_y	c3,s2					;A8
	db_c_y	c3,s3					;A9
	db_c_y	c2,s1					;A10
	db_c_y	c2,s2					;A11
	db_c_y	c2,s3					;A12
	db_c_y	c1,s0					;A13
	db_c_y	c1,s3					;A14
	db_c_y	c1,s4					;A15
	db_c_y	c1,s1					;A16
	db_c_y	c1,s2					;A17
	db_c_y	c0,s3					;A18
	db_c_y	c0,s0					;A19
	db_c_y	c0,s1					;A20
	db_c_y	c0,s2					;A21

	db_c_y	c4,s5					;B1
	db_c_y	c4,s6					;B2
	db_c_y	c4,s7					;B3
	db_c_y	c4,s4					;B4
	db_c_y	c3,s6					;B5
	db_c_y	c3,s7					;B6
	db_c_y	c3,s4					;B7
	db_c_y	c3,s5					;B8
	db_c_y	c2,s8					;B9
	db_c_y	c2,s4					;B10
	db_c_y	c2,s6					;B11
	db_c_y	c2,s7					;B12
	db_c_y	c2,s5					;B13
	db_c_y	c1,s7					;B14
	db_c_y	c1,s8					;B15
	db_c_y	c1,s5					;B16
	db_c_y	c1,s6					;B17
	db_c_y	c0,s7					;B18
	db_c_y	c0,s4					;B19
	db_c_y	c0,s5					;B20
	db_c_y	c0,s6					;B21

	db_c_y	c4,s8					;C1
	db_c_y	c4,s9					;C2
	db_c_y	c4,s10					;C3
	db_c_y	c3,s8					;C4
	db_c_y	c3,s11					;C5
	db_c_y	c4,s11					;C6
	db_c_y	c3,s9					;C7
	db_c_y	c3,s10					;C8
	db_c_y	c3,s12					;C9
	db_c_y	c2,s9					;C10
	db_c_y	c2,s10					;C11
	db_c_y	c2,s11					;C12
	db_c_y	c1,s9					;C13
	db_c_y	c1,s10					;C14
	db_c_y	c2,s12					;C15
	db_c_y	c0,s8					;C16
	db_c_y	c1,s11					;C17
	db_c_y	c1,s12					;C18
	db_c_y	c0,s9					;C19
	db_c_y	c0,s10					;C20
	db_c_y	c0,s11					;C21

	db_c_y	c4,s13					;D1
	db_c_y	c4,s14					;D2
	db_c_y	c4,s15					;D3
	db_c_y	c4,s12					;D4
	db_c_y	c3,s15					;D5
	db_c_y	c3,s40					;D6
	db_c_y	c3,s13					;D7
	db_c_y	c3,s14					;D8
	db_c_y	c2,s40					;D9
	db_c_y	c2,s13					;D10
	db_c_y	c2,s14					;D11
	db_c_y	c2,s15					;D12
	db_c_y	c1,s14					;D13
	db_c_y	c1,s15					;D14
	db_c_y	c1,s40					;D15
	db_c_y	c1,s13					;D16
	db_c_y	c0,s14					;D17
	db_c_y	c0,s15					;D18
	db_c_y	c0,s12					;D19
	db_c_y	c0,s13					;D20
	db_c_y	c0,s40					;D21

	db_c_y	c4,s40					;MS
;=========================================