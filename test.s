
test:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <start>:
   0:	ff010113          	addi	sp,sp,-16
   4:	00812623          	sw	s0,12(sp)
   8:	01010413          	addi	s0,sp,16
   c:	40000113          	li	sp,1024
  10:	04c000ef          	jal	ra,5c <main>
  14:	00000013          	nop
  18:	00c12403          	lw	s0,12(sp)
  1c:	01010113          	addi	sp,sp,16
  20:	00008067          	ret

00000024 <wait>:
  24:	fe010113          	addi	sp,sp,-32
  28:	00812e23          	sw	s0,28(sp)
  2c:	02010413          	addi	s0,sp,32
  30:	fea42623          	sw	a0,-20(s0)
  34:	00000013          	nop
  38:	fec42783          	lw	a5,-20(s0)
  3c:	fff78713          	addi	a4,a5,-1
  40:	fee42623          	sw	a4,-20(s0)
  44:	fe079ae3          	bnez	a5,38 <wait+0x14>
  48:	00000013          	nop
  4c:	00000013          	nop
  50:	01c12403          	lw	s0,28(sp)
  54:	02010113          	addi	sp,sp,32
  58:	00008067          	ret

0000005c <main>:
  5c:	fe010113          	addi	sp,sp,-32
  60:	00112e23          	sw	ra,28(sp)
  64:	00812c23          	sw	s0,24(sp)
  68:	02010413          	addi	s0,sp,32
  6c:	00100793          	li	a5,1
  70:	fef42623          	sw	a5,-20(s0)
  74:	f00007b7          	lui	a5,0xf0000
  78:	0007d783          	lhu	a5,0(a5) # f0000000 <__global_pointer$+0xefffe638>
  7c:	01079793          	slli	a5,a5,0x10
  80:	0107d793          	srli	a5,a5,0x10
  84:	fef42423          	sw	a5,-24(s0)
  88:	fe842783          	lw	a5,-24(s0)
  8c:	1007f793          	andi	a5,a5,256
  90:	00078863          	beqz	a5,a0 <main+0x44>
  94:	fec42503          	lw	a0,-20(s0)
  98:	034000ef          	jal	ra,cc <guess>
  9c:	fd9ff06f          	j	74 <main+0x18>
  a0:	fec42783          	lw	a5,-20(s0)
  a4:	00178793          	addi	a5,a5,1
  a8:	fef42623          	sw	a5,-20(s0)
  ac:	fec42703          	lw	a4,-20(s0)
  b0:	1ff00793          	li	a5,511
  b4:	00e7f663          	bgeu	a5,a4,c0 <main+0x64>
  b8:	00100793          	li	a5,1
  bc:	fef42623          	sw	a5,-20(s0)
  c0:	00a00513          	li	a0,10
  c4:	f61ff0ef          	jal	ra,24 <wait>
  c8:	fadff06f          	j	74 <main+0x18>

000000cc <guess>:
  cc:	fd010113          	addi	sp,sp,-48
  d0:	02812623          	sw	s0,44(sp)
  d4:	03010413          	addi	s0,sp,48
  d8:	fca42e23          	sw	a0,-36(s0)
  dc:	f00007b7          	lui	a5,0xf0000
  e0:	0007d783          	lhu	a5,0(a5) # f0000000 <__global_pointer$+0xefffe638>
  e4:	01079793          	slli	a5,a5,0x10
  e8:	0107d793          	srli	a5,a5,0x10
  ec:	fef42623          	sw	a5,-20(s0)
  f0:	fec42783          	lw	a5,-20(s0)
  f4:	1007f793          	andi	a5,a5,256
  f8:	0c078063          	beqz	a5,1b8 <guess+0xec>
  fc:	fec42783          	lw	a5,-20(s0)
 100:	0187f793          	andi	a5,a5,24
 104:	00800713          	li	a4,8
 108:	00e78863          	beq	a5,a4,118 <guess+0x4c>
 10c:	01000713          	li	a4,16
 110:	06e78a63          	beq	a5,a4,184 <guess+0xb8>
 114:	0800006f          	j	194 <guess+0xc8>
 118:	fec42783          	lw	a5,-20(s0)
 11c:	0087d793          	srli	a5,a5,0x8
 120:	fef405a3          	sb	a5,-21(s0)
 124:	feb44783          	lbu	a5,-21(s0)
 128:	fdc42703          	lw	a4,-36(s0)
 12c:	00f77c63          	bgeu	a4,a5,144 <guess+0x78>
 130:	e00007b7          	lui	a5,0xe0000
 134:	ff840737          	lui	a4,0xff840
 138:	99070713          	addi	a4,a4,-1648 # ff83f990 <__global_pointer$+0xff83dfc8>
 13c:	00e7a023          	sw	a4,0(a5) # e0000000 <__global_pointer$+0xdfffe638>
 140:	0700006f          	j	1b0 <guess+0xe4>
 144:	feb44783          	lbu	a5,-21(s0)
 148:	fdc42703          	lw	a4,-36(s0)
 14c:	00e7fc63          	bgeu	a5,a4,164 <guess+0x98>
 150:	e00007b7          	lui	a5,0xe0000
 154:	c7c7c737          	lui	a4,0xc7c7c
 158:	7c770713          	addi	a4,a4,1991 # c7c7c7c7 <__global_pointer$+0xc7c7adff>
 15c:	00e7a023          	sw	a4,0(a5) # e0000000 <__global_pointer$+0xdfffe638>
 160:	0500006f          	j	1b0 <guess+0xe4>
 164:	feb44783          	lbu	a5,-21(s0)
 168:	fdc42703          	lw	a4,-36(s0)
 16c:	04f71263          	bne	a4,a5,1b0 <guess+0xe4>
 170:	e00007b7          	lui	a5,0xe0000
 174:	88c69737          	lui	a4,0x88c69
 178:	8c670713          	addi	a4,a4,-1850 # 88c688c6 <__global_pointer$+0x88c66efe>
 17c:	00e7a023          	sw	a4,0(a5) # e0000000 <__global_pointer$+0xdfffe638>
 180:	0300006f          	j	1b0 <guess+0xe4>
 184:	e00007b7          	lui	a5,0xe0000
 188:	fdc42703          	lw	a4,-36(s0)
 18c:	00e7a023          	sw	a4,0(a5) # e0000000 <__global_pointer$+0xdfffe638>
 190:	0240006f          	j	1b4 <guess+0xe8>
 194:	fec42783          	lw	a5,-20(s0)
 198:	0087d793          	srli	a5,a5,0x8
 19c:	fef40523          	sb	a5,-22(s0)
 1a0:	e00007b7          	lui	a5,0xe0000
 1a4:	fea44703          	lbu	a4,-22(s0)
 1a8:	00e7a023          	sw	a4,0(a5) # e0000000 <__global_pointer$+0xdfffe638>
 1ac:	0080006f          	j	1b4 <guess+0xe8>
 1b0:	00000013          	nop
 1b4:	f29ff06f          	j	dc <guess+0x10>
 1b8:	00000013          	nop
 1bc:	02c12403          	lw	s0,44(sp)
 1c0:	03010113          	addi	sp,sp,48
 1c4:	00008067          	ret
