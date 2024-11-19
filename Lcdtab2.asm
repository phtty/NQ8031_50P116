Lcd_byte2:
lcd_table2:										;段码<==>SEG/COM表
lcd2_d0	equ	$-lcd_table2
	db_c_s	c1,s33	; 0BC

lcd2_d1	equ	$-lcd_table2
	db_c_s	c1,s35	; 1A
	db_c_s	c1,s36	; 1B
	db_c_s	c0,s36	; 1C
	db_c_s	c0,s33	; 1D
	db_c_s	c0,s34 	; 1E
	db_c_s	c1,s34	; 1F
	db_c_s	c0,s35	; 1G

lcd2_d2	equ	$-lcd_table2
	db_c_s	c1,s38	; 2AD
	db_c_s	c1,s39	; 2B
	db_c_s	c0,s39	; 2C
	db_c_s	c0,s37	; 2E
	db_c_s	c1,s37	; 2F
	db_c_s	c0,s38	; 2G

lcd2_d3	equ	$-lcd_table2
	db_c_s	c1,s42	; 3A
	db_c_s	c1,s43	; 3B
	db_c_s	c0,s43	; 3C
	db_c_s	c0,s44	; 3D
	db_c_s	c0,s41	; 3E
	db_c_s	c1,s41	; 3F
	db_c_s	c0,s42	; 3G

lcd2_dot:
lcd2_PM		equ	$-lcd_table2
	db_c_s	c1,s32	; PM
lcd2_bell	equ	$-lcd_table2
	db_c_s	c1,s44	; bell
lcd2_DotC	equ	$-lcd_table2
	db_c_s	c0,s32	; DotC
lcd2_Zz		equ	$-lcd_table2
	db_c_s	c0,s40	; Zz


;==========================================================
;==========================================================

Lcd_bit2:
	db_c_y	c1,s33	; 0BC

	db_c_y	c1,s35	; 1A
	db_c_y	c1,s36	; 1B
	db_c_y	c0,s36	; 1C
	db_c_y	c0,s33	; 1D
	db_c_y	c0,s34 	; 1E
	db_c_y	c1,s34	; 1F
	db_c_y	c0,s35	; 1G

	db_c_y	c1,s38	; 2AD
	db_c_y	c1,s39	; 2B
	db_c_y	c0,s39	; 2C
	db_c_y	c0,s37	; 2E
	db_c_y	c1,s37	; 2F
	db_c_y	c0,s38	; 2G

	db_c_y	c1,s42	; 3A
	db_c_y	c1,s43	; 3B
	db_c_y	c0,s43	; 3C
	db_c_y	c0,s44	; 3D
	db_c_y	c0,s41	; 3E
	db_c_y	c1,s41	; 3F
	db_c_y	c0,s42	; 3G

	db_c_y	c1,s32	; PM
	db_c_y	c1,s44	; bell
	db_c_y	c0,s32	; DotC
	db_c_y	c0,s40	; Zz