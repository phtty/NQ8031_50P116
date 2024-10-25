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
s39		.equ	39
s38		.equ	38
s37		.equ	37
s36		.equ	36
s35		.equ	35
s34		.equ	34
s33		.equ	33
s32		.equ	32
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


.MACRO  db_c_s	com,seg
          .BYTE com*6+seg/8
.ENDMACRO

.MACRO  db_c_y	com,seg
	      .BYTE 1.shl.(seg-seg/8*8)
.ENDMACRO

Lcd_byte:							;段码<==>SEG/COM表
lcd_table1:
lcd_d0	equ	$-lcd_table1
	db_c_s	c1,s42	; 0AGED
	db_c_s	c2,s42	; 0B
	db_c_s	c0,s42	; 0C
lcd_d1	equ	$-lcd_table1
	db_c_s	c3,s40	; 1A
	db_c_s	c2,s40	; 1B
	db_c_s	c1,s40	; 1C
	db_c_s	c0,s40	; 1D
	db_c_s	c0,s41	; 1E
	db_c_s	c2,s41	; 1F
	db_c_s	c1,s41	; 1G

lcd_d2	equ	$-lcd_table1
	db_c_s	c3,s37	; 2A 
	db_c_s	c2,s37	; 2B
	db_c_s	c1,s37	; 2C
	db_c_s	c0,s37	; 2D
	db_c_s	c0,s38	; 2E
	db_c_s	c2,s38	; 2F
	db_c_s	c1,s38	; 2G

lcd_d3	equ	$-lcd_table1
	db_c_s	c3,s35	; 3A
	db_c_s	c2,s35	; 3B
	db_c_s	c1,s35	; 3C
	db_c_s	c0,s35	; 3D
	db_c_s	c0,s36	; 3E
	db_c_s	c2,s36	; 3F
	db_c_s	c1,s36	; 3G

lcd_d4	equ	$-lcd_table1
	db_c_s	c3,s34	; 4A
	db_c_s	c2,s34	; 4B
	db_c_s	c1,s34	; 4C
	db_c_s	c0,s34	; 4D
	db_c_s	c0,s33	; 4E
	db_c_s	c2,s33	; 4F
	db_c_s	c1,s33	; 4G

lcd_d5	equ	$-lcd_table1
	db_c_s	c3,s32	; 5A
	db_c_s	c2,s32	; 5B
	db_c_s	c1,s32	; 5C
	db_c_s	c0,s32	; 5D
	db_c_s	c0,s15	; 5E
	db_c_s	c2,s15	; 5F
	db_c_s	c1,s15	; 5G

lcd_d6	equ	$-lcd_table1
	db_c_s	c3,s14	; 6A
	db_c_s	c2,s14	; 6B
	db_c_s	c1,s14	; 6C
	db_c_s	c0,s14	; 6D
	db_c_s	c0,s13	; 6E
	db_c_s	c2,s13	; 6F
	db_c_s	c1,s13	; 6G

lcd_d7	equ	$-lcd_table1
	db_c_s	c1,s12	; 7AGED
	db_c_s	c2,s12	; 7B
	db_c_s	c0,s12	; 7C

lcd_d8	equ	$-lcd_table1
	db_c_s	c3,s11	; 8A
	db_c_s	c2,s11	; 8B
	db_c_s	c1,s11	; 8C
	db_c_s	c0,s11	; 8D
	db_c_s	c0,s10	; 8E
	db_c_s	c2,s10	; 8F
	db_c_s	c1,s10	; 8G

lcd_d9	equ	$-lcd_table1
	db_c_s	c3,s9	; 9A
	db_c_s	c2,s9	; 9B
	db_c_s	c1,s9	; 9C
	db_c_s	c0,s9	; 9D
	db_c_s	c0,s8	; 9E
	db_c_s	c1,s8	; 9G

lcd_d10	equ	$-lcd_table1
	db_c_s	c3,s7	; 10A
	db_c_s	c2,s7	; 10B
	db_c_s	c1,s7	; 10C
	db_c_s	c0,s7	; 10D
	db_c_s	c0,s6	; 10E
	db_c_s	c2,s6	; 10F
	db_c_s	c1,s6	; 10G

lcd_d11	equ	$-lcd_table1
	db_c_s	c3,s6	; 11BC

lcd_dot:
lcd_AM		equ	$-lcd_table1
	db_c_s	c1,s43	; AM
lcd_PM		equ	$-lcd_table1
	db_c_s	c0,s43	; PM
lcd_bell	equ	$-lcd_table1
	db_c_s	c2,s39	; bell
lcd_DotC	equ	$-lcd_table1
	db_c_s	c1,s39	; DotC
lcd_Zz		equ	$-lcd_table1
	db_c_s	c0,s39	; Zz
lcd_MD		equ	$-lcd_table1
	db_c_s	c3,s10	; MD
lcd_ALM		equ	$-lcd_table1
	db_c_s	c3,s33	; ALM
lcd_DotA	equ	$-lcd_table1
	db_c_s	c3,s15	; DotA
lcd_SLH		equ	$-lcd_table1
	db_c_s	c3,s8	; SLH
lcd_PM2		equ	$-lcd_table1
	db_c_s	c3,s13	; PM2


;==========================================================
;==========================================================

Lcd_bit:
	db_c_y	c1,s42	; 0AGED
	db_c_y	c2,s42	; 0B
	db_c_y	c0,s42	; 0C

	db_c_y	c3,s40	; 1A
	db_c_y	c2,s40	; 1B
	db_c_y	c1,s40	; 1C
	db_c_y	c0,s40	; 1D
	db_c_y	c0,s41	; 1E
	db_c_y	c2,s41	; 1F
	db_c_y	c1,s41	; 1G

	db_c_y	c3,s37	; 2A 
	db_c_y	c2,s37	; 2B
	db_c_y	c1,s37	; 2C
	db_c_y	c0,s37	; 2D
	db_c_y	c0,s38	; 2E
	db_c_y	c2,s38	; 2F
	db_c_y	c1,s38	; 2G

	db_c_y	c3,s35	; 3A
	db_c_y	c2,s35	; 3B
	db_c_y	c1,s35	; 3C
	db_c_y	c0,s35	; 3D
	db_c_y	c0,s36	; 3E
	db_c_y	c2,s36	; 3F
	db_c_y	c1,s36	; 3G

	db_c_y	c3,s34	; 4A
	db_c_y	c2,s34	; 4B
	db_c_y	c1,s34	; 4C
	db_c_y	c0,s34	; 4D
	db_c_y	c0,s33	; 4E
	db_c_y	c2,s33	; 4F
	db_c_y	c1,s33	; 4G

	db_c_y	c3,s32	; 5A
	db_c_y	c2,s32	; 5B
	db_c_y	c1,s32	; 5C
	db_c_y	c0,s32	; 5D
	db_c_y	c0,s15	; 5E
	db_c_y	c2,s15	; 5F
	db_c_y	c1,s15	; 5G

	db_c_y	c3,s14	; 6A
	db_c_y	c2,s14	; 6B
	db_c_y	c1,s14	; 6C
	db_c_y	c0,s14	; 6D
	db_c_y	c0,s13	; 6E
	db_c_y	c2,s13	; 6F
	db_c_y	c1,s13	; 6G

	db_c_y	c1,s12	; 7AGED
	db_c_y	c2,s12	; 7B
	db_c_y	c0,s12	; 7C

	db_c_y	c3,s11	; 8A
	db_c_y	c2,s11	; 8B
	db_c_y	c1,s11	; 8C
	db_c_y	c0,s11	; 8D
	db_c_y	c0,s10	; 8E
	db_c_y	c2,s10	; 8F
	db_c_y	c1,s10	; 8G

	db_c_y	c3,s9	; 9A
	db_c_y	c2,s9	; 9B
	db_c_y	c1,s9	; 9C
	db_c_y	c0,s9	; 9D
	db_c_y	c0,s8	; 9E
	db_c_y	c1,s8	; 9G

	db_c_y	c3,s7	; 10A
	db_c_y	c2,s7	; 10B
	db_c_y	c1,s7	; 10C
	db_c_y	c0,s7	; 10D
	db_c_y	c0,s6	; 10E
	db_c_y	c2,s6	; 10F
	db_c_y	c1,s6	; 10G

	db_c_y	c3,s6	; 11BC

	db_c_y	c1,s43	; AM
	db_c_y	c0,s43	; PM
	db_c_y	c2,s39	; bell
	db_c_y	c1,s39	; DotC
	db_c_y	c0,s39	; Zz
	db_c_y	c3,s10	; MD
	db_c_y	c3,s33	; ALM
	db_c_y	c3,s15	; DotA
	db_c_y	c3,s8	; SLH
	db_c_y	c3,s13	; PM2
;=========================================