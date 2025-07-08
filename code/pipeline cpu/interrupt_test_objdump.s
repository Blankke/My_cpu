# RISC-V Interrupt Test Program - objdump format
# 包含中断处理程序的机器码和汇编对照

interrupt_test.o:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
   0:	10000137          	lui	sp,0x10000
   4:	11110093          	addi	ra,zero,0x1111
   8:	22220113          	addi	sp,zero,0x2222
   c:	33330193          	addi	gp,zero,0x3333
  10:	800002b7          	lui	t0,0x80000

00000014 <main_loop>:
  14:	00120213          	addi	tp,tp,1
  18:	00228293          	addi	t0,t0,2
  1c:	002083b3          	add	t2,ra,sp
  20:	40108433          	sub	s0,ra,gp
  24:	008474b3          	and	s1,s0,s0
  28:	008464b3          	or	s1,s0,s0
  2c:	00000073          	ecall


80000000 <interrupt_handler>:
80000000:	fc010113          	addi	sp,sp,-64
80000004:	00112023          	sw	ra,0(sp)
80000008:	00212223          	sw	sp,4(sp)
8000000c:	00312423          	sw	gp,8(sp)
80000010:	00412623          	sw	tp,12(sp)
80000014:	00512823          	sw	t0,16(sp)
80000018:	00612a23          	sw	t1,20(sp)
8000001c:	00712c23          	sw	t2,24(sp)
80000020:	00812e23          	sw	s0,28(sp)
80000024:	02912023          	sw	s1,32(sp)
80000028:	02a12223          	sw	a0,36(sp)
8000002c:	02b12423          	sw	a1,40(sp)
80000030:	02c12623          	sw	a2,44(sp)
80000034:	02d12823          	sw	a3,48(sp)
80000038:	02e12a23          	sw	a4,52(sp)
8000003c:	02f12c23          	sw	a5,56(sp)
80000040:	aaaa0713          	li	a4,-21846
80000044:	00178793          	addi	a5,a5,1
80000048:	00050863          	beqz	a0,80000058 <syscall_exit>
8000004c:	55550093          	li	ra,21845
80000050:	00050113          	mv	sp,a0
80000054:	00000013          	nop

80000058 <syscall_exit>:
80000058:	03812783          	lw	a5,56(sp)
8000005c:	03412703          	lw	a4,52(sp)
80000060:	03012683          	lw	a3,48(sp)
80000064:	02c12603          	lw	a2,44(sp)
80000068:	02812583          	lw	a1,40(sp)
8000006c:	02412503          	lw	a0,36(sp)
80000070:	02012483          	lw	s1,32(sp)
80000074:	01c12403          	lw	s0,28(sp)
80000078:	01812383          	lw	t2,24(sp)
8000007c:	01412303          	lw	t1,20(sp)
80000080:	01012283          	lw	t0,16(sp)
80000084:	00c12203          	lw	tp,12(sp)
80000088:	00812183          	lw	gp,8(sp)
8000008c:	00412103          	lw	sp,4(sp)
80000090:	00012083          	lw	ra,0(sp)
80000094:	04010113          	addi	sp,sp,64
80000098:	30200073          	mret

Disassembly of section .data:

8000009c <interrupt_count>:
8000009c:	00000000          	unimp

800000a0 <system_status>:
800000a0:	00000000          	unimp
