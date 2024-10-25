Lcd3_byte:								;段码<==>SEG/COM表
lcd_table3:
lcd3_d0	equ	$-lcd_table3
	db_c_s	c1,s43	; 0AGED
	db_c_s	c3,s42	; 0B
	db_c_s	c0,s43	; 0C

lcd3_d1	equ	$-lcd_table3
	db_c_s	c3,s41	; 1A
	db_c_s	c2,s41	; 1B
	db_c_s	c1,s41	; 1C
	db_c_s	c0,s41	; 1D
	db_c_s	c0,s42	; 1E
	db_c_s	c2,s42	; 1F
	db_c_s	c1,s42	; 1G

lcd3_d2	equ	$-lcd_table3
	db_c_s	c3,s38	; 2A
	db_c_s	c2,s38	; 2B
	db_c_s	c1,s38	; 2C
	db_c_s	c0,s38	; 2D
	db_c_s	c0,s39	; 2E
	db_c_s	c2,s39	; 2F
	db_c_s	c1,s39	; 2G

lcd3_d3	equ	$-lcd_table3
	db_c_s	c3,s36	; 3A
	db_c_s	c2,s36	; 3B
	db_c_s	c1,s36	; 3C
	db_c_s	c0,s36	; 3D
	db_c_s	c0,s37	; 3E
	db_c_s	c2,s37	; 3F
	db_c_s	c1,s37	; 3G

lcd3_d4	equ	$-lcd_table3
	db_c_s	c3,s34	; 4A
	db_c_s	c3,s35	; 4B
	db_c_s	c0,s35	; 4C
	db_c_s	c0,s34	; 4D
	db_c_s	c0,s33	; 4E
	db_c_s	c3,s33	; 4F
	db_c_s	c1,s33	; 4G
	db_c_s	c2,s35	; 4H
	db_c_s	c2,s33	; 4I
	db_c_s	c2,s34	; 4J
	db_c_s	c1,s35	; 4L
	db_c_s	c1,s34	; 4M

lcd3_d5	equ	$-lcd_table3
	db_c_s	c3,s15	; 5A
	db_c_s	c2,s32	; 5B
	db_c_s	c0,s32	; 5C
	db_c_s	c0,s15	; 5D
	db_c_s	c0,s14	; 5E
	db_c_s	c2,s14	; 5F
	db_c_s	c2,s15	; 5G
	db_c_s	c1,s32	; 5H
	db_c_s	c1,s15	; 5L

lcd3_d6	equ	$-lcd_table3
	db_c_s	c3,s12	; 6A
	db_c_s	c3,s14	; 6B
	db_c_s	c1,s14	; 6C
	db_c_s	c0,s13	; 6D
	db_c_s	c0,s11	; 6E
	db_c_s	c3,s11	; 6F
	db_c_s	c1,s11	; 6G
	db_c_s	c2,s13	; 6H
	db_c_s	c2,s11	; 6I
	db_c_s	c2,s12	; 6J
	db_c_s	c3,s13	; 6K
	db_c_s	c1,s13	; 6L
	db_c_s	c1,s12	; 6M
	db_c_s	c0,s12	; 6N

lcd3_d7	equ	$-lcd_table3
	db_c_s	c3,s10	; 7A
	db_c_s	c2,s10	; 7B
	db_c_s	c1,s10	; 7C
	db_c_s	c0,s10	; 7D
	db_c_s	c0,s9	; 7E
	db_c_s	c2,s9	; 7F
	db_c_s	c1,s9	; 7G

lcd3_d8	equ	$-lcd_table3
	db_c_s	c2,s8	; 8AGD
	db_c_s	c3,s8	; 8B
	db_c_s	c0,s8	; 8C
	db_c_s	c1,s8	; 8E

lcd3_d9	equ	$-lcd_table3
	db_c_s	c3,s7	; 9A
	db_c_s	c2,s7	; 9B
	db_c_s	c1,s7	; 9C
	db_c_s	c0,s7	; 9D
	db_c_s	c0,s6	; 9E
	db_c_s	c2,s6	; 9F
	db_c_s	c1,s6	; 9G

lcd3_d10	equ	$-lcd_table3
	db_c_s	c3,s6	; 10BC

lcd3_dot:
lcd3_AM		equ	$-lcd_table3
	db_c_s	c3,s43	; AM
lcd3_PM		equ	$-lcd_table3
	db_c_s	c2,s43	;PM
lcd3_bell	equ	$-lcd_table3
	db_c_s	c3,s40	; bell
lcd3_DotC	equ	$-lcd_table3
	db_c_s	c2,s40	; DotC
lcd3_Zz		equ	$-lcd_table3
	db_c_s	c1,s40	; Zz
lcd3_MDS	equ	$-lcd_table3
	db_c_s	c3,s9	; MDS
lcd3_ALM	equ	$-lcd_table3
	db_c_s	c0,s40	; ALM
lcd3_Day	equ	$-lcd_table3
	db_c_s	c3,s32	; DAY


;==========================================================
;==========================================================

Lcd3_bit:
	db_c_y	c1,s43	; 0AGED
	db_c_y	c3,s42	; 0B
	db_c_y	c0,s43	; 0C

	db_c_y	c3,s41	; 1A
	db_c_y	c2,s41	; 1B
	db_c_y	c1,s41	; 1C
	db_c_y	c0,s41	; 1D
	db_c_y	c0,s42	; 1E
	db_c_y	c2,s42	; 1F
	db_c_y	c1,s42	; 1G

	db_c_y	c3,s38	; 2A
	db_c_y	c2,s38	; 2B
	db_c_y	c1,s38	; 2C
	db_c_y	c0,s38	; 2D
	db_c_y	c0,s39	; 2E
	db_c_y	c2,s39	; 2F
	db_c_y	c1,s39	; 2G

	db_c_y	c3,s36	; 3A
	db_c_y	c2,s36	; 3B
	db_c_y	c1,s36	; 3C
	db_c_y	c0,s36	; 3D
	db_c_y	c0,s37	; 3E
	db_c_y	c2,s37	; 3F
	db_c_y	c1,s37	; 3G

	db_c_y	c3,s34	; 4A
	db_c_y	c3,s35	; 4B
	db_c_y	c0,s35	; 4C
	db_c_y	c0,s34	; 4D
	db_c_y	c0,s33	; 4E
	db_c_y	c3,s33	; 4F
	db_c_y	c1,s33	; 4G
	db_c_y	c2,s35	; 4H
	db_c_y	c2,s33	; 4I
	db_c_y	c2,s34	; 4J
	db_c_y	c1,s35	; 4L
	db_c_y	c1,s34	; 4M

	db_c_y	c3,s15	; 5A
	db_c_y	c2,s32	; 5B
	db_c_y	c0,s32	; 5C
	db_c_y	c0,s15	; 5D
	db_c_y	c0,s14	; 5E
	db_c_y	c2,s14	; 5F
	db_c_y	c2,s15	; 5G
	db_c_y	c1,s32	; 5H
	db_c_y	c1,s15	; 5L

	db_c_y	c3,s12	; 6A
	db_c_y	c3,s14	; 6B
	db_c_y	c1,s14	; 6C
	db_c_y	c0,s13	; 6D
	db_c_y	c0,s11	; 6E
	db_c_y	c3,s11	; 6F
	db_c_y	c1,s11	; 6G
	db_c_y	c2,s13	; 6H
	db_c_y	c2,s11	; 6I
	db_c_y	c2,s12	; 6J
	db_c_y	c3,s13	; 6K
	db_c_y	c1,s13	; 6L
	db_c_y	c1,s12	; 6M
	db_c_y	c0,s12	; 6N

	db_c_y	c3,s10	; 7A
	db_c_y	c2,s10	; 7B
	db_c_y	c1,s10	; 7C
	db_c_y	c0,s10	; 7D
	db_c_y	c0,s9	; 7E
	db_c_y	c2,s9	; 7F
	db_c_y	c1,s9	; 7G

	db_c_y	c2,s8	; 8AGD
	db_c_y	c3,s8	; 8B
	db_c_y	c0,s8	; 8C
	db_c_y	c1,s8	; 8E

	db_c_y	c3,s7	; 9A
	db_c_y	c2,s7	; 9B
	db_c_y	c1,s7	; 9C
	db_c_y	c0,s7	; 9D
	db_c_y	c0,s6	; 9E
	db_c_y	c2,s6	; 9F
	db_c_y	c1,s6	; 9G

	db_c_y	c3,s6	; 10BC

	db_c_y	c3,s43	; AM
	db_c_y	c2,s43	; PM
	db_c_y	c3,s40	; bell
	db_c_y	c2,s40	; DotC
	db_c_y	c1,s40	; Zz
	db_c_y	c3,s9	; MD
	db_c_y	c0,s40	; ALM
	db_c_y	c3,s32	; DAY
