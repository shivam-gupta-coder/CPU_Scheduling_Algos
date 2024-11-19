
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	94013103          	ld	sp,-1728(sp) # 80008940 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	95070713          	addi	a4,a4,-1712 # 800089a0 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	57e78793          	addi	a5,a5,1406 # 800065e0 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd8ddf>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dcc78793          	addi	a5,a5,-564 # 80000e78 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	6cc080e7          	jalr	1740(ra) # 800027f6 <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	784080e7          	jalr	1924(ra) # 800008be <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	95650513          	addi	a0,a0,-1706 # 80010ae0 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	94648493          	addi	s1,s1,-1722 # 80010ae0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	9d690913          	addi	s2,s2,-1578 # 80010b78 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if(killed(myproc())){
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	986080e7          	jalr	-1658(ra) # 80001b46 <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	45a080e7          	jalr	1114(ra) # 80002622 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	146080e7          	jalr	326(ra) # 8000231c <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	58e080e7          	jalr	1422(ra) # 800027a0 <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	8ba50513          	addi	a0,a0,-1862 # 80010ae0 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	8a450513          	addi	a0,a0,-1884 # 80010ae0 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	90f72323          	sw	a5,-1786(a4) # 80010b78 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	560080e7          	jalr	1376(ra) # 800007ec <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54e080e7          	jalr	1358(ra) # 800007ec <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	542080e7          	jalr	1346(ra) # 800007ec <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	538080e7          	jalr	1336(ra) # 800007ec <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00011517          	auipc	a0,0x11
    800002d0:	81450513          	addi	a0,a0,-2028 # 80010ae0 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	55a080e7          	jalr	1370(ra) # 8000284c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	7e650513          	addi	a0,a0,2022 # 80010ae0 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00010717          	auipc	a4,0x10
    80000322:	7c270713          	addi	a4,a4,1986 # 80010ae0 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00010797          	auipc	a5,0x10
    8000034c:	79878793          	addi	a5,a5,1944 # 80010ae0 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00011797          	auipc	a5,0x11
    8000037a:	8027a783          	lw	a5,-2046(a5) # 80010b78 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	75670713          	addi	a4,a4,1878 # 80010ae0 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	74648493          	addi	s1,s1,1862 # 80010ae0 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	70a70713          	addi	a4,a4,1802 # 80010ae0 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	78f72a23          	sw	a5,1940(a4) # 80010b80 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	6ce78793          	addi	a5,a5,1742 # 80010ae0 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	74c7a323          	sw	a2,1862(a5) # 80010b7c <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	73a50513          	addi	a0,a0,1850 # 80010b78 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	f4a080e7          	jalr	-182(ra) # 80002390 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	68050513          	addi	a0,a0,1664 # 80010ae0 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32c080e7          	jalr	812(ra) # 8000079c <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00024797          	auipc	a5,0x24
    8000047c:	41078793          	addi	a5,a5,1040 # 80024888 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7670713          	addi	a4,a4,-906 # 80000100 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054763          	bltz	a0,80000538 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088c63          	beqz	a7,800004fe <printint+0x62>
    buf[i++] = '-';
    800004ea:	fe070793          	addi	a5,a4,-32
    800004ee:	00878733          	add	a4,a5,s0
    800004f2:	02d00793          	li	a5,45
    800004f6:	fef70823          	sb	a5,-16(a4)
    800004fa:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fe:	02e05763          	blez	a4,8000052c <printint+0x90>
    80000502:	fd040793          	addi	a5,s0,-48
    80000506:	00e784b3          	add	s1,a5,a4
    8000050a:	fff78913          	addi	s2,a5,-1
    8000050e:	993a                	add	s2,s2,a4
    80000510:	377d                	addiw	a4,a4,-1
    80000512:	1702                	slli	a4,a4,0x20
    80000514:	9301                	srli	a4,a4,0x20
    80000516:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051a:	fff4c503          	lbu	a0,-1(s1)
    8000051e:	00000097          	auipc	ra,0x0
    80000522:	d5e080e7          	jalr	-674(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000526:	14fd                	addi	s1,s1,-1
    80000528:	ff2499e3          	bne	s1,s2,8000051a <printint+0x7e>
}
    8000052c:	70a2                	ld	ra,40(sp)
    8000052e:	7402                	ld	s0,32(sp)
    80000530:	64e2                	ld	s1,24(sp)
    80000532:	6942                	ld	s2,16(sp)
    80000534:	6145                	addi	sp,sp,48
    80000536:	8082                	ret
    x = -xx;
    80000538:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053c:	4885                	li	a7,1
    x = -xx;
    8000053e:	bf95                	j	800004b2 <printint+0x16>

0000000080000540 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000540:	1101                	addi	sp,sp,-32
    80000542:	ec06                	sd	ra,24(sp)
    80000544:	e822                	sd	s0,16(sp)
    80000546:	e426                	sd	s1,8(sp)
    80000548:	1000                	addi	s0,sp,32
    8000054a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054c:	00010797          	auipc	a5,0x10
    80000550:	6407aa23          	sw	zero,1620(a5) # 80010ba0 <pr+0x18>
  printf("panic: ");
    80000554:	00008517          	auipc	a0,0x8
    80000558:	ac450513          	addi	a0,a0,-1340 # 80008018 <etext+0x18>
    8000055c:	00000097          	auipc	ra,0x0
    80000560:	02e080e7          	jalr	46(ra) # 8000058a <printf>
  printf(s);
    80000564:	8526                	mv	a0,s1
    80000566:	00000097          	auipc	ra,0x0
    8000056a:	024080e7          	jalr	36(ra) # 8000058a <printf>
  printf("\n");
    8000056e:	00008517          	auipc	a0,0x8
    80000572:	d4a50513          	addi	a0,a0,-694 # 800082b8 <digits+0x278>
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	014080e7          	jalr	20(ra) # 8000058a <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057e:	4785                	li	a5,1
    80000580:	00008717          	auipc	a4,0x8
    80000584:	3ef72023          	sw	a5,992(a4) # 80008960 <panicked>
  for(;;)
    80000588:	a001                	j	80000588 <panic+0x48>

000000008000058a <printf>:
{
    8000058a:	7131                	addi	sp,sp,-192
    8000058c:	fc86                	sd	ra,120(sp)
    8000058e:	f8a2                	sd	s0,112(sp)
    80000590:	f4a6                	sd	s1,104(sp)
    80000592:	f0ca                	sd	s2,96(sp)
    80000594:	ecce                	sd	s3,88(sp)
    80000596:	e8d2                	sd	s4,80(sp)
    80000598:	e4d6                	sd	s5,72(sp)
    8000059a:	e0da                	sd	s6,64(sp)
    8000059c:	fc5e                	sd	s7,56(sp)
    8000059e:	f862                	sd	s8,48(sp)
    800005a0:	f466                	sd	s9,40(sp)
    800005a2:	f06a                	sd	s10,32(sp)
    800005a4:	ec6e                	sd	s11,24(sp)
    800005a6:	0100                	addi	s0,sp,128
    800005a8:	8a2a                	mv	s4,a0
    800005aa:	e40c                	sd	a1,8(s0)
    800005ac:	e810                	sd	a2,16(s0)
    800005ae:	ec14                	sd	a3,24(s0)
    800005b0:	f018                	sd	a4,32(s0)
    800005b2:	f41c                	sd	a5,40(s0)
    800005b4:	03043823          	sd	a6,48(s0)
    800005b8:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005bc:	00010d97          	auipc	s11,0x10
    800005c0:	5e4dad83          	lw	s11,1508(s11) # 80010ba0 <pr+0x18>
  if(locking)
    800005c4:	020d9b63          	bnez	s11,800005fa <printf+0x70>
  if (fmt == 0)
    800005c8:	040a0263          	beqz	s4,8000060c <printf+0x82>
  va_start(ap, fmt);
    800005cc:	00840793          	addi	a5,s0,8
    800005d0:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d4:	000a4503          	lbu	a0,0(s4)
    800005d8:	14050f63          	beqz	a0,80000736 <printf+0x1ac>
    800005dc:	4981                	li	s3,0
    if(c != '%'){
    800005de:	02500a93          	li	s5,37
    switch(c){
    800005e2:	07000b93          	li	s7,112
  consputc('x');
    800005e6:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e8:	00008b17          	auipc	s6,0x8
    800005ec:	a58b0b13          	addi	s6,s6,-1448 # 80008040 <digits>
    switch(c){
    800005f0:	07300c93          	li	s9,115
    800005f4:	06400c13          	li	s8,100
    800005f8:	a82d                	j	80000632 <printf+0xa8>
    acquire(&pr.lock);
    800005fa:	00010517          	auipc	a0,0x10
    800005fe:	58e50513          	addi	a0,a0,1422 # 80010b88 <pr>
    80000602:	00000097          	auipc	ra,0x0
    80000606:	5d4080e7          	jalr	1492(ra) # 80000bd6 <acquire>
    8000060a:	bf7d                	j	800005c8 <printf+0x3e>
    panic("null fmt");
    8000060c:	00008517          	auipc	a0,0x8
    80000610:	a1c50513          	addi	a0,a0,-1508 # 80008028 <etext+0x28>
    80000614:	00000097          	auipc	ra,0x0
    80000618:	f2c080e7          	jalr	-212(ra) # 80000540 <panic>
      consputc(c);
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	c60080e7          	jalr	-928(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000624:	2985                	addiw	s3,s3,1
    80000626:	013a07b3          	add	a5,s4,s3
    8000062a:	0007c503          	lbu	a0,0(a5)
    8000062e:	10050463          	beqz	a0,80000736 <printf+0x1ac>
    if(c != '%'){
    80000632:	ff5515e3          	bne	a0,s5,8000061c <printf+0x92>
    c = fmt[++i] & 0xff;
    80000636:	2985                	addiw	s3,s3,1
    80000638:	013a07b3          	add	a5,s4,s3
    8000063c:	0007c783          	lbu	a5,0(a5)
    80000640:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000644:	cbed                	beqz	a5,80000736 <printf+0x1ac>
    switch(c){
    80000646:	05778a63          	beq	a5,s7,8000069a <printf+0x110>
    8000064a:	02fbf663          	bgeu	s7,a5,80000676 <printf+0xec>
    8000064e:	09978863          	beq	a5,s9,800006de <printf+0x154>
    80000652:	07800713          	li	a4,120
    80000656:	0ce79563          	bne	a5,a4,80000720 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    8000065a:	f8843783          	ld	a5,-120(s0)
    8000065e:	00878713          	addi	a4,a5,8
    80000662:	f8e43423          	sd	a4,-120(s0)
    80000666:	4605                	li	a2,1
    80000668:	85ea                	mv	a1,s10
    8000066a:	4388                	lw	a0,0(a5)
    8000066c:	00000097          	auipc	ra,0x0
    80000670:	e30080e7          	jalr	-464(ra) # 8000049c <printint>
      break;
    80000674:	bf45                	j	80000624 <printf+0x9a>
    switch(c){
    80000676:	09578f63          	beq	a5,s5,80000714 <printf+0x18a>
    8000067a:	0b879363          	bne	a5,s8,80000720 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067e:	f8843783          	ld	a5,-120(s0)
    80000682:	00878713          	addi	a4,a5,8
    80000686:	f8e43423          	sd	a4,-120(s0)
    8000068a:	4605                	li	a2,1
    8000068c:	45a9                	li	a1,10
    8000068e:	4388                	lw	a0,0(a5)
    80000690:	00000097          	auipc	ra,0x0
    80000694:	e0c080e7          	jalr	-500(ra) # 8000049c <printint>
      break;
    80000698:	b771                	j	80000624 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069a:	f8843783          	ld	a5,-120(s0)
    8000069e:	00878713          	addi	a4,a5,8
    800006a2:	f8e43423          	sd	a4,-120(s0)
    800006a6:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006aa:	03000513          	li	a0,48
    800006ae:	00000097          	auipc	ra,0x0
    800006b2:	bce080e7          	jalr	-1074(ra) # 8000027c <consputc>
  consputc('x');
    800006b6:	07800513          	li	a0,120
    800006ba:	00000097          	auipc	ra,0x0
    800006be:	bc2080e7          	jalr	-1086(ra) # 8000027c <consputc>
    800006c2:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c4:	03c95793          	srli	a5,s2,0x3c
    800006c8:	97da                	add	a5,a5,s6
    800006ca:	0007c503          	lbu	a0,0(a5)
    800006ce:	00000097          	auipc	ra,0x0
    800006d2:	bae080e7          	jalr	-1106(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d6:	0912                	slli	s2,s2,0x4
    800006d8:	34fd                	addiw	s1,s1,-1
    800006da:	f4ed                	bnez	s1,800006c4 <printf+0x13a>
    800006dc:	b7a1                	j	80000624 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	6384                	ld	s1,0(a5)
    800006ec:	cc89                	beqz	s1,80000706 <printf+0x17c>
      for(; *s; s++)
    800006ee:	0004c503          	lbu	a0,0(s1)
    800006f2:	d90d                	beqz	a0,80000624 <printf+0x9a>
        consputc(*s);
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	b88080e7          	jalr	-1144(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fc:	0485                	addi	s1,s1,1
    800006fe:	0004c503          	lbu	a0,0(s1)
    80000702:	f96d                	bnez	a0,800006f4 <printf+0x16a>
    80000704:	b705                	j	80000624 <printf+0x9a>
        s = "(null)";
    80000706:	00008497          	auipc	s1,0x8
    8000070a:	91a48493          	addi	s1,s1,-1766 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070e:	02800513          	li	a0,40
    80000712:	b7cd                	j	800006f4 <printf+0x16a>
      consputc('%');
    80000714:	8556                	mv	a0,s5
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b66080e7          	jalr	-1178(ra) # 8000027c <consputc>
      break;
    8000071e:	b719                	j	80000624 <printf+0x9a>
      consputc('%');
    80000720:	8556                	mv	a0,s5
    80000722:	00000097          	auipc	ra,0x0
    80000726:	b5a080e7          	jalr	-1190(ra) # 8000027c <consputc>
      consputc(c);
    8000072a:	8526                	mv	a0,s1
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b50080e7          	jalr	-1200(ra) # 8000027c <consputc>
      break;
    80000734:	bdc5                	j	80000624 <printf+0x9a>
  if(locking)
    80000736:	020d9163          	bnez	s11,80000758 <printf+0x1ce>
}
    8000073a:	70e6                	ld	ra,120(sp)
    8000073c:	7446                	ld	s0,112(sp)
    8000073e:	74a6                	ld	s1,104(sp)
    80000740:	7906                	ld	s2,96(sp)
    80000742:	69e6                	ld	s3,88(sp)
    80000744:	6a46                	ld	s4,80(sp)
    80000746:	6aa6                	ld	s5,72(sp)
    80000748:	6b06                	ld	s6,64(sp)
    8000074a:	7be2                	ld	s7,56(sp)
    8000074c:	7c42                	ld	s8,48(sp)
    8000074e:	7ca2                	ld	s9,40(sp)
    80000750:	7d02                	ld	s10,32(sp)
    80000752:	6de2                	ld	s11,24(sp)
    80000754:	6129                	addi	sp,sp,192
    80000756:	8082                	ret
    release(&pr.lock);
    80000758:	00010517          	auipc	a0,0x10
    8000075c:	43050513          	addi	a0,a0,1072 # 80010b88 <pr>
    80000760:	00000097          	auipc	ra,0x0
    80000764:	52a080e7          	jalr	1322(ra) # 80000c8a <release>
}
    80000768:	bfc9                	j	8000073a <printf+0x1b0>

000000008000076a <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076a:	1101                	addi	sp,sp,-32
    8000076c:	ec06                	sd	ra,24(sp)
    8000076e:	e822                	sd	s0,16(sp)
    80000770:	e426                	sd	s1,8(sp)
    80000772:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000774:	00010497          	auipc	s1,0x10
    80000778:	41448493          	addi	s1,s1,1044 # 80010b88 <pr>
    8000077c:	00008597          	auipc	a1,0x8
    80000780:	8bc58593          	addi	a1,a1,-1860 # 80008038 <etext+0x38>
    80000784:	8526                	mv	a0,s1
    80000786:	00000097          	auipc	ra,0x0
    8000078a:	3c0080e7          	jalr	960(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078e:	4785                	li	a5,1
    80000790:	cc9c                	sw	a5,24(s1)
}
    80000792:	60e2                	ld	ra,24(sp)
    80000794:	6442                	ld	s0,16(sp)
    80000796:	64a2                	ld	s1,8(sp)
    80000798:	6105                	addi	sp,sp,32
    8000079a:	8082                	ret

000000008000079c <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079c:	1141                	addi	sp,sp,-16
    8000079e:	e406                	sd	ra,8(sp)
    800007a0:	e022                	sd	s0,0(sp)
    800007a2:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a4:	100007b7          	lui	a5,0x10000
    800007a8:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ac:	f8000713          	li	a4,-128
    800007b0:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b4:	470d                	li	a4,3
    800007b6:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007ba:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007be:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c2:	469d                	li	a3,7
    800007c4:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c8:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007cc:	00008597          	auipc	a1,0x8
    800007d0:	88c58593          	addi	a1,a1,-1908 # 80008058 <digits+0x18>
    800007d4:	00010517          	auipc	a0,0x10
    800007d8:	3d450513          	addi	a0,a0,980 # 80010ba8 <uart_tx_lock>
    800007dc:	00000097          	auipc	ra,0x0
    800007e0:	36a080e7          	jalr	874(ra) # 80000b46 <initlock>
}
    800007e4:	60a2                	ld	ra,8(sp)
    800007e6:	6402                	ld	s0,0(sp)
    800007e8:	0141                	addi	sp,sp,16
    800007ea:	8082                	ret

00000000800007ec <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ec:	1101                	addi	sp,sp,-32
    800007ee:	ec06                	sd	ra,24(sp)
    800007f0:	e822                	sd	s0,16(sp)
    800007f2:	e426                	sd	s1,8(sp)
    800007f4:	1000                	addi	s0,sp,32
    800007f6:	84aa                	mv	s1,a0
  push_off();
    800007f8:	00000097          	auipc	ra,0x0
    800007fc:	392080e7          	jalr	914(ra) # 80000b8a <push_off>

  if(panicked){
    80000800:	00008797          	auipc	a5,0x8
    80000804:	1607a783          	lw	a5,352(a5) # 80008960 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000808:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080c:	c391                	beqz	a5,80000810 <uartputc_sync+0x24>
    for(;;)
    8000080e:	a001                	j	8000080e <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000810:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000814:	0207f793          	andi	a5,a5,32
    80000818:	dfe5                	beqz	a5,80000810 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000081a:	0ff4f513          	zext.b	a0,s1
    8000081e:	100007b7          	lui	a5,0x10000
    80000822:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000826:	00000097          	auipc	ra,0x0
    8000082a:	404080e7          	jalr	1028(ra) # 80000c2a <pop_off>
}
    8000082e:	60e2                	ld	ra,24(sp)
    80000830:	6442                	ld	s0,16(sp)
    80000832:	64a2                	ld	s1,8(sp)
    80000834:	6105                	addi	sp,sp,32
    80000836:	8082                	ret

0000000080000838 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000838:	00008797          	auipc	a5,0x8
    8000083c:	1307b783          	ld	a5,304(a5) # 80008968 <uart_tx_r>
    80000840:	00008717          	auipc	a4,0x8
    80000844:	13073703          	ld	a4,304(a4) # 80008970 <uart_tx_w>
    80000848:	06f70a63          	beq	a4,a5,800008bc <uartstart+0x84>
{
    8000084c:	7139                	addi	sp,sp,-64
    8000084e:	fc06                	sd	ra,56(sp)
    80000850:	f822                	sd	s0,48(sp)
    80000852:	f426                	sd	s1,40(sp)
    80000854:	f04a                	sd	s2,32(sp)
    80000856:	ec4e                	sd	s3,24(sp)
    80000858:	e852                	sd	s4,16(sp)
    8000085a:	e456                	sd	s5,8(sp)
    8000085c:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085e:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000862:	00010a17          	auipc	s4,0x10
    80000866:	346a0a13          	addi	s4,s4,838 # 80010ba8 <uart_tx_lock>
    uart_tx_r += 1;
    8000086a:	00008497          	auipc	s1,0x8
    8000086e:	0fe48493          	addi	s1,s1,254 # 80008968 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000872:	00008997          	auipc	s3,0x8
    80000876:	0fe98993          	addi	s3,s3,254 # 80008970 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000087a:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087e:	02077713          	andi	a4,a4,32
    80000882:	c705                	beqz	a4,800008aa <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000884:	01f7f713          	andi	a4,a5,31
    80000888:	9752                	add	a4,a4,s4
    8000088a:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088e:	0785                	addi	a5,a5,1
    80000890:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000892:	8526                	mv	a0,s1
    80000894:	00002097          	auipc	ra,0x2
    80000898:	afc080e7          	jalr	-1284(ra) # 80002390 <wakeup>
    
    WriteReg(THR, c);
    8000089c:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008a0:	609c                	ld	a5,0(s1)
    800008a2:	0009b703          	ld	a4,0(s3)
    800008a6:	fcf71ae3          	bne	a4,a5,8000087a <uartstart+0x42>
  }
}
    800008aa:	70e2                	ld	ra,56(sp)
    800008ac:	7442                	ld	s0,48(sp)
    800008ae:	74a2                	ld	s1,40(sp)
    800008b0:	7902                	ld	s2,32(sp)
    800008b2:	69e2                	ld	s3,24(sp)
    800008b4:	6a42                	ld	s4,16(sp)
    800008b6:	6aa2                	ld	s5,8(sp)
    800008b8:	6121                	addi	sp,sp,64
    800008ba:	8082                	ret
    800008bc:	8082                	ret

00000000800008be <uartputc>:
{
    800008be:	7179                	addi	sp,sp,-48
    800008c0:	f406                	sd	ra,40(sp)
    800008c2:	f022                	sd	s0,32(sp)
    800008c4:	ec26                	sd	s1,24(sp)
    800008c6:	e84a                	sd	s2,16(sp)
    800008c8:	e44e                	sd	s3,8(sp)
    800008ca:	e052                	sd	s4,0(sp)
    800008cc:	1800                	addi	s0,sp,48
    800008ce:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008d0:	00010517          	auipc	a0,0x10
    800008d4:	2d850513          	addi	a0,a0,728 # 80010ba8 <uart_tx_lock>
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	2fe080e7          	jalr	766(ra) # 80000bd6 <acquire>
  if(panicked){
    800008e0:	00008797          	auipc	a5,0x8
    800008e4:	0807a783          	lw	a5,128(a5) # 80008960 <panicked>
    800008e8:	e7c9                	bnez	a5,80000972 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008ea:	00008717          	auipc	a4,0x8
    800008ee:	08673703          	ld	a4,134(a4) # 80008970 <uart_tx_w>
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	0767b783          	ld	a5,118(a5) # 80008968 <uart_tx_r>
    800008fa:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00010997          	auipc	s3,0x10
    80000902:	2aa98993          	addi	s3,s3,682 # 80010ba8 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	06248493          	addi	s1,s1,98 # 80008968 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	06290913          	addi	s2,s2,98 # 80008970 <uart_tx_w>
    80000916:	00e79f63          	bne	a5,a4,80000934 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000091a:	85ce                	mv	a1,s3
    8000091c:	8526                	mv	a0,s1
    8000091e:	00002097          	auipc	ra,0x2
    80000922:	9fe080e7          	jalr	-1538(ra) # 8000231c <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000926:	00093703          	ld	a4,0(s2)
    8000092a:	609c                	ld	a5,0(s1)
    8000092c:	02078793          	addi	a5,a5,32
    80000930:	fee785e3          	beq	a5,a4,8000091a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000934:	00010497          	auipc	s1,0x10
    80000938:	27448493          	addi	s1,s1,628 # 80010ba8 <uart_tx_lock>
    8000093c:	01f77793          	andi	a5,a4,31
    80000940:	97a6                	add	a5,a5,s1
    80000942:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000946:	0705                	addi	a4,a4,1
    80000948:	00008797          	auipc	a5,0x8
    8000094c:	02e7b423          	sd	a4,40(a5) # 80008970 <uart_tx_w>
  uartstart();
    80000950:	00000097          	auipc	ra,0x0
    80000954:	ee8080e7          	jalr	-280(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    80000958:	8526                	mv	a0,s1
    8000095a:	00000097          	auipc	ra,0x0
    8000095e:	330080e7          	jalr	816(ra) # 80000c8a <release>
}
    80000962:	70a2                	ld	ra,40(sp)
    80000964:	7402                	ld	s0,32(sp)
    80000966:	64e2                	ld	s1,24(sp)
    80000968:	6942                	ld	s2,16(sp)
    8000096a:	69a2                	ld	s3,8(sp)
    8000096c:	6a02                	ld	s4,0(sp)
    8000096e:	6145                	addi	sp,sp,48
    80000970:	8082                	ret
    for(;;)
    80000972:	a001                	j	80000972 <uartputc+0xb4>

0000000080000974 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000974:	1141                	addi	sp,sp,-16
    80000976:	e422                	sd	s0,8(sp)
    80000978:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000097a:	100007b7          	lui	a5,0x10000
    8000097e:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000982:	8b85                	andi	a5,a5,1
    80000984:	cb81                	beqz	a5,80000994 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000986:	100007b7          	lui	a5,0x10000
    8000098a:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098e:	6422                	ld	s0,8(sp)
    80000990:	0141                	addi	sp,sp,16
    80000992:	8082                	ret
    return -1;
    80000994:	557d                	li	a0,-1
    80000996:	bfe5                	j	8000098e <uartgetc+0x1a>

0000000080000998 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000998:	1101                	addi	sp,sp,-32
    8000099a:	ec06                	sd	ra,24(sp)
    8000099c:	e822                	sd	s0,16(sp)
    8000099e:	e426                	sd	s1,8(sp)
    800009a0:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a2:	54fd                	li	s1,-1
    800009a4:	a029                	j	800009ae <uartintr+0x16>
      break;
    consoleintr(c);
    800009a6:	00000097          	auipc	ra,0x0
    800009aa:	918080e7          	jalr	-1768(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009ae:	00000097          	auipc	ra,0x0
    800009b2:	fc6080e7          	jalr	-58(ra) # 80000974 <uartgetc>
    if(c == -1)
    800009b6:	fe9518e3          	bne	a0,s1,800009a6 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009ba:	00010497          	auipc	s1,0x10
    800009be:	1ee48493          	addi	s1,s1,494 # 80010ba8 <uart_tx_lock>
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	212080e7          	jalr	530(ra) # 80000bd6 <acquire>
  uartstart();
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	e6c080e7          	jalr	-404(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    800009d4:	8526                	mv	a0,s1
    800009d6:	00000097          	auipc	ra,0x0
    800009da:	2b4080e7          	jalr	692(ra) # 80000c8a <release>
}
    800009de:	60e2                	ld	ra,24(sp)
    800009e0:	6442                	ld	s0,16(sp)
    800009e2:	64a2                	ld	s1,8(sp)
    800009e4:	6105                	addi	sp,sp,32
    800009e6:	8082                	ret

00000000800009e8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e8:	1101                	addi	sp,sp,-32
    800009ea:	ec06                	sd	ra,24(sp)
    800009ec:	e822                	sd	s0,16(sp)
    800009ee:	e426                	sd	s1,8(sp)
    800009f0:	e04a                	sd	s2,0(sp)
    800009f2:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f4:	03451793          	slli	a5,a0,0x34
    800009f8:	ebb9                	bnez	a5,80000a4e <kfree+0x66>
    800009fa:	84aa                	mv	s1,a0
    800009fc:	00025797          	auipc	a5,0x25
    80000a00:	02478793          	addi	a5,a5,36 # 80025a20 <end>
    80000a04:	04f56563          	bltu	a0,a5,80000a4e <kfree+0x66>
    80000a08:	47c5                	li	a5,17
    80000a0a:	07ee                	slli	a5,a5,0x1b
    80000a0c:	04f57163          	bgeu	a0,a5,80000a4e <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a10:	6605                	lui	a2,0x1
    80000a12:	4585                	li	a1,1
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	2be080e7          	jalr	702(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1c:	00010917          	auipc	s2,0x10
    80000a20:	1c490913          	addi	s2,s2,452 # 80010be0 <kmem>
    80000a24:	854a                	mv	a0,s2
    80000a26:	00000097          	auipc	ra,0x0
    80000a2a:	1b0080e7          	jalr	432(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a2e:	01893783          	ld	a5,24(s2)
    80000a32:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a34:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a38:	854a                	mv	a0,s2
    80000a3a:	00000097          	auipc	ra,0x0
    80000a3e:	250080e7          	jalr	592(ra) # 80000c8a <release>
}
    80000a42:	60e2                	ld	ra,24(sp)
    80000a44:	6442                	ld	s0,16(sp)
    80000a46:	64a2                	ld	s1,8(sp)
    80000a48:	6902                	ld	s2,0(sp)
    80000a4a:	6105                	addi	sp,sp,32
    80000a4c:	8082                	ret
    panic("kfree");
    80000a4e:	00007517          	auipc	a0,0x7
    80000a52:	61250513          	addi	a0,a0,1554 # 80008060 <digits+0x20>
    80000a56:	00000097          	auipc	ra,0x0
    80000a5a:	aea080e7          	jalr	-1302(ra) # 80000540 <panic>

0000000080000a5e <freerange>:
{
    80000a5e:	7179                	addi	sp,sp,-48
    80000a60:	f406                	sd	ra,40(sp)
    80000a62:	f022                	sd	s0,32(sp)
    80000a64:	ec26                	sd	s1,24(sp)
    80000a66:	e84a                	sd	s2,16(sp)
    80000a68:	e44e                	sd	s3,8(sp)
    80000a6a:	e052                	sd	s4,0(sp)
    80000a6c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6e:	6785                	lui	a5,0x1
    80000a70:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a74:	00e504b3          	add	s1,a0,a4
    80000a78:	777d                	lui	a4,0xfffff
    80000a7a:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3c>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5c080e7          	jalr	-164(ra) # 800009e8 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x2a>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	12650513          	addi	a0,a0,294 # 80010be0 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00025517          	auipc	a0,0x25
    80000ad2:	f5250513          	addi	a0,a0,-174 # 80025a20 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f88080e7          	jalr	-120(ra) # 80000a5e <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	0f048493          	addi	s1,s1,240 # 80010be0 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	0d850513          	addi	a0,a0,216 # 80010be0 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	0ac50513          	addi	a0,a0,172 # 80010be0 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	fba080e7          	jalr	-70(ra) # 80001b2a <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	f88080e7          	jalr	-120(ra) # 80001b2a <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	f7c080e7          	jalr	-132(ra) # 80001b2a <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	f64080e7          	jalr	-156(ra) # 80001b2a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	f24080e7          	jalr	-220(ra) # 80001b2a <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91e080e7          	jalr	-1762(ra) # 80000540 <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	ef8080e7          	jalr	-264(ra) # 80001b2a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8ce080e7          	jalr	-1842(ra) # 80000540 <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8be080e7          	jalr	-1858(ra) # 80000540 <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	876080e7          	jalr	-1930(ra) # 80000540 <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd95e1>
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	40d707bb          	subw	a5,a4,a3
    80000e0c:	37fd                	addiw	a5,a5,-1
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	c9a080e7          	jalr	-870(ra) # 80001b1a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	af070713          	addi	a4,a4,-1296 # 80008978 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	c7e080e7          	jalr	-898(ra) # 80001b1a <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6dc080e7          	jalr	1756(ra) # 8000058a <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0d8080e7          	jalr	216(ra) # 80000f8e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00002097          	auipc	ra,0x2
    80000ec2:	cd4080e7          	jalr	-812(ra) # 80002b92 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	75a080e7          	jalr	1882(ra) # 80006620 <plicinithart>
  }
  
  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	208080e7          	jalr	520(ra) # 800020d6 <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88c080e7          	jalr	-1908(ra) # 8000076a <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	3d250513          	addi	a0,a0,978 # 800082b8 <digits+0x278>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69c080e7          	jalr	1692(ra) # 8000058a <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68c080e7          	jalr	1676(ra) # 8000058a <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	3b250513          	addi	a0,a0,946 # 800082b8 <digits+0x278>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67c080e7          	jalr	1660(ra) # 8000058a <printf>
    kinit();         // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	326080e7          	jalr	806(ra) # 80001244 <kvminit>
    kvminithart();   // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	068080e7          	jalr	104(ra) # 80000f8e <kvminithart>
    procinit();      // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	b38080e7          	jalr	-1224(ra) # 80001a66 <procinit>
    trapinit();      // trap vectors
    80000f36:	00002097          	auipc	ra,0x2
    80000f3a:	c34080e7          	jalr	-972(ra) # 80002b6a <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	c54080e7          	jalr	-940(ra) # 80002b92 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	6c4080e7          	jalr	1732(ra) # 8000660a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	6d2080e7          	jalr	1746(ra) # 80006620 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	79a080e7          	jalr	1946(ra) # 800036f0 <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	e3a080e7          	jalr	-454(ra) # 80003d98 <iinit>
    fileinit();      // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	de4080e7          	jalr	-540(ra) # 80004d4a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	7ba080e7          	jalr	1978(ra) # 80006728 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	f12080e7          	jalr	-238(ra) # 80001e88 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	9ef72a23          	sw	a5,-1548(a4) # 80008978 <started>
    80000f8c:	b789                	j	80000ece <main+0x56>

0000000080000f8e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f94:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f98:	00008797          	auipc	a5,0x8
    80000f9c:	9e87b783          	ld	a5,-1560(a5) # 80008980 <kernel_pagetable>
    80000fa0:	83b1                	srli	a5,a5,0xc
    80000fa2:	577d                	li	a4,-1
    80000fa4:	177e                	slli	a4,a4,0x3f
    80000fa6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fac:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb0:	6422                	ld	s0,8(sp)
    80000fb2:	0141                	addi	sp,sp,16
    80000fb4:	8082                	ret

0000000080000fb6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb6:	7139                	addi	sp,sp,-64
    80000fb8:	fc06                	sd	ra,56(sp)
    80000fba:	f822                	sd	s0,48(sp)
    80000fbc:	f426                	sd	s1,40(sp)
    80000fbe:	f04a                	sd	s2,32(sp)
    80000fc0:	ec4e                	sd	s3,24(sp)
    80000fc2:	e852                	sd	s4,16(sp)
    80000fc4:	e456                	sd	s5,8(sp)
    80000fc6:	e05a                	sd	s6,0(sp)
    80000fc8:	0080                	addi	s0,sp,64
    80000fca:	84aa                	mv	s1,a0
    80000fcc:	89ae                	mv	s3,a1
    80000fce:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd0:	57fd                	li	a5,-1
    80000fd2:	83e9                	srli	a5,a5,0x1a
    80000fd4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd8:	04b7f263          	bgeu	a5,a1,8000101c <walk+0x66>
    panic("walk");
    80000fdc:	00007517          	auipc	a0,0x7
    80000fe0:	0f450513          	addi	a0,a0,244 # 800080d0 <digits+0x90>
    80000fe4:	fffff097          	auipc	ra,0xfffff
    80000fe8:	55c080e7          	jalr	1372(ra) # 80000540 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fec:	060a8663          	beqz	s5,80001058 <walk+0xa2>
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	af6080e7          	jalr	-1290(ra) # 80000ae6 <kalloc>
    80000ff8:	84aa                	mv	s1,a0
    80000ffa:	c529                	beqz	a0,80001044 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	4581                	li	a1,0
    80001000:	00000097          	auipc	ra,0x0
    80001004:	cd2080e7          	jalr	-814(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001008:	00c4d793          	srli	a5,s1,0xc
    8000100c:	07aa                	slli	a5,a5,0xa
    8000100e:	0017e793          	ori	a5,a5,1
    80001012:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001016:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd95d7>
    80001018:	036a0063          	beq	s4,s6,80001038 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101c:	0149d933          	srl	s2,s3,s4
    80001020:	1ff97913          	andi	s2,s2,511
    80001024:	090e                	slli	s2,s2,0x3
    80001026:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001028:	00093483          	ld	s1,0(s2)
    8000102c:	0014f793          	andi	a5,s1,1
    80001030:	dfd5                	beqz	a5,80000fec <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001032:	80a9                	srli	s1,s1,0xa
    80001034:	04b2                	slli	s1,s1,0xc
    80001036:	b7c5                	j	80001016 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001038:	00c9d513          	srli	a0,s3,0xc
    8000103c:	1ff57513          	andi	a0,a0,511
    80001040:	050e                	slli	a0,a0,0x3
    80001042:	9526                	add	a0,a0,s1
}
    80001044:	70e2                	ld	ra,56(sp)
    80001046:	7442                	ld	s0,48(sp)
    80001048:	74a2                	ld	s1,40(sp)
    8000104a:	7902                	ld	s2,32(sp)
    8000104c:	69e2                	ld	s3,24(sp)
    8000104e:	6a42                	ld	s4,16(sp)
    80001050:	6aa2                	ld	s5,8(sp)
    80001052:	6b02                	ld	s6,0(sp)
    80001054:	6121                	addi	sp,sp,64
    80001056:	8082                	ret
        return 0;
    80001058:	4501                	li	a0,0
    8000105a:	b7ed                	j	80001044 <walk+0x8e>

000000008000105c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105c:	57fd                	li	a5,-1
    8000105e:	83e9                	srli	a5,a5,0x1a
    80001060:	00b7f463          	bgeu	a5,a1,80001068 <walkaddr+0xc>
    return 0;
    80001064:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001066:	8082                	ret
{
    80001068:	1141                	addi	sp,sp,-16
    8000106a:	e406                	sd	ra,8(sp)
    8000106c:	e022                	sd	s0,0(sp)
    8000106e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001070:	4601                	li	a2,0
    80001072:	00000097          	auipc	ra,0x0
    80001076:	f44080e7          	jalr	-188(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000107a:	c105                	beqz	a0,8000109a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107e:	0117f693          	andi	a3,a5,17
    80001082:	4745                	li	a4,17
    return 0;
    80001084:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001086:	00e68663          	beq	a3,a4,80001092 <walkaddr+0x36>
}
    8000108a:	60a2                	ld	ra,8(sp)
    8000108c:	6402                	ld	s0,0(sp)
    8000108e:	0141                	addi	sp,sp,16
    80001090:	8082                	ret
  pa = PTE2PA(*pte);
    80001092:	83a9                	srli	a5,a5,0xa
    80001094:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001098:	bfcd                	j	8000108a <walkaddr+0x2e>
    return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7fd                	j	8000108a <walkaddr+0x2e>

000000008000109e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109e:	715d                	addi	sp,sp,-80
    800010a0:	e486                	sd	ra,72(sp)
    800010a2:	e0a2                	sd	s0,64(sp)
    800010a4:	fc26                	sd	s1,56(sp)
    800010a6:	f84a                	sd	s2,48(sp)
    800010a8:	f44e                	sd	s3,40(sp)
    800010aa:	f052                	sd	s4,32(sp)
    800010ac:	ec56                	sd	s5,24(sp)
    800010ae:	e85a                	sd	s6,16(sp)
    800010b0:	e45e                	sd	s7,8(sp)
    800010b2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b4:	c639                	beqz	a2,80001102 <mappages+0x64>
    800010b6:	8aaa                	mv	s5,a0
    800010b8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010ba:	777d                	lui	a4,0xfffff
    800010bc:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010c0:	fff58993          	addi	s3,a1,-1
    800010c4:	99b2                	add	s3,s3,a2
    800010c6:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010ca:	893e                	mv	s2,a5
    800010cc:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d0:	6b85                	lui	s7,0x1
    800010d2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d6:	4605                	li	a2,1
    800010d8:	85ca                	mv	a1,s2
    800010da:	8556                	mv	a0,s5
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	eda080e7          	jalr	-294(ra) # 80000fb6 <walk>
    800010e4:	cd1d                	beqz	a0,80001122 <mappages+0x84>
    if(*pte & PTE_V)
    800010e6:	611c                	ld	a5,0(a0)
    800010e8:	8b85                	andi	a5,a5,1
    800010ea:	e785                	bnez	a5,80001112 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ec:	80b1                	srli	s1,s1,0xc
    800010ee:	04aa                	slli	s1,s1,0xa
    800010f0:	0164e4b3          	or	s1,s1,s6
    800010f4:	0014e493          	ori	s1,s1,1
    800010f8:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fa:	05390063          	beq	s2,s3,8000113a <mappages+0x9c>
    a += PGSIZE;
    800010fe:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001100:	bfc9                	j	800010d2 <mappages+0x34>
    panic("mappages: size");
    80001102:	00007517          	auipc	a0,0x7
    80001106:	fd650513          	addi	a0,a0,-42 # 800080d8 <digits+0x98>
    8000110a:	fffff097          	auipc	ra,0xfffff
    8000110e:	436080e7          	jalr	1078(ra) # 80000540 <panic>
      panic("mappages: remap");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fd650513          	addi	a0,a0,-42 # 800080e8 <digits+0xa8>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	426080e7          	jalr	1062(ra) # 80000540 <panic>
      return -1;
    80001122:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001124:	60a6                	ld	ra,72(sp)
    80001126:	6406                	ld	s0,64(sp)
    80001128:	74e2                	ld	s1,56(sp)
    8000112a:	7942                	ld	s2,48(sp)
    8000112c:	79a2                	ld	s3,40(sp)
    8000112e:	7a02                	ld	s4,32(sp)
    80001130:	6ae2                	ld	s5,24(sp)
    80001132:	6b42                	ld	s6,16(sp)
    80001134:	6ba2                	ld	s7,8(sp)
    80001136:	6161                	addi	sp,sp,80
    80001138:	8082                	ret
  return 0;
    8000113a:	4501                	li	a0,0
    8000113c:	b7e5                	j	80001124 <mappages+0x86>

000000008000113e <kvmmap>:
{
    8000113e:	1141                	addi	sp,sp,-16
    80001140:	e406                	sd	ra,8(sp)
    80001142:	e022                	sd	s0,0(sp)
    80001144:	0800                	addi	s0,sp,16
    80001146:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001148:	86b2                	mv	a3,a2
    8000114a:	863e                	mv	a2,a5
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	f52080e7          	jalr	-174(ra) # 8000109e <mappages>
    80001154:	e509                	bnez	a0,8000115e <kvmmap+0x20>
}
    80001156:	60a2                	ld	ra,8(sp)
    80001158:	6402                	ld	s0,0(sp)
    8000115a:	0141                	addi	sp,sp,16
    8000115c:	8082                	ret
    panic("kvmmap");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f9a50513          	addi	a0,a0,-102 # 800080f8 <digits+0xb8>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	3da080e7          	jalr	986(ra) # 80000540 <panic>

000000008000116e <kvmmake>:
{
    8000116e:	1101                	addi	sp,sp,-32
    80001170:	ec06                	sd	ra,24(sp)
    80001172:	e822                	sd	s0,16(sp)
    80001174:	e426                	sd	s1,8(sp)
    80001176:	e04a                	sd	s2,0(sp)
    80001178:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	96c080e7          	jalr	-1684(ra) # 80000ae6 <kalloc>
    80001182:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001184:	6605                	lui	a2,0x1
    80001186:	4581                	li	a1,0
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	b4a080e7          	jalr	-1206(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001190:	4719                	li	a4,6
    80001192:	6685                	lui	a3,0x1
    80001194:	10000637          	lui	a2,0x10000
    80001198:	100005b7          	lui	a1,0x10000
    8000119c:	8526                	mv	a0,s1
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	fa0080e7          	jalr	-96(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a6:	4719                	li	a4,6
    800011a8:	6685                	lui	a3,0x1
    800011aa:	10001637          	lui	a2,0x10001
    800011ae:	100015b7          	lui	a1,0x10001
    800011b2:	8526                	mv	a0,s1
    800011b4:	00000097          	auipc	ra,0x0
    800011b8:	f8a080e7          	jalr	-118(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011bc:	4719                	li	a4,6
    800011be:	004006b7          	lui	a3,0x400
    800011c2:	0c000637          	lui	a2,0xc000
    800011c6:	0c0005b7          	lui	a1,0xc000
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f72080e7          	jalr	-142(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d4:	00007917          	auipc	s2,0x7
    800011d8:	e2c90913          	addi	s2,s2,-468 # 80008000 <etext>
    800011dc:	4729                	li	a4,10
    800011de:	80007697          	auipc	a3,0x80007
    800011e2:	e2268693          	addi	a3,a3,-478 # 8000 <_entry-0x7fff8000>
    800011e6:	4605                	li	a2,1
    800011e8:	067e                	slli	a2,a2,0x1f
    800011ea:	85b2                	mv	a1,a2
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	f50080e7          	jalr	-176(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	46c5                	li	a3,17
    800011fa:	06ee                	slli	a3,a3,0x1b
    800011fc:	412686b3          	sub	a3,a3,s2
    80001200:	864a                	mv	a2,s2
    80001202:	85ca                	mv	a1,s2
    80001204:	8526                	mv	a0,s1
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f38080e7          	jalr	-200(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120e:	4729                	li	a4,10
    80001210:	6685                	lui	a3,0x1
    80001212:	00006617          	auipc	a2,0x6
    80001216:	dee60613          	addi	a2,a2,-530 # 80007000 <_trampoline>
    8000121a:	040005b7          	lui	a1,0x4000
    8000121e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001220:	05b2                	slli	a1,a1,0xc
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f1a080e7          	jalr	-230(ra) # 8000113e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	7a2080e7          	jalr	1954(ra) # 800019d0 <proc_mapstacks>
}
    80001236:	8526                	mv	a0,s1
    80001238:	60e2                	ld	ra,24(sp)
    8000123a:	6442                	ld	s0,16(sp)
    8000123c:	64a2                	ld	s1,8(sp)
    8000123e:	6902                	ld	s2,0(sp)
    80001240:	6105                	addi	sp,sp,32
    80001242:	8082                	ret

0000000080001244 <kvminit>:
{
    80001244:	1141                	addi	sp,sp,-16
    80001246:	e406                	sd	ra,8(sp)
    80001248:	e022                	sd	s0,0(sp)
    8000124a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f22080e7          	jalr	-222(ra) # 8000116e <kvmmake>
    80001254:	00007797          	auipc	a5,0x7
    80001258:	72a7b623          	sd	a0,1836(a5) # 80008980 <kernel_pagetable>
}
    8000125c:	60a2                	ld	ra,8(sp)
    8000125e:	6402                	ld	s0,0(sp)
    80001260:	0141                	addi	sp,sp,16
    80001262:	8082                	ret

0000000080001264 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001264:	715d                	addi	sp,sp,-80
    80001266:	e486                	sd	ra,72(sp)
    80001268:	e0a2                	sd	s0,64(sp)
    8000126a:	fc26                	sd	s1,56(sp)
    8000126c:	f84a                	sd	s2,48(sp)
    8000126e:	f44e                	sd	s3,40(sp)
    80001270:	f052                	sd	s4,32(sp)
    80001272:	ec56                	sd	s5,24(sp)
    80001274:	e85a                	sd	s6,16(sp)
    80001276:	e45e                	sd	s7,8(sp)
    80001278:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127a:	03459793          	slli	a5,a1,0x34
    8000127e:	e795                	bnez	a5,800012aa <uvmunmap+0x46>
    80001280:	8a2a                	mv	s4,a0
    80001282:	892e                	mv	s2,a1
    80001284:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001286:	0632                	slli	a2,a2,0xc
    80001288:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	6b05                	lui	s6,0x1
    80001290:	0735e263          	bltu	a1,s3,800012f4 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	74e2                	ld	s1,56(sp)
    8000129a:	7942                	ld	s2,48(sp)
    8000129c:	79a2                	ld	s3,40(sp)
    8000129e:	7a02                	ld	s4,32(sp)
    800012a0:	6ae2                	ld	s5,24(sp)
    800012a2:	6b42                	ld	s6,16(sp)
    800012a4:	6ba2                	ld	s7,8(sp)
    800012a6:	6161                	addi	sp,sp,80
    800012a8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012aa:	00007517          	auipc	a0,0x7
    800012ae:	e5650513          	addi	a0,a0,-426 # 80008100 <digits+0xc0>
    800012b2:	fffff097          	auipc	ra,0xfffff
    800012b6:	28e080e7          	jalr	654(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e5e50513          	addi	a0,a0,-418 # 80008118 <digits+0xd8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27e080e7          	jalr	638(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e5e50513          	addi	a0,a0,-418 # 80008128 <digits+0xe8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26e080e7          	jalr	622(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25e080e7          	jalr	606(ra) # 80000540 <panic>
    *pte = 0;
    800012ea:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ee:	995a                	add	s2,s2,s6
    800012f0:	fb3972e3          	bgeu	s2,s3,80001294 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f4:	4601                	li	a2,0
    800012f6:	85ca                	mv	a1,s2
    800012f8:	8552                	mv	a0,s4
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	cbc080e7          	jalr	-836(ra) # 80000fb6 <walk>
    80001302:	84aa                	mv	s1,a0
    80001304:	d95d                	beqz	a0,800012ba <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001306:	6108                	ld	a0,0(a0)
    80001308:	00157793          	andi	a5,a0,1
    8000130c:	dfdd                	beqz	a5,800012ca <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130e:	3ff57793          	andi	a5,a0,1023
    80001312:	fd7784e3          	beq	a5,s7,800012da <uvmunmap+0x76>
    if(do_free){
    80001316:	fc0a8ae3          	beqz	s5,800012ea <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000131c:	0532                	slli	a0,a0,0xc
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	6ca080e7          	jalr	1738(ra) # 800009e8 <kfree>
    80001326:	b7d1                	j	800012ea <uvmunmap+0x86>

0000000080001328 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001328:	1101                	addi	sp,sp,-32
    8000132a:	ec06                	sd	ra,24(sp)
    8000132c:	e822                	sd	s0,16(sp)
    8000132e:	e426                	sd	s1,8(sp)
    80001330:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	7b4080e7          	jalr	1972(ra) # 80000ae6 <kalloc>
    8000133a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133c:	c519                	beqz	a0,8000134a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000133e:	6605                	lui	a2,0x1
    80001340:	4581                	li	a1,0
    80001342:	00000097          	auipc	ra,0x0
    80001346:	990080e7          	jalr	-1648(ra) # 80000cd2 <memset>
  return pagetable;
}
    8000134a:	8526                	mv	a0,s1
    8000134c:	60e2                	ld	ra,24(sp)
    8000134e:	6442                	ld	s0,16(sp)
    80001350:	64a2                	ld	s1,8(sp)
    80001352:	6105                	addi	sp,sp,32
    80001354:	8082                	ret

0000000080001356 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001356:	7179                	addi	sp,sp,-48
    80001358:	f406                	sd	ra,40(sp)
    8000135a:	f022                	sd	s0,32(sp)
    8000135c:	ec26                	sd	s1,24(sp)
    8000135e:	e84a                	sd	s2,16(sp)
    80001360:	e44e                	sd	s3,8(sp)
    80001362:	e052                	sd	s4,0(sp)
    80001364:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001366:	6785                	lui	a5,0x1
    80001368:	04f67863          	bgeu	a2,a5,800013b8 <uvmfirst+0x62>
    8000136c:	8a2a                	mv	s4,a0
    8000136e:	89ae                	mv	s3,a1
    80001370:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	774080e7          	jalr	1908(ra) # 80000ae6 <kalloc>
    8000137a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137c:	6605                	lui	a2,0x1
    8000137e:	4581                	li	a1,0
    80001380:	00000097          	auipc	ra,0x0
    80001384:	952080e7          	jalr	-1710(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001388:	4779                	li	a4,30
    8000138a:	86ca                	mv	a3,s2
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	8552                	mv	a0,s4
    80001392:	00000097          	auipc	ra,0x0
    80001396:	d0c080e7          	jalr	-756(ra) # 8000109e <mappages>
  memmove(mem, src, sz);
    8000139a:	8626                	mv	a2,s1
    8000139c:	85ce                	mv	a1,s3
    8000139e:	854a                	mv	a0,s2
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	98e080e7          	jalr	-1650(ra) # 80000d2e <memmove>
}
    800013a8:	70a2                	ld	ra,40(sp)
    800013aa:	7402                	ld	s0,32(sp)
    800013ac:	64e2                	ld	s1,24(sp)
    800013ae:	6942                	ld	s2,16(sp)
    800013b0:	69a2                	ld	s3,8(sp)
    800013b2:	6a02                	ld	s4,0(sp)
    800013b4:	6145                	addi	sp,sp,48
    800013b6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b8:	00007517          	auipc	a0,0x7
    800013bc:	da050513          	addi	a0,a0,-608 # 80008158 <digits+0x118>
    800013c0:	fffff097          	auipc	ra,0xfffff
    800013c4:	180080e7          	jalr	384(ra) # 80000540 <panic>

00000000800013c8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c8:	1101                	addi	sp,sp,-32
    800013ca:	ec06                	sd	ra,24(sp)
    800013cc:	e822                	sd	s0,16(sp)
    800013ce:	e426                	sd	s1,8(sp)
    800013d0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d4:	00b67d63          	bgeu	a2,a1,800013ee <uvmdealloc+0x26>
    800013d8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013da:	6785                	lui	a5,0x1
    800013dc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013de:	00f60733          	add	a4,a2,a5
    800013e2:	76fd                	lui	a3,0xfffff
    800013e4:	8f75                	and	a4,a4,a3
    800013e6:	97ae                	add	a5,a5,a1
    800013e8:	8ff5                	and	a5,a5,a3
    800013ea:	00f76863          	bltu	a4,a5,800013fa <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013ee:	8526                	mv	a0,s1
    800013f0:	60e2                	ld	ra,24(sp)
    800013f2:	6442                	ld	s0,16(sp)
    800013f4:	64a2                	ld	s1,8(sp)
    800013f6:	6105                	addi	sp,sp,32
    800013f8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fa:	8f99                	sub	a5,a5,a4
    800013fc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013fe:	4685                	li	a3,1
    80001400:	0007861b          	sext.w	a2,a5
    80001404:	85ba                	mv	a1,a4
    80001406:	00000097          	auipc	ra,0x0
    8000140a:	e5e080e7          	jalr	-418(ra) # 80001264 <uvmunmap>
    8000140e:	b7c5                	j	800013ee <uvmdealloc+0x26>

0000000080001410 <uvmalloc>:
  if(newsz < oldsz)
    80001410:	0ab66563          	bltu	a2,a1,800014ba <uvmalloc+0xaa>
{
    80001414:	7139                	addi	sp,sp,-64
    80001416:	fc06                	sd	ra,56(sp)
    80001418:	f822                	sd	s0,48(sp)
    8000141a:	f426                	sd	s1,40(sp)
    8000141c:	f04a                	sd	s2,32(sp)
    8000141e:	ec4e                	sd	s3,24(sp)
    80001420:	e852                	sd	s4,16(sp)
    80001422:	e456                	sd	s5,8(sp)
    80001424:	e05a                	sd	s6,0(sp)
    80001426:	0080                	addi	s0,sp,64
    80001428:	8aaa                	mv	s5,a0
    8000142a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142c:	6785                	lui	a5,0x1
    8000142e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001430:	95be                	add	a1,a1,a5
    80001432:	77fd                	lui	a5,0xfffff
    80001434:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001438:	08c9f363          	bgeu	s3,a2,800014be <uvmalloc+0xae>
    8000143c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000143e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	6a4080e7          	jalr	1700(ra) # 80000ae6 <kalloc>
    8000144a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000144c:	c51d                	beqz	a0,8000147a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000144e:	6605                	lui	a2,0x1
    80001450:	4581                	li	a1,0
    80001452:	00000097          	auipc	ra,0x0
    80001456:	880080e7          	jalr	-1920(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	875a                	mv	a4,s6
    8000145c:	86a6                	mv	a3,s1
    8000145e:	6605                	lui	a2,0x1
    80001460:	85ca                	mv	a1,s2
    80001462:	8556                	mv	a0,s5
    80001464:	00000097          	auipc	ra,0x0
    80001468:	c3a080e7          	jalr	-966(ra) # 8000109e <mappages>
    8000146c:	e90d                	bnez	a0,8000149e <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000146e:	6785                	lui	a5,0x1
    80001470:	993e                	add	s2,s2,a5
    80001472:	fd4968e3          	bltu	s2,s4,80001442 <uvmalloc+0x32>
  return newsz;
    80001476:	8552                	mv	a0,s4
    80001478:	a809                	j	8000148a <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000147a:	864e                	mv	a2,s3
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	f48080e7          	jalr	-184(ra) # 800013c8 <uvmdealloc>
      return 0;
    80001488:	4501                	li	a0,0
}
    8000148a:	70e2                	ld	ra,56(sp)
    8000148c:	7442                	ld	s0,48(sp)
    8000148e:	74a2                	ld	s1,40(sp)
    80001490:	7902                	ld	s2,32(sp)
    80001492:	69e2                	ld	s3,24(sp)
    80001494:	6a42                	ld	s4,16(sp)
    80001496:	6aa2                	ld	s5,8(sp)
    80001498:	6b02                	ld	s6,0(sp)
    8000149a:	6121                	addi	sp,sp,64
    8000149c:	8082                	ret
      kfree(mem);
    8000149e:	8526                	mv	a0,s1
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	548080e7          	jalr	1352(ra) # 800009e8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a8:	864e                	mv	a2,s3
    800014aa:	85ca                	mv	a1,s2
    800014ac:	8556                	mv	a0,s5
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f1a080e7          	jalr	-230(ra) # 800013c8 <uvmdealloc>
      return 0;
    800014b6:	4501                	li	a0,0
    800014b8:	bfc9                	j	8000148a <uvmalloc+0x7a>
    return oldsz;
    800014ba:	852e                	mv	a0,a1
}
    800014bc:	8082                	ret
  return newsz;
    800014be:	8532                	mv	a0,a2
    800014c0:	b7e9                	j	8000148a <uvmalloc+0x7a>

00000000800014c2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014c2:	7179                	addi	sp,sp,-48
    800014c4:	f406                	sd	ra,40(sp)
    800014c6:	f022                	sd	s0,32(sp)
    800014c8:	ec26                	sd	s1,24(sp)
    800014ca:	e84a                	sd	s2,16(sp)
    800014cc:	e44e                	sd	s3,8(sp)
    800014ce:	e052                	sd	s4,0(sp)
    800014d0:	1800                	addi	s0,sp,48
    800014d2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d4:	84aa                	mv	s1,a0
    800014d6:	6905                	lui	s2,0x1
    800014d8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014da:	4985                	li	s3,1
    800014dc:	a829                	j	800014f6 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014de:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014e0:	00c79513          	slli	a0,a5,0xc
    800014e4:	00000097          	auipc	ra,0x0
    800014e8:	fde080e7          	jalr	-34(ra) # 800014c2 <freewalk>
      pagetable[i] = 0;
    800014ec:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014f0:	04a1                	addi	s1,s1,8
    800014f2:	03248163          	beq	s1,s2,80001514 <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014f6:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f8:	00f7f713          	andi	a4,a5,15
    800014fc:	ff3701e3          	beq	a4,s3,800014de <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001500:	8b85                	andi	a5,a5,1
    80001502:	d7fd                	beqz	a5,800014f0 <freewalk+0x2e>
      panic("freewalk: leaf");
    80001504:	00007517          	auipc	a0,0x7
    80001508:	c7450513          	addi	a0,a0,-908 # 80008178 <digits+0x138>
    8000150c:	fffff097          	auipc	ra,0xfffff
    80001510:	034080e7          	jalr	52(ra) # 80000540 <panic>
    }
  }
  kfree((void*)pagetable);
    80001514:	8552                	mv	a0,s4
    80001516:	fffff097          	auipc	ra,0xfffff
    8000151a:	4d2080e7          	jalr	1234(ra) # 800009e8 <kfree>
}
    8000151e:	70a2                	ld	ra,40(sp)
    80001520:	7402                	ld	s0,32(sp)
    80001522:	64e2                	ld	s1,24(sp)
    80001524:	6942                	ld	s2,16(sp)
    80001526:	69a2                	ld	s3,8(sp)
    80001528:	6a02                	ld	s4,0(sp)
    8000152a:	6145                	addi	sp,sp,48
    8000152c:	8082                	ret

000000008000152e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000152e:	1101                	addi	sp,sp,-32
    80001530:	ec06                	sd	ra,24(sp)
    80001532:	e822                	sd	s0,16(sp)
    80001534:	e426                	sd	s1,8(sp)
    80001536:	1000                	addi	s0,sp,32
    80001538:	84aa                	mv	s1,a0
  if(sz > 0)
    8000153a:	e999                	bnez	a1,80001550 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000153c:	8526                	mv	a0,s1
    8000153e:	00000097          	auipc	ra,0x0
    80001542:	f84080e7          	jalr	-124(ra) # 800014c2 <freewalk>
}
    80001546:	60e2                	ld	ra,24(sp)
    80001548:	6442                	ld	s0,16(sp)
    8000154a:	64a2                	ld	s1,8(sp)
    8000154c:	6105                	addi	sp,sp,32
    8000154e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001550:	6785                	lui	a5,0x1
    80001552:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001554:	95be                	add	a1,a1,a5
    80001556:	4685                	li	a3,1
    80001558:	00c5d613          	srli	a2,a1,0xc
    8000155c:	4581                	li	a1,0
    8000155e:	00000097          	auipc	ra,0x0
    80001562:	d06080e7          	jalr	-762(ra) # 80001264 <uvmunmap>
    80001566:	bfd9                	j	8000153c <uvmfree+0xe>

0000000080001568 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001568:	c679                	beqz	a2,80001636 <uvmcopy+0xce>
{
    8000156a:	715d                	addi	sp,sp,-80
    8000156c:	e486                	sd	ra,72(sp)
    8000156e:	e0a2                	sd	s0,64(sp)
    80001570:	fc26                	sd	s1,56(sp)
    80001572:	f84a                	sd	s2,48(sp)
    80001574:	f44e                	sd	s3,40(sp)
    80001576:	f052                	sd	s4,32(sp)
    80001578:	ec56                	sd	s5,24(sp)
    8000157a:	e85a                	sd	s6,16(sp)
    8000157c:	e45e                	sd	s7,8(sp)
    8000157e:	0880                	addi	s0,sp,80
    80001580:	8b2a                	mv	s6,a0
    80001582:	8aae                	mv	s5,a1
    80001584:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001586:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001588:	4601                	li	a2,0
    8000158a:	85ce                	mv	a1,s3
    8000158c:	855a                	mv	a0,s6
    8000158e:	00000097          	auipc	ra,0x0
    80001592:	a28080e7          	jalr	-1496(ra) # 80000fb6 <walk>
    80001596:	c531                	beqz	a0,800015e2 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001598:	6118                	ld	a4,0(a0)
    8000159a:	00177793          	andi	a5,a4,1
    8000159e:	cbb1                	beqz	a5,800015f2 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015a0:	00a75593          	srli	a1,a4,0xa
    800015a4:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a8:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015ac:	fffff097          	auipc	ra,0xfffff
    800015b0:	53a080e7          	jalr	1338(ra) # 80000ae6 <kalloc>
    800015b4:	892a                	mv	s2,a0
    800015b6:	c939                	beqz	a0,8000160c <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b8:	6605                	lui	a2,0x1
    800015ba:	85de                	mv	a1,s7
    800015bc:	fffff097          	auipc	ra,0xfffff
    800015c0:	772080e7          	jalr	1906(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c4:	8726                	mv	a4,s1
    800015c6:	86ca                	mv	a3,s2
    800015c8:	6605                	lui	a2,0x1
    800015ca:	85ce                	mv	a1,s3
    800015cc:	8556                	mv	a0,s5
    800015ce:	00000097          	auipc	ra,0x0
    800015d2:	ad0080e7          	jalr	-1328(ra) # 8000109e <mappages>
    800015d6:	e515                	bnez	a0,80001602 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d8:	6785                	lui	a5,0x1
    800015da:	99be                	add	s3,s3,a5
    800015dc:	fb49e6e3          	bltu	s3,s4,80001588 <uvmcopy+0x20>
    800015e0:	a081                	j	80001620 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015e2:	00007517          	auipc	a0,0x7
    800015e6:	ba650513          	addi	a0,a0,-1114 # 80008188 <digits+0x148>
    800015ea:	fffff097          	auipc	ra,0xfffff
    800015ee:	f56080e7          	jalr	-170(ra) # 80000540 <panic>
      panic("uvmcopy: page not present");
    800015f2:	00007517          	auipc	a0,0x7
    800015f6:	bb650513          	addi	a0,a0,-1098 # 800081a8 <digits+0x168>
    800015fa:	fffff097          	auipc	ra,0xfffff
    800015fe:	f46080e7          	jalr	-186(ra) # 80000540 <panic>
      kfree(mem);
    80001602:	854a                	mv	a0,s2
    80001604:	fffff097          	auipc	ra,0xfffff
    80001608:	3e4080e7          	jalr	996(ra) # 800009e8 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000160c:	4685                	li	a3,1
    8000160e:	00c9d613          	srli	a2,s3,0xc
    80001612:	4581                	li	a1,0
    80001614:	8556                	mv	a0,s5
    80001616:	00000097          	auipc	ra,0x0
    8000161a:	c4e080e7          	jalr	-946(ra) # 80001264 <uvmunmap>
  return -1;
    8000161e:	557d                	li	a0,-1
}
    80001620:	60a6                	ld	ra,72(sp)
    80001622:	6406                	ld	s0,64(sp)
    80001624:	74e2                	ld	s1,56(sp)
    80001626:	7942                	ld	s2,48(sp)
    80001628:	79a2                	ld	s3,40(sp)
    8000162a:	7a02                	ld	s4,32(sp)
    8000162c:	6ae2                	ld	s5,24(sp)
    8000162e:	6b42                	ld	s6,16(sp)
    80001630:	6ba2                	ld	s7,8(sp)
    80001632:	6161                	addi	sp,sp,80
    80001634:	8082                	ret
  return 0;
    80001636:	4501                	li	a0,0
}
    80001638:	8082                	ret

000000008000163a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000163a:	1141                	addi	sp,sp,-16
    8000163c:	e406                	sd	ra,8(sp)
    8000163e:	e022                	sd	s0,0(sp)
    80001640:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001642:	4601                	li	a2,0
    80001644:	00000097          	auipc	ra,0x0
    80001648:	972080e7          	jalr	-1678(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000164c:	c901                	beqz	a0,8000165c <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000164e:	611c                	ld	a5,0(a0)
    80001650:	9bbd                	andi	a5,a5,-17
    80001652:	e11c                	sd	a5,0(a0)
}
    80001654:	60a2                	ld	ra,8(sp)
    80001656:	6402                	ld	s0,0(sp)
    80001658:	0141                	addi	sp,sp,16
    8000165a:	8082                	ret
    panic("uvmclear");
    8000165c:	00007517          	auipc	a0,0x7
    80001660:	b6c50513          	addi	a0,a0,-1172 # 800081c8 <digits+0x188>
    80001664:	fffff097          	auipc	ra,0xfffff
    80001668:	edc080e7          	jalr	-292(ra) # 80000540 <panic>

000000008000166c <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000166c:	c6bd                	beqz	a3,800016da <copyout+0x6e>
{
    8000166e:	715d                	addi	sp,sp,-80
    80001670:	e486                	sd	ra,72(sp)
    80001672:	e0a2                	sd	s0,64(sp)
    80001674:	fc26                	sd	s1,56(sp)
    80001676:	f84a                	sd	s2,48(sp)
    80001678:	f44e                	sd	s3,40(sp)
    8000167a:	f052                	sd	s4,32(sp)
    8000167c:	ec56                	sd	s5,24(sp)
    8000167e:	e85a                	sd	s6,16(sp)
    80001680:	e45e                	sd	s7,8(sp)
    80001682:	e062                	sd	s8,0(sp)
    80001684:	0880                	addi	s0,sp,80
    80001686:	8b2a                	mv	s6,a0
    80001688:	8c2e                	mv	s8,a1
    8000168a:	8a32                	mv	s4,a2
    8000168c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000168e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001690:	6a85                	lui	s5,0x1
    80001692:	a015                	j	800016b6 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001694:	9562                	add	a0,a0,s8
    80001696:	0004861b          	sext.w	a2,s1
    8000169a:	85d2                	mv	a1,s4
    8000169c:	41250533          	sub	a0,a0,s2
    800016a0:	fffff097          	auipc	ra,0xfffff
    800016a4:	68e080e7          	jalr	1678(ra) # 80000d2e <memmove>

    len -= n;
    800016a8:	409989b3          	sub	s3,s3,s1
    src += n;
    800016ac:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016ae:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016b2:	02098263          	beqz	s3,800016d6 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b6:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016ba:	85ca                	mv	a1,s2
    800016bc:	855a                	mv	a0,s6
    800016be:	00000097          	auipc	ra,0x0
    800016c2:	99e080e7          	jalr	-1634(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800016c6:	cd01                	beqz	a0,800016de <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c8:	418904b3          	sub	s1,s2,s8
    800016cc:	94d6                	add	s1,s1,s5
    800016ce:	fc99f3e3          	bgeu	s3,s1,80001694 <copyout+0x28>
    800016d2:	84ce                	mv	s1,s3
    800016d4:	b7c1                	j	80001694 <copyout+0x28>
  }
  return 0;
    800016d6:	4501                	li	a0,0
    800016d8:	a021                	j	800016e0 <copyout+0x74>
    800016da:	4501                	li	a0,0
}
    800016dc:	8082                	ret
      return -1;
    800016de:	557d                	li	a0,-1
}
    800016e0:	60a6                	ld	ra,72(sp)
    800016e2:	6406                	ld	s0,64(sp)
    800016e4:	74e2                	ld	s1,56(sp)
    800016e6:	7942                	ld	s2,48(sp)
    800016e8:	79a2                	ld	s3,40(sp)
    800016ea:	7a02                	ld	s4,32(sp)
    800016ec:	6ae2                	ld	s5,24(sp)
    800016ee:	6b42                	ld	s6,16(sp)
    800016f0:	6ba2                	ld	s7,8(sp)
    800016f2:	6c02                	ld	s8,0(sp)
    800016f4:	6161                	addi	sp,sp,80
    800016f6:	8082                	ret

00000000800016f8 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f8:	caa5                	beqz	a3,80001768 <copyin+0x70>
{
    800016fa:	715d                	addi	sp,sp,-80
    800016fc:	e486                	sd	ra,72(sp)
    800016fe:	e0a2                	sd	s0,64(sp)
    80001700:	fc26                	sd	s1,56(sp)
    80001702:	f84a                	sd	s2,48(sp)
    80001704:	f44e                	sd	s3,40(sp)
    80001706:	f052                	sd	s4,32(sp)
    80001708:	ec56                	sd	s5,24(sp)
    8000170a:	e85a                	sd	s6,16(sp)
    8000170c:	e45e                	sd	s7,8(sp)
    8000170e:	e062                	sd	s8,0(sp)
    80001710:	0880                	addi	s0,sp,80
    80001712:	8b2a                	mv	s6,a0
    80001714:	8a2e                	mv	s4,a1
    80001716:	8c32                	mv	s8,a2
    80001718:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000171a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000171c:	6a85                	lui	s5,0x1
    8000171e:	a01d                	j	80001744 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001720:	018505b3          	add	a1,a0,s8
    80001724:	0004861b          	sext.w	a2,s1
    80001728:	412585b3          	sub	a1,a1,s2
    8000172c:	8552                	mv	a0,s4
    8000172e:	fffff097          	auipc	ra,0xfffff
    80001732:	600080e7          	jalr	1536(ra) # 80000d2e <memmove>

    len -= n;
    80001736:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000173a:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000173c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001740:	02098263          	beqz	s3,80001764 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001744:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001748:	85ca                	mv	a1,s2
    8000174a:	855a                	mv	a0,s6
    8000174c:	00000097          	auipc	ra,0x0
    80001750:	910080e7          	jalr	-1776(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    80001754:	cd01                	beqz	a0,8000176c <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001756:	418904b3          	sub	s1,s2,s8
    8000175a:	94d6                	add	s1,s1,s5
    8000175c:	fc99f2e3          	bgeu	s3,s1,80001720 <copyin+0x28>
    80001760:	84ce                	mv	s1,s3
    80001762:	bf7d                	j	80001720 <copyin+0x28>
  }
  return 0;
    80001764:	4501                	li	a0,0
    80001766:	a021                	j	8000176e <copyin+0x76>
    80001768:	4501                	li	a0,0
}
    8000176a:	8082                	ret
      return -1;
    8000176c:	557d                	li	a0,-1
}
    8000176e:	60a6                	ld	ra,72(sp)
    80001770:	6406                	ld	s0,64(sp)
    80001772:	74e2                	ld	s1,56(sp)
    80001774:	7942                	ld	s2,48(sp)
    80001776:	79a2                	ld	s3,40(sp)
    80001778:	7a02                	ld	s4,32(sp)
    8000177a:	6ae2                	ld	s5,24(sp)
    8000177c:	6b42                	ld	s6,16(sp)
    8000177e:	6ba2                	ld	s7,8(sp)
    80001780:	6c02                	ld	s8,0(sp)
    80001782:	6161                	addi	sp,sp,80
    80001784:	8082                	ret

0000000080001786 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001786:	c2dd                	beqz	a3,8000182c <copyinstr+0xa6>
{
    80001788:	715d                	addi	sp,sp,-80
    8000178a:	e486                	sd	ra,72(sp)
    8000178c:	e0a2                	sd	s0,64(sp)
    8000178e:	fc26                	sd	s1,56(sp)
    80001790:	f84a                	sd	s2,48(sp)
    80001792:	f44e                	sd	s3,40(sp)
    80001794:	f052                	sd	s4,32(sp)
    80001796:	ec56                	sd	s5,24(sp)
    80001798:	e85a                	sd	s6,16(sp)
    8000179a:	e45e                	sd	s7,8(sp)
    8000179c:	0880                	addi	s0,sp,80
    8000179e:	8a2a                	mv	s4,a0
    800017a0:	8b2e                	mv	s6,a1
    800017a2:	8bb2                	mv	s7,a2
    800017a4:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a6:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a8:	6985                	lui	s3,0x1
    800017aa:	a02d                	j	800017d4 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017ac:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017b0:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017b2:	37fd                	addiw	a5,a5,-1
    800017b4:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b8:	60a6                	ld	ra,72(sp)
    800017ba:	6406                	ld	s0,64(sp)
    800017bc:	74e2                	ld	s1,56(sp)
    800017be:	7942                	ld	s2,48(sp)
    800017c0:	79a2                	ld	s3,40(sp)
    800017c2:	7a02                	ld	s4,32(sp)
    800017c4:	6ae2                	ld	s5,24(sp)
    800017c6:	6b42                	ld	s6,16(sp)
    800017c8:	6ba2                	ld	s7,8(sp)
    800017ca:	6161                	addi	sp,sp,80
    800017cc:	8082                	ret
    srcva = va0 + PGSIZE;
    800017ce:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d2:	c8a9                	beqz	s1,80001824 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017d4:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d8:	85ca                	mv	a1,s2
    800017da:	8552                	mv	a0,s4
    800017dc:	00000097          	auipc	ra,0x0
    800017e0:	880080e7          	jalr	-1920(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800017e4:	c131                	beqz	a0,80001828 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017e6:	417906b3          	sub	a3,s2,s7
    800017ea:	96ce                	add	a3,a3,s3
    800017ec:	00d4f363          	bgeu	s1,a3,800017f2 <copyinstr+0x6c>
    800017f0:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f2:	955e                	add	a0,a0,s7
    800017f4:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f8:	daf9                	beqz	a3,800017ce <copyinstr+0x48>
    800017fa:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017fc:	41650633          	sub	a2,a0,s6
    80001800:	fff48593          	addi	a1,s1,-1
    80001804:	95da                	add	a1,a1,s6
    while(n > 0){
    80001806:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80001808:	00f60733          	add	a4,a2,a5
    8000180c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd95e0>
    80001810:	df51                	beqz	a4,800017ac <copyinstr+0x26>
        *dst = *p;
    80001812:	00e78023          	sb	a4,0(a5)
      --max;
    80001816:	40f584b3          	sub	s1,a1,a5
      dst++;
    8000181a:	0785                	addi	a5,a5,1
    while(n > 0){
    8000181c:	fed796e3          	bne	a5,a3,80001808 <copyinstr+0x82>
      dst++;
    80001820:	8b3e                	mv	s6,a5
    80001822:	b775                	j	800017ce <copyinstr+0x48>
    80001824:	4781                	li	a5,0
    80001826:	b771                	j	800017b2 <copyinstr+0x2c>
      return -1;
    80001828:	557d                	li	a0,-1
    8000182a:	b779                	j	800017b8 <copyinstr+0x32>
  int got_null = 0;
    8000182c:	4781                	li	a5,0
  if(got_null){
    8000182e:	37fd                	addiw	a5,a5,-1
    80001830:	0007851b          	sext.w	a0,a5
}
    80001834:	8082                	ret

0000000080001836 <rand>:
#define TIME_SLICE 1
#define MAXTIME 30

// Pseudo-random number generator (LCG) function
unsigned int rand()
{
    80001836:	1141                	addi	sp,sp,-16
    80001838:	e422                	sd	s0,8(sp)
    8000183a:	0800                	addi	s0,sp,16
  static uint64 seed = 123456789;        // Initial seed (can be any number)
  seed = (LCG_A * seed + LCG_C) & LCG_M; // Generate next random number
    8000183c:	00007717          	auipc	a4,0x7
    80001840:	09c70713          	addi	a4,a4,156 # 800088d8 <seed.2>
    80001844:	6308                	ld	a0,0(a4)
    80001846:	001967b7          	lui	a5,0x196
    8000184a:	60d78793          	addi	a5,a5,1549 # 19660d <_entry-0x7fe699f3>
    8000184e:	02f50533          	mul	a0,a0,a5
    80001852:	3c6ef7b7          	lui	a5,0x3c6ef
    80001856:	35f78793          	addi	a5,a5,863 # 3c6ef35f <_entry-0x43910ca1>
    8000185a:	953e                	add	a0,a0,a5
    8000185c:	02051793          	slli	a5,a0,0x20
    80001860:	9381                	srli	a5,a5,0x20
    80001862:	e31c                	sd	a5,0(a4)
  return seed;                           // Return the pseudo-random number
}
    80001864:	2501                	sext.w	a0,a0
    80001866:	6422                	ld	s0,8(sp)
    80001868:	0141                	addi	sp,sp,16
    8000186a:	8082                	ret

000000008000186c <rand_at_max>:
int rand_at_max(int parameter)
{
    8000186c:	1101                	addi	sp,sp,-32
    8000186e:	ec06                	sd	ra,24(sp)
    80001870:	e822                	sd	s0,16(sp)
    80001872:	e426                	sd	s1,8(sp)
    80001874:	1000                	addi	s0,sp,32
    80001876:	84aa                	mv	s1,a0
  return rand() % (parameter + 1);
    80001878:	00000097          	auipc	ra,0x0
    8000187c:	fbe080e7          	jalr	-66(ra) # 80001836 <rand>
    80001880:	2485                	addiw	s1,s1,1
}
    80001882:	0295753b          	remuw	a0,a0,s1
    80001886:	60e2                	ld	ra,24(sp)
    80001888:	6442                	ld	s0,16(sp)
    8000188a:	64a2                	ld	s1,8(sp)
    8000188c:	6105                	addi	sp,sp,32
    8000188e:	8082                	ret

0000000080001890 <enqueue>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.

void enqueue(struct proc *p, int priorityq)
{
    80001890:	1141                	addi	sp,sp,-16
    80001892:	e422                	sd	s0,8(sp)
    80001894:	0800                	addi	s0,sp,16
  // if (p->state != RUNNABLE)
  //   return;

  for (int i = 0; i < sizeofq[priorityq]; i++)
    80001896:	00259713          	slli	a4,a1,0x2
    8000189a:	0000f797          	auipc	a5,0xf
    8000189e:	36678793          	addi	a5,a5,870 # 80010c00 <sizeofq>
    800018a2:	97ba                	add	a5,a5,a4
    800018a4:	0007a803          	lw	a6,0(a5)
    800018a8:	05005063          	blez	a6,800018e8 <enqueue+0x58>
  {
    if (multique[priorityq][i]->pid == p->pid){
    800018ac:	0b052603          	lw	a2,176(a0)
    800018b0:	00959793          	slli	a5,a1,0x9
    800018b4:	0000f717          	auipc	a4,0xf
    800018b8:	78c70713          	addi	a4,a4,1932 # 80011040 <multique>
    800018bc:	97ba                	add	a5,a5,a4
    800018be:	00659693          	slli	a3,a1,0x6
    800018c2:	fff8071b          	addiw	a4,a6,-1
    800018c6:	1702                	slli	a4,a4,0x20
    800018c8:	9301                	srli	a4,a4,0x20
    800018ca:	96ba                	add	a3,a3,a4
    800018cc:	068e                	slli	a3,a3,0x3
    800018ce:	0000f717          	auipc	a4,0xf
    800018d2:	77a70713          	addi	a4,a4,1914 # 80011048 <multique+0x8>
    800018d6:	96ba                	add	a3,a3,a4
    800018d8:	6398                	ld	a4,0(a5)
    800018da:	0b072703          	lw	a4,176(a4)
    800018de:	02c70d63          	beq	a4,a2,80001918 <enqueue+0x88>
  for (int i = 0; i < sizeofq[priorityq]; i++)
    800018e2:	07a1                	addi	a5,a5,8
    800018e4:	fed79ae3          	bne	a5,a3,800018d8 <enqueue+0x48>
      return;
    }
  }
  multique[priorityq][sizeofq[priorityq]++] = p;
    800018e8:	00259713          	slli	a4,a1,0x2
    800018ec:	0000f797          	auipc	a5,0xf
    800018f0:	31478793          	addi	a5,a5,788 # 80010c00 <sizeofq>
    800018f4:	97ba                	add	a5,a5,a4
    800018f6:	0018071b          	addiw	a4,a6,1
    800018fa:	c398                	sw	a4,0(a5)
    800018fc:	00659793          	slli	a5,a1,0x6
    80001900:	97c2                	add	a5,a5,a6
    80001902:	078e                	slli	a5,a5,0x3
    80001904:	0000f717          	auipc	a4,0xf
    80001908:	73c70713          	addi	a4,a4,1852 # 80011040 <multique>
    8000190c:	97ba                	add	a5,a5,a4
    8000190e:	e388                	sd	a0,0(a5)
  p->queueticks = 0;
    80001910:	22052823          	sw	zero,560(a0)
  p->queue_number = priorityq;
    80001914:	22b52223          	sw	a1,548(a0)
}
    80001918:	6422                	ld	s0,8(sp)
    8000191a:	0141                	addi	sp,sp,16
    8000191c:	8082                	ret

000000008000191e <dequeue>:

void dequeue(struct proc *p, int priorityq)
{
    8000191e:	1141                	addi	sp,sp,-16
    80001920:	e422                	sd	s0,8(sp)
    80001922:	0800                	addi	s0,sp,16
  if (sizeofq[priorityq] == 0)
    80001924:	00259713          	slli	a4,a1,0x2
    80001928:	0000f797          	auipc	a5,0xf
    8000192c:	2d878793          	addi	a5,a5,728 # 80010c00 <sizeofq>
    80001930:	97ba                	add	a5,a5,a4
    80001932:	4394                	lw	a3,0(a5)
  {
    return;
  }
  for (int i = 0; i < sizeofq[priorityq]; i++)
    80001934:	08d05b63          	blez	a3,800019ca <dequeue+0xac>
  {
    if (multique[priorityq][i]->pid == p->pid)
    80001938:	0b052503          	lw	a0,176(a0)
    8000193c:	00959793          	slli	a5,a1,0x9
    80001940:	0000f717          	auipc	a4,0xf
    80001944:	70070713          	addi	a4,a4,1792 # 80011040 <multique>
    80001948:	97ba                	add	a5,a5,a4
  for (int i = 0; i < sizeofq[priorityq]; i++)
    8000194a:	4701                	li	a4,0
    if (multique[priorityq][i]->pid == p->pid)
    8000194c:	6390                	ld	a2,0(a5)
    8000194e:	0b062603          	lw	a2,176(a2) # 10b0 <_entry-0x7fffef50>
    80001952:	00a60763          	beq	a2,a0,80001960 <dequeue+0x42>
  for (int i = 0; i < sizeofq[priorityq]; i++)
    80001956:	2705                	addiw	a4,a4,1
    80001958:	07a1                	addi	a5,a5,8
    8000195a:	fee699e3          	bne	a3,a4,8000194c <dequeue+0x2e>
    8000195e:	a0b5                	j	800019ca <dequeue+0xac>
    {
     
      for (int j = i; j < sizeofq[priorityq] - 1; j++)
    80001960:	fff6889b          	addiw	a7,a3,-1 # ffffffffffffefff <end+0xffffffff7ffd95df>
    80001964:	0008881b          	sext.w	a6,a7
    80001968:	03075d63          	bge	a4,a6,800019a2 <dequeue+0x84>
    8000196c:	00659513          	slli	a0,a1,0x6
    80001970:	953a                	add	a0,a0,a4
    80001972:	00351613          	slli	a2,a0,0x3
    80001976:	0000f797          	auipc	a5,0xf
    8000197a:	6ca78793          	addi	a5,a5,1738 # 80011040 <multique>
    8000197e:	963e                	add	a2,a2,a5
    80001980:	ffe6879b          	addiw	a5,a3,-2
    80001984:	9f99                	subw	a5,a5,a4
    80001986:	1782                	slli	a5,a5,0x20
    80001988:	9381                	srli	a5,a5,0x20
    8000198a:	97aa                	add	a5,a5,a0
    8000198c:	078e                	slli	a5,a5,0x3
    8000198e:	0000f717          	auipc	a4,0xf
    80001992:	6ba70713          	addi	a4,a4,1722 # 80011048 <multique+0x8>
    80001996:	97ba                	add	a5,a5,a4
      {
        multique[priorityq][j] = multique[priorityq][j + 1];
    80001998:	6618                	ld	a4,8(a2)
    8000199a:	e218                	sd	a4,0(a2)
      for (int j = i; j < sizeofq[priorityq] - 1; j++)
    8000199c:	0621                	addi	a2,a2,8
    8000199e:	fef61de3          	bne	a2,a5,80001998 <dequeue+0x7a>
      }
      sizeofq[priorityq]--;
    800019a2:	00259713          	slli	a4,a1,0x2
    800019a6:	0000f797          	auipc	a5,0xf
    800019aa:	25a78793          	addi	a5,a5,602 # 80010c00 <sizeofq>
    800019ae:	97ba                	add	a5,a5,a4
    800019b0:	0117a023          	sw	a7,0(a5)
      multique[priorityq][sizeofq[priorityq]] = 0;
    800019b4:	00659793          	slli	a5,a1,0x6
    800019b8:	97c2                	add	a5,a5,a6
    800019ba:	078e                	slli	a5,a5,0x3
    800019bc:	0000f717          	auipc	a4,0xf
    800019c0:	68470713          	addi	a4,a4,1668 # 80011040 <multique>
    800019c4:	97ba                	add	a5,a5,a4
    800019c6:	0007b023          	sd	zero,0(a5)
      return;
    }
  }
  // return;
}
    800019ca:	6422                	ld	s0,8(sp)
    800019cc:	0141                	addi	sp,sp,16
    800019ce:	8082                	ret

00000000800019d0 <proc_mapstacks>:

void proc_mapstacks(pagetable_t kpgtbl)
{
    800019d0:	7139                	addi	sp,sp,-64
    800019d2:	fc06                	sd	ra,56(sp)
    800019d4:	f822                	sd	s0,48(sp)
    800019d6:	f426                	sd	s1,40(sp)
    800019d8:	f04a                	sd	s2,32(sp)
    800019da:	ec4e                	sd	s3,24(sp)
    800019dc:	e852                	sd	s4,16(sp)
    800019de:	e456                	sd	s5,8(sp)
    800019e0:	e05a                	sd	s6,0(sp)
    800019e2:	0080                	addi	s0,sp,64
    800019e4:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800019e6:	00010497          	auipc	s1,0x10
    800019ea:	e5a48493          	addi	s1,s1,-422 # 80011840 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800019ee:	8b26                	mv	s6,s1
    800019f0:	00006a97          	auipc	s5,0x6
    800019f4:	610a8a93          	addi	s5,s5,1552 # 80008000 <etext>
    800019f8:	04000937          	lui	s2,0x4000
    800019fc:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    800019fe:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001a00:	00019a17          	auipc	s4,0x19
    80001a04:	c40a0a13          	addi	s4,s4,-960 # 8001a640 <tickslock>
    char *pa = kalloc();
    80001a08:	fffff097          	auipc	ra,0xfffff
    80001a0c:	0de080e7          	jalr	222(ra) # 80000ae6 <kalloc>
    80001a10:	862a                	mv	a2,a0
    if (pa == 0)
    80001a12:	c131                	beqz	a0,80001a56 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    80001a14:	416485b3          	sub	a1,s1,s6
    80001a18:	858d                	srai	a1,a1,0x3
    80001a1a:	000ab783          	ld	a5,0(s5)
    80001a1e:	02f585b3          	mul	a1,a1,a5
    80001a22:	2585                	addiw	a1,a1,1
    80001a24:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a28:	4719                	li	a4,6
    80001a2a:	6685                	lui	a3,0x1
    80001a2c:	40b905b3          	sub	a1,s2,a1
    80001a30:	854e                	mv	a0,s3
    80001a32:	fffff097          	auipc	ra,0xfffff
    80001a36:	70c080e7          	jalr	1804(ra) # 8000113e <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    80001a3a:	23848493          	addi	s1,s1,568
    80001a3e:	fd4495e3          	bne	s1,s4,80001a08 <proc_mapstacks+0x38>
  }
}
    80001a42:	70e2                	ld	ra,56(sp)
    80001a44:	7442                	ld	s0,48(sp)
    80001a46:	74a2                	ld	s1,40(sp)
    80001a48:	7902                	ld	s2,32(sp)
    80001a4a:	69e2                	ld	s3,24(sp)
    80001a4c:	6a42                	ld	s4,16(sp)
    80001a4e:	6aa2                	ld	s5,8(sp)
    80001a50:	6b02                	ld	s6,0(sp)
    80001a52:	6121                	addi	sp,sp,64
    80001a54:	8082                	ret
      panic("kalloc");
    80001a56:	00006517          	auipc	a0,0x6
    80001a5a:	78250513          	addi	a0,a0,1922 # 800081d8 <digits+0x198>
    80001a5e:	fffff097          	auipc	ra,0xfffff
    80001a62:	ae2080e7          	jalr	-1310(ra) # 80000540 <panic>

0000000080001a66 <procinit>:

// initialize the proc table.
void procinit(void)
{
    80001a66:	7139                	addi	sp,sp,-64
    80001a68:	fc06                	sd	ra,56(sp)
    80001a6a:	f822                	sd	s0,48(sp)
    80001a6c:	f426                	sd	s1,40(sp)
    80001a6e:	f04a                	sd	s2,32(sp)
    80001a70:	ec4e                	sd	s3,24(sp)
    80001a72:	e852                	sd	s4,16(sp)
    80001a74:	e456                	sd	s5,8(sp)
    80001a76:	e05a                	sd	s6,0(sp)
    80001a78:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001a7a:	00006597          	auipc	a1,0x6
    80001a7e:	76658593          	addi	a1,a1,1894 # 800081e0 <digits+0x1a0>
    80001a82:	0000f517          	auipc	a0,0xf
    80001a86:	18e50513          	addi	a0,a0,398 # 80010c10 <pid_lock>
    80001a8a:	fffff097          	auipc	ra,0xfffff
    80001a8e:	0bc080e7          	jalr	188(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001a92:	00006597          	auipc	a1,0x6
    80001a96:	75658593          	addi	a1,a1,1878 # 800081e8 <digits+0x1a8>
    80001a9a:	0000f517          	auipc	a0,0xf
    80001a9e:	18e50513          	addi	a0,a0,398 # 80010c28 <wait_lock>
    80001aa2:	fffff097          	auipc	ra,0xfffff
    80001aa6:	0a4080e7          	jalr	164(ra) # 80000b46 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001aaa:	00010497          	auipc	s1,0x10
    80001aae:	d9648493          	addi	s1,s1,-618 # 80011840 <proc>
  {
    initlock(&p->lock, "proc");
    80001ab2:	00006b17          	auipc	s6,0x6
    80001ab6:	746b0b13          	addi	s6,s6,1862 # 800081f8 <digits+0x1b8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001aba:	8aa6                	mv	s5,s1
    80001abc:	00006a17          	auipc	s4,0x6
    80001ac0:	544a0a13          	addi	s4,s4,1348 # 80008000 <etext>
    80001ac4:	04000937          	lui	s2,0x4000
    80001ac8:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001aca:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001acc:	00019997          	auipc	s3,0x19
    80001ad0:	b7498993          	addi	s3,s3,-1164 # 8001a640 <tickslock>
    initlock(&p->lock, "proc");
    80001ad4:	85da                	mv	a1,s6
    80001ad6:	8526                	mv	a0,s1
    80001ad8:	fffff097          	auipc	ra,0xfffff
    80001adc:	06e080e7          	jalr	110(ra) # 80000b46 <initlock>
    p->state = UNUSED;
    80001ae0:	0804ac23          	sw	zero,152(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001ae4:	415487b3          	sub	a5,s1,s5
    80001ae8:	878d                	srai	a5,a5,0x3
    80001aea:	000a3703          	ld	a4,0(s4)
    80001aee:	02e787b3          	mul	a5,a5,a4
    80001af2:	2785                	addiw	a5,a5,1
    80001af4:	00d7979b          	slliw	a5,a5,0xd
    80001af8:	40f907b3          	sub	a5,s2,a5
    80001afc:	e0fc                	sd	a5,192(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001afe:	23848493          	addi	s1,s1,568
    80001b02:	fd3499e3          	bne	s1,s3,80001ad4 <procinit+0x6e>
  }
}
    80001b06:	70e2                	ld	ra,56(sp)
    80001b08:	7442                	ld	s0,48(sp)
    80001b0a:	74a2                	ld	s1,40(sp)
    80001b0c:	7902                	ld	s2,32(sp)
    80001b0e:	69e2                	ld	s3,24(sp)
    80001b10:	6a42                	ld	s4,16(sp)
    80001b12:	6aa2                	ld	s5,8(sp)
    80001b14:	6b02                	ld	s6,0(sp)
    80001b16:	6121                	addi	sp,sp,64
    80001b18:	8082                	ret

0000000080001b1a <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001b1a:	1141                	addi	sp,sp,-16
    80001b1c:	e422                	sd	s0,8(sp)
    80001b1e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b20:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001b22:	2501                	sext.w	a0,a0
    80001b24:	6422                	ld	s0,8(sp)
    80001b26:	0141                	addi	sp,sp,16
    80001b28:	8082                	ret

0000000080001b2a <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001b2a:	1141                	addi	sp,sp,-16
    80001b2c:	e422                	sd	s0,8(sp)
    80001b2e:	0800                	addi	s0,sp,16
    80001b30:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001b32:	2781                	sext.w	a5,a5
    80001b34:	079e                	slli	a5,a5,0x7
  return c;
}
    80001b36:	0000f517          	auipc	a0,0xf
    80001b3a:	10a50513          	addi	a0,a0,266 # 80010c40 <cpus>
    80001b3e:	953e                	add	a0,a0,a5
    80001b40:	6422                	ld	s0,8(sp)
    80001b42:	0141                	addi	sp,sp,16
    80001b44:	8082                	ret

0000000080001b46 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001b46:	1101                	addi	sp,sp,-32
    80001b48:	ec06                	sd	ra,24(sp)
    80001b4a:	e822                	sd	s0,16(sp)
    80001b4c:	e426                	sd	s1,8(sp)
    80001b4e:	1000                	addi	s0,sp,32
  push_off();
    80001b50:	fffff097          	auipc	ra,0xfffff
    80001b54:	03a080e7          	jalr	58(ra) # 80000b8a <push_off>
    80001b58:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001b5a:	2781                	sext.w	a5,a5
    80001b5c:	079e                	slli	a5,a5,0x7
    80001b5e:	0000f717          	auipc	a4,0xf
    80001b62:	0a270713          	addi	a4,a4,162 # 80010c00 <sizeofq>
    80001b66:	97ba                	add	a5,a5,a4
    80001b68:	63a4                	ld	s1,64(a5)
  pop_off();
    80001b6a:	fffff097          	auipc	ra,0xfffff
    80001b6e:	0c0080e7          	jalr	192(ra) # 80000c2a <pop_off>
  return p;
}
    80001b72:	8526                	mv	a0,s1
    80001b74:	60e2                	ld	ra,24(sp)
    80001b76:	6442                	ld	s0,16(sp)
    80001b78:	64a2                	ld	s1,8(sp)
    80001b7a:	6105                	addi	sp,sp,32
    80001b7c:	8082                	ret

0000000080001b7e <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001b7e:	1141                	addi	sp,sp,-16
    80001b80:	e406                	sd	ra,8(sp)
    80001b82:	e022                	sd	s0,0(sp)
    80001b84:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001b86:	00000097          	auipc	ra,0x0
    80001b8a:	fc0080e7          	jalr	-64(ra) # 80001b46 <myproc>
    80001b8e:	fffff097          	auipc	ra,0xfffff
    80001b92:	0fc080e7          	jalr	252(ra) # 80000c8a <release>

  if (first)
    80001b96:	00007797          	auipc	a5,0x7
    80001b9a:	d3a7a783          	lw	a5,-710(a5) # 800088d0 <first.1>
    80001b9e:	eb89                	bnez	a5,80001bb0 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001ba0:	00001097          	auipc	ra,0x1
    80001ba4:	00a080e7          	jalr	10(ra) # 80002baa <usertrapret>
}
    80001ba8:	60a2                	ld	ra,8(sp)
    80001baa:	6402                	ld	s0,0(sp)
    80001bac:	0141                	addi	sp,sp,16
    80001bae:	8082                	ret
    first = 0;
    80001bb0:	00007797          	auipc	a5,0x7
    80001bb4:	d207a023          	sw	zero,-736(a5) # 800088d0 <first.1>
    fsinit(ROOTDEV);
    80001bb8:	4505                	li	a0,1
    80001bba:	00002097          	auipc	ra,0x2
    80001bbe:	15e080e7          	jalr	350(ra) # 80003d18 <fsinit>
    80001bc2:	bff9                	j	80001ba0 <forkret+0x22>

0000000080001bc4 <allocpid>:
{
    80001bc4:	1101                	addi	sp,sp,-32
    80001bc6:	ec06                	sd	ra,24(sp)
    80001bc8:	e822                	sd	s0,16(sp)
    80001bca:	e426                	sd	s1,8(sp)
    80001bcc:	e04a                	sd	s2,0(sp)
    80001bce:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001bd0:	0000f917          	auipc	s2,0xf
    80001bd4:	04090913          	addi	s2,s2,64 # 80010c10 <pid_lock>
    80001bd8:	854a                	mv	a0,s2
    80001bda:	fffff097          	auipc	ra,0xfffff
    80001bde:	ffc080e7          	jalr	-4(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001be2:	00007797          	auipc	a5,0x7
    80001be6:	cfe78793          	addi	a5,a5,-770 # 800088e0 <nextpid>
    80001bea:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001bec:	0014871b          	addiw	a4,s1,1
    80001bf0:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001bf2:	854a                	mv	a0,s2
    80001bf4:	fffff097          	auipc	ra,0xfffff
    80001bf8:	096080e7          	jalr	150(ra) # 80000c8a <release>
}
    80001bfc:	8526                	mv	a0,s1
    80001bfe:	60e2                	ld	ra,24(sp)
    80001c00:	6442                	ld	s0,16(sp)
    80001c02:	64a2                	ld	s1,8(sp)
    80001c04:	6902                	ld	s2,0(sp)
    80001c06:	6105                	addi	sp,sp,32
    80001c08:	8082                	ret

0000000080001c0a <proc_pagetable>:
{
    80001c0a:	1101                	addi	sp,sp,-32
    80001c0c:	ec06                	sd	ra,24(sp)
    80001c0e:	e822                	sd	s0,16(sp)
    80001c10:	e426                	sd	s1,8(sp)
    80001c12:	e04a                	sd	s2,0(sp)
    80001c14:	1000                	addi	s0,sp,32
    80001c16:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c18:	fffff097          	auipc	ra,0xfffff
    80001c1c:	710080e7          	jalr	1808(ra) # 80001328 <uvmcreate>
    80001c20:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001c22:	c121                	beqz	a0,80001c62 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c24:	4729                	li	a4,10
    80001c26:	00005697          	auipc	a3,0x5
    80001c2a:	3da68693          	addi	a3,a3,986 # 80007000 <_trampoline>
    80001c2e:	6605                	lui	a2,0x1
    80001c30:	040005b7          	lui	a1,0x4000
    80001c34:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c36:	05b2                	slli	a1,a1,0xc
    80001c38:	fffff097          	auipc	ra,0xfffff
    80001c3c:	466080e7          	jalr	1126(ra) # 8000109e <mappages>
    80001c40:	02054863          	bltz	a0,80001c70 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c44:	4719                	li	a4,6
    80001c46:	0d893683          	ld	a3,216(s2)
    80001c4a:	6605                	lui	a2,0x1
    80001c4c:	020005b7          	lui	a1,0x2000
    80001c50:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c52:	05b6                	slli	a1,a1,0xd
    80001c54:	8526                	mv	a0,s1
    80001c56:	fffff097          	auipc	ra,0xfffff
    80001c5a:	448080e7          	jalr	1096(ra) # 8000109e <mappages>
    80001c5e:	02054163          	bltz	a0,80001c80 <proc_pagetable+0x76>
}
    80001c62:	8526                	mv	a0,s1
    80001c64:	60e2                	ld	ra,24(sp)
    80001c66:	6442                	ld	s0,16(sp)
    80001c68:	64a2                	ld	s1,8(sp)
    80001c6a:	6902                	ld	s2,0(sp)
    80001c6c:	6105                	addi	sp,sp,32
    80001c6e:	8082                	ret
    uvmfree(pagetable, 0);
    80001c70:	4581                	li	a1,0
    80001c72:	8526                	mv	a0,s1
    80001c74:	00000097          	auipc	ra,0x0
    80001c78:	8ba080e7          	jalr	-1862(ra) # 8000152e <uvmfree>
    return 0;
    80001c7c:	4481                	li	s1,0
    80001c7e:	b7d5                	j	80001c62 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c80:	4681                	li	a3,0
    80001c82:	4605                	li	a2,1
    80001c84:	040005b7          	lui	a1,0x4000
    80001c88:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c8a:	05b2                	slli	a1,a1,0xc
    80001c8c:	8526                	mv	a0,s1
    80001c8e:	fffff097          	auipc	ra,0xfffff
    80001c92:	5d6080e7          	jalr	1494(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001c96:	4581                	li	a1,0
    80001c98:	8526                	mv	a0,s1
    80001c9a:	00000097          	auipc	ra,0x0
    80001c9e:	894080e7          	jalr	-1900(ra) # 8000152e <uvmfree>
    return 0;
    80001ca2:	4481                	li	s1,0
    80001ca4:	bf7d                	j	80001c62 <proc_pagetable+0x58>

0000000080001ca6 <proc_freepagetable>:
{
    80001ca6:	1101                	addi	sp,sp,-32
    80001ca8:	ec06                	sd	ra,24(sp)
    80001caa:	e822                	sd	s0,16(sp)
    80001cac:	e426                	sd	s1,8(sp)
    80001cae:	e04a                	sd	s2,0(sp)
    80001cb0:	1000                	addi	s0,sp,32
    80001cb2:	84aa                	mv	s1,a0
    80001cb4:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001cb6:	4681                	li	a3,0
    80001cb8:	4605                	li	a2,1
    80001cba:	040005b7          	lui	a1,0x4000
    80001cbe:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001cc0:	05b2                	slli	a1,a1,0xc
    80001cc2:	fffff097          	auipc	ra,0xfffff
    80001cc6:	5a2080e7          	jalr	1442(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001cca:	4681                	li	a3,0
    80001ccc:	4605                	li	a2,1
    80001cce:	020005b7          	lui	a1,0x2000
    80001cd2:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001cd4:	05b6                	slli	a1,a1,0xd
    80001cd6:	8526                	mv	a0,s1
    80001cd8:	fffff097          	auipc	ra,0xfffff
    80001cdc:	58c080e7          	jalr	1420(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001ce0:	85ca                	mv	a1,s2
    80001ce2:	8526                	mv	a0,s1
    80001ce4:	00000097          	auipc	ra,0x0
    80001ce8:	84a080e7          	jalr	-1974(ra) # 8000152e <uvmfree>
}
    80001cec:	60e2                	ld	ra,24(sp)
    80001cee:	6442                	ld	s0,16(sp)
    80001cf0:	64a2                	ld	s1,8(sp)
    80001cf2:	6902                	ld	s2,0(sp)
    80001cf4:	6105                	addi	sp,sp,32
    80001cf6:	8082                	ret

0000000080001cf8 <freeproc>:
{
    80001cf8:	1101                	addi	sp,sp,-32
    80001cfa:	ec06                	sd	ra,24(sp)
    80001cfc:	e822                	sd	s0,16(sp)
    80001cfe:	e426                	sd	s1,8(sp)
    80001d00:	1000                	addi	s0,sp,32
    80001d02:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001d04:	6d68                	ld	a0,216(a0)
    80001d06:	c509                	beqz	a0,80001d10 <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001d08:	fffff097          	auipc	ra,0xfffff
    80001d0c:	ce0080e7          	jalr	-800(ra) # 800009e8 <kfree>
  p->trapframe = 0;
    80001d10:	0c04bc23          	sd	zero,216(s1)
  if (p->pagetable)
    80001d14:	68e8                	ld	a0,208(s1)
    80001d16:	c511                	beqz	a0,80001d22 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001d18:	64ec                	ld	a1,200(s1)
    80001d1a:	00000097          	auipc	ra,0x0
    80001d1e:	f8c080e7          	jalr	-116(ra) # 80001ca6 <proc_freepagetable>
  p->pagetable = 0;
    80001d22:	0c04b823          	sd	zero,208(s1)
  p->sz = 0;
    80001d26:	0c04b423          	sd	zero,200(s1)
  p->pid = 0;
    80001d2a:	0a04a823          	sw	zero,176(s1)
  p->parent = 0;
    80001d2e:	0a04bc23          	sd	zero,184(s1)
  p->name[0] = 0;
    80001d32:	1c048c23          	sb	zero,472(s1)
  p->chan = 0;
    80001d36:	0a04b023          	sd	zero,160(s1)
  p->killed = 0;
    80001d3a:	0a04a423          	sw	zero,168(s1)
  p->xstate = 0;
    80001d3e:	0a04a623          	sw	zero,172(s1)
  p->state = UNUSED;
    80001d42:	0804ac23          	sw	zero,152(s1)
  dequeue(p,p->queue_number);
    80001d46:	2244a583          	lw	a1,548(s1)
    80001d4a:	8526                	mv	a0,s1
    80001d4c:	00000097          	auipc	ra,0x0
    80001d50:	bd2080e7          	jalr	-1070(ra) # 8000191e <dequeue>
}
    80001d54:	60e2                	ld	ra,24(sp)
    80001d56:	6442                	ld	s0,16(sp)
    80001d58:	64a2                	ld	s1,8(sp)
    80001d5a:	6105                	addi	sp,sp,32
    80001d5c:	8082                	ret

0000000080001d5e <allocproc>:
{
    80001d5e:	7179                	addi	sp,sp,-48
    80001d60:	f406                	sd	ra,40(sp)
    80001d62:	f022                	sd	s0,32(sp)
    80001d64:	ec26                	sd	s1,24(sp)
    80001d66:	e84a                	sd	s2,16(sp)
    80001d68:	e44e                	sd	s3,8(sp)
    80001d6a:	1800                	addi	s0,sp,48
  for (p = proc; p < &proc[NPROC]; p++)
    80001d6c:	00010497          	auipc	s1,0x10
    80001d70:	ad448493          	addi	s1,s1,-1324 # 80011840 <proc>
    80001d74:	00019997          	auipc	s3,0x19
    80001d78:	8cc98993          	addi	s3,s3,-1844 # 8001a640 <tickslock>
    acquire(&p->lock);
    80001d7c:	8926                	mv	s2,s1
    80001d7e:	8526                	mv	a0,s1
    80001d80:	fffff097          	auipc	ra,0xfffff
    80001d84:	e56080e7          	jalr	-426(ra) # 80000bd6 <acquire>
    if (p->state == UNUSED)
    80001d88:	0984a783          	lw	a5,152(s1)
    80001d8c:	cf81                	beqz	a5,80001da4 <allocproc+0x46>
      release(&p->lock);
    80001d8e:	8526                	mv	a0,s1
    80001d90:	fffff097          	auipc	ra,0xfffff
    80001d94:	efa080e7          	jalr	-262(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001d98:	23848493          	addi	s1,s1,568
    80001d9c:	ff3490e3          	bne	s1,s3,80001d7c <allocproc+0x1e>
  return 0;
    80001da0:	4481                	li	s1,0
    80001da2:	a05d                	j	80001e48 <allocproc+0xea>
  p->pid = allocpid();
    80001da4:	00000097          	auipc	ra,0x0
    80001da8:	e20080e7          	jalr	-480(ra) # 80001bc4 <allocpid>
    80001dac:	0aa4a823          	sw	a0,176(s1)
  p->state = USED;
    80001db0:	4785                	li	a5,1
    80001db2:	08f4ac23          	sw	a5,152(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001db6:	fffff097          	auipc	ra,0xfffff
    80001dba:	d30080e7          	jalr	-720(ra) # 80000ae6 <kalloc>
    80001dbe:	89aa                	mv	s3,a0
    80001dc0:	ece8                	sd	a0,216(s1)
    80001dc2:	c959                	beqz	a0,80001e58 <allocproc+0xfa>
  p->pagetable = proc_pagetable(p);
    80001dc4:	8526                	mv	a0,s1
    80001dc6:	00000097          	auipc	ra,0x0
    80001dca:	e44080e7          	jalr	-444(ra) # 80001c0a <proc_pagetable>
    80001dce:	89aa                	mv	s3,a0
    80001dd0:	e8e8                	sd	a0,208(s1)
  if (p->pagetable == 0)
    80001dd2:	cd59                	beqz	a0,80001e70 <allocproc+0x112>
  p->ticks = 0;     // No alarm set initially
    80001dd4:	2004a023          	sw	zero,512(s1)
  p->cur_ticks = 0; // Initialize cur_ticks to 0
    80001dd8:	2004a223          	sw	zero,516(s1)
  p->alarm_tf = 0;  // No cached trapframe initially
    80001ddc:	2004b423          	sd	zero,520(s1)
  p->alarm_on = 0;  // Alarm is not active
    80001de0:	2004a823          	sw	zero,528(s1)
  p->handler = 0;   // No handler set initially
    80001de4:	1e04bc23          	sd	zero,504(s1)
  p->queueticks=0;
    80001de8:	2204a823          	sw	zero,560(s1)
  if (p->parent)
    80001dec:	7cd8                	ld	a4,184(s1)
    p->tickets = 1;
    80001dee:	4785                	li	a5,1
  if (p->parent)
    80001df0:	c319                	beqz	a4,80001df6 <allocproc+0x98>
    p->tickets = p->parent->tickets; // Inherit tickets from parent
    80001df2:	21872783          	lw	a5,536(a4)
    80001df6:	20f4ac23          	sw	a5,536(s1)
  memset(&p->context, 0, sizeof(p->context));
    80001dfa:	07000613          	li	a2,112
    80001dfe:	4581                	li	a1,0
    80001e00:	0e048513          	addi	a0,s1,224
    80001e04:	fffff097          	auipc	ra,0xfffff
    80001e08:	ece080e7          	jalr	-306(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001e0c:	00000797          	auipc	a5,0x0
    80001e10:	d7278793          	addi	a5,a5,-654 # 80001b7e <forkret>
    80001e14:	f0fc                	sd	a5,224(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001e16:	60fc                	ld	a5,192(s1)
    80001e18:	6705                	lui	a4,0x1
    80001e1a:	97ba                	add	a5,a5,a4
    80001e1c:	f4fc                	sd	a5,232(s1)
  p->rtime = 0;
    80001e1e:	1e04a423          	sw	zero,488(s1)
  p->etime = 0;
    80001e22:	1e04a823          	sw	zero,496(s1)
  p->ctime = ticks;
    80001e26:	00007797          	auipc	a5,0x7
    80001e2a:	b6a7a783          	lw	a5,-1174(a5) # 80008990 <ticks>
    80001e2e:	1ef4a623          	sw	a5,492(s1)
  p->arrival_time = p->ctime;
    80001e32:	20f4ae23          	sw	a5,540(s1)
  for(int i=0;i<=31;i++) {
    80001e36:	01848793          	addi	a5,s1,24
    80001e3a:	09890713          	addi	a4,s2,152
    p->syscall_count[i]=0;
    80001e3e:	0007a023          	sw	zero,0(a5)
  for(int i=0;i<=31;i++) {
    80001e42:	0791                	addi	a5,a5,4
    80001e44:	fee79de3          	bne	a5,a4,80001e3e <allocproc+0xe0>
}
    80001e48:	8526                	mv	a0,s1
    80001e4a:	70a2                	ld	ra,40(sp)
    80001e4c:	7402                	ld	s0,32(sp)
    80001e4e:	64e2                	ld	s1,24(sp)
    80001e50:	6942                	ld	s2,16(sp)
    80001e52:	69a2                	ld	s3,8(sp)
    80001e54:	6145                	addi	sp,sp,48
    80001e56:	8082                	ret
    freeproc(p);
    80001e58:	8526                	mv	a0,s1
    80001e5a:	00000097          	auipc	ra,0x0
    80001e5e:	e9e080e7          	jalr	-354(ra) # 80001cf8 <freeproc>
    release(&p->lock);
    80001e62:	8526                	mv	a0,s1
    80001e64:	fffff097          	auipc	ra,0xfffff
    80001e68:	e26080e7          	jalr	-474(ra) # 80000c8a <release>
    return 0;
    80001e6c:	84ce                	mv	s1,s3
    80001e6e:	bfe9                	j	80001e48 <allocproc+0xea>
    freeproc(p);
    80001e70:	8526                	mv	a0,s1
    80001e72:	00000097          	auipc	ra,0x0
    80001e76:	e86080e7          	jalr	-378(ra) # 80001cf8 <freeproc>
    release(&p->lock);
    80001e7a:	8526                	mv	a0,s1
    80001e7c:	fffff097          	auipc	ra,0xfffff
    80001e80:	e0e080e7          	jalr	-498(ra) # 80000c8a <release>
    return 0;
    80001e84:	84ce                	mv	s1,s3
    80001e86:	b7c9                	j	80001e48 <allocproc+0xea>

0000000080001e88 <userinit>:
{
    80001e88:	1101                	addi	sp,sp,-32
    80001e8a:	ec06                	sd	ra,24(sp)
    80001e8c:	e822                	sd	s0,16(sp)
    80001e8e:	e426                	sd	s1,8(sp)
    80001e90:	1000                	addi	s0,sp,32
  p = allocproc();
    80001e92:	00000097          	auipc	ra,0x0
    80001e96:	ecc080e7          	jalr	-308(ra) # 80001d5e <allocproc>
    80001e9a:	84aa                	mv	s1,a0
  initproc = p;
    80001e9c:	00007797          	auipc	a5,0x7
    80001ea0:	aea7b623          	sd	a0,-1300(a5) # 80008988 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001ea4:	03400613          	li	a2,52
    80001ea8:	00007597          	auipc	a1,0x7
    80001eac:	a4858593          	addi	a1,a1,-1464 # 800088f0 <initcode>
    80001eb0:	6968                	ld	a0,208(a0)
    80001eb2:	fffff097          	auipc	ra,0xfffff
    80001eb6:	4a4080e7          	jalr	1188(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001eba:	6785                	lui	a5,0x1
    80001ebc:	e4fc                	sd	a5,200(s1)
  p->trapframe->epc = 0;     // user program counter
    80001ebe:	6cf8                	ld	a4,216(s1)
    80001ec0:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001ec4:	6cf8                	ld	a4,216(s1)
    80001ec6:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ec8:	4641                	li	a2,16
    80001eca:	00006597          	auipc	a1,0x6
    80001ece:	33658593          	addi	a1,a1,822 # 80008200 <digits+0x1c0>
    80001ed2:	1d848513          	addi	a0,s1,472
    80001ed6:	fffff097          	auipc	ra,0xfffff
    80001eda:	f46080e7          	jalr	-186(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001ede:	00006517          	auipc	a0,0x6
    80001ee2:	33250513          	addi	a0,a0,818 # 80008210 <digits+0x1d0>
    80001ee6:	00003097          	auipc	ra,0x3
    80001eea:	85c080e7          	jalr	-1956(ra) # 80004742 <namei>
    80001eee:	1ca4b823          	sd	a0,464(s1)
  p->state = RUNNABLE;
    80001ef2:	478d                	li	a5,3
    80001ef4:	08f4ac23          	sw	a5,152(s1)
  p->tickets = 1;
    80001ef8:	4785                	li	a5,1
    80001efa:	20f4ac23          	sw	a5,536(s1)
  printf("shell is ready to run\n");
    80001efe:	00006517          	auipc	a0,0x6
    80001f02:	31a50513          	addi	a0,a0,794 # 80008218 <digits+0x1d8>
    80001f06:	ffffe097          	auipc	ra,0xffffe
    80001f0a:	684080e7          	jalr	1668(ra) # 8000058a <printf>
  enqueue(p,0);
    80001f0e:	4581                	li	a1,0
    80001f10:	8526                	mv	a0,s1
    80001f12:	00000097          	auipc	ra,0x0
    80001f16:	97e080e7          	jalr	-1666(ra) # 80001890 <enqueue>
  release(&p->lock);
    80001f1a:	8526                	mv	a0,s1
    80001f1c:	fffff097          	auipc	ra,0xfffff
    80001f20:	d6e080e7          	jalr	-658(ra) # 80000c8a <release>
}
    80001f24:	60e2                	ld	ra,24(sp)
    80001f26:	6442                	ld	s0,16(sp)
    80001f28:	64a2                	ld	s1,8(sp)
    80001f2a:	6105                	addi	sp,sp,32
    80001f2c:	8082                	ret

0000000080001f2e <growproc>:
{
    80001f2e:	1101                	addi	sp,sp,-32
    80001f30:	ec06                	sd	ra,24(sp)
    80001f32:	e822                	sd	s0,16(sp)
    80001f34:	e426                	sd	s1,8(sp)
    80001f36:	e04a                	sd	s2,0(sp)
    80001f38:	1000                	addi	s0,sp,32
    80001f3a:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001f3c:	00000097          	auipc	ra,0x0
    80001f40:	c0a080e7          	jalr	-1014(ra) # 80001b46 <myproc>
    80001f44:	84aa                	mv	s1,a0
  sz = p->sz;
    80001f46:	656c                	ld	a1,200(a0)
  if (n > 0)
    80001f48:	01204c63          	bgtz	s2,80001f60 <growproc+0x32>
  else if (n < 0)
    80001f4c:	02094663          	bltz	s2,80001f78 <growproc+0x4a>
  p->sz = sz;
    80001f50:	e4ec                	sd	a1,200(s1)
  return 0;
    80001f52:	4501                	li	a0,0
}
    80001f54:	60e2                	ld	ra,24(sp)
    80001f56:	6442                	ld	s0,16(sp)
    80001f58:	64a2                	ld	s1,8(sp)
    80001f5a:	6902                	ld	s2,0(sp)
    80001f5c:	6105                	addi	sp,sp,32
    80001f5e:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001f60:	4691                	li	a3,4
    80001f62:	00b90633          	add	a2,s2,a1
    80001f66:	6968                	ld	a0,208(a0)
    80001f68:	fffff097          	auipc	ra,0xfffff
    80001f6c:	4a8080e7          	jalr	1192(ra) # 80001410 <uvmalloc>
    80001f70:	85aa                	mv	a1,a0
    80001f72:	fd79                	bnez	a0,80001f50 <growproc+0x22>
      return -1;
    80001f74:	557d                	li	a0,-1
    80001f76:	bff9                	j	80001f54 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001f78:	00b90633          	add	a2,s2,a1
    80001f7c:	6968                	ld	a0,208(a0)
    80001f7e:	fffff097          	auipc	ra,0xfffff
    80001f82:	44a080e7          	jalr	1098(ra) # 800013c8 <uvmdealloc>
    80001f86:	85aa                	mv	a1,a0
    80001f88:	b7e1                	j	80001f50 <growproc+0x22>

0000000080001f8a <fork>:
{
    80001f8a:	7139                	addi	sp,sp,-64
    80001f8c:	fc06                	sd	ra,56(sp)
    80001f8e:	f822                	sd	s0,48(sp)
    80001f90:	f426                	sd	s1,40(sp)
    80001f92:	f04a                	sd	s2,32(sp)
    80001f94:	ec4e                	sd	s3,24(sp)
    80001f96:	e852                	sd	s4,16(sp)
    80001f98:	e456                	sd	s5,8(sp)
    80001f9a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001f9c:	00000097          	auipc	ra,0x0
    80001fa0:	baa080e7          	jalr	-1110(ra) # 80001b46 <myproc>
    80001fa4:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001fa6:	00000097          	auipc	ra,0x0
    80001faa:	db8080e7          	jalr	-584(ra) # 80001d5e <allocproc>
    80001fae:	12050263          	beqz	a0,800020d2 <fork+0x148>
    80001fb2:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001fb4:	0c8ab603          	ld	a2,200(s5)
    80001fb8:	696c                	ld	a1,208(a0)
    80001fba:	0d0ab503          	ld	a0,208(s5)
    80001fbe:	fffff097          	auipc	ra,0xfffff
    80001fc2:	5aa080e7          	jalr	1450(ra) # 80001568 <uvmcopy>
    80001fc6:	04054863          	bltz	a0,80002016 <fork+0x8c>
  np->sz = p->sz;
    80001fca:	0c8ab783          	ld	a5,200(s5)
    80001fce:	0cf9b423          	sd	a5,200(s3)
  *(np->trapframe) = *(p->trapframe);
    80001fd2:	0d8ab683          	ld	a3,216(s5)
    80001fd6:	87b6                	mv	a5,a3
    80001fd8:	0d89b703          	ld	a4,216(s3)
    80001fdc:	12068693          	addi	a3,a3,288
    80001fe0:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001fe4:	6788                	ld	a0,8(a5)
    80001fe6:	6b8c                	ld	a1,16(a5)
    80001fe8:	6f90                	ld	a2,24(a5)
    80001fea:	01073023          	sd	a6,0(a4)
    80001fee:	e708                	sd	a0,8(a4)
    80001ff0:	eb0c                	sd	a1,16(a4)
    80001ff2:	ef10                	sd	a2,24(a4)
    80001ff4:	02078793          	addi	a5,a5,32
    80001ff8:	02070713          	addi	a4,a4,32
    80001ffc:	fed792e3          	bne	a5,a3,80001fe0 <fork+0x56>
  np->trapframe->a0 = 0;
    80002000:	0d89b783          	ld	a5,216(s3)
    80002004:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80002008:	150a8493          	addi	s1,s5,336
    8000200c:	15098913          	addi	s2,s3,336
    80002010:	1d0a8a13          	addi	s4,s5,464
    80002014:	a00d                	j	80002036 <fork+0xac>
    freeproc(np);
    80002016:	854e                	mv	a0,s3
    80002018:	00000097          	auipc	ra,0x0
    8000201c:	ce0080e7          	jalr	-800(ra) # 80001cf8 <freeproc>
    release(&np->lock);
    80002020:	854e                	mv	a0,s3
    80002022:	fffff097          	auipc	ra,0xfffff
    80002026:	c68080e7          	jalr	-920(ra) # 80000c8a <release>
    return -1;
    8000202a:	597d                	li	s2,-1
    8000202c:	a849                	j	800020be <fork+0x134>
  for (i = 0; i < NOFILE; i++)
    8000202e:	04a1                	addi	s1,s1,8
    80002030:	0921                	addi	s2,s2,8
    80002032:	01448b63          	beq	s1,s4,80002048 <fork+0xbe>
    if (p->ofile[i])
    80002036:	6088                	ld	a0,0(s1)
    80002038:	d97d                	beqz	a0,8000202e <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    8000203a:	00003097          	auipc	ra,0x3
    8000203e:	da2080e7          	jalr	-606(ra) # 80004ddc <filedup>
    80002042:	00a93023          	sd	a0,0(s2)
    80002046:	b7e5                	j	8000202e <fork+0xa4>
  np->cwd = idup(p->cwd);
    80002048:	1d0ab503          	ld	a0,464(s5)
    8000204c:	00002097          	auipc	ra,0x2
    80002050:	f0c080e7          	jalr	-244(ra) # 80003f58 <idup>
    80002054:	1ca9b823          	sd	a0,464(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002058:	4641                	li	a2,16
    8000205a:	1d8a8593          	addi	a1,s5,472
    8000205e:	1d898513          	addi	a0,s3,472
    80002062:	fffff097          	auipc	ra,0xfffff
    80002066:	dba080e7          	jalr	-582(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    8000206a:	0b09a903          	lw	s2,176(s3)
  release(&np->lock);
    8000206e:	854e                	mv	a0,s3
    80002070:	fffff097          	auipc	ra,0xfffff
    80002074:	c1a080e7          	jalr	-998(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80002078:	0000f497          	auipc	s1,0xf
    8000207c:	bb048493          	addi	s1,s1,-1104 # 80010c28 <wait_lock>
    80002080:	8526                	mv	a0,s1
    80002082:	fffff097          	auipc	ra,0xfffff
    80002086:	b54080e7          	jalr	-1196(ra) # 80000bd6 <acquire>
  np->parent = p;
    8000208a:	0b59bc23          	sd	s5,184(s3)
  release(&wait_lock);
    8000208e:	8526                	mv	a0,s1
    80002090:	fffff097          	auipc	ra,0xfffff
    80002094:	bfa080e7          	jalr	-1030(ra) # 80000c8a <release>
  acquire(&np->lock);
    80002098:	854e                	mv	a0,s3
    8000209a:	fffff097          	auipc	ra,0xfffff
    8000209e:	b3c080e7          	jalr	-1220(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    800020a2:	478d                	li	a5,3
    800020a4:	08f9ac23          	sw	a5,152(s3)
  enqueue(np,0);
    800020a8:	4581                	li	a1,0
    800020aa:	854e                	mv	a0,s3
    800020ac:	fffff097          	auipc	ra,0xfffff
    800020b0:	7e4080e7          	jalr	2020(ra) # 80001890 <enqueue>
  release(&np->lock);
    800020b4:	854e                	mv	a0,s3
    800020b6:	fffff097          	auipc	ra,0xfffff
    800020ba:	bd4080e7          	jalr	-1068(ra) # 80000c8a <release>
}
    800020be:	854a                	mv	a0,s2
    800020c0:	70e2                	ld	ra,56(sp)
    800020c2:	7442                	ld	s0,48(sp)
    800020c4:	74a2                	ld	s1,40(sp)
    800020c6:	7902                	ld	s2,32(sp)
    800020c8:	69e2                	ld	s3,24(sp)
    800020ca:	6a42                	ld	s4,16(sp)
    800020cc:	6aa2                	ld	s5,8(sp)
    800020ce:	6121                	addi	sp,sp,64
    800020d0:	8082                	ret
    return -1;
    800020d2:	597d                	li	s2,-1
    800020d4:	b7ed                	j	800020be <fork+0x134>

00000000800020d6 <scheduler>:
{
    800020d6:	711d                	addi	sp,sp,-96
    800020d8:	ec86                	sd	ra,88(sp)
    800020da:	e8a2                	sd	s0,80(sp)
    800020dc:	e4a6                	sd	s1,72(sp)
    800020de:	e0ca                	sd	s2,64(sp)
    800020e0:	fc4e                	sd	s3,56(sp)
    800020e2:	f852                	sd	s4,48(sp)
    800020e4:	f456                	sd	s5,40(sp)
    800020e6:	f05a                	sd	s6,32(sp)
    800020e8:	ec5e                	sd	s7,24(sp)
    800020ea:	e862                	sd	s8,16(sp)
    800020ec:	e466                	sd	s9,8(sp)
    800020ee:	1080                	addi	s0,sp,96
    800020f0:	8792                	mv	a5,tp
  int id = r_tp();
    800020f2:	2781                	sext.w	a5,a5
  c->proc = 0;
    800020f4:	00779693          	slli	a3,a5,0x7
    800020f8:	0000f717          	auipc	a4,0xf
    800020fc:	b0870713          	addi	a4,a4,-1272 # 80010c00 <sizeofq>
    80002100:	9736                	add	a4,a4,a3
    80002102:	04073023          	sd	zero,64(a4)
        swtch(&c->context, &p->context);
    80002106:	0000f717          	auipc	a4,0xf
    8000210a:	b4270713          	addi	a4,a4,-1214 # 80010c48 <cpus+0x8>
    8000210e:	00e68cb3          	add	s9,a3,a4
    80002112:	0000fa97          	auipc	s5,0xf
    80002116:	f2ea8a93          	addi	s5,s5,-210 # 80011040 <multique>
    8000211a:	008a8a13          	addi	s4,s5,8
    for (int level = 0; level <= 3; level++)
    8000211e:	10000b13          	li	s6,256
        c->proc = p;
    80002122:	0000fb97          	auipc	s7,0xf
    80002126:	adeb8b93          	addi	s7,s7,-1314 # 80010c00 <sizeofq>
    8000212a:	9bb6                	add	s7,s7,a3
    8000212c:	a0f9                	j	800021fa <scheduler+0x124>
      release(&temp->lock);
    8000212e:	8526                	mv	a0,s1
    80002130:	fffff097          	auipc	ra,0xfffff
    80002134:	b5a080e7          	jalr	-1190(ra) # 80000c8a <release>
    for (temp = proc; temp < &proc[NPROC]; temp++)
    80002138:	23848493          	addi	s1,s1,568
    8000213c:	03348763          	beq	s1,s3,8000216a <scheduler+0x94>
      acquire(&temp->lock);
    80002140:	8526                	mv	a0,s1
    80002142:	fffff097          	auipc	ra,0xfffff
    80002146:	a94080e7          	jalr	-1388(ra) # 80000bd6 <acquire>
      if (temp->state == RUNNABLE)
    8000214a:	0984a783          	lw	a5,152(s1)
    8000214e:	ff2790e3          	bne	a5,s2,8000212e <scheduler+0x58>
        int old_ticks = temp->queueticks;
    80002152:	2304ac03          	lw	s8,560(s1)
        enqueue(temp,temp->queue_number);
    80002156:	2244a583          	lw	a1,548(s1)
    8000215a:	8526                	mv	a0,s1
    8000215c:	fffff097          	auipc	ra,0xfffff
    80002160:	734080e7          	jalr	1844(ra) # 80001890 <enqueue>
        temp->queueticks = old_ticks;
    80002164:	2384a823          	sw	s8,560(s1)
    80002168:	b7d9                	j	8000212e <scheduler+0x58>
    8000216a:	0000f597          	auipc	a1,0xf
    8000216e:	a9658593          	addi	a1,a1,-1386 # 80010c00 <sizeofq>
    for (temp = proc; temp < &proc[NPROC]; temp++)
    80002172:	8556                	mv	a0,s5
    80002174:	4601                	li	a2,0
      for (int j = 0; j < sizeofq[level]; j++)
    80002176:	419c                	lw	a5,0(a1)
    80002178:	02f05263          	blez	a5,8000219c <scheduler+0xc6>
    8000217c:	fff7871b          	addiw	a4,a5,-1
    80002180:	1702                	slli	a4,a4,0x20
    80002182:	9301                	srli	a4,a4,0x20
    80002184:	9732                	add	a4,a4,a2
    80002186:	070e                	slli	a4,a4,0x3
    80002188:	9752                	add	a4,a4,s4
    8000218a:	87aa                	mv	a5,a0
        if(multique[level][j]->state==RUNNABLE) {
    8000218c:	6384                	ld	s1,0(a5)
    8000218e:	0984a683          	lw	a3,152(s1)
    80002192:	03268763          	beq	a3,s2,800021c0 <scheduler+0xea>
      for (int j = 0; j < sizeofq[level]; j++)
    80002196:	07a1                	addi	a5,a5,8
    80002198:	fee79ae3          	bne	a5,a4,8000218c <scheduler+0xb6>
    for (int level = 0; level <= 3; level++)
    8000219c:	0591                	addi	a1,a1,4
    8000219e:	20050513          	addi	a0,a0,512
    800021a2:	04060613          	addi	a2,a2,64 # 1040 <_entry-0x7fffefc0>
    800021a6:	fd6618e3          	bne	a2,s6,80002176 <scheduler+0xa0>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800021aa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800021ae:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800021b2:	10079073          	csrw	sstatus,a5
    for (temp = proc; temp < &proc[NPROC]; temp++)
    800021b6:	0000f497          	auipc	s1,0xf
    800021ba:	68a48493          	addi	s1,s1,1674 # 80011840 <proc>
    800021be:	b749                	j	80002140 <scheduler+0x6a>
      acquire(&p->lock);
    800021c0:	8526                	mv	a0,s1
    800021c2:	fffff097          	auipc	ra,0xfffff
    800021c6:	a14080e7          	jalr	-1516(ra) # 80000bd6 <acquire>
      if (p->state == RUNNABLE)
    800021ca:	0984a703          	lw	a4,152(s1)
    800021ce:	478d                	li	a5,3
    800021d0:	02f71063          	bne	a4,a5,800021f0 <scheduler+0x11a>
        p->state = RUNNING;
    800021d4:	4791                	li	a5,4
    800021d6:	08f4ac23          	sw	a5,152(s1)
        c->proc = p;
    800021da:	049bb023          	sd	s1,64(s7)
        swtch(&c->context, &p->context);
    800021de:	0e048593          	addi	a1,s1,224
    800021e2:	8566                	mv	a0,s9
    800021e4:	00001097          	auipc	ra,0x1
    800021e8:	91c080e7          	jalr	-1764(ra) # 80002b00 <swtch>
        c->proc =0;
    800021ec:	040bb023          	sd	zero,64(s7)
      release(&p->lock);
    800021f0:	8526                	mv	a0,s1
    800021f2:	fffff097          	auipc	ra,0xfffff
    800021f6:	a98080e7          	jalr	-1384(ra) # 80000c8a <release>
      if (temp->state == RUNNABLE)
    800021fa:	490d                	li	s2,3
    for (temp = proc; temp < &proc[NPROC]; temp++)
    800021fc:	00018997          	auipc	s3,0x18
    80002200:	44498993          	addi	s3,s3,1092 # 8001a640 <tickslock>
    80002204:	b75d                	j	800021aa <scheduler+0xd4>

0000000080002206 <sched>:
{
    80002206:	7179                	addi	sp,sp,-48
    80002208:	f406                	sd	ra,40(sp)
    8000220a:	f022                	sd	s0,32(sp)
    8000220c:	ec26                	sd	s1,24(sp)
    8000220e:	e84a                	sd	s2,16(sp)
    80002210:	e44e                	sd	s3,8(sp)
    80002212:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002214:	00000097          	auipc	ra,0x0
    80002218:	932080e7          	jalr	-1742(ra) # 80001b46 <myproc>
    8000221c:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    8000221e:	fffff097          	auipc	ra,0xfffff
    80002222:	93e080e7          	jalr	-1730(ra) # 80000b5c <holding>
    80002226:	cd25                	beqz	a0,8000229e <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002228:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    8000222a:	2781                	sext.w	a5,a5
    8000222c:	079e                	slli	a5,a5,0x7
    8000222e:	0000f717          	auipc	a4,0xf
    80002232:	9d270713          	addi	a4,a4,-1582 # 80010c00 <sizeofq>
    80002236:	97ba                	add	a5,a5,a4
    80002238:	0b87a703          	lw	a4,184(a5)
    8000223c:	4785                	li	a5,1
    8000223e:	06f71863          	bne	a4,a5,800022ae <sched+0xa8>
  if (p->state == RUNNING)
    80002242:	0984a703          	lw	a4,152(s1)
    80002246:	4791                	li	a5,4
    80002248:	06f70b63          	beq	a4,a5,800022be <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000224c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002250:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002252:	efb5                	bnez	a5,800022ce <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002254:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002256:	0000f917          	auipc	s2,0xf
    8000225a:	9aa90913          	addi	s2,s2,-1622 # 80010c00 <sizeofq>
    8000225e:	2781                	sext.w	a5,a5
    80002260:	079e                	slli	a5,a5,0x7
    80002262:	97ca                	add	a5,a5,s2
    80002264:	0bc7a983          	lw	s3,188(a5)
    80002268:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000226a:	2781                	sext.w	a5,a5
    8000226c:	079e                	slli	a5,a5,0x7
    8000226e:	0000f597          	auipc	a1,0xf
    80002272:	9da58593          	addi	a1,a1,-1574 # 80010c48 <cpus+0x8>
    80002276:	95be                	add	a1,a1,a5
    80002278:	0e048513          	addi	a0,s1,224
    8000227c:	00001097          	auipc	ra,0x1
    80002280:	884080e7          	jalr	-1916(ra) # 80002b00 <swtch>
    80002284:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002286:	2781                	sext.w	a5,a5
    80002288:	079e                	slli	a5,a5,0x7
    8000228a:	993e                	add	s2,s2,a5
    8000228c:	0b392e23          	sw	s3,188(s2)
}
    80002290:	70a2                	ld	ra,40(sp)
    80002292:	7402                	ld	s0,32(sp)
    80002294:	64e2                	ld	s1,24(sp)
    80002296:	6942                	ld	s2,16(sp)
    80002298:	69a2                	ld	s3,8(sp)
    8000229a:	6145                	addi	sp,sp,48
    8000229c:	8082                	ret
    panic("sched p->lock");
    8000229e:	00006517          	auipc	a0,0x6
    800022a2:	f9250513          	addi	a0,a0,-110 # 80008230 <digits+0x1f0>
    800022a6:	ffffe097          	auipc	ra,0xffffe
    800022aa:	29a080e7          	jalr	666(ra) # 80000540 <panic>
    panic("sched locks");
    800022ae:	00006517          	auipc	a0,0x6
    800022b2:	f9250513          	addi	a0,a0,-110 # 80008240 <digits+0x200>
    800022b6:	ffffe097          	auipc	ra,0xffffe
    800022ba:	28a080e7          	jalr	650(ra) # 80000540 <panic>
    panic("sched running");
    800022be:	00006517          	auipc	a0,0x6
    800022c2:	f9250513          	addi	a0,a0,-110 # 80008250 <digits+0x210>
    800022c6:	ffffe097          	auipc	ra,0xffffe
    800022ca:	27a080e7          	jalr	634(ra) # 80000540 <panic>
    panic("sched interruptible");
    800022ce:	00006517          	auipc	a0,0x6
    800022d2:	f9250513          	addi	a0,a0,-110 # 80008260 <digits+0x220>
    800022d6:	ffffe097          	auipc	ra,0xffffe
    800022da:	26a080e7          	jalr	618(ra) # 80000540 <panic>

00000000800022de <yield>:
{
    800022de:	1101                	addi	sp,sp,-32
    800022e0:	ec06                	sd	ra,24(sp)
    800022e2:	e822                	sd	s0,16(sp)
    800022e4:	e426                	sd	s1,8(sp)
    800022e6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800022e8:	00000097          	auipc	ra,0x0
    800022ec:	85e080e7          	jalr	-1954(ra) # 80001b46 <myproc>
    800022f0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022f2:	fffff097          	auipc	ra,0xfffff
    800022f6:	8e4080e7          	jalr	-1820(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    800022fa:	478d                	li	a5,3
    800022fc:	08f4ac23          	sw	a5,152(s1)
  sched();
    80002300:	00000097          	auipc	ra,0x0
    80002304:	f06080e7          	jalr	-250(ra) # 80002206 <sched>
  release(&p->lock);
    80002308:	8526                	mv	a0,s1
    8000230a:	fffff097          	auipc	ra,0xfffff
    8000230e:	980080e7          	jalr	-1664(ra) # 80000c8a <release>
}
    80002312:	60e2                	ld	ra,24(sp)
    80002314:	6442                	ld	s0,16(sp)
    80002316:	64a2                	ld	s1,8(sp)
    80002318:	6105                	addi	sp,sp,32
    8000231a:	8082                	ret

000000008000231c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    8000231c:	7179                	addi	sp,sp,-48
    8000231e:	f406                	sd	ra,40(sp)
    80002320:	f022                	sd	s0,32(sp)
    80002322:	ec26                	sd	s1,24(sp)
    80002324:	e84a                	sd	s2,16(sp)
    80002326:	e44e                	sd	s3,8(sp)
    80002328:	1800                	addi	s0,sp,48
    8000232a:	89aa                	mv	s3,a0
    8000232c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000232e:	00000097          	auipc	ra,0x0
    80002332:	818080e7          	jalr	-2024(ra) # 80001b46 <myproc>
    80002336:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002338:	fffff097          	auipc	ra,0xfffff
    8000233c:	89e080e7          	jalr	-1890(ra) # 80000bd6 <acquire>
  release(lk);
    80002340:	854a                	mv	a0,s2
    80002342:	fffff097          	auipc	ra,0xfffff
    80002346:	948080e7          	jalr	-1720(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    8000234a:	0b34b023          	sd	s3,160(s1)
  p->state = SLEEPING;
    8000234e:	4789                	li	a5,2
    80002350:	08f4ac23          	sw	a5,152(s1)
  dequeue(p, p->queue_number);
    80002354:	2244a583          	lw	a1,548(s1)
    80002358:	8526                	mv	a0,s1
    8000235a:	fffff097          	auipc	ra,0xfffff
    8000235e:	5c4080e7          	jalr	1476(ra) # 8000191e <dequeue>

  sched();
    80002362:	00000097          	auipc	ra,0x0
    80002366:	ea4080e7          	jalr	-348(ra) # 80002206 <sched>

  // Tidy up.
  p->chan = 0;
    8000236a:	0a04b023          	sd	zero,160(s1)
  
  // Reacquire original lock.
  release(&p->lock);
    8000236e:	8526                	mv	a0,s1
    80002370:	fffff097          	auipc	ra,0xfffff
    80002374:	91a080e7          	jalr	-1766(ra) # 80000c8a <release>
  acquire(lk);
    80002378:	854a                	mv	a0,s2
    8000237a:	fffff097          	auipc	ra,0xfffff
    8000237e:	85c080e7          	jalr	-1956(ra) # 80000bd6 <acquire>
}
    80002382:	70a2                	ld	ra,40(sp)
    80002384:	7402                	ld	s0,32(sp)
    80002386:	64e2                	ld	s1,24(sp)
    80002388:	6942                	ld	s2,16(sp)
    8000238a:	69a2                	ld	s3,8(sp)
    8000238c:	6145                	addi	sp,sp,48
    8000238e:	8082                	ret

0000000080002390 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002390:	7139                	addi	sp,sp,-64
    80002392:	fc06                	sd	ra,56(sp)
    80002394:	f822                	sd	s0,48(sp)
    80002396:	f426                	sd	s1,40(sp)
    80002398:	f04a                	sd	s2,32(sp)
    8000239a:	ec4e                	sd	s3,24(sp)
    8000239c:	e852                	sd	s4,16(sp)
    8000239e:	e456                	sd	s5,8(sp)
    800023a0:	e05a                	sd	s6,0(sp)
    800023a2:	0080                	addi	s0,sp,64
    800023a4:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800023a6:	0000f497          	auipc	s1,0xf
    800023aa:	49a48493          	addi	s1,s1,1178 # 80011840 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    800023ae:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    800023b0:	4b0d                	li	s6,3
  for (p = proc; p < &proc[NPROC]; p++)
    800023b2:	00018917          	auipc	s2,0x18
    800023b6:	28e90913          	addi	s2,s2,654 # 8001a640 <tickslock>
    800023ba:	a811                	j	800023ce <wakeup+0x3e>
        int old_ticks = p->queueticks;
        enqueue(p,p->queue_number);
        p->queueticks = old_ticks;
      }
      release(&p->lock);
    800023bc:	8526                	mv	a0,s1
    800023be:	fffff097          	auipc	ra,0xfffff
    800023c2:	8cc080e7          	jalr	-1844(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800023c6:	23848493          	addi	s1,s1,568
    800023ca:	05248263          	beq	s1,s2,8000240e <wakeup+0x7e>
    if (p != myproc())
    800023ce:	fffff097          	auipc	ra,0xfffff
    800023d2:	778080e7          	jalr	1912(ra) # 80001b46 <myproc>
    800023d6:	fea488e3          	beq	s1,a0,800023c6 <wakeup+0x36>
      acquire(&p->lock);
    800023da:	8526                	mv	a0,s1
    800023dc:	ffffe097          	auipc	ra,0xffffe
    800023e0:	7fa080e7          	jalr	2042(ra) # 80000bd6 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    800023e4:	0984a783          	lw	a5,152(s1)
    800023e8:	fd379ae3          	bne	a5,s3,800023bc <wakeup+0x2c>
    800023ec:	70dc                	ld	a5,160(s1)
    800023ee:	fd4797e3          	bne	a5,s4,800023bc <wakeup+0x2c>
        p->state = RUNNABLE;
    800023f2:	0964ac23          	sw	s6,152(s1)
        int old_ticks = p->queueticks;
    800023f6:	2304aa83          	lw	s5,560(s1)
        enqueue(p,p->queue_number);
    800023fa:	2244a583          	lw	a1,548(s1)
    800023fe:	8526                	mv	a0,s1
    80002400:	fffff097          	auipc	ra,0xfffff
    80002404:	490080e7          	jalr	1168(ra) # 80001890 <enqueue>
        p->queueticks = old_ticks;
    80002408:	2354a823          	sw	s5,560(s1)
    8000240c:	bf45                	j	800023bc <wakeup+0x2c>
    }
  }
}
    8000240e:	70e2                	ld	ra,56(sp)
    80002410:	7442                	ld	s0,48(sp)
    80002412:	74a2                	ld	s1,40(sp)
    80002414:	7902                	ld	s2,32(sp)
    80002416:	69e2                	ld	s3,24(sp)
    80002418:	6a42                	ld	s4,16(sp)
    8000241a:	6aa2                	ld	s5,8(sp)
    8000241c:	6b02                	ld	s6,0(sp)
    8000241e:	6121                	addi	sp,sp,64
    80002420:	8082                	ret

0000000080002422 <reparent>:
{
    80002422:	7179                	addi	sp,sp,-48
    80002424:	f406                	sd	ra,40(sp)
    80002426:	f022                	sd	s0,32(sp)
    80002428:	ec26                	sd	s1,24(sp)
    8000242a:	e84a                	sd	s2,16(sp)
    8000242c:	e44e                	sd	s3,8(sp)
    8000242e:	e052                	sd	s4,0(sp)
    80002430:	1800                	addi	s0,sp,48
    80002432:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002434:	0000f497          	auipc	s1,0xf
    80002438:	40c48493          	addi	s1,s1,1036 # 80011840 <proc>
      pp->parent = initproc;
    8000243c:	00006a17          	auipc	s4,0x6
    80002440:	54ca0a13          	addi	s4,s4,1356 # 80008988 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002444:	00018997          	auipc	s3,0x18
    80002448:	1fc98993          	addi	s3,s3,508 # 8001a640 <tickslock>
    8000244c:	a029                	j	80002456 <reparent+0x34>
    8000244e:	23848493          	addi	s1,s1,568
    80002452:	01348d63          	beq	s1,s3,8000246c <reparent+0x4a>
    if (pp->parent == p)
    80002456:	7cdc                	ld	a5,184(s1)
    80002458:	ff279be3          	bne	a5,s2,8000244e <reparent+0x2c>
      pp->parent = initproc;
    8000245c:	000a3503          	ld	a0,0(s4)
    80002460:	fcc8                	sd	a0,184(s1)
      wakeup(initproc);
    80002462:	00000097          	auipc	ra,0x0
    80002466:	f2e080e7          	jalr	-210(ra) # 80002390 <wakeup>
    8000246a:	b7d5                	j	8000244e <reparent+0x2c>
}
    8000246c:	70a2                	ld	ra,40(sp)
    8000246e:	7402                	ld	s0,32(sp)
    80002470:	64e2                	ld	s1,24(sp)
    80002472:	6942                	ld	s2,16(sp)
    80002474:	69a2                	ld	s3,8(sp)
    80002476:	6a02                	ld	s4,0(sp)
    80002478:	6145                	addi	sp,sp,48
    8000247a:	8082                	ret

000000008000247c <exit>:
{
    8000247c:	7179                	addi	sp,sp,-48
    8000247e:	f406                	sd	ra,40(sp)
    80002480:	f022                	sd	s0,32(sp)
    80002482:	ec26                	sd	s1,24(sp)
    80002484:	e84a                	sd	s2,16(sp)
    80002486:	e44e                	sd	s3,8(sp)
    80002488:	e052                	sd	s4,0(sp)
    8000248a:	1800                	addi	s0,sp,48
    8000248c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000248e:	fffff097          	auipc	ra,0xfffff
    80002492:	6b8080e7          	jalr	1720(ra) # 80001b46 <myproc>
    80002496:	89aa                	mv	s3,a0
  if (p == initproc)
    80002498:	00006797          	auipc	a5,0x6
    8000249c:	4f07b783          	ld	a5,1264(a5) # 80008988 <initproc>
    800024a0:	15050493          	addi	s1,a0,336
    800024a4:	1d050913          	addi	s2,a0,464
    800024a8:	02a79363          	bne	a5,a0,800024ce <exit+0x52>
    panic("init exiting");
    800024ac:	00006517          	auipc	a0,0x6
    800024b0:	dcc50513          	addi	a0,a0,-564 # 80008278 <digits+0x238>
    800024b4:	ffffe097          	auipc	ra,0xffffe
    800024b8:	08c080e7          	jalr	140(ra) # 80000540 <panic>
      fileclose(f);
    800024bc:	00003097          	auipc	ra,0x3
    800024c0:	972080e7          	jalr	-1678(ra) # 80004e2e <fileclose>
      p->ofile[fd] = 0;
    800024c4:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    800024c8:	04a1                	addi	s1,s1,8
    800024ca:	01248563          	beq	s1,s2,800024d4 <exit+0x58>
    if (p->ofile[fd])
    800024ce:	6088                	ld	a0,0(s1)
    800024d0:	f575                	bnez	a0,800024bc <exit+0x40>
    800024d2:	bfdd                	j	800024c8 <exit+0x4c>
  begin_op();
    800024d4:	00002097          	auipc	ra,0x2
    800024d8:	48e080e7          	jalr	1166(ra) # 80004962 <begin_op>
  iput(p->cwd);
    800024dc:	1d09b503          	ld	a0,464(s3)
    800024e0:	00002097          	auipc	ra,0x2
    800024e4:	c70080e7          	jalr	-912(ra) # 80004150 <iput>
  end_op();
    800024e8:	00002097          	auipc	ra,0x2
    800024ec:	4f8080e7          	jalr	1272(ra) # 800049e0 <end_op>
  p->cwd = 0;
    800024f0:	1c09b823          	sd	zero,464(s3)
  acquire(&wait_lock);
    800024f4:	0000e497          	auipc	s1,0xe
    800024f8:	73448493          	addi	s1,s1,1844 # 80010c28 <wait_lock>
    800024fc:	8526                	mv	a0,s1
    800024fe:	ffffe097          	auipc	ra,0xffffe
    80002502:	6d8080e7          	jalr	1752(ra) # 80000bd6 <acquire>
  reparent(p);
    80002506:	854e                	mv	a0,s3
    80002508:	00000097          	auipc	ra,0x0
    8000250c:	f1a080e7          	jalr	-230(ra) # 80002422 <reparent>
  wakeup(p->parent);
    80002510:	0b89b503          	ld	a0,184(s3)
    80002514:	00000097          	auipc	ra,0x0
    80002518:	e7c080e7          	jalr	-388(ra) # 80002390 <wakeup>
  acquire(&p->lock);
    8000251c:	854e                	mv	a0,s3
    8000251e:	ffffe097          	auipc	ra,0xffffe
    80002522:	6b8080e7          	jalr	1720(ra) # 80000bd6 <acquire>
  p->xstate = status;
    80002526:	0b49a623          	sw	s4,172(s3)
  p->state = ZOMBIE;
    8000252a:	4795                	li	a5,5
    8000252c:	08f9ac23          	sw	a5,152(s3)
  p->etime = ticks;
    80002530:	00006797          	auipc	a5,0x6
    80002534:	4607a783          	lw	a5,1120(a5) # 80008990 <ticks>
    80002538:	1ef9a823          	sw	a5,496(s3)
  dequeue(p, p->queue_number);
    8000253c:	2249a583          	lw	a1,548(s3)
    80002540:	854e                	mv	a0,s3
    80002542:	fffff097          	auipc	ra,0xfffff
    80002546:	3dc080e7          	jalr	988(ra) # 8000191e <dequeue>
  release(&wait_lock);
    8000254a:	8526                	mv	a0,s1
    8000254c:	ffffe097          	auipc	ra,0xffffe
    80002550:	73e080e7          	jalr	1854(ra) # 80000c8a <release>
  sched();
    80002554:	00000097          	auipc	ra,0x0
    80002558:	cb2080e7          	jalr	-846(ra) # 80002206 <sched>
  panic("zombie exit");
    8000255c:	00006517          	auipc	a0,0x6
    80002560:	d2c50513          	addi	a0,a0,-724 # 80008288 <digits+0x248>
    80002564:	ffffe097          	auipc	ra,0xffffe
    80002568:	fdc080e7          	jalr	-36(ra) # 80000540 <panic>

000000008000256c <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    8000256c:	7179                	addi	sp,sp,-48
    8000256e:	f406                	sd	ra,40(sp)
    80002570:	f022                	sd	s0,32(sp)
    80002572:	ec26                	sd	s1,24(sp)
    80002574:	e84a                	sd	s2,16(sp)
    80002576:	e44e                	sd	s3,8(sp)
    80002578:	1800                	addi	s0,sp,48
    8000257a:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000257c:	0000f497          	auipc	s1,0xf
    80002580:	2c448493          	addi	s1,s1,708 # 80011840 <proc>
    80002584:	00018997          	auipc	s3,0x18
    80002588:	0bc98993          	addi	s3,s3,188 # 8001a640 <tickslock>
  {
    acquire(&p->lock);
    8000258c:	8526                	mv	a0,s1
    8000258e:	ffffe097          	auipc	ra,0xffffe
    80002592:	648080e7          	jalr	1608(ra) # 80000bd6 <acquire>
    if (p->pid == pid)
    80002596:	0b04a783          	lw	a5,176(s1)
    8000259a:	01278d63          	beq	a5,s2,800025b4 <kill+0x48>
        enqueue(p, p->queue_number);
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000259e:	8526                	mv	a0,s1
    800025a0:	ffffe097          	auipc	ra,0xffffe
    800025a4:	6ea080e7          	jalr	1770(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800025a8:	23848493          	addi	s1,s1,568
    800025ac:	ff3490e3          	bne	s1,s3,8000258c <kill+0x20>
  }
  return -1;
    800025b0:	557d                	li	a0,-1
    800025b2:	a839                	j	800025d0 <kill+0x64>
      p->killed = 1;
    800025b4:	4785                	li	a5,1
    800025b6:	0af4a423          	sw	a5,168(s1)
      if (p->state == SLEEPING)
    800025ba:	0984a703          	lw	a4,152(s1)
    800025be:	4789                	li	a5,2
    800025c0:	00f70f63          	beq	a4,a5,800025de <kill+0x72>
      release(&p->lock);
    800025c4:	8526                	mv	a0,s1
    800025c6:	ffffe097          	auipc	ra,0xffffe
    800025ca:	6c4080e7          	jalr	1732(ra) # 80000c8a <release>
      return 0;
    800025ce:	4501                	li	a0,0
}
    800025d0:	70a2                	ld	ra,40(sp)
    800025d2:	7402                	ld	s0,32(sp)
    800025d4:	64e2                	ld	s1,24(sp)
    800025d6:	6942                	ld	s2,16(sp)
    800025d8:	69a2                	ld	s3,8(sp)
    800025da:	6145                	addi	sp,sp,48
    800025dc:	8082                	ret
        p->state = RUNNABLE;
    800025de:	478d                	li	a5,3
    800025e0:	08f4ac23          	sw	a5,152(s1)
        enqueue(p, p->queue_number);
    800025e4:	2244a583          	lw	a1,548(s1)
    800025e8:	8526                	mv	a0,s1
    800025ea:	fffff097          	auipc	ra,0xfffff
    800025ee:	2a6080e7          	jalr	678(ra) # 80001890 <enqueue>
    800025f2:	bfc9                	j	800025c4 <kill+0x58>

00000000800025f4 <setkilled>:

void setkilled(struct proc *p)
{
    800025f4:	1101                	addi	sp,sp,-32
    800025f6:	ec06                	sd	ra,24(sp)
    800025f8:	e822                	sd	s0,16(sp)
    800025fa:	e426                	sd	s1,8(sp)
    800025fc:	1000                	addi	s0,sp,32
    800025fe:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002600:	ffffe097          	auipc	ra,0xffffe
    80002604:	5d6080e7          	jalr	1494(ra) # 80000bd6 <acquire>
  p->killed = 1;
    80002608:	4785                	li	a5,1
    8000260a:	0af4a423          	sw	a5,168(s1)
  release(&p->lock);
    8000260e:	8526                	mv	a0,s1
    80002610:	ffffe097          	auipc	ra,0xffffe
    80002614:	67a080e7          	jalr	1658(ra) # 80000c8a <release>
}
    80002618:	60e2                	ld	ra,24(sp)
    8000261a:	6442                	ld	s0,16(sp)
    8000261c:	64a2                	ld	s1,8(sp)
    8000261e:	6105                	addi	sp,sp,32
    80002620:	8082                	ret

0000000080002622 <killed>:

int killed(struct proc *p)
{
    80002622:	1101                	addi	sp,sp,-32
    80002624:	ec06                	sd	ra,24(sp)
    80002626:	e822                	sd	s0,16(sp)
    80002628:	e426                	sd	s1,8(sp)
    8000262a:	e04a                	sd	s2,0(sp)
    8000262c:	1000                	addi	s0,sp,32
    8000262e:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002630:	ffffe097          	auipc	ra,0xffffe
    80002634:	5a6080e7          	jalr	1446(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002638:	0a84a903          	lw	s2,168(s1)
  release(&p->lock);
    8000263c:	8526                	mv	a0,s1
    8000263e:	ffffe097          	auipc	ra,0xffffe
    80002642:	64c080e7          	jalr	1612(ra) # 80000c8a <release>
  return k;
}
    80002646:	854a                	mv	a0,s2
    80002648:	60e2                	ld	ra,24(sp)
    8000264a:	6442                	ld	s0,16(sp)
    8000264c:	64a2                	ld	s1,8(sp)
    8000264e:	6902                	ld	s2,0(sp)
    80002650:	6105                	addi	sp,sp,32
    80002652:	8082                	ret

0000000080002654 <wait>:
{
    80002654:	715d                	addi	sp,sp,-80
    80002656:	e486                	sd	ra,72(sp)
    80002658:	e0a2                	sd	s0,64(sp)
    8000265a:	fc26                	sd	s1,56(sp)
    8000265c:	f84a                	sd	s2,48(sp)
    8000265e:	f44e                	sd	s3,40(sp)
    80002660:	f052                	sd	s4,32(sp)
    80002662:	ec56                	sd	s5,24(sp)
    80002664:	e85a                	sd	s6,16(sp)
    80002666:	e45e                	sd	s7,8(sp)
    80002668:	e062                	sd	s8,0(sp)
    8000266a:	0880                	addi	s0,sp,80
    8000266c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000266e:	fffff097          	auipc	ra,0xfffff
    80002672:	4d8080e7          	jalr	1240(ra) # 80001b46 <myproc>
    80002676:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002678:	0000e517          	auipc	a0,0xe
    8000267c:	5b050513          	addi	a0,a0,1456 # 80010c28 <wait_lock>
    80002680:	ffffe097          	auipc	ra,0xffffe
    80002684:	556080e7          	jalr	1366(ra) # 80000bd6 <acquire>
    havekids = 0;
    80002688:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    8000268a:	4a95                	li	s5,5
        havekids = 1;
    8000268c:	4b05                	li	s6,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000268e:	00018997          	auipc	s3,0x18
    80002692:	fb298993          	addi	s3,s3,-78 # 8001a640 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002696:	0000ec17          	auipc	s8,0xe
    8000269a:	592c0c13          	addi	s8,s8,1426 # 80010c28 <wait_lock>
    havekids = 0;
    8000269e:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800026a0:	0000f497          	auipc	s1,0xf
    800026a4:	1a048493          	addi	s1,s1,416 # 80011840 <proc>
    800026a8:	a069                	j	80002732 <wait+0xde>
    800026aa:	01890793          	addi	a5,s2,24
    800026ae:	01848693          	addi	a3,s1,24
    800026b2:	09890593          	addi	a1,s2,152
            p->syscall_count[i] += pp->syscall_count[i];
    800026b6:	4390                	lw	a2,0(a5)
    800026b8:	4298                	lw	a4,0(a3)
    800026ba:	9f31                	addw	a4,a4,a2
    800026bc:	c398                	sw	a4,0(a5)
          for (int i = 0; i < 32; i++)
    800026be:	0791                	addi	a5,a5,4
    800026c0:	0691                	addi	a3,a3,4
    800026c2:	feb79ae3          	bne	a5,a1,800026b6 <wait+0x62>
          pid = pp->pid;
    800026c6:	0b04a983          	lw	s3,176(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800026ca:	000a0e63          	beqz	s4,800026e6 <wait+0x92>
    800026ce:	4691                	li	a3,4
    800026d0:	0ac48613          	addi	a2,s1,172
    800026d4:	85d2                	mv	a1,s4
    800026d6:	0d093503          	ld	a0,208(s2)
    800026da:	fffff097          	auipc	ra,0xfffff
    800026de:	f92080e7          	jalr	-110(ra) # 8000166c <copyout>
    800026e2:	02054563          	bltz	a0,8000270c <wait+0xb8>
          freeproc(pp);
    800026e6:	8526                	mv	a0,s1
    800026e8:	fffff097          	auipc	ra,0xfffff
    800026ec:	610080e7          	jalr	1552(ra) # 80001cf8 <freeproc>
          release(&pp->lock);
    800026f0:	8526                	mv	a0,s1
    800026f2:	ffffe097          	auipc	ra,0xffffe
    800026f6:	598080e7          	jalr	1432(ra) # 80000c8a <release>
          release(&wait_lock);
    800026fa:	0000e517          	auipc	a0,0xe
    800026fe:	52e50513          	addi	a0,a0,1326 # 80010c28 <wait_lock>
    80002702:	ffffe097          	auipc	ra,0xffffe
    80002706:	588080e7          	jalr	1416(ra) # 80000c8a <release>
          return pid;
    8000270a:	a0bd                	j	80002778 <wait+0x124>
            release(&pp->lock);
    8000270c:	8526                	mv	a0,s1
    8000270e:	ffffe097          	auipc	ra,0xffffe
    80002712:	57c080e7          	jalr	1404(ra) # 80000c8a <release>
            release(&wait_lock);
    80002716:	0000e517          	auipc	a0,0xe
    8000271a:	51250513          	addi	a0,a0,1298 # 80010c28 <wait_lock>
    8000271e:	ffffe097          	auipc	ra,0xffffe
    80002722:	56c080e7          	jalr	1388(ra) # 80000c8a <release>
            return -1;
    80002726:	59fd                	li	s3,-1
    80002728:	a881                	j	80002778 <wait+0x124>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000272a:	23848493          	addi	s1,s1,568
    8000272e:	03348563          	beq	s1,s3,80002758 <wait+0x104>
      if (pp->parent == p)
    80002732:	7cdc                	ld	a5,184(s1)
    80002734:	ff279be3          	bne	a5,s2,8000272a <wait+0xd6>
        acquire(&pp->lock);
    80002738:	8526                	mv	a0,s1
    8000273a:	ffffe097          	auipc	ra,0xffffe
    8000273e:	49c080e7          	jalr	1180(ra) # 80000bd6 <acquire>
        if (pp->state == ZOMBIE)
    80002742:	0984a783          	lw	a5,152(s1)
    80002746:	f75782e3          	beq	a5,s5,800026aa <wait+0x56>
        release(&pp->lock);
    8000274a:	8526                	mv	a0,s1
    8000274c:	ffffe097          	auipc	ra,0xffffe
    80002750:	53e080e7          	jalr	1342(ra) # 80000c8a <release>
        havekids = 1;
    80002754:	875a                	mv	a4,s6
    80002756:	bfd1                	j	8000272a <wait+0xd6>
    if (!havekids || killed(p))
    80002758:	c719                	beqz	a4,80002766 <wait+0x112>
    8000275a:	854a                	mv	a0,s2
    8000275c:	00000097          	auipc	ra,0x0
    80002760:	ec6080e7          	jalr	-314(ra) # 80002622 <killed>
    80002764:	c51d                	beqz	a0,80002792 <wait+0x13e>
      release(&wait_lock);
    80002766:	0000e517          	auipc	a0,0xe
    8000276a:	4c250513          	addi	a0,a0,1218 # 80010c28 <wait_lock>
    8000276e:	ffffe097          	auipc	ra,0xffffe
    80002772:	51c080e7          	jalr	1308(ra) # 80000c8a <release>
      return -1;
    80002776:	59fd                	li	s3,-1
}
    80002778:	854e                	mv	a0,s3
    8000277a:	60a6                	ld	ra,72(sp)
    8000277c:	6406                	ld	s0,64(sp)
    8000277e:	74e2                	ld	s1,56(sp)
    80002780:	7942                	ld	s2,48(sp)
    80002782:	79a2                	ld	s3,40(sp)
    80002784:	7a02                	ld	s4,32(sp)
    80002786:	6ae2                	ld	s5,24(sp)
    80002788:	6b42                	ld	s6,16(sp)
    8000278a:	6ba2                	ld	s7,8(sp)
    8000278c:	6c02                	ld	s8,0(sp)
    8000278e:	6161                	addi	sp,sp,80
    80002790:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002792:	85e2                	mv	a1,s8
    80002794:	854a                	mv	a0,s2
    80002796:	00000097          	auipc	ra,0x0
    8000279a:	b86080e7          	jalr	-1146(ra) # 8000231c <sleep>
    havekids = 0;
    8000279e:	b701                	j	8000269e <wait+0x4a>

00000000800027a0 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800027a0:	7179                	addi	sp,sp,-48
    800027a2:	f406                	sd	ra,40(sp)
    800027a4:	f022                	sd	s0,32(sp)
    800027a6:	ec26                	sd	s1,24(sp)
    800027a8:	e84a                	sd	s2,16(sp)
    800027aa:	e44e                	sd	s3,8(sp)
    800027ac:	e052                	sd	s4,0(sp)
    800027ae:	1800                	addi	s0,sp,48
    800027b0:	84aa                	mv	s1,a0
    800027b2:	892e                	mv	s2,a1
    800027b4:	89b2                	mv	s3,a2
    800027b6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800027b8:	fffff097          	auipc	ra,0xfffff
    800027bc:	38e080e7          	jalr	910(ra) # 80001b46 <myproc>
  if (user_dst)
    800027c0:	c08d                	beqz	s1,800027e2 <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    800027c2:	86d2                	mv	a3,s4
    800027c4:	864e                	mv	a2,s3
    800027c6:	85ca                	mv	a1,s2
    800027c8:	6968                	ld	a0,208(a0)
    800027ca:	fffff097          	auipc	ra,0xfffff
    800027ce:	ea2080e7          	jalr	-350(ra) # 8000166c <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800027d2:	70a2                	ld	ra,40(sp)
    800027d4:	7402                	ld	s0,32(sp)
    800027d6:	64e2                	ld	s1,24(sp)
    800027d8:	6942                	ld	s2,16(sp)
    800027da:	69a2                	ld	s3,8(sp)
    800027dc:	6a02                	ld	s4,0(sp)
    800027de:	6145                	addi	sp,sp,48
    800027e0:	8082                	ret
    memmove((char *)dst, src, len);
    800027e2:	000a061b          	sext.w	a2,s4
    800027e6:	85ce                	mv	a1,s3
    800027e8:	854a                	mv	a0,s2
    800027ea:	ffffe097          	auipc	ra,0xffffe
    800027ee:	544080e7          	jalr	1348(ra) # 80000d2e <memmove>
    return 0;
    800027f2:	8526                	mv	a0,s1
    800027f4:	bff9                	j	800027d2 <either_copyout+0x32>

00000000800027f6 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800027f6:	7179                	addi	sp,sp,-48
    800027f8:	f406                	sd	ra,40(sp)
    800027fa:	f022                	sd	s0,32(sp)
    800027fc:	ec26                	sd	s1,24(sp)
    800027fe:	e84a                	sd	s2,16(sp)
    80002800:	e44e                	sd	s3,8(sp)
    80002802:	e052                	sd	s4,0(sp)
    80002804:	1800                	addi	s0,sp,48
    80002806:	892a                	mv	s2,a0
    80002808:	84ae                	mv	s1,a1
    8000280a:	89b2                	mv	s3,a2
    8000280c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000280e:	fffff097          	auipc	ra,0xfffff
    80002812:	338080e7          	jalr	824(ra) # 80001b46 <myproc>
  if (user_src)
    80002816:	c08d                	beqz	s1,80002838 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    80002818:	86d2                	mv	a3,s4
    8000281a:	864e                	mv	a2,s3
    8000281c:	85ca                	mv	a1,s2
    8000281e:	6968                	ld	a0,208(a0)
    80002820:	fffff097          	auipc	ra,0xfffff
    80002824:	ed8080e7          	jalr	-296(ra) # 800016f8 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002828:	70a2                	ld	ra,40(sp)
    8000282a:	7402                	ld	s0,32(sp)
    8000282c:	64e2                	ld	s1,24(sp)
    8000282e:	6942                	ld	s2,16(sp)
    80002830:	69a2                	ld	s3,8(sp)
    80002832:	6a02                	ld	s4,0(sp)
    80002834:	6145                	addi	sp,sp,48
    80002836:	8082                	ret
    memmove(dst, (char *)src, len);
    80002838:	000a061b          	sext.w	a2,s4
    8000283c:	85ce                	mv	a1,s3
    8000283e:	854a                	mv	a0,s2
    80002840:	ffffe097          	auipc	ra,0xffffe
    80002844:	4ee080e7          	jalr	1262(ra) # 80000d2e <memmove>
    return 0;
    80002848:	8526                	mv	a0,s1
    8000284a:	bff9                	j	80002828 <either_copyin+0x32>

000000008000284c <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    8000284c:	715d                	addi	sp,sp,-80
    8000284e:	e486                	sd	ra,72(sp)
    80002850:	e0a2                	sd	s0,64(sp)
    80002852:	fc26                	sd	s1,56(sp)
    80002854:	f84a                	sd	s2,48(sp)
    80002856:	f44e                	sd	s3,40(sp)
    80002858:	f052                	sd	s4,32(sp)
    8000285a:	ec56                	sd	s5,24(sp)
    8000285c:	e85a                	sd	s6,16(sp)
    8000285e:	e45e                	sd	s7,8(sp)
    80002860:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002862:	00006517          	auipc	a0,0x6
    80002866:	a5650513          	addi	a0,a0,-1450 # 800082b8 <digits+0x278>
    8000286a:	ffffe097          	auipc	ra,0xffffe
    8000286e:	d20080e7          	jalr	-736(ra) # 8000058a <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002872:	0000f497          	auipc	s1,0xf
    80002876:	1a648493          	addi	s1,s1,422 # 80011a18 <proc+0x1d8>
    8000287a:	00018917          	auipc	s2,0x18
    8000287e:	f9e90913          	addi	s2,s2,-98 # 8001a818 <bcache+0x1c0>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002882:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002884:	00006997          	auipc	s3,0x6
    80002888:	a1498993          	addi	s3,s3,-1516 # 80008298 <digits+0x258>
    printf("%d %s %s %d", p->pid, state, p->name, p->queue_number);
    8000288c:	00006a97          	auipc	s5,0x6
    80002890:	a14a8a93          	addi	s5,s5,-1516 # 800082a0 <digits+0x260>
    printf("\n");
    80002894:	00006a17          	auipc	s4,0x6
    80002898:	a24a0a13          	addi	s4,s4,-1500 # 800082b8 <digits+0x278>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000289c:	00006b97          	auipc	s7,0x6
    800028a0:	a54b8b93          	addi	s7,s7,-1452 # 800082f0 <states.0>
    800028a4:	a015                	j	800028c8 <procdump+0x7c>
    printf("%d %s %s %d", p->pid, state, p->name, p->queue_number);
    800028a6:	46f8                	lw	a4,76(a3)
    800028a8:	ed86a583          	lw	a1,-296(a3)
    800028ac:	8556                	mv	a0,s5
    800028ae:	ffffe097          	auipc	ra,0xffffe
    800028b2:	cdc080e7          	jalr	-804(ra) # 8000058a <printf>
    printf("\n");
    800028b6:	8552                	mv	a0,s4
    800028b8:	ffffe097          	auipc	ra,0xffffe
    800028bc:	cd2080e7          	jalr	-814(ra) # 8000058a <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800028c0:	23848493          	addi	s1,s1,568
    800028c4:	03248263          	beq	s1,s2,800028e8 <procdump+0x9c>
    if (p->state == UNUSED)
    800028c8:	86a6                	mv	a3,s1
    800028ca:	ec04a783          	lw	a5,-320(s1)
    800028ce:	dbed                	beqz	a5,800028c0 <procdump+0x74>
      state = "???";
    800028d0:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028d2:	fcfb6ae3          	bltu	s6,a5,800028a6 <procdump+0x5a>
    800028d6:	02079713          	slli	a4,a5,0x20
    800028da:	01d75793          	srli	a5,a4,0x1d
    800028de:	97de                	add	a5,a5,s7
    800028e0:	6390                	ld	a2,0(a5)
    800028e2:	f271                	bnez	a2,800028a6 <procdump+0x5a>
      state = "???";
    800028e4:	864e                	mv	a2,s3
    800028e6:	b7c1                	j	800028a6 <procdump+0x5a>
  }
}
    800028e8:	60a6                	ld	ra,72(sp)
    800028ea:	6406                	ld	s0,64(sp)
    800028ec:	74e2                	ld	s1,56(sp)
    800028ee:	7942                	ld	s2,48(sp)
    800028f0:	79a2                	ld	s3,40(sp)
    800028f2:	7a02                	ld	s4,32(sp)
    800028f4:	6ae2                	ld	s5,24(sp)
    800028f6:	6b42                	ld	s6,16(sp)
    800028f8:	6ba2                	ld	s7,8(sp)
    800028fa:	6161                	addi	sp,sp,80
    800028fc:	8082                	ret

00000000800028fe <waitx>:

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    800028fe:	711d                	addi	sp,sp,-96
    80002900:	ec86                	sd	ra,88(sp)
    80002902:	e8a2                	sd	s0,80(sp)
    80002904:	e4a6                	sd	s1,72(sp)
    80002906:	e0ca                	sd	s2,64(sp)
    80002908:	fc4e                	sd	s3,56(sp)
    8000290a:	f852                	sd	s4,48(sp)
    8000290c:	f456                	sd	s5,40(sp)
    8000290e:	f05a                	sd	s6,32(sp)
    80002910:	ec5e                	sd	s7,24(sp)
    80002912:	e862                	sd	s8,16(sp)
    80002914:	e466                	sd	s9,8(sp)
    80002916:	e06a                	sd	s10,0(sp)
    80002918:	1080                	addi	s0,sp,96
    8000291a:	8b2a                	mv	s6,a0
    8000291c:	8bae                	mv	s7,a1
    8000291e:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    80002920:	fffff097          	auipc	ra,0xfffff
    80002924:	226080e7          	jalr	550(ra) # 80001b46 <myproc>
    80002928:	892a                	mv	s2,a0

  acquire(&wait_lock);
    8000292a:	0000e517          	auipc	a0,0xe
    8000292e:	2fe50513          	addi	a0,a0,766 # 80010c28 <wait_lock>
    80002932:	ffffe097          	auipc	ra,0xffffe
    80002936:	2a4080e7          	jalr	676(ra) # 80000bd6 <acquire>

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    8000293a:	4c81                	li	s9,0
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    8000293c:	4a15                	li	s4,5
        havekids = 1;
    8000293e:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    80002940:	00018997          	auipc	s3,0x18
    80002944:	d0098993          	addi	s3,s3,-768 # 8001a640 <tickslock>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002948:	0000ed17          	auipc	s10,0xe
    8000294c:	2e0d0d13          	addi	s10,s10,736 # 80010c28 <wait_lock>
    havekids = 0;
    80002950:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    80002952:	0000f497          	auipc	s1,0xf
    80002956:	eee48493          	addi	s1,s1,-274 # 80011840 <proc>
    8000295a:	a059                	j	800029e0 <waitx+0xe2>
          pid = np->pid;
    8000295c:	0b04a983          	lw	s3,176(s1)
          *rtime = np->rtime;
    80002960:	1e84a783          	lw	a5,488(s1)
    80002964:	00fc2023          	sw	a5,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    80002968:	1ec4a703          	lw	a4,492(s1)
    8000296c:	9f3d                	addw	a4,a4,a5
    8000296e:	1f04a783          	lw	a5,496(s1)
    80002972:	9f99                	subw	a5,a5,a4
    80002974:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002978:	000b0e63          	beqz	s6,80002994 <waitx+0x96>
    8000297c:	4691                	li	a3,4
    8000297e:	0ac48613          	addi	a2,s1,172
    80002982:	85da                	mv	a1,s6
    80002984:	0d093503          	ld	a0,208(s2)
    80002988:	fffff097          	auipc	ra,0xfffff
    8000298c:	ce4080e7          	jalr	-796(ra) # 8000166c <copyout>
    80002990:	02054563          	bltz	a0,800029ba <waitx+0xbc>
          freeproc(np);
    80002994:	8526                	mv	a0,s1
    80002996:	fffff097          	auipc	ra,0xfffff
    8000299a:	362080e7          	jalr	866(ra) # 80001cf8 <freeproc>
          release(&np->lock);
    8000299e:	8526                	mv	a0,s1
    800029a0:	ffffe097          	auipc	ra,0xffffe
    800029a4:	2ea080e7          	jalr	746(ra) # 80000c8a <release>
          release(&wait_lock);
    800029a8:	0000e517          	auipc	a0,0xe
    800029ac:	28050513          	addi	a0,a0,640 # 80010c28 <wait_lock>
    800029b0:	ffffe097          	auipc	ra,0xffffe
    800029b4:	2da080e7          	jalr	730(ra) # 80000c8a <release>
          return pid;
    800029b8:	a0a5                	j	80002a20 <waitx+0x122>
            release(&np->lock);
    800029ba:	8526                	mv	a0,s1
    800029bc:	ffffe097          	auipc	ra,0xffffe
    800029c0:	2ce080e7          	jalr	718(ra) # 80000c8a <release>
            release(&wait_lock);
    800029c4:	0000e517          	auipc	a0,0xe
    800029c8:	26450513          	addi	a0,a0,612 # 80010c28 <wait_lock>
    800029cc:	ffffe097          	auipc	ra,0xffffe
    800029d0:	2be080e7          	jalr	702(ra) # 80000c8a <release>
            return -1;
    800029d4:	59fd                	li	s3,-1
    800029d6:	a0a9                	j	80002a20 <waitx+0x122>
    for (np = proc; np < &proc[NPROC]; np++)
    800029d8:	23848493          	addi	s1,s1,568
    800029dc:	03348563          	beq	s1,s3,80002a06 <waitx+0x108>
      if (np->parent == p)
    800029e0:	7cdc                	ld	a5,184(s1)
    800029e2:	ff279be3          	bne	a5,s2,800029d8 <waitx+0xda>
        acquire(&np->lock);
    800029e6:	8526                	mv	a0,s1
    800029e8:	ffffe097          	auipc	ra,0xffffe
    800029ec:	1ee080e7          	jalr	494(ra) # 80000bd6 <acquire>
        if (np->state == ZOMBIE)
    800029f0:	0984a783          	lw	a5,152(s1)
    800029f4:	f74784e3          	beq	a5,s4,8000295c <waitx+0x5e>
        release(&np->lock);
    800029f8:	8526                	mv	a0,s1
    800029fa:	ffffe097          	auipc	ra,0xffffe
    800029fe:	290080e7          	jalr	656(ra) # 80000c8a <release>
        havekids = 1;
    80002a02:	8756                	mv	a4,s5
    80002a04:	bfd1                	j	800029d8 <waitx+0xda>
    if (!havekids || p->killed)
    80002a06:	c701                	beqz	a4,80002a0e <waitx+0x110>
    80002a08:	0a892783          	lw	a5,168(s2)
    80002a0c:	cb8d                	beqz	a5,80002a3e <waitx+0x140>
      release(&wait_lock);
    80002a0e:	0000e517          	auipc	a0,0xe
    80002a12:	21a50513          	addi	a0,a0,538 # 80010c28 <wait_lock>
    80002a16:	ffffe097          	auipc	ra,0xffffe
    80002a1a:	274080e7          	jalr	628(ra) # 80000c8a <release>
      return -1;
    80002a1e:	59fd                	li	s3,-1
  }
}
    80002a20:	854e                	mv	a0,s3
    80002a22:	60e6                	ld	ra,88(sp)
    80002a24:	6446                	ld	s0,80(sp)
    80002a26:	64a6                	ld	s1,72(sp)
    80002a28:	6906                	ld	s2,64(sp)
    80002a2a:	79e2                	ld	s3,56(sp)
    80002a2c:	7a42                	ld	s4,48(sp)
    80002a2e:	7aa2                	ld	s5,40(sp)
    80002a30:	7b02                	ld	s6,32(sp)
    80002a32:	6be2                	ld	s7,24(sp)
    80002a34:	6c42                	ld	s8,16(sp)
    80002a36:	6ca2                	ld	s9,8(sp)
    80002a38:	6d02                	ld	s10,0(sp)
    80002a3a:	6125                	addi	sp,sp,96
    80002a3c:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002a3e:	85ea                	mv	a1,s10
    80002a40:	854a                	mv	a0,s2
    80002a42:	00000097          	auipc	ra,0x0
    80002a46:	8da080e7          	jalr	-1830(ra) # 8000231c <sleep>
    havekids = 0;
    80002a4a:	b719                	j	80002950 <waitx+0x52>

0000000080002a4c <update_time>:

void update_time()
{
    80002a4c:	7139                	addi	sp,sp,-64
    80002a4e:	fc06                	sd	ra,56(sp)
    80002a50:	f822                	sd	s0,48(sp)
    80002a52:	f426                	sd	s1,40(sp)
    80002a54:	f04a                	sd	s2,32(sp)
    80002a56:	ec4e                	sd	s3,24(sp)
    80002a58:	e852                	sd	s4,16(sp)
    80002a5a:	e456                	sd	s5,8(sp)
    80002a5c:	0080                	addi	s0,sp,64
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    80002a5e:	0000f497          	auipc	s1,0xf
    80002a62:	de248493          	addi	s1,s1,-542 # 80011840 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    80002a66:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    80002a68:	00018917          	auipc	s2,0x18
    80002a6c:	bd890913          	addi	s2,s2,-1064 # 8001a640 <tickslock>
    80002a70:	a811                	j	80002a84 <update_time+0x38>
    {
      p->rtime++;
    }
    release(&p->lock);
    80002a72:	8526                	mv	a0,s1
    80002a74:	ffffe097          	auipc	ra,0xffffe
    80002a78:	216080e7          	jalr	534(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002a7c:	23848493          	addi	s1,s1,568
    80002a80:	03248163          	beq	s1,s2,80002aa2 <update_time+0x56>
    acquire(&p->lock);
    80002a84:	8526                	mv	a0,s1
    80002a86:	ffffe097          	auipc	ra,0xffffe
    80002a8a:	150080e7          	jalr	336(ra) # 80000bd6 <acquire>
    if (p->state == RUNNING)
    80002a8e:	0984a783          	lw	a5,152(s1)
    80002a92:	ff3790e3          	bne	a5,s3,80002a72 <update_time+0x26>
      p->rtime++;
    80002a96:	1e84a783          	lw	a5,488(s1)
    80002a9a:	2785                	addiw	a5,a5,1
    80002a9c:	1ef4a423          	sw	a5,488(s1)
    80002aa0:	bfc9                	j	80002a72 <update_time+0x26>
  }
  for(p = proc;p < &proc[NPROC];p++){
    80002aa2:	0000f497          	auipc	s1,0xf
    80002aa6:	d9e48493          	addi	s1,s1,-610 # 80011840 <proc>
    if(p->pid >= 3 && p->pid <= 13){
    80002aaa:	49a9                	li	s3,10
      printf("%d %d %d\n",ticks,p->pid,p->queue_number);
    80002aac:	00006a97          	auipc	s5,0x6
    80002ab0:	ee4a8a93          	addi	s5,s5,-284 # 80008990 <ticks>
    80002ab4:	00005a17          	auipc	s4,0x5
    80002ab8:	7fca0a13          	addi	s4,s4,2044 # 800082b0 <digits+0x270>
  for(p = proc;p < &proc[NPROC];p++){
    80002abc:	00018917          	auipc	s2,0x18
    80002ac0:	b8490913          	addi	s2,s2,-1148 # 8001a640 <tickslock>
    80002ac4:	a029                	j	80002ace <update_time+0x82>
    80002ac6:	23848493          	addi	s1,s1,568
    80002aca:	03248263          	beq	s1,s2,80002aee <update_time+0xa2>
    if(p->pid >= 3 && p->pid <= 13){
    80002ace:	0b04a603          	lw	a2,176(s1)
    80002ad2:	ffd6079b          	addiw	a5,a2,-3
    80002ad6:	fef9e8e3          	bltu	s3,a5,80002ac6 <update_time+0x7a>
      printf("%d %d %d\n",ticks,p->pid,p->queue_number);
    80002ada:	2244a683          	lw	a3,548(s1)
    80002ade:	000aa583          	lw	a1,0(s5)
    80002ae2:	8552                	mv	a0,s4
    80002ae4:	ffffe097          	auipc	ra,0xffffe
    80002ae8:	aa6080e7          	jalr	-1370(ra) # 8000058a <printf>
    80002aec:	bfe9                	j	80002ac6 <update_time+0x7a>
    }
  }
    80002aee:	70e2                	ld	ra,56(sp)
    80002af0:	7442                	ld	s0,48(sp)
    80002af2:	74a2                	ld	s1,40(sp)
    80002af4:	7902                	ld	s2,32(sp)
    80002af6:	69e2                	ld	s3,24(sp)
    80002af8:	6a42                	ld	s4,16(sp)
    80002afa:	6aa2                	ld	s5,8(sp)
    80002afc:	6121                	addi	sp,sp,64
    80002afe:	8082                	ret

0000000080002b00 <swtch>:
    80002b00:	00153023          	sd	ra,0(a0)
    80002b04:	00253423          	sd	sp,8(a0)
    80002b08:	e900                	sd	s0,16(a0)
    80002b0a:	ed04                	sd	s1,24(a0)
    80002b0c:	03253023          	sd	s2,32(a0)
    80002b10:	03353423          	sd	s3,40(a0)
    80002b14:	03453823          	sd	s4,48(a0)
    80002b18:	03553c23          	sd	s5,56(a0)
    80002b1c:	05653023          	sd	s6,64(a0)
    80002b20:	05753423          	sd	s7,72(a0)
    80002b24:	05853823          	sd	s8,80(a0)
    80002b28:	05953c23          	sd	s9,88(a0)
    80002b2c:	07a53023          	sd	s10,96(a0)
    80002b30:	07b53423          	sd	s11,104(a0)
    80002b34:	0005b083          	ld	ra,0(a1)
    80002b38:	0085b103          	ld	sp,8(a1)
    80002b3c:	6980                	ld	s0,16(a1)
    80002b3e:	6d84                	ld	s1,24(a1)
    80002b40:	0205b903          	ld	s2,32(a1)
    80002b44:	0285b983          	ld	s3,40(a1)
    80002b48:	0305ba03          	ld	s4,48(a1)
    80002b4c:	0385ba83          	ld	s5,56(a1)
    80002b50:	0405bb03          	ld	s6,64(a1)
    80002b54:	0485bb83          	ld	s7,72(a1)
    80002b58:	0505bc03          	ld	s8,80(a1)
    80002b5c:	0585bc83          	ld	s9,88(a1)
    80002b60:	0605bd03          	ld	s10,96(a1)
    80002b64:	0685bd83          	ld	s11,104(a1)
    80002b68:	8082                	ret

0000000080002b6a <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002b6a:	1141                	addi	sp,sp,-16
    80002b6c:	e406                	sd	ra,8(sp)
    80002b6e:	e022                	sd	s0,0(sp)
    80002b70:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002b72:	00005597          	auipc	a1,0x5
    80002b76:	7ae58593          	addi	a1,a1,1966 # 80008320 <states.0+0x30>
    80002b7a:	00018517          	auipc	a0,0x18
    80002b7e:	ac650513          	addi	a0,a0,-1338 # 8001a640 <tickslock>
    80002b82:	ffffe097          	auipc	ra,0xffffe
    80002b86:	fc4080e7          	jalr	-60(ra) # 80000b46 <initlock>
}
    80002b8a:	60a2                	ld	ra,8(sp)
    80002b8c:	6402                	ld	s0,0(sp)
    80002b8e:	0141                	addi	sp,sp,16
    80002b90:	8082                	ret

0000000080002b92 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002b92:	1141                	addi	sp,sp,-16
    80002b94:	e422                	sd	s0,8(sp)
    80002b96:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b98:	00004797          	auipc	a5,0x4
    80002b9c:	9b878793          	addi	a5,a5,-1608 # 80006550 <kernelvec>
    80002ba0:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002ba4:	6422                	ld	s0,8(sp)
    80002ba6:	0141                	addi	sp,sp,16
    80002ba8:	8082                	ret

0000000080002baa <usertrapret>:
}
//
// return to user space
//
void usertrapret(void)
{
    80002baa:	1141                	addi	sp,sp,-16
    80002bac:	e406                	sd	ra,8(sp)
    80002bae:	e022                	sd	s0,0(sp)
    80002bb0:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002bb2:	fffff097          	auipc	ra,0xfffff
    80002bb6:	f94080e7          	jalr	-108(ra) # 80001b46 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bba:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002bbe:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bc0:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002bc4:	00004697          	auipc	a3,0x4
    80002bc8:	43c68693          	addi	a3,a3,1084 # 80007000 <_trampoline>
    80002bcc:	00004717          	auipc	a4,0x4
    80002bd0:	43470713          	addi	a4,a4,1076 # 80007000 <_trampoline>
    80002bd4:	8f15                	sub	a4,a4,a3
    80002bd6:	040007b7          	lui	a5,0x4000
    80002bda:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002bdc:	07b2                	slli	a5,a5,0xc
    80002bde:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002be0:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002be4:	6d78                	ld	a4,216(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002be6:	18002673          	csrr	a2,satp
    80002bea:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002bec:	6d70                	ld	a2,216(a0)
    80002bee:	6178                	ld	a4,192(a0)
    80002bf0:	6585                	lui	a1,0x1
    80002bf2:	972e                	add	a4,a4,a1
    80002bf4:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002bf6:	6d78                	ld	a4,216(a0)
    80002bf8:	00000617          	auipc	a2,0x0
    80002bfc:	13e60613          	addi	a2,a2,318 # 80002d36 <usertrap>
    80002c00:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002c02:	6d78                	ld	a4,216(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002c04:	8612                	mv	a2,tp
    80002c06:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c08:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002c0c:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002c10:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c14:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002c18:	6d78                	ld	a4,216(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c1a:	6f18                	ld	a4,24(a4)
    80002c1c:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002c20:	6968                	ld	a0,208(a0)
    80002c22:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002c24:	00004717          	auipc	a4,0x4
    80002c28:	47870713          	addi	a4,a4,1144 # 8000709c <userret>
    80002c2c:	8f15                	sub	a4,a4,a3
    80002c2e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002c30:	577d                	li	a4,-1
    80002c32:	177e                	slli	a4,a4,0x3f
    80002c34:	8d59                	or	a0,a0,a4
    80002c36:	9782                	jalr	a5
}
    80002c38:	60a2                	ld	ra,8(sp)
    80002c3a:	6402                	ld	s0,0(sp)
    80002c3c:	0141                	addi	sp,sp,16
    80002c3e:	8082                	ret

0000000080002c40 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002c40:	1101                	addi	sp,sp,-32
    80002c42:	ec06                	sd	ra,24(sp)
    80002c44:	e822                	sd	s0,16(sp)
    80002c46:	e426                	sd	s1,8(sp)
    80002c48:	e04a                	sd	s2,0(sp)
    80002c4a:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002c4c:	00018917          	auipc	s2,0x18
    80002c50:	9f490913          	addi	s2,s2,-1548 # 8001a640 <tickslock>
    80002c54:	854a                	mv	a0,s2
    80002c56:	ffffe097          	auipc	ra,0xffffe
    80002c5a:	f80080e7          	jalr	-128(ra) # 80000bd6 <acquire>
  ticks++;
    80002c5e:	00006497          	auipc	s1,0x6
    80002c62:	d3248493          	addi	s1,s1,-718 # 80008990 <ticks>
    80002c66:	409c                	lw	a5,0(s1)
    80002c68:	2785                	addiw	a5,a5,1
    80002c6a:	c09c                	sw	a5,0(s1)
  update_time();
    80002c6c:	00000097          	auipc	ra,0x0
    80002c70:	de0080e7          	jalr	-544(ra) # 80002a4c <update_time>
  //   // {
  //   //   p->wtime++;
  //   // }
  //   release(&p->lock);
  // }
  wakeup(&ticks);
    80002c74:	8526                	mv	a0,s1
    80002c76:	fffff097          	auipc	ra,0xfffff
    80002c7a:	71a080e7          	jalr	1818(ra) # 80002390 <wakeup>
  release(&tickslock);
    80002c7e:	854a                	mv	a0,s2
    80002c80:	ffffe097          	auipc	ra,0xffffe
    80002c84:	00a080e7          	jalr	10(ra) # 80000c8a <release>
}
    80002c88:	60e2                	ld	ra,24(sp)
    80002c8a:	6442                	ld	s0,16(sp)
    80002c8c:	64a2                	ld	s1,8(sp)
    80002c8e:	6902                	ld	s2,0(sp)
    80002c90:	6105                	addi	sp,sp,32
    80002c92:	8082                	ret

0000000080002c94 <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002c94:	1101                	addi	sp,sp,-32
    80002c96:	ec06                	sd	ra,24(sp)
    80002c98:	e822                	sd	s0,16(sp)
    80002c9a:	e426                	sd	s1,8(sp)
    80002c9c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c9e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    80002ca2:	00074d63          	bltz	a4,80002cbc <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    80002ca6:	57fd                	li	a5,-1
    80002ca8:	17fe                	slli	a5,a5,0x3f
    80002caa:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    80002cac:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002cae:	06f70363          	beq	a4,a5,80002d14 <devintr+0x80>
  }
}
    80002cb2:	60e2                	ld	ra,24(sp)
    80002cb4:	6442                	ld	s0,16(sp)
    80002cb6:	64a2                	ld	s1,8(sp)
    80002cb8:	6105                	addi	sp,sp,32
    80002cba:	8082                	ret
      (scause & 0xff) == 9)
    80002cbc:	0ff77793          	zext.b	a5,a4
  if ((scause & 0x8000000000000000L) &&
    80002cc0:	46a5                	li	a3,9
    80002cc2:	fed792e3          	bne	a5,a3,80002ca6 <devintr+0x12>
    int irq = plic_claim();
    80002cc6:	00004097          	auipc	ra,0x4
    80002cca:	992080e7          	jalr	-1646(ra) # 80006658 <plic_claim>
    80002cce:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002cd0:	47a9                	li	a5,10
    80002cd2:	02f50763          	beq	a0,a5,80002d00 <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    80002cd6:	4785                	li	a5,1
    80002cd8:	02f50963          	beq	a0,a5,80002d0a <devintr+0x76>
    return 1;
    80002cdc:	4505                	li	a0,1
    else if (irq)
    80002cde:	d8f1                	beqz	s1,80002cb2 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002ce0:	85a6                	mv	a1,s1
    80002ce2:	00005517          	auipc	a0,0x5
    80002ce6:	64650513          	addi	a0,a0,1606 # 80008328 <states.0+0x38>
    80002cea:	ffffe097          	auipc	ra,0xffffe
    80002cee:	8a0080e7          	jalr	-1888(ra) # 8000058a <printf>
      plic_complete(irq);
    80002cf2:	8526                	mv	a0,s1
    80002cf4:	00004097          	auipc	ra,0x4
    80002cf8:	988080e7          	jalr	-1656(ra) # 8000667c <plic_complete>
    return 1;
    80002cfc:	4505                	li	a0,1
    80002cfe:	bf55                	j	80002cb2 <devintr+0x1e>
      uartintr();
    80002d00:	ffffe097          	auipc	ra,0xffffe
    80002d04:	c98080e7          	jalr	-872(ra) # 80000998 <uartintr>
    80002d08:	b7ed                	j	80002cf2 <devintr+0x5e>
      virtio_disk_intr();
    80002d0a:	00004097          	auipc	ra,0x4
    80002d0e:	e3a080e7          	jalr	-454(ra) # 80006b44 <virtio_disk_intr>
    80002d12:	b7c5                	j	80002cf2 <devintr+0x5e>
    if (cpuid() == 0)
    80002d14:	fffff097          	auipc	ra,0xfffff
    80002d18:	e06080e7          	jalr	-506(ra) # 80001b1a <cpuid>
    80002d1c:	c901                	beqz	a0,80002d2c <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002d1e:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002d22:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002d24:	14479073          	csrw	sip,a5
    return 2;
    80002d28:	4509                	li	a0,2
    80002d2a:	b761                	j	80002cb2 <devintr+0x1e>
      clockintr();
    80002d2c:	00000097          	auipc	ra,0x0
    80002d30:	f14080e7          	jalr	-236(ra) # 80002c40 <clockintr>
    80002d34:	b7ed                	j	80002d1e <devintr+0x8a>

0000000080002d36 <usertrap>:
{
    80002d36:	711d                	addi	sp,sp,-96
    80002d38:	ec86                	sd	ra,88(sp)
    80002d3a:	e8a2                	sd	s0,80(sp)
    80002d3c:	e4a6                	sd	s1,72(sp)
    80002d3e:	e0ca                	sd	s2,64(sp)
    80002d40:	fc4e                	sd	s3,56(sp)
    80002d42:	f852                	sd	s4,48(sp)
    80002d44:	f456                	sd	s5,40(sp)
    80002d46:	f05a                	sd	s6,32(sp)
    80002d48:	ec5e                	sd	s7,24(sp)
    80002d4a:	e862                	sd	s8,16(sp)
    80002d4c:	e466                	sd	s9,8(sp)
    80002d4e:	1080                	addi	s0,sp,96
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d50:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002d54:	1007f793          	andi	a5,a5,256
    80002d58:	e3b1                	bnez	a5,80002d9c <usertrap+0x66>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d5a:	00003797          	auipc	a5,0x3
    80002d5e:	7f678793          	addi	a5,a5,2038 # 80006550 <kernelvec>
    80002d62:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002d66:	fffff097          	auipc	ra,0xfffff
    80002d6a:	de0080e7          	jalr	-544(ra) # 80001b46 <myproc>
    80002d6e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002d70:	6d7c                	ld	a5,216(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d72:	14102773          	csrr	a4,sepc
    80002d76:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d78:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002d7c:	47a1                	li	a5,8
    80002d7e:	02f70763          	beq	a4,a5,80002dac <usertrap+0x76>
  else if ((which_dev = devintr()) != 0)
    80002d82:	00000097          	auipc	ra,0x0
    80002d86:	f12080e7          	jalr	-238(ra) # 80002c94 <devintr>
    80002d8a:	892a                	mv	s2,a0
    80002d8c:	c141                	beqz	a0,80002e0c <usertrap+0xd6>
  if (killed(p))
    80002d8e:	8526                	mv	a0,s1
    80002d90:	00000097          	auipc	ra,0x0
    80002d94:	892080e7          	jalr	-1902(ra) # 80002622 <killed>
    80002d98:	cd55                	beqz	a0,80002e54 <usertrap+0x11e>
    80002d9a:	a845                	j	80002e4a <usertrap+0x114>
    panic("usertrap: not from user mode");
    80002d9c:	00005517          	auipc	a0,0x5
    80002da0:	5ac50513          	addi	a0,a0,1452 # 80008348 <states.0+0x58>
    80002da4:	ffffd097          	auipc	ra,0xffffd
    80002da8:	79c080e7          	jalr	1948(ra) # 80000540 <panic>
    if (killed(p))
    80002dac:	00000097          	auipc	ra,0x0
    80002db0:	876080e7          	jalr	-1930(ra) # 80002622 <killed>
    80002db4:	e531                	bnez	a0,80002e00 <usertrap+0xca>
    p->trapframe->epc += 4;
    80002db6:	6cf8                	ld	a4,216(s1)
    80002db8:	6f1c                	ld	a5,24(a4)
    80002dba:	0791                	addi	a5,a5,4
    80002dbc:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002dbe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002dc2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002dc6:	10079073          	csrw	sstatus,a5
    syscall();
    80002dca:	00000097          	auipc	ra,0x0
    80002dce:	44c080e7          	jalr	1100(ra) # 80003216 <syscall>
  if (killed(p))
    80002dd2:	8526                	mv	a0,s1
    80002dd4:	00000097          	auipc	ra,0x0
    80002dd8:	84e080e7          	jalr	-1970(ra) # 80002622 <killed>
    80002ddc:	e535                	bnez	a0,80002e48 <usertrap+0x112>
  usertrapret();
    80002dde:	00000097          	auipc	ra,0x0
    80002de2:	dcc080e7          	jalr	-564(ra) # 80002baa <usertrapret>
}
    80002de6:	60e6                	ld	ra,88(sp)
    80002de8:	6446                	ld	s0,80(sp)
    80002dea:	64a6                	ld	s1,72(sp)
    80002dec:	6906                	ld	s2,64(sp)
    80002dee:	79e2                	ld	s3,56(sp)
    80002df0:	7a42                	ld	s4,48(sp)
    80002df2:	7aa2                	ld	s5,40(sp)
    80002df4:	7b02                	ld	s6,32(sp)
    80002df6:	6be2                	ld	s7,24(sp)
    80002df8:	6c42                	ld	s8,16(sp)
    80002dfa:	6ca2                	ld	s9,8(sp)
    80002dfc:	6125                	addi	sp,sp,96
    80002dfe:	8082                	ret
      exit(-1);
    80002e00:	557d                	li	a0,-1
    80002e02:	fffff097          	auipc	ra,0xfffff
    80002e06:	67a080e7          	jalr	1658(ra) # 8000247c <exit>
    80002e0a:	b775                	j	80002db6 <usertrap+0x80>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e0c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002e10:	0b04a603          	lw	a2,176(s1)
    80002e14:	00005517          	auipc	a0,0x5
    80002e18:	55450513          	addi	a0,a0,1364 # 80008368 <states.0+0x78>
    80002e1c:	ffffd097          	auipc	ra,0xffffd
    80002e20:	76e080e7          	jalr	1902(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e24:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e28:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e2c:	00005517          	auipc	a0,0x5
    80002e30:	56c50513          	addi	a0,a0,1388 # 80008398 <states.0+0xa8>
    80002e34:	ffffd097          	auipc	ra,0xffffd
    80002e38:	756080e7          	jalr	1878(ra) # 8000058a <printf>
    setkilled(p);
    80002e3c:	8526                	mv	a0,s1
    80002e3e:	fffff097          	auipc	ra,0xfffff
    80002e42:	7b6080e7          	jalr	1974(ra) # 800025f4 <setkilled>
    80002e46:	b771                	j	80002dd2 <usertrap+0x9c>
  if (killed(p))
    80002e48:	4901                	li	s2,0
    exit(-1);
    80002e4a:	557d                	li	a0,-1
    80002e4c:	fffff097          	auipc	ra,0xfffff
    80002e50:	630080e7          	jalr	1584(ra) # 8000247c <exit>
  if (which_dev == 2)
    80002e54:	4789                	li	a5,2
    80002e56:	f8f914e3          	bne	s2,a5,80002dde <usertrap+0xa8>
    struct proc* p=myproc();
    80002e5a:	fffff097          	auipc	ra,0xfffff
    80002e5e:	cec080e7          	jalr	-788(ra) # 80001b46 <myproc>
    80002e62:	8a2a                	mv	s4,a0
     if (p != 0 && p->state == RUNNING)
    80002e64:	c511                	beqz	a0,80002e70 <usertrap+0x13a>
    80002e66:	09852703          	lw	a4,152(a0)
    80002e6a:	4791                	li	a5,4
    80002e6c:	0af70663          	beq	a4,a5,80002f18 <usertrap+0x1e2>
      p->queueticks++;
    80002e70:	230a2783          	lw	a5,560(s4)
    80002e74:	2785                	addiw	a5,a5,1
    80002e76:	22fa2823          	sw	a5,560(s4)
      if(ticks%48 == 0){
    80002e7a:	00006797          	auipc	a5,0x6
    80002e7e:	b167a783          	lw	a5,-1258(a5) # 80008990 <ticks>
    80002e82:	03000713          	li	a4,48
    80002e86:	02e7f7bb          	remuw	a5,a5,a4
    80002e8a:	efb9                	bnez	a5,80002ee8 <usertrap+0x1b2>
    80002e8c:	0000eb97          	auipc	s7,0xe
    80002e90:	d74b8b93          	addi	s7,s7,-652 # 80010c00 <sizeofq>
    80002e94:	0000ec17          	auipc	s8,0xe
    80002e98:	3acc0c13          	addi	s8,s8,940 # 80011240 <multique+0x200>
    80002e9c:	0000ec97          	auipc	s9,0xe
    80002ea0:	d70c8c93          	addi	s9,s9,-656 # 80010c0c <sizeofq+0xc>
          for (int j = 0; j<sizeofq[level];j++)
    80002ea4:	4a81                	li	s5,0
    80002ea6:	8b5e                	mv	s6,s7
    80002ea8:	004ba783          	lw	a5,4(s7)
    80002eac:	89e2                	mv	s3,s8
    80002eae:	8956                	mv	s2,s5
    80002eb0:	02f05763          	blez	a5,80002ede <usertrap+0x1a8>
            temp = multique[level][j];
    80002eb4:	0009b483          	ld	s1,0(s3)
            dequeue(temp, temp->queue_number); // Remove from the current queue
    80002eb8:	2244a583          	lw	a1,548(s1)
    80002ebc:	8526                	mv	a0,s1
    80002ebe:	fffff097          	auipc	ra,0xfffff
    80002ec2:	a60080e7          	jalr	-1440(ra) # 8000191e <dequeue>
            enqueue(temp, 0);               // Insert at the end of queue 0
    80002ec6:	85d6                	mv	a1,s5
    80002ec8:	8526                	mv	a0,s1
    80002eca:	fffff097          	auipc	ra,0xfffff
    80002ece:	9c6080e7          	jalr	-1594(ra) # 80001890 <enqueue>
          for (int j = 0; j<sizeofq[level];j++)
    80002ed2:	2905                	addiw	s2,s2,1
    80002ed4:	09a1                	addi	s3,s3,8
    80002ed6:	004b2783          	lw	a5,4(s6)
    80002eda:	fcf94de3          	blt	s2,a5,80002eb4 <usertrap+0x17e>
        for(int level = 1;level < 4 ;level++){
    80002ede:	0b91                	addi	s7,s7,4
    80002ee0:	200c0c13          	addi	s8,s8,512
    80002ee4:	fd9b91e3          	bne	s7,s9,80002ea6 <usertrap+0x170>
      if(p->queueticks >= timesliceq[p->queue_number]){
    80002ee8:	224a2583          	lw	a1,548(s4)
    80002eec:	00259713          	slli	a4,a1,0x2
    80002ef0:	00006797          	auipc	a5,0x6
    80002ef4:	a3878793          	addi	a5,a5,-1480 # 80008928 <timesliceq>
    80002ef8:	97ba                	add	a5,a5,a4
    80002efa:	230a2703          	lw	a4,560(s4)
    80002efe:	439c                	lw	a5,0(a5)
    80002f00:	06f75f63          	bge	a4,a5,80002f7e <usertrap+0x248>
      for(int i=0;i<p->queue_number;i++){
    80002f04:	224a2783          	lw	a5,548(s4)
    80002f08:	ecf05be3          	blez	a5,80002dde <usertrap+0xa8>
    80002f0c:	0000e917          	auipc	s2,0xe
    80002f10:	cf490913          	addi	s2,s2,-780 # 80010c00 <sizeofq>
    80002f14:	4481                	li	s1,0
    80002f16:	a04d                	j	80002fb8 <usertrap+0x282>
      p->cur_ticks++;
    80002f18:	20452783          	lw	a5,516(a0)
    80002f1c:	2785                	addiw	a5,a5,1
    80002f1e:	0007871b          	sext.w	a4,a5
    80002f22:	20f52223          	sw	a5,516(a0)
      if (p->ticks > 0 && p->cur_ticks >= p->ticks && p->in_alarm_handler == 0)
    80002f26:	20052783          	lw	a5,512(a0)
    80002f2a:	f4f053e3          	blez	a5,80002e70 <usertrap+0x13a>
    80002f2e:	f4f741e3          	blt	a4,a5,80002e70 <usertrap+0x13a>
    80002f32:	21452783          	lw	a5,532(a0)
    80002f36:	ff8d                	bnez	a5,80002e70 <usertrap+0x13a>
        p->in_alarm_handler = 1;
    80002f38:	4785                	li	a5,1
    80002f3a:	20f52a23          	sw	a5,532(a0)
        struct trapframe *tf = kalloc();
    80002f3e:	ffffe097          	auipc	ra,0xffffe
    80002f42:	ba8080e7          	jalr	-1112(ra) # 80000ae6 <kalloc>
    80002f46:	84aa                	mv	s1,a0
        if (tf == 0)
    80002f48:	c11d                	beqz	a0,80002f6e <usertrap+0x238>
        memmove(tf, p->trapframe, sizeof(struct trapframe));
    80002f4a:	12000613          	li	a2,288
    80002f4e:	0d8a3583          	ld	a1,216(s4)
    80002f52:	ffffe097          	auipc	ra,0xffffe
    80002f56:	ddc080e7          	jalr	-548(ra) # 80000d2e <memmove>
        p->alarm_tf = tf;
    80002f5a:	209a3423          	sd	s1,520(s4)
        p->trapframe->epc = p->handler;
    80002f5e:	0d8a3783          	ld	a5,216(s4)
    80002f62:	1f8a3703          	ld	a4,504(s4)
    80002f66:	ef98                	sd	a4,24(a5)
        p->cur_ticks = 0;
    80002f68:	200a2223          	sw	zero,516(s4)
    80002f6c:	b711                	j	80002e70 <usertrap+0x13a>
        panic("usertrap: failed to allocate memory for alarm trapframe");
    80002f6e:	00005517          	auipc	a0,0x5
    80002f72:	44a50513          	addi	a0,a0,1098 # 800083b8 <states.0+0xc8>
    80002f76:	ffffd097          	auipc	ra,0xffffd
    80002f7a:	5ca080e7          	jalr	1482(ra) # 80000540 <panic>
        dequeue(p,p->queue_number);
    80002f7e:	8552                	mv	a0,s4
    80002f80:	fffff097          	auipc	ra,0xfffff
    80002f84:	99e080e7          	jalr	-1634(ra) # 8000191e <dequeue>
        int npriority = p->queue_number + 1;
    80002f88:	224a2783          	lw	a5,548(s4)
    80002f8c:	0017859b          	addiw	a1,a5,1
        if(npriority > 3 )npriority--;
    80002f90:	470d                	li	a4,3
    80002f92:	00b75363          	bge	a4,a1,80002f98 <usertrap+0x262>
    80002f96:	85be                	mv	a1,a5
        enqueue(p,npriority);
    80002f98:	8552                	mv	a0,s4
    80002f9a:	fffff097          	auipc	ra,0xfffff
    80002f9e:	8f6080e7          	jalr	-1802(ra) # 80001890 <enqueue>
        yield();
    80002fa2:	fffff097          	auipc	ra,0xfffff
    80002fa6:	33c080e7          	jalr	828(ra) # 800022de <yield>
    80002faa:	bfa9                	j	80002f04 <usertrap+0x1ce>
      for(int i=0;i<p->queue_number;i++){
    80002fac:	2485                	addiw	s1,s1,1
    80002fae:	0911                	addi	s2,s2,4
    80002fb0:	224a2783          	lw	a5,548(s4)
    80002fb4:	e2f4d5e3          	bge	s1,a5,80002dde <usertrap+0xa8>
        if(sizeofq[i] > 0) yield();
    80002fb8:	00092783          	lw	a5,0(s2)
    80002fbc:	fef058e3          	blez	a5,80002fac <usertrap+0x276>
    80002fc0:	fffff097          	auipc	ra,0xfffff
    80002fc4:	31e080e7          	jalr	798(ra) # 800022de <yield>
    80002fc8:	b7d5                	j	80002fac <usertrap+0x276>

0000000080002fca <kerneltrap>:
{
    80002fca:	7179                	addi	sp,sp,-48
    80002fcc:	f406                	sd	ra,40(sp)
    80002fce:	f022                	sd	s0,32(sp)
    80002fd0:	ec26                	sd	s1,24(sp)
    80002fd2:	e84a                	sd	s2,16(sp)
    80002fd4:	e44e                	sd	s3,8(sp)
    80002fd6:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002fd8:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002fdc:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002fe0:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002fe4:	1004f793          	andi	a5,s1,256
    80002fe8:	cb85                	beqz	a5,80003018 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002fea:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002fee:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002ff0:	ef85                	bnez	a5,80003028 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002ff2:	00000097          	auipc	ra,0x0
    80002ff6:	ca2080e7          	jalr	-862(ra) # 80002c94 <devintr>
    80002ffa:	cd1d                	beqz	a0,80003038 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002ffc:	4789                	li	a5,2
    80002ffe:	06f50a63          	beq	a0,a5,80003072 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003002:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003006:	10049073          	csrw	sstatus,s1
}
    8000300a:	70a2                	ld	ra,40(sp)
    8000300c:	7402                	ld	s0,32(sp)
    8000300e:	64e2                	ld	s1,24(sp)
    80003010:	6942                	ld	s2,16(sp)
    80003012:	69a2                	ld	s3,8(sp)
    80003014:	6145                	addi	sp,sp,48
    80003016:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003018:	00005517          	auipc	a0,0x5
    8000301c:	3d850513          	addi	a0,a0,984 # 800083f0 <states.0+0x100>
    80003020:	ffffd097          	auipc	ra,0xffffd
    80003024:	520080e7          	jalr	1312(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80003028:	00005517          	auipc	a0,0x5
    8000302c:	3f050513          	addi	a0,a0,1008 # 80008418 <states.0+0x128>
    80003030:	ffffd097          	auipc	ra,0xffffd
    80003034:	510080e7          	jalr	1296(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    80003038:	85ce                	mv	a1,s3
    8000303a:	00005517          	auipc	a0,0x5
    8000303e:	3fe50513          	addi	a0,a0,1022 # 80008438 <states.0+0x148>
    80003042:	ffffd097          	auipc	ra,0xffffd
    80003046:	548080e7          	jalr	1352(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000304a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000304e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003052:	00005517          	auipc	a0,0x5
    80003056:	3f650513          	addi	a0,a0,1014 # 80008448 <states.0+0x158>
    8000305a:	ffffd097          	auipc	ra,0xffffd
    8000305e:	530080e7          	jalr	1328(ra) # 8000058a <printf>
    panic("kerneltrap");
    80003062:	00005517          	auipc	a0,0x5
    80003066:	3fe50513          	addi	a0,a0,1022 # 80008460 <states.0+0x170>
    8000306a:	ffffd097          	auipc	ra,0xffffd
    8000306e:	4d6080e7          	jalr	1238(ra) # 80000540 <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003072:	fffff097          	auipc	ra,0xfffff
    80003076:	ad4080e7          	jalr	-1324(ra) # 80001b46 <myproc>
    8000307a:	d541                	beqz	a0,80003002 <kerneltrap+0x38>
    8000307c:	fffff097          	auipc	ra,0xfffff
    80003080:	aca080e7          	jalr	-1334(ra) # 80001b46 <myproc>
    80003084:	09852703          	lw	a4,152(a0)
    80003088:	4791                	li	a5,4
    8000308a:	f6f71ce3          	bne	a4,a5,80003002 <kerneltrap+0x38>
    yield();
    8000308e:	fffff097          	auipc	ra,0xfffff
    80003092:	250080e7          	jalr	592(ra) # 800022de <yield>
    80003096:	b7b5                	j	80003002 <kerneltrap+0x38>

0000000080003098 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003098:	1101                	addi	sp,sp,-32
    8000309a:	ec06                	sd	ra,24(sp)
    8000309c:	e822                	sd	s0,16(sp)
    8000309e:	e426                	sd	s1,8(sp)
    800030a0:	1000                	addi	s0,sp,32
    800030a2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800030a4:	fffff097          	auipc	ra,0xfffff
    800030a8:	aa2080e7          	jalr	-1374(ra) # 80001b46 <myproc>
  switch (n) {
    800030ac:	4795                	li	a5,5
    800030ae:	0497e163          	bltu	a5,s1,800030f0 <argraw+0x58>
    800030b2:	048a                	slli	s1,s1,0x2
    800030b4:	00005717          	auipc	a4,0x5
    800030b8:	3e470713          	addi	a4,a4,996 # 80008498 <states.0+0x1a8>
    800030bc:	94ba                	add	s1,s1,a4
    800030be:	409c                	lw	a5,0(s1)
    800030c0:	97ba                	add	a5,a5,a4
    800030c2:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800030c4:	6d7c                	ld	a5,216(a0)
    800030c6:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800030c8:	60e2                	ld	ra,24(sp)
    800030ca:	6442                	ld	s0,16(sp)
    800030cc:	64a2                	ld	s1,8(sp)
    800030ce:	6105                	addi	sp,sp,32
    800030d0:	8082                	ret
    return p->trapframe->a1;
    800030d2:	6d7c                	ld	a5,216(a0)
    800030d4:	7fa8                	ld	a0,120(a5)
    800030d6:	bfcd                	j	800030c8 <argraw+0x30>
    return p->trapframe->a2;
    800030d8:	6d7c                	ld	a5,216(a0)
    800030da:	63c8                	ld	a0,128(a5)
    800030dc:	b7f5                	j	800030c8 <argraw+0x30>
    return p->trapframe->a3;
    800030de:	6d7c                	ld	a5,216(a0)
    800030e0:	67c8                	ld	a0,136(a5)
    800030e2:	b7dd                	j	800030c8 <argraw+0x30>
    return p->trapframe->a4;
    800030e4:	6d7c                	ld	a5,216(a0)
    800030e6:	6bc8                	ld	a0,144(a5)
    800030e8:	b7c5                	j	800030c8 <argraw+0x30>
    return p->trapframe->a5;
    800030ea:	6d7c                	ld	a5,216(a0)
    800030ec:	6fc8                	ld	a0,152(a5)
    800030ee:	bfe9                	j	800030c8 <argraw+0x30>
  panic("argraw");
    800030f0:	00005517          	auipc	a0,0x5
    800030f4:	38050513          	addi	a0,a0,896 # 80008470 <states.0+0x180>
    800030f8:	ffffd097          	auipc	ra,0xffffd
    800030fc:	448080e7          	jalr	1096(ra) # 80000540 <panic>

0000000080003100 <fetchaddr>:
{
    80003100:	1101                	addi	sp,sp,-32
    80003102:	ec06                	sd	ra,24(sp)
    80003104:	e822                	sd	s0,16(sp)
    80003106:	e426                	sd	s1,8(sp)
    80003108:	e04a                	sd	s2,0(sp)
    8000310a:	1000                	addi	s0,sp,32
    8000310c:	84aa                	mv	s1,a0
    8000310e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003110:	fffff097          	auipc	ra,0xfffff
    80003114:	a36080e7          	jalr	-1482(ra) # 80001b46 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80003118:	657c                	ld	a5,200(a0)
    8000311a:	02f4f863          	bgeu	s1,a5,8000314a <fetchaddr+0x4a>
    8000311e:	00848713          	addi	a4,s1,8
    80003122:	02e7e663          	bltu	a5,a4,8000314e <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003126:	46a1                	li	a3,8
    80003128:	8626                	mv	a2,s1
    8000312a:	85ca                	mv	a1,s2
    8000312c:	6968                	ld	a0,208(a0)
    8000312e:	ffffe097          	auipc	ra,0xffffe
    80003132:	5ca080e7          	jalr	1482(ra) # 800016f8 <copyin>
    80003136:	00a03533          	snez	a0,a0
    8000313a:	40a00533          	neg	a0,a0
}
    8000313e:	60e2                	ld	ra,24(sp)
    80003140:	6442                	ld	s0,16(sp)
    80003142:	64a2                	ld	s1,8(sp)
    80003144:	6902                	ld	s2,0(sp)
    80003146:	6105                	addi	sp,sp,32
    80003148:	8082                	ret
    return -1;
    8000314a:	557d                	li	a0,-1
    8000314c:	bfcd                	j	8000313e <fetchaddr+0x3e>
    8000314e:	557d                	li	a0,-1
    80003150:	b7fd                	j	8000313e <fetchaddr+0x3e>

0000000080003152 <fetchstr>:
{
    80003152:	7179                	addi	sp,sp,-48
    80003154:	f406                	sd	ra,40(sp)
    80003156:	f022                	sd	s0,32(sp)
    80003158:	ec26                	sd	s1,24(sp)
    8000315a:	e84a                	sd	s2,16(sp)
    8000315c:	e44e                	sd	s3,8(sp)
    8000315e:	1800                	addi	s0,sp,48
    80003160:	892a                	mv	s2,a0
    80003162:	84ae                	mv	s1,a1
    80003164:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003166:	fffff097          	auipc	ra,0xfffff
    8000316a:	9e0080e7          	jalr	-1568(ra) # 80001b46 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    8000316e:	86ce                	mv	a3,s3
    80003170:	864a                	mv	a2,s2
    80003172:	85a6                	mv	a1,s1
    80003174:	6968                	ld	a0,208(a0)
    80003176:	ffffe097          	auipc	ra,0xffffe
    8000317a:	610080e7          	jalr	1552(ra) # 80001786 <copyinstr>
    8000317e:	00054e63          	bltz	a0,8000319a <fetchstr+0x48>
  return strlen(buf);
    80003182:	8526                	mv	a0,s1
    80003184:	ffffe097          	auipc	ra,0xffffe
    80003188:	cca080e7          	jalr	-822(ra) # 80000e4e <strlen>
}
    8000318c:	70a2                	ld	ra,40(sp)
    8000318e:	7402                	ld	s0,32(sp)
    80003190:	64e2                	ld	s1,24(sp)
    80003192:	6942                	ld	s2,16(sp)
    80003194:	69a2                	ld	s3,8(sp)
    80003196:	6145                	addi	sp,sp,48
    80003198:	8082                	ret
    return -1;
    8000319a:	557d                	li	a0,-1
    8000319c:	bfc5                	j	8000318c <fetchstr+0x3a>

000000008000319e <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    8000319e:	1101                	addi	sp,sp,-32
    800031a0:	ec06                	sd	ra,24(sp)
    800031a2:	e822                	sd	s0,16(sp)
    800031a4:	e426                	sd	s1,8(sp)
    800031a6:	1000                	addi	s0,sp,32
    800031a8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800031aa:	00000097          	auipc	ra,0x0
    800031ae:	eee080e7          	jalr	-274(ra) # 80003098 <argraw>
    800031b2:	c088                	sw	a0,0(s1)
}
    800031b4:	60e2                	ld	ra,24(sp)
    800031b6:	6442                	ld	s0,16(sp)
    800031b8:	64a2                	ld	s1,8(sp)
    800031ba:	6105                	addi	sp,sp,32
    800031bc:	8082                	ret

00000000800031be <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800031be:	1101                	addi	sp,sp,-32
    800031c0:	ec06                	sd	ra,24(sp)
    800031c2:	e822                	sd	s0,16(sp)
    800031c4:	e426                	sd	s1,8(sp)
    800031c6:	1000                	addi	s0,sp,32
    800031c8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800031ca:	00000097          	auipc	ra,0x0
    800031ce:	ece080e7          	jalr	-306(ra) # 80003098 <argraw>
    800031d2:	e088                	sd	a0,0(s1)
}
    800031d4:	60e2                	ld	ra,24(sp)
    800031d6:	6442                	ld	s0,16(sp)
    800031d8:	64a2                	ld	s1,8(sp)
    800031da:	6105                	addi	sp,sp,32
    800031dc:	8082                	ret

00000000800031de <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800031de:	7179                	addi	sp,sp,-48
    800031e0:	f406                	sd	ra,40(sp)
    800031e2:	f022                	sd	s0,32(sp)
    800031e4:	ec26                	sd	s1,24(sp)
    800031e6:	e84a                	sd	s2,16(sp)
    800031e8:	1800                	addi	s0,sp,48
    800031ea:	84ae                	mv	s1,a1
    800031ec:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800031ee:	fd840593          	addi	a1,s0,-40
    800031f2:	00000097          	auipc	ra,0x0
    800031f6:	fcc080e7          	jalr	-52(ra) # 800031be <argaddr>
  return fetchstr(addr, buf, max);
    800031fa:	864a                	mv	a2,s2
    800031fc:	85a6                	mv	a1,s1
    800031fe:	fd843503          	ld	a0,-40(s0)
    80003202:	00000097          	auipc	ra,0x0
    80003206:	f50080e7          	jalr	-176(ra) # 80003152 <fetchstr>
}
    8000320a:	70a2                	ld	ra,40(sp)
    8000320c:	7402                	ld	s0,32(sp)
    8000320e:	64e2                	ld	s1,24(sp)
    80003210:	6942                	ld	s2,16(sp)
    80003212:	6145                	addi	sp,sp,48
    80003214:	8082                	ret

0000000080003216 <syscall>:
[SYS_settickets]  sys_settickets,
};

void
syscall(void)
{
    80003216:	1101                	addi	sp,sp,-32
    80003218:	ec06                	sd	ra,24(sp)
    8000321a:	e822                	sd	s0,16(sp)
    8000321c:	e426                	sd	s1,8(sp)
    8000321e:	e04a                	sd	s2,0(sp)
    80003220:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003222:	fffff097          	auipc	ra,0xfffff
    80003226:	924080e7          	jalr	-1756(ra) # 80001b46 <myproc>
    8000322a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000322c:	0d853903          	ld	s2,216(a0)
    80003230:	0a893783          	ld	a5,168(s2)
    80003234:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003238:	37fd                	addiw	a5,a5,-1
    8000323a:	4765                	li	a4,25
    8000323c:	00f76f63          	bltu	a4,a5,8000325a <syscall+0x44>
    80003240:	00369713          	slli	a4,a3,0x3
    80003244:	00005797          	auipc	a5,0x5
    80003248:	26c78793          	addi	a5,a5,620 # 800084b0 <syscalls>
    8000324c:	97ba                	add	a5,a5,a4
    8000324e:	639c                	ld	a5,0(a5)
    80003250:	c789                	beqz	a5,8000325a <syscall+0x44>
      // p->syscall_count[num]++;
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80003252:	9782                	jalr	a5
    80003254:	06a93823          	sd	a0,112(s2)
    80003258:	a005                	j	80003278 <syscall+0x62>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000325a:	1d848613          	addi	a2,s1,472
    8000325e:	0b04a583          	lw	a1,176(s1)
    80003262:	00005517          	auipc	a0,0x5
    80003266:	21650513          	addi	a0,a0,534 # 80008478 <states.0+0x188>
    8000326a:	ffffd097          	auipc	ra,0xffffd
    8000326e:	320080e7          	jalr	800(ra) # 8000058a <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003272:	6cfc                	ld	a5,216(s1)
    80003274:	577d                	li	a4,-1
    80003276:	fbb8                	sd	a4,112(a5)
  }
}
    80003278:	60e2                	ld	ra,24(sp)
    8000327a:	6442                	ld	s0,16(sp)
    8000327c:	64a2                	ld	s1,8(sp)
    8000327e:	6902                	ld	s2,0(sp)
    80003280:	6105                	addi	sp,sp,32
    80003282:	8082                	ret

0000000080003284 <sys_exit>:
#include "proc.h"
#include "memlayout.h"
#include "syscall.h"
uint64
sys_exit(void)
{
    80003284:	1101                	addi	sp,sp,-32
    80003286:	ec06                	sd	ra,24(sp)
    80003288:	e822                	sd	s0,16(sp)
    8000328a:	1000                	addi	s0,sp,32
  myproc()->syscall_count[SYS_exit]++;
    8000328c:	fffff097          	auipc	ra,0xfffff
    80003290:	8ba080e7          	jalr	-1862(ra) # 80001b46 <myproc>
    80003294:	511c                	lw	a5,32(a0)
    80003296:	2785                	addiw	a5,a5,1
    80003298:	d11c                	sw	a5,32(a0)
  int n;
  argint(0, &n);
    8000329a:	fec40593          	addi	a1,s0,-20
    8000329e:	4501                	li	a0,0
    800032a0:	00000097          	auipc	ra,0x0
    800032a4:	efe080e7          	jalr	-258(ra) # 8000319e <argint>
  exit(n);
    800032a8:	fec42503          	lw	a0,-20(s0)
    800032ac:	fffff097          	auipc	ra,0xfffff
    800032b0:	1d0080e7          	jalr	464(ra) # 8000247c <exit>
  return 0; // not reached
}
    800032b4:	4501                	li	a0,0
    800032b6:	60e2                	ld	ra,24(sp)
    800032b8:	6442                	ld	s0,16(sp)
    800032ba:	6105                	addi	sp,sp,32
    800032bc:	8082                	ret

00000000800032be <sys_getpid>:

uint64
sys_getpid(void)
{
    800032be:	1141                	addi	sp,sp,-16
    800032c0:	e406                	sd	ra,8(sp)
    800032c2:	e022                	sd	s0,0(sp)
    800032c4:	0800                	addi	s0,sp,16
  myproc()->syscall_count[SYS_getpid]++;
    800032c6:	fffff097          	auipc	ra,0xfffff
    800032ca:	880080e7          	jalr	-1920(ra) # 80001b46 <myproc>
    800032ce:	417c                	lw	a5,68(a0)
    800032d0:	2785                	addiw	a5,a5,1
    800032d2:	c17c                	sw	a5,68(a0)
  return myproc()->pid;
    800032d4:	fffff097          	auipc	ra,0xfffff
    800032d8:	872080e7          	jalr	-1934(ra) # 80001b46 <myproc>
}
    800032dc:	0b052503          	lw	a0,176(a0)
    800032e0:	60a2                	ld	ra,8(sp)
    800032e2:	6402                	ld	s0,0(sp)
    800032e4:	0141                	addi	sp,sp,16
    800032e6:	8082                	ret

00000000800032e8 <sys_fork>:

uint64
sys_fork(void)
{
    800032e8:	1141                	addi	sp,sp,-16
    800032ea:	e406                	sd	ra,8(sp)
    800032ec:	e022                	sd	s0,0(sp)
    800032ee:	0800                	addi	s0,sp,16
  myproc()->syscall_count[SYS_fork]++;
    800032f0:	fffff097          	auipc	ra,0xfffff
    800032f4:	856080e7          	jalr	-1962(ra) # 80001b46 <myproc>
    800032f8:	4d5c                	lw	a5,28(a0)
    800032fa:	2785                	addiw	a5,a5,1
    800032fc:	cd5c                	sw	a5,28(a0)
  return fork();
    800032fe:	fffff097          	auipc	ra,0xfffff
    80003302:	c8c080e7          	jalr	-884(ra) # 80001f8a <fork>
}
    80003306:	60a2                	ld	ra,8(sp)
    80003308:	6402                	ld	s0,0(sp)
    8000330a:	0141                	addi	sp,sp,16
    8000330c:	8082                	ret

000000008000330e <sys_wait>:

uint64
sys_wait(void)
{
    8000330e:	1101                	addi	sp,sp,-32
    80003310:	ec06                	sd	ra,24(sp)
    80003312:	e822                	sd	s0,16(sp)
    80003314:	1000                	addi	s0,sp,32
  myproc()->syscall_count[SYS_wait]++;
    80003316:	fffff097          	auipc	ra,0xfffff
    8000331a:	830080e7          	jalr	-2000(ra) # 80001b46 <myproc>
    8000331e:	515c                	lw	a5,36(a0)
    80003320:	2785                	addiw	a5,a5,1
    80003322:	d15c                	sw	a5,36(a0)
  uint64 p;
  argaddr(0, &p);
    80003324:	fe840593          	addi	a1,s0,-24
    80003328:	4501                	li	a0,0
    8000332a:	00000097          	auipc	ra,0x0
    8000332e:	e94080e7          	jalr	-364(ra) # 800031be <argaddr>
  return wait(p);
    80003332:	fe843503          	ld	a0,-24(s0)
    80003336:	fffff097          	auipc	ra,0xfffff
    8000333a:	31e080e7          	jalr	798(ra) # 80002654 <wait>
}
    8000333e:	60e2                	ld	ra,24(sp)
    80003340:	6442                	ld	s0,16(sp)
    80003342:	6105                	addi	sp,sp,32
    80003344:	8082                	ret

0000000080003346 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003346:	7179                	addi	sp,sp,-48
    80003348:	f406                	sd	ra,40(sp)
    8000334a:	f022                	sd	s0,32(sp)
    8000334c:	ec26                	sd	s1,24(sp)
    8000334e:	1800                	addi	s0,sp,48
  myproc()->syscall_count[SYS_sbrk]++;
    80003350:	ffffe097          	auipc	ra,0xffffe
    80003354:	7f6080e7          	jalr	2038(ra) # 80001b46 <myproc>
    80003358:	453c                	lw	a5,72(a0)
    8000335a:	2785                	addiw	a5,a5,1
    8000335c:	c53c                	sw	a5,72(a0)
  uint64 addr;
  int n;

  argint(0, &n);
    8000335e:	fdc40593          	addi	a1,s0,-36
    80003362:	4501                	li	a0,0
    80003364:	00000097          	auipc	ra,0x0
    80003368:	e3a080e7          	jalr	-454(ra) # 8000319e <argint>
  addr = myproc()->sz;
    8000336c:	ffffe097          	auipc	ra,0xffffe
    80003370:	7da080e7          	jalr	2010(ra) # 80001b46 <myproc>
    80003374:	6564                	ld	s1,200(a0)
  if (growproc(n) < 0)
    80003376:	fdc42503          	lw	a0,-36(s0)
    8000337a:	fffff097          	auipc	ra,0xfffff
    8000337e:	bb4080e7          	jalr	-1100(ra) # 80001f2e <growproc>
    80003382:	00054863          	bltz	a0,80003392 <sys_sbrk+0x4c>
    return -1;
  return addr;
}
    80003386:	8526                	mv	a0,s1
    80003388:	70a2                	ld	ra,40(sp)
    8000338a:	7402                	ld	s0,32(sp)
    8000338c:	64e2                	ld	s1,24(sp)
    8000338e:	6145                	addi	sp,sp,48
    80003390:	8082                	ret
    return -1;
    80003392:	54fd                	li	s1,-1
    80003394:	bfcd                	j	80003386 <sys_sbrk+0x40>

0000000080003396 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003396:	7139                	addi	sp,sp,-64
    80003398:	fc06                	sd	ra,56(sp)
    8000339a:	f822                	sd	s0,48(sp)
    8000339c:	f426                	sd	s1,40(sp)
    8000339e:	f04a                	sd	s2,32(sp)
    800033a0:	ec4e                	sd	s3,24(sp)
    800033a2:	0080                	addi	s0,sp,64
  myproc()->syscall_count[SYS_sleep]++;
    800033a4:	ffffe097          	auipc	ra,0xffffe
    800033a8:	7a2080e7          	jalr	1954(ra) # 80001b46 <myproc>
    800033ac:	457c                	lw	a5,76(a0)
    800033ae:	2785                	addiw	a5,a5,1
    800033b0:	c57c                	sw	a5,76(a0)
  int n;
  uint ticks0;

  argint(0, &n);
    800033b2:	fcc40593          	addi	a1,s0,-52
    800033b6:	4501                	li	a0,0
    800033b8:	00000097          	auipc	ra,0x0
    800033bc:	de6080e7          	jalr	-538(ra) # 8000319e <argint>
  acquire(&tickslock);
    800033c0:	00017517          	auipc	a0,0x17
    800033c4:	28050513          	addi	a0,a0,640 # 8001a640 <tickslock>
    800033c8:	ffffe097          	auipc	ra,0xffffe
    800033cc:	80e080e7          	jalr	-2034(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    800033d0:	00005917          	auipc	s2,0x5
    800033d4:	5c092903          	lw	s2,1472(s2) # 80008990 <ticks>
  while (ticks - ticks0 < n)
    800033d8:	fcc42783          	lw	a5,-52(s0)
    800033dc:	cf9d                	beqz	a5,8000341a <sys_sleep+0x84>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800033de:	00017997          	auipc	s3,0x17
    800033e2:	26298993          	addi	s3,s3,610 # 8001a640 <tickslock>
    800033e6:	00005497          	auipc	s1,0x5
    800033ea:	5aa48493          	addi	s1,s1,1450 # 80008990 <ticks>
    if (killed(myproc()))
    800033ee:	ffffe097          	auipc	ra,0xffffe
    800033f2:	758080e7          	jalr	1880(ra) # 80001b46 <myproc>
    800033f6:	fffff097          	auipc	ra,0xfffff
    800033fa:	22c080e7          	jalr	556(ra) # 80002622 <killed>
    800033fe:	ed15                	bnez	a0,8000343a <sys_sleep+0xa4>
    sleep(&ticks, &tickslock);
    80003400:	85ce                	mv	a1,s3
    80003402:	8526                	mv	a0,s1
    80003404:	fffff097          	auipc	ra,0xfffff
    80003408:	f18080e7          	jalr	-232(ra) # 8000231c <sleep>
  while (ticks - ticks0 < n)
    8000340c:	409c                	lw	a5,0(s1)
    8000340e:	412787bb          	subw	a5,a5,s2
    80003412:	fcc42703          	lw	a4,-52(s0)
    80003416:	fce7ece3          	bltu	a5,a4,800033ee <sys_sleep+0x58>
  }
  release(&tickslock);
    8000341a:	00017517          	auipc	a0,0x17
    8000341e:	22650513          	addi	a0,a0,550 # 8001a640 <tickslock>
    80003422:	ffffe097          	auipc	ra,0xffffe
    80003426:	868080e7          	jalr	-1944(ra) # 80000c8a <release>
  return 0;
    8000342a:	4501                	li	a0,0
}
    8000342c:	70e2                	ld	ra,56(sp)
    8000342e:	7442                	ld	s0,48(sp)
    80003430:	74a2                	ld	s1,40(sp)
    80003432:	7902                	ld	s2,32(sp)
    80003434:	69e2                	ld	s3,24(sp)
    80003436:	6121                	addi	sp,sp,64
    80003438:	8082                	ret
      release(&tickslock);
    8000343a:	00017517          	auipc	a0,0x17
    8000343e:	20650513          	addi	a0,a0,518 # 8001a640 <tickslock>
    80003442:	ffffe097          	auipc	ra,0xffffe
    80003446:	848080e7          	jalr	-1976(ra) # 80000c8a <release>
      return -1;
    8000344a:	557d                	li	a0,-1
    8000344c:	b7c5                	j	8000342c <sys_sleep+0x96>

000000008000344e <sys_kill>:

uint64
sys_kill(void)
{
    8000344e:	1101                	addi	sp,sp,-32
    80003450:	ec06                	sd	ra,24(sp)
    80003452:	e822                	sd	s0,16(sp)
    80003454:	1000                	addi	s0,sp,32
  myproc()->syscall_count[SYS_kill]++;
    80003456:	ffffe097          	auipc	ra,0xffffe
    8000345a:	6f0080e7          	jalr	1776(ra) # 80001b46 <myproc>
    8000345e:	591c                	lw	a5,48(a0)
    80003460:	2785                	addiw	a5,a5,1
    80003462:	d91c                	sw	a5,48(a0)
  int pid;

  argint(0, &pid);
    80003464:	fec40593          	addi	a1,s0,-20
    80003468:	4501                	li	a0,0
    8000346a:	00000097          	auipc	ra,0x0
    8000346e:	d34080e7          	jalr	-716(ra) # 8000319e <argint>
  return kill(pid);
    80003472:	fec42503          	lw	a0,-20(s0)
    80003476:	fffff097          	auipc	ra,0xfffff
    8000347a:	0f6080e7          	jalr	246(ra) # 8000256c <kill>
}
    8000347e:	60e2                	ld	ra,24(sp)
    80003480:	6442                	ld	s0,16(sp)
    80003482:	6105                	addi	sp,sp,32
    80003484:	8082                	ret

0000000080003486 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003486:	1101                	addi	sp,sp,-32
    80003488:	ec06                	sd	ra,24(sp)
    8000348a:	e822                	sd	s0,16(sp)
    8000348c:	e426                	sd	s1,8(sp)
    8000348e:	1000                	addi	s0,sp,32
  myproc()->syscall_count[SYS_uptime]++;
    80003490:	ffffe097          	auipc	ra,0xffffe
    80003494:	6b6080e7          	jalr	1718(ra) # 80001b46 <myproc>
    80003498:	493c                	lw	a5,80(a0)
    8000349a:	2785                	addiw	a5,a5,1
    8000349c:	c93c                	sw	a5,80(a0)
  uint xticks;

  acquire(&tickslock);
    8000349e:	00017517          	auipc	a0,0x17
    800034a2:	1a250513          	addi	a0,a0,418 # 8001a640 <tickslock>
    800034a6:	ffffd097          	auipc	ra,0xffffd
    800034aa:	730080e7          	jalr	1840(ra) # 80000bd6 <acquire>
  xticks = ticks;
    800034ae:	00005497          	auipc	s1,0x5
    800034b2:	4e24a483          	lw	s1,1250(s1) # 80008990 <ticks>
  release(&tickslock);
    800034b6:	00017517          	auipc	a0,0x17
    800034ba:	18a50513          	addi	a0,a0,394 # 8001a640 <tickslock>
    800034be:	ffffd097          	auipc	ra,0xffffd
    800034c2:	7cc080e7          	jalr	1996(ra) # 80000c8a <release>
  return xticks;
}
    800034c6:	02049513          	slli	a0,s1,0x20
    800034ca:	9101                	srli	a0,a0,0x20
    800034cc:	60e2                	ld	ra,24(sp)
    800034ce:	6442                	ld	s0,16(sp)
    800034d0:	64a2                	ld	s1,8(sp)
    800034d2:	6105                	addi	sp,sp,32
    800034d4:	8082                	ret

00000000800034d6 <sys_waitx>:

uint64
sys_waitx(void)
{
    800034d6:	7139                	addi	sp,sp,-64
    800034d8:	fc06                	sd	ra,56(sp)
    800034da:	f822                	sd	s0,48(sp)
    800034dc:	f426                	sd	s1,40(sp)
    800034de:	f04a                	sd	s2,32(sp)
    800034e0:	0080                	addi	s0,sp,64
  myproc()->syscall_count[SYS_waitx]++;
    800034e2:	ffffe097          	auipc	ra,0xffffe
    800034e6:	664080e7          	jalr	1636(ra) # 80001b46 <myproc>
    800034ea:	593c                	lw	a5,112(a0)
    800034ec:	2785                	addiw	a5,a5,1
    800034ee:	d93c                	sw	a5,112(a0)
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    800034f0:	fd840593          	addi	a1,s0,-40
    800034f4:	4501                	li	a0,0
    800034f6:	00000097          	auipc	ra,0x0
    800034fa:	cc8080e7          	jalr	-824(ra) # 800031be <argaddr>
  argaddr(1, &addr1); // user virtual memory
    800034fe:	fd040593          	addi	a1,s0,-48
    80003502:	4505                	li	a0,1
    80003504:	00000097          	auipc	ra,0x0
    80003508:	cba080e7          	jalr	-838(ra) # 800031be <argaddr>
  argaddr(2, &addr2);
    8000350c:	fc840593          	addi	a1,s0,-56
    80003510:	4509                	li	a0,2
    80003512:	00000097          	auipc	ra,0x0
    80003516:	cac080e7          	jalr	-852(ra) # 800031be <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    8000351a:	fc040613          	addi	a2,s0,-64
    8000351e:	fc440593          	addi	a1,s0,-60
    80003522:	fd843503          	ld	a0,-40(s0)
    80003526:	fffff097          	auipc	ra,0xfffff
    8000352a:	3d8080e7          	jalr	984(ra) # 800028fe <waitx>
    8000352e:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80003530:	ffffe097          	auipc	ra,0xffffe
    80003534:	616080e7          	jalr	1558(ra) # 80001b46 <myproc>
    80003538:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    8000353a:	4691                	li	a3,4
    8000353c:	fc440613          	addi	a2,s0,-60
    80003540:	fd043583          	ld	a1,-48(s0)
    80003544:	6968                	ld	a0,208(a0)
    80003546:	ffffe097          	auipc	ra,0xffffe
    8000354a:	126080e7          	jalr	294(ra) # 8000166c <copyout>
    return -1;
    8000354e:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003550:	00054f63          	bltz	a0,8000356e <sys_waitx+0x98>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    80003554:	4691                	li	a3,4
    80003556:	fc040613          	addi	a2,s0,-64
    8000355a:	fc843583          	ld	a1,-56(s0)
    8000355e:	68e8                	ld	a0,208(s1)
    80003560:	ffffe097          	auipc	ra,0xffffe
    80003564:	10c080e7          	jalr	268(ra) # 8000166c <copyout>
    80003568:	00054a63          	bltz	a0,8000357c <sys_waitx+0xa6>
    return -1;
  return ret;
    8000356c:	87ca                	mv	a5,s2
}
    8000356e:	853e                	mv	a0,a5
    80003570:	70e2                	ld	ra,56(sp)
    80003572:	7442                	ld	s0,48(sp)
    80003574:	74a2                	ld	s1,40(sp)
    80003576:	7902                	ld	s2,32(sp)
    80003578:	6121                	addi	sp,sp,64
    8000357a:	8082                	ret
    return -1;
    8000357c:	57fd                	li	a5,-1
    8000357e:	bfc5                	j	8000356e <sys_waitx+0x98>

0000000080003580 <sys_getSysCount>:
int sys_getSysCount(void) {
    80003580:	1101                	addi	sp,sp,-32
    80003582:	ec06                	sd	ra,24(sp)
    80003584:	e822                	sd	s0,16(sp)
    80003586:	1000                	addi	s0,sp,32
  myproc()->syscall_count[SYS_getSysCount]++;
    80003588:	ffffe097          	auipc	ra,0xffffe
    8000358c:	5be080e7          	jalr	1470(ra) # 80001b46 <myproc>
    80003590:	597c                	lw	a5,116(a0)
    80003592:	2785                	addiw	a5,a5,1
    80003594:	d97c                	sw	a5,116(a0)
    int mask; // Get the mask argument
    argint(0,&mask);
    80003596:	fec40593          	addi	a1,s0,-20
    8000359a:	4501                	li	a0,0
    8000359c:	00000097          	auipc	ra,0x0
    800035a0:	c02080e7          	jalr	-1022(ra) # 8000319e <argint>
    
    struct proc *p = myproc();
    800035a4:	ffffe097          	auipc	ra,0xffffe
    800035a8:	5a2080e7          	jalr	1442(ra) # 80001b46 <myproc>
    // Find the syscall index from the mask
    int syscall_index = -1;
    for (int i = 0; i < 32; i++) {
        if (mask & (1 << i)) {
    800035ac:	fec42683          	lw	a3,-20(s0)
    800035b0:	0016f793          	andi	a5,a3,1
    800035b4:	eb95                	bnez	a5,800035e8 <sys_getSysCount+0x68>
    for (int i = 0; i < 32; i++) {
    800035b6:	4785                	li	a5,1
    800035b8:	02000613          	li	a2,32
        if (mask & (1 << i)) {
    800035bc:	40f6d73b          	sraw	a4,a3,a5
    800035c0:	8b05                	andi	a4,a4,1
    800035c2:	e711                	bnez	a4,800035ce <sys_getSysCount+0x4e>
    for (int i = 0; i < 32; i++) {
    800035c4:	2785                	addiw	a5,a5,1
    800035c6:	fec79be3          	bne	a5,a2,800035bc <sys_getSysCount+0x3c>
            break;
        }
    }

    if (syscall_index == -1 || syscall_index >= NELEM(p->syscall_count)) {
        return -1; // Invalid mask or syscall index
    800035ca:	557d                	li	a0,-1
    800035cc:	a811                	j	800035e0 <sys_getSysCount+0x60>
    if (syscall_index == -1 || syscall_index >= NELEM(p->syscall_count)) {
    800035ce:	0007871b          	sext.w	a4,a5
    800035d2:	46fd                	li	a3,31
    800035d4:	00e6ec63          	bltu	a3,a4,800035ec <sys_getSysCount+0x6c>
    }

    return p->syscall_count[syscall_index]; // Return the count for that syscall
    800035d8:	0791                	addi	a5,a5,4
    800035da:	078a                	slli	a5,a5,0x2
    800035dc:	953e                	add	a0,a0,a5
    800035de:	4508                	lw	a0,8(a0)
}
    800035e0:	60e2                	ld	ra,24(sp)
    800035e2:	6442                	ld	s0,16(sp)
    800035e4:	6105                	addi	sp,sp,32
    800035e6:	8082                	ret
    for (int i = 0; i < 32; i++) {
    800035e8:	4781                	li	a5,0
    800035ea:	b7fd                	j	800035d8 <sys_getSysCount+0x58>
        return -1; // Invalid mask or syscall index
    800035ec:	557d                	li	a0,-1
    800035ee:	bfcd                	j	800035e0 <sys_getSysCount+0x60>

00000000800035f0 <sys_sigalarm>:
uint64 sys_sigalarm(void)
{
    800035f0:	1101                	addi	sp,sp,-32
    800035f2:	ec06                	sd	ra,24(sp)
    800035f4:	e822                	sd	s0,16(sp)
    800035f6:	1000                	addi	s0,sp,32
  myproc()->syscall_count[SYS_sigalarm]++;
    800035f8:	ffffe097          	auipc	ra,0xffffe
    800035fc:	54e080e7          	jalr	1358(ra) # 80001b46 <myproc>
    80003600:	5d3c                	lw	a5,120(a0)
    80003602:	2785                	addiw	a5,a5,1
    80003604:	dd3c                	sw	a5,120(a0)
  uint64 addr;
  int ticks;
  argint(0, &ticks);
    80003606:	fe440593          	addi	a1,s0,-28
    8000360a:	4501                	li	a0,0
    8000360c:	00000097          	auipc	ra,0x0
    80003610:	b92080e7          	jalr	-1134(ra) # 8000319e <argint>
    // return -1;
  argaddr(1, &addr);
    80003614:	fe840593          	addi	a1,s0,-24
    80003618:	4505                	li	a0,1
    8000361a:	00000097          	auipc	ra,0x0
    8000361e:	ba4080e7          	jalr	-1116(ra) # 800031be <argaddr>
  myproc()->ticks = ticks;
    80003622:	ffffe097          	auipc	ra,0xffffe
    80003626:	524080e7          	jalr	1316(ra) # 80001b46 <myproc>
    8000362a:	fe442783          	lw	a5,-28(s0)
    8000362e:	20f52023          	sw	a5,512(a0)
  myproc()->handler = addr;
    80003632:	ffffe097          	auipc	ra,0xffffe
    80003636:	514080e7          	jalr	1300(ra) # 80001b46 <myproc>
    8000363a:	fe843783          	ld	a5,-24(s0)
    8000363e:	1ef53c23          	sd	a5,504(a0)
  return 0;
}
    80003642:	4501                	li	a0,0
    80003644:	60e2                	ld	ra,24(sp)
    80003646:	6442                	ld	s0,16(sp)
    80003648:	6105                	addi	sp,sp,32
    8000364a:	8082                	ret

000000008000364c <sys_sigreturn>:
uint64 sys_sigreturn(void)
{
    8000364c:	1101                	addi	sp,sp,-32
    8000364e:	ec06                	sd	ra,24(sp)
    80003650:	e822                	sd	s0,16(sp)
    80003652:	e426                	sd	s1,8(sp)
    80003654:	1000                	addi	s0,sp,32
  myproc()->syscall_count[SYS_sigreturn]++;
    80003656:	ffffe097          	auipc	ra,0xffffe
    8000365a:	4f0080e7          	jalr	1264(ra) # 80001b46 <myproc>
    8000365e:	5d7c                	lw	a5,124(a0)
    80003660:	2785                	addiw	a5,a5,1
    80003662:	dd7c                	sw	a5,124(a0)
  struct proc *p = myproc();
    80003664:	ffffe097          	auipc	ra,0xffffe
    80003668:	4e2080e7          	jalr	1250(ra) # 80001b46 <myproc>
    8000366c:	84aa                	mv	s1,a0
  memmove(p->trapframe, p->alarm_tf, PGSIZE);
    8000366e:	6605                	lui	a2,0x1
    80003670:	20853583          	ld	a1,520(a0)
    80003674:	6d68                	ld	a0,216(a0)
    80003676:	ffffd097          	auipc	ra,0xffffd
    8000367a:	6b8080e7          	jalr	1720(ra) # 80000d2e <memmove>

  kfree(p->alarm_tf);
    8000367e:	2084b503          	ld	a0,520(s1)
    80003682:	ffffd097          	auipc	ra,0xffffd
    80003686:	366080e7          	jalr	870(ra) # 800009e8 <kfree>
  p->alarm_tf = 0;
    8000368a:	2004b423          	sd	zero,520(s1)
  p->alarm_on = 0;
    8000368e:	2004a823          	sw	zero,528(s1)
  p->cur_ticks = 0;
    80003692:	2004a223          	sw	zero,516(s1)
  p->in_alarm_handler = 0;
    80003696:	2004aa23          	sw	zero,532(s1)
  usertrapret();
    8000369a:	fffff097          	auipc	ra,0xfffff
    8000369e:	510080e7          	jalr	1296(ra) # 80002baa <usertrapret>
  return 0;
}
    800036a2:	4501                	li	a0,0
    800036a4:	60e2                	ld	ra,24(sp)
    800036a6:	6442                	ld	s0,16(sp)
    800036a8:	64a2                	ld	s1,8(sp)
    800036aa:	6105                	addi	sp,sp,32
    800036ac:	8082                	ret

00000000800036ae <sys_settickets>:
uint64 sys_settickets(void) {
    800036ae:	1101                	addi	sp,sp,-32
    800036b0:	ec06                	sd	ra,24(sp)
    800036b2:	e822                	sd	s0,16(sp)
    800036b4:	1000                	addi	s0,sp,32
  myproc()->syscall_count[SYS_settickets]++;
    800036b6:	ffffe097          	auipc	ra,0xffffe
    800036ba:	490080e7          	jalr	1168(ra) # 80001b46 <myproc>
    800036be:	08052783          	lw	a5,128(a0)
    800036c2:	2785                	addiw	a5,a5,1
    800036c4:	08f52023          	sw	a5,128(a0)
  int n;
  argint(0, &n);
    800036c8:	fec40593          	addi	a1,s0,-20
    800036cc:	4501                	li	a0,0
    800036ce:	00000097          	auipc	ra,0x0
    800036d2:	ad0080e7          	jalr	-1328(ra) # 8000319e <argint>
  myproc()->tickets = n;
    800036d6:	ffffe097          	auipc	ra,0xffffe
    800036da:	470080e7          	jalr	1136(ra) # 80001b46 <myproc>
    800036de:	fec42783          	lw	a5,-20(s0)
    800036e2:	20f52c23          	sw	a5,536(a0)
  return 0;
}
    800036e6:	4501                	li	a0,0
    800036e8:	60e2                	ld	ra,24(sp)
    800036ea:	6442                	ld	s0,16(sp)
    800036ec:	6105                	addi	sp,sp,32
    800036ee:	8082                	ret

00000000800036f0 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800036f0:	7179                	addi	sp,sp,-48
    800036f2:	f406                	sd	ra,40(sp)
    800036f4:	f022                	sd	s0,32(sp)
    800036f6:	ec26                	sd	s1,24(sp)
    800036f8:	e84a                	sd	s2,16(sp)
    800036fa:	e44e                	sd	s3,8(sp)
    800036fc:	e052                	sd	s4,0(sp)
    800036fe:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003700:	00005597          	auipc	a1,0x5
    80003704:	e8858593          	addi	a1,a1,-376 # 80008588 <syscalls+0xd8>
    80003708:	00017517          	auipc	a0,0x17
    8000370c:	f5050513          	addi	a0,a0,-176 # 8001a658 <bcache>
    80003710:	ffffd097          	auipc	ra,0xffffd
    80003714:	436080e7          	jalr	1078(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003718:	0001f797          	auipc	a5,0x1f
    8000371c:	f4078793          	addi	a5,a5,-192 # 80022658 <bcache+0x8000>
    80003720:	0001f717          	auipc	a4,0x1f
    80003724:	1a070713          	addi	a4,a4,416 # 800228c0 <bcache+0x8268>
    80003728:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000372c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003730:	00017497          	auipc	s1,0x17
    80003734:	f4048493          	addi	s1,s1,-192 # 8001a670 <bcache+0x18>
    b->next = bcache.head.next;
    80003738:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000373a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000373c:	00005a17          	auipc	s4,0x5
    80003740:	e54a0a13          	addi	s4,s4,-428 # 80008590 <syscalls+0xe0>
    b->next = bcache.head.next;
    80003744:	2b893783          	ld	a5,696(s2)
    80003748:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000374a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000374e:	85d2                	mv	a1,s4
    80003750:	01048513          	addi	a0,s1,16
    80003754:	00001097          	auipc	ra,0x1
    80003758:	4c8080e7          	jalr	1224(ra) # 80004c1c <initsleeplock>
    bcache.head.next->prev = b;
    8000375c:	2b893783          	ld	a5,696(s2)
    80003760:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003762:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003766:	45848493          	addi	s1,s1,1112
    8000376a:	fd349de3          	bne	s1,s3,80003744 <binit+0x54>
  }
}
    8000376e:	70a2                	ld	ra,40(sp)
    80003770:	7402                	ld	s0,32(sp)
    80003772:	64e2                	ld	s1,24(sp)
    80003774:	6942                	ld	s2,16(sp)
    80003776:	69a2                	ld	s3,8(sp)
    80003778:	6a02                	ld	s4,0(sp)
    8000377a:	6145                	addi	sp,sp,48
    8000377c:	8082                	ret

000000008000377e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000377e:	7179                	addi	sp,sp,-48
    80003780:	f406                	sd	ra,40(sp)
    80003782:	f022                	sd	s0,32(sp)
    80003784:	ec26                	sd	s1,24(sp)
    80003786:	e84a                	sd	s2,16(sp)
    80003788:	e44e                	sd	s3,8(sp)
    8000378a:	1800                	addi	s0,sp,48
    8000378c:	892a                	mv	s2,a0
    8000378e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003790:	00017517          	auipc	a0,0x17
    80003794:	ec850513          	addi	a0,a0,-312 # 8001a658 <bcache>
    80003798:	ffffd097          	auipc	ra,0xffffd
    8000379c:	43e080e7          	jalr	1086(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800037a0:	0001f497          	auipc	s1,0x1f
    800037a4:	1704b483          	ld	s1,368(s1) # 80022910 <bcache+0x82b8>
    800037a8:	0001f797          	auipc	a5,0x1f
    800037ac:	11878793          	addi	a5,a5,280 # 800228c0 <bcache+0x8268>
    800037b0:	02f48f63          	beq	s1,a5,800037ee <bread+0x70>
    800037b4:	873e                	mv	a4,a5
    800037b6:	a021                	j	800037be <bread+0x40>
    800037b8:	68a4                	ld	s1,80(s1)
    800037ba:	02e48a63          	beq	s1,a4,800037ee <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800037be:	449c                	lw	a5,8(s1)
    800037c0:	ff279ce3          	bne	a5,s2,800037b8 <bread+0x3a>
    800037c4:	44dc                	lw	a5,12(s1)
    800037c6:	ff3799e3          	bne	a5,s3,800037b8 <bread+0x3a>
      b->refcnt++;
    800037ca:	40bc                	lw	a5,64(s1)
    800037cc:	2785                	addiw	a5,a5,1
    800037ce:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800037d0:	00017517          	auipc	a0,0x17
    800037d4:	e8850513          	addi	a0,a0,-376 # 8001a658 <bcache>
    800037d8:	ffffd097          	auipc	ra,0xffffd
    800037dc:	4b2080e7          	jalr	1202(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800037e0:	01048513          	addi	a0,s1,16
    800037e4:	00001097          	auipc	ra,0x1
    800037e8:	472080e7          	jalr	1138(ra) # 80004c56 <acquiresleep>
      return b;
    800037ec:	a8b9                	j	8000384a <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800037ee:	0001f497          	auipc	s1,0x1f
    800037f2:	11a4b483          	ld	s1,282(s1) # 80022908 <bcache+0x82b0>
    800037f6:	0001f797          	auipc	a5,0x1f
    800037fa:	0ca78793          	addi	a5,a5,202 # 800228c0 <bcache+0x8268>
    800037fe:	00f48863          	beq	s1,a5,8000380e <bread+0x90>
    80003802:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003804:	40bc                	lw	a5,64(s1)
    80003806:	cf81                	beqz	a5,8000381e <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003808:	64a4                	ld	s1,72(s1)
    8000380a:	fee49de3          	bne	s1,a4,80003804 <bread+0x86>
  panic("bget: no buffers");
    8000380e:	00005517          	auipc	a0,0x5
    80003812:	d8a50513          	addi	a0,a0,-630 # 80008598 <syscalls+0xe8>
    80003816:	ffffd097          	auipc	ra,0xffffd
    8000381a:	d2a080e7          	jalr	-726(ra) # 80000540 <panic>
      b->dev = dev;
    8000381e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003822:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003826:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000382a:	4785                	li	a5,1
    8000382c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000382e:	00017517          	auipc	a0,0x17
    80003832:	e2a50513          	addi	a0,a0,-470 # 8001a658 <bcache>
    80003836:	ffffd097          	auipc	ra,0xffffd
    8000383a:	454080e7          	jalr	1108(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    8000383e:	01048513          	addi	a0,s1,16
    80003842:	00001097          	auipc	ra,0x1
    80003846:	414080e7          	jalr	1044(ra) # 80004c56 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000384a:	409c                	lw	a5,0(s1)
    8000384c:	cb89                	beqz	a5,8000385e <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000384e:	8526                	mv	a0,s1
    80003850:	70a2                	ld	ra,40(sp)
    80003852:	7402                	ld	s0,32(sp)
    80003854:	64e2                	ld	s1,24(sp)
    80003856:	6942                	ld	s2,16(sp)
    80003858:	69a2                	ld	s3,8(sp)
    8000385a:	6145                	addi	sp,sp,48
    8000385c:	8082                	ret
    virtio_disk_rw(b, 0);
    8000385e:	4581                	li	a1,0
    80003860:	8526                	mv	a0,s1
    80003862:	00003097          	auipc	ra,0x3
    80003866:	0b0080e7          	jalr	176(ra) # 80006912 <virtio_disk_rw>
    b->valid = 1;
    8000386a:	4785                	li	a5,1
    8000386c:	c09c                	sw	a5,0(s1)
  return b;
    8000386e:	b7c5                	j	8000384e <bread+0xd0>

0000000080003870 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003870:	1101                	addi	sp,sp,-32
    80003872:	ec06                	sd	ra,24(sp)
    80003874:	e822                	sd	s0,16(sp)
    80003876:	e426                	sd	s1,8(sp)
    80003878:	1000                	addi	s0,sp,32
    8000387a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000387c:	0541                	addi	a0,a0,16
    8000387e:	00001097          	auipc	ra,0x1
    80003882:	474080e7          	jalr	1140(ra) # 80004cf2 <holdingsleep>
    80003886:	cd01                	beqz	a0,8000389e <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003888:	4585                	li	a1,1
    8000388a:	8526                	mv	a0,s1
    8000388c:	00003097          	auipc	ra,0x3
    80003890:	086080e7          	jalr	134(ra) # 80006912 <virtio_disk_rw>
}
    80003894:	60e2                	ld	ra,24(sp)
    80003896:	6442                	ld	s0,16(sp)
    80003898:	64a2                	ld	s1,8(sp)
    8000389a:	6105                	addi	sp,sp,32
    8000389c:	8082                	ret
    panic("bwrite");
    8000389e:	00005517          	auipc	a0,0x5
    800038a2:	d1250513          	addi	a0,a0,-750 # 800085b0 <syscalls+0x100>
    800038a6:	ffffd097          	auipc	ra,0xffffd
    800038aa:	c9a080e7          	jalr	-870(ra) # 80000540 <panic>

00000000800038ae <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800038ae:	1101                	addi	sp,sp,-32
    800038b0:	ec06                	sd	ra,24(sp)
    800038b2:	e822                	sd	s0,16(sp)
    800038b4:	e426                	sd	s1,8(sp)
    800038b6:	e04a                	sd	s2,0(sp)
    800038b8:	1000                	addi	s0,sp,32
    800038ba:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800038bc:	01050913          	addi	s2,a0,16
    800038c0:	854a                	mv	a0,s2
    800038c2:	00001097          	auipc	ra,0x1
    800038c6:	430080e7          	jalr	1072(ra) # 80004cf2 <holdingsleep>
    800038ca:	c92d                	beqz	a0,8000393c <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800038cc:	854a                	mv	a0,s2
    800038ce:	00001097          	auipc	ra,0x1
    800038d2:	3e0080e7          	jalr	992(ra) # 80004cae <releasesleep>

  acquire(&bcache.lock);
    800038d6:	00017517          	auipc	a0,0x17
    800038da:	d8250513          	addi	a0,a0,-638 # 8001a658 <bcache>
    800038de:	ffffd097          	auipc	ra,0xffffd
    800038e2:	2f8080e7          	jalr	760(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800038e6:	40bc                	lw	a5,64(s1)
    800038e8:	37fd                	addiw	a5,a5,-1
    800038ea:	0007871b          	sext.w	a4,a5
    800038ee:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800038f0:	eb05                	bnez	a4,80003920 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800038f2:	68bc                	ld	a5,80(s1)
    800038f4:	64b8                	ld	a4,72(s1)
    800038f6:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800038f8:	64bc                	ld	a5,72(s1)
    800038fa:	68b8                	ld	a4,80(s1)
    800038fc:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800038fe:	0001f797          	auipc	a5,0x1f
    80003902:	d5a78793          	addi	a5,a5,-678 # 80022658 <bcache+0x8000>
    80003906:	2b87b703          	ld	a4,696(a5)
    8000390a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000390c:	0001f717          	auipc	a4,0x1f
    80003910:	fb470713          	addi	a4,a4,-76 # 800228c0 <bcache+0x8268>
    80003914:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003916:	2b87b703          	ld	a4,696(a5)
    8000391a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000391c:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003920:	00017517          	auipc	a0,0x17
    80003924:	d3850513          	addi	a0,a0,-712 # 8001a658 <bcache>
    80003928:	ffffd097          	auipc	ra,0xffffd
    8000392c:	362080e7          	jalr	866(ra) # 80000c8a <release>
}
    80003930:	60e2                	ld	ra,24(sp)
    80003932:	6442                	ld	s0,16(sp)
    80003934:	64a2                	ld	s1,8(sp)
    80003936:	6902                	ld	s2,0(sp)
    80003938:	6105                	addi	sp,sp,32
    8000393a:	8082                	ret
    panic("brelse");
    8000393c:	00005517          	auipc	a0,0x5
    80003940:	c7c50513          	addi	a0,a0,-900 # 800085b8 <syscalls+0x108>
    80003944:	ffffd097          	auipc	ra,0xffffd
    80003948:	bfc080e7          	jalr	-1028(ra) # 80000540 <panic>

000000008000394c <bpin>:

void
bpin(struct buf *b) {
    8000394c:	1101                	addi	sp,sp,-32
    8000394e:	ec06                	sd	ra,24(sp)
    80003950:	e822                	sd	s0,16(sp)
    80003952:	e426                	sd	s1,8(sp)
    80003954:	1000                	addi	s0,sp,32
    80003956:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003958:	00017517          	auipc	a0,0x17
    8000395c:	d0050513          	addi	a0,a0,-768 # 8001a658 <bcache>
    80003960:	ffffd097          	auipc	ra,0xffffd
    80003964:	276080e7          	jalr	630(ra) # 80000bd6 <acquire>
  b->refcnt++;
    80003968:	40bc                	lw	a5,64(s1)
    8000396a:	2785                	addiw	a5,a5,1
    8000396c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000396e:	00017517          	auipc	a0,0x17
    80003972:	cea50513          	addi	a0,a0,-790 # 8001a658 <bcache>
    80003976:	ffffd097          	auipc	ra,0xffffd
    8000397a:	314080e7          	jalr	788(ra) # 80000c8a <release>
}
    8000397e:	60e2                	ld	ra,24(sp)
    80003980:	6442                	ld	s0,16(sp)
    80003982:	64a2                	ld	s1,8(sp)
    80003984:	6105                	addi	sp,sp,32
    80003986:	8082                	ret

0000000080003988 <bunpin>:

void
bunpin(struct buf *b) {
    80003988:	1101                	addi	sp,sp,-32
    8000398a:	ec06                	sd	ra,24(sp)
    8000398c:	e822                	sd	s0,16(sp)
    8000398e:	e426                	sd	s1,8(sp)
    80003990:	1000                	addi	s0,sp,32
    80003992:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003994:	00017517          	auipc	a0,0x17
    80003998:	cc450513          	addi	a0,a0,-828 # 8001a658 <bcache>
    8000399c:	ffffd097          	auipc	ra,0xffffd
    800039a0:	23a080e7          	jalr	570(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800039a4:	40bc                	lw	a5,64(s1)
    800039a6:	37fd                	addiw	a5,a5,-1
    800039a8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800039aa:	00017517          	auipc	a0,0x17
    800039ae:	cae50513          	addi	a0,a0,-850 # 8001a658 <bcache>
    800039b2:	ffffd097          	auipc	ra,0xffffd
    800039b6:	2d8080e7          	jalr	728(ra) # 80000c8a <release>
}
    800039ba:	60e2                	ld	ra,24(sp)
    800039bc:	6442                	ld	s0,16(sp)
    800039be:	64a2                	ld	s1,8(sp)
    800039c0:	6105                	addi	sp,sp,32
    800039c2:	8082                	ret

00000000800039c4 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800039c4:	1101                	addi	sp,sp,-32
    800039c6:	ec06                	sd	ra,24(sp)
    800039c8:	e822                	sd	s0,16(sp)
    800039ca:	e426                	sd	s1,8(sp)
    800039cc:	e04a                	sd	s2,0(sp)
    800039ce:	1000                	addi	s0,sp,32
    800039d0:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800039d2:	00d5d59b          	srliw	a1,a1,0xd
    800039d6:	0001f797          	auipc	a5,0x1f
    800039da:	35e7a783          	lw	a5,862(a5) # 80022d34 <sb+0x1c>
    800039de:	9dbd                	addw	a1,a1,a5
    800039e0:	00000097          	auipc	ra,0x0
    800039e4:	d9e080e7          	jalr	-610(ra) # 8000377e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800039e8:	0074f713          	andi	a4,s1,7
    800039ec:	4785                	li	a5,1
    800039ee:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800039f2:	14ce                	slli	s1,s1,0x33
    800039f4:	90d9                	srli	s1,s1,0x36
    800039f6:	00950733          	add	a4,a0,s1
    800039fa:	05874703          	lbu	a4,88(a4)
    800039fe:	00e7f6b3          	and	a3,a5,a4
    80003a02:	c69d                	beqz	a3,80003a30 <bfree+0x6c>
    80003a04:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003a06:	94aa                	add	s1,s1,a0
    80003a08:	fff7c793          	not	a5,a5
    80003a0c:	8f7d                	and	a4,a4,a5
    80003a0e:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003a12:	00001097          	auipc	ra,0x1
    80003a16:	126080e7          	jalr	294(ra) # 80004b38 <log_write>
  brelse(bp);
    80003a1a:	854a                	mv	a0,s2
    80003a1c:	00000097          	auipc	ra,0x0
    80003a20:	e92080e7          	jalr	-366(ra) # 800038ae <brelse>
}
    80003a24:	60e2                	ld	ra,24(sp)
    80003a26:	6442                	ld	s0,16(sp)
    80003a28:	64a2                	ld	s1,8(sp)
    80003a2a:	6902                	ld	s2,0(sp)
    80003a2c:	6105                	addi	sp,sp,32
    80003a2e:	8082                	ret
    panic("freeing free block");
    80003a30:	00005517          	auipc	a0,0x5
    80003a34:	b9050513          	addi	a0,a0,-1136 # 800085c0 <syscalls+0x110>
    80003a38:	ffffd097          	auipc	ra,0xffffd
    80003a3c:	b08080e7          	jalr	-1272(ra) # 80000540 <panic>

0000000080003a40 <balloc>:
{
    80003a40:	711d                	addi	sp,sp,-96
    80003a42:	ec86                	sd	ra,88(sp)
    80003a44:	e8a2                	sd	s0,80(sp)
    80003a46:	e4a6                	sd	s1,72(sp)
    80003a48:	e0ca                	sd	s2,64(sp)
    80003a4a:	fc4e                	sd	s3,56(sp)
    80003a4c:	f852                	sd	s4,48(sp)
    80003a4e:	f456                	sd	s5,40(sp)
    80003a50:	f05a                	sd	s6,32(sp)
    80003a52:	ec5e                	sd	s7,24(sp)
    80003a54:	e862                	sd	s8,16(sp)
    80003a56:	e466                	sd	s9,8(sp)
    80003a58:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003a5a:	0001f797          	auipc	a5,0x1f
    80003a5e:	2c27a783          	lw	a5,706(a5) # 80022d1c <sb+0x4>
    80003a62:	cff5                	beqz	a5,80003b5e <balloc+0x11e>
    80003a64:	8baa                	mv	s7,a0
    80003a66:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003a68:	0001fb17          	auipc	s6,0x1f
    80003a6c:	2b0b0b13          	addi	s6,s6,688 # 80022d18 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a70:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003a72:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a74:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003a76:	6c89                	lui	s9,0x2
    80003a78:	a061                	j	80003b00 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003a7a:	97ca                	add	a5,a5,s2
    80003a7c:	8e55                	or	a2,a2,a3
    80003a7e:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003a82:	854a                	mv	a0,s2
    80003a84:	00001097          	auipc	ra,0x1
    80003a88:	0b4080e7          	jalr	180(ra) # 80004b38 <log_write>
        brelse(bp);
    80003a8c:	854a                	mv	a0,s2
    80003a8e:	00000097          	auipc	ra,0x0
    80003a92:	e20080e7          	jalr	-480(ra) # 800038ae <brelse>
  bp = bread(dev, bno);
    80003a96:	85a6                	mv	a1,s1
    80003a98:	855e                	mv	a0,s7
    80003a9a:	00000097          	auipc	ra,0x0
    80003a9e:	ce4080e7          	jalr	-796(ra) # 8000377e <bread>
    80003aa2:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003aa4:	40000613          	li	a2,1024
    80003aa8:	4581                	li	a1,0
    80003aaa:	05850513          	addi	a0,a0,88
    80003aae:	ffffd097          	auipc	ra,0xffffd
    80003ab2:	224080e7          	jalr	548(ra) # 80000cd2 <memset>
  log_write(bp);
    80003ab6:	854a                	mv	a0,s2
    80003ab8:	00001097          	auipc	ra,0x1
    80003abc:	080080e7          	jalr	128(ra) # 80004b38 <log_write>
  brelse(bp);
    80003ac0:	854a                	mv	a0,s2
    80003ac2:	00000097          	auipc	ra,0x0
    80003ac6:	dec080e7          	jalr	-532(ra) # 800038ae <brelse>
}
    80003aca:	8526                	mv	a0,s1
    80003acc:	60e6                	ld	ra,88(sp)
    80003ace:	6446                	ld	s0,80(sp)
    80003ad0:	64a6                	ld	s1,72(sp)
    80003ad2:	6906                	ld	s2,64(sp)
    80003ad4:	79e2                	ld	s3,56(sp)
    80003ad6:	7a42                	ld	s4,48(sp)
    80003ad8:	7aa2                	ld	s5,40(sp)
    80003ada:	7b02                	ld	s6,32(sp)
    80003adc:	6be2                	ld	s7,24(sp)
    80003ade:	6c42                	ld	s8,16(sp)
    80003ae0:	6ca2                	ld	s9,8(sp)
    80003ae2:	6125                	addi	sp,sp,96
    80003ae4:	8082                	ret
    brelse(bp);
    80003ae6:	854a                	mv	a0,s2
    80003ae8:	00000097          	auipc	ra,0x0
    80003aec:	dc6080e7          	jalr	-570(ra) # 800038ae <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003af0:	015c87bb          	addw	a5,s9,s5
    80003af4:	00078a9b          	sext.w	s5,a5
    80003af8:	004b2703          	lw	a4,4(s6)
    80003afc:	06eaf163          	bgeu	s5,a4,80003b5e <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003b00:	41fad79b          	sraiw	a5,s5,0x1f
    80003b04:	0137d79b          	srliw	a5,a5,0x13
    80003b08:	015787bb          	addw	a5,a5,s5
    80003b0c:	40d7d79b          	sraiw	a5,a5,0xd
    80003b10:	01cb2583          	lw	a1,28(s6)
    80003b14:	9dbd                	addw	a1,a1,a5
    80003b16:	855e                	mv	a0,s7
    80003b18:	00000097          	auipc	ra,0x0
    80003b1c:	c66080e7          	jalr	-922(ra) # 8000377e <bread>
    80003b20:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b22:	004b2503          	lw	a0,4(s6)
    80003b26:	000a849b          	sext.w	s1,s5
    80003b2a:	8762                	mv	a4,s8
    80003b2c:	faa4fde3          	bgeu	s1,a0,80003ae6 <balloc+0xa6>
      m = 1 << (bi % 8);
    80003b30:	00777693          	andi	a3,a4,7
    80003b34:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003b38:	41f7579b          	sraiw	a5,a4,0x1f
    80003b3c:	01d7d79b          	srliw	a5,a5,0x1d
    80003b40:	9fb9                	addw	a5,a5,a4
    80003b42:	4037d79b          	sraiw	a5,a5,0x3
    80003b46:	00f90633          	add	a2,s2,a5
    80003b4a:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80003b4e:	00c6f5b3          	and	a1,a3,a2
    80003b52:	d585                	beqz	a1,80003a7a <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b54:	2705                	addiw	a4,a4,1
    80003b56:	2485                	addiw	s1,s1,1
    80003b58:	fd471ae3          	bne	a4,s4,80003b2c <balloc+0xec>
    80003b5c:	b769                	j	80003ae6 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80003b5e:	00005517          	auipc	a0,0x5
    80003b62:	a7a50513          	addi	a0,a0,-1414 # 800085d8 <syscalls+0x128>
    80003b66:	ffffd097          	auipc	ra,0xffffd
    80003b6a:	a24080e7          	jalr	-1500(ra) # 8000058a <printf>
  return 0;
    80003b6e:	4481                	li	s1,0
    80003b70:	bfa9                	j	80003aca <balloc+0x8a>

0000000080003b72 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003b72:	7179                	addi	sp,sp,-48
    80003b74:	f406                	sd	ra,40(sp)
    80003b76:	f022                	sd	s0,32(sp)
    80003b78:	ec26                	sd	s1,24(sp)
    80003b7a:	e84a                	sd	s2,16(sp)
    80003b7c:	e44e                	sd	s3,8(sp)
    80003b7e:	e052                	sd	s4,0(sp)
    80003b80:	1800                	addi	s0,sp,48
    80003b82:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003b84:	47ad                	li	a5,11
    80003b86:	02b7e863          	bltu	a5,a1,80003bb6 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003b8a:	02059793          	slli	a5,a1,0x20
    80003b8e:	01e7d593          	srli	a1,a5,0x1e
    80003b92:	00b504b3          	add	s1,a0,a1
    80003b96:	0504a903          	lw	s2,80(s1)
    80003b9a:	06091e63          	bnez	s2,80003c16 <bmap+0xa4>
      addr = balloc(ip->dev);
    80003b9e:	4108                	lw	a0,0(a0)
    80003ba0:	00000097          	auipc	ra,0x0
    80003ba4:	ea0080e7          	jalr	-352(ra) # 80003a40 <balloc>
    80003ba8:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003bac:	06090563          	beqz	s2,80003c16 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003bb0:	0524a823          	sw	s2,80(s1)
    80003bb4:	a08d                	j	80003c16 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003bb6:	ff45849b          	addiw	s1,a1,-12
    80003bba:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003bbe:	0ff00793          	li	a5,255
    80003bc2:	08e7e563          	bltu	a5,a4,80003c4c <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003bc6:	08052903          	lw	s2,128(a0)
    80003bca:	00091d63          	bnez	s2,80003be4 <bmap+0x72>
      addr = balloc(ip->dev);
    80003bce:	4108                	lw	a0,0(a0)
    80003bd0:	00000097          	auipc	ra,0x0
    80003bd4:	e70080e7          	jalr	-400(ra) # 80003a40 <balloc>
    80003bd8:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003bdc:	02090d63          	beqz	s2,80003c16 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003be0:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003be4:	85ca                	mv	a1,s2
    80003be6:	0009a503          	lw	a0,0(s3)
    80003bea:	00000097          	auipc	ra,0x0
    80003bee:	b94080e7          	jalr	-1132(ra) # 8000377e <bread>
    80003bf2:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003bf4:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003bf8:	02049713          	slli	a4,s1,0x20
    80003bfc:	01e75593          	srli	a1,a4,0x1e
    80003c00:	00b784b3          	add	s1,a5,a1
    80003c04:	0004a903          	lw	s2,0(s1)
    80003c08:	02090063          	beqz	s2,80003c28 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003c0c:	8552                	mv	a0,s4
    80003c0e:	00000097          	auipc	ra,0x0
    80003c12:	ca0080e7          	jalr	-864(ra) # 800038ae <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003c16:	854a                	mv	a0,s2
    80003c18:	70a2                	ld	ra,40(sp)
    80003c1a:	7402                	ld	s0,32(sp)
    80003c1c:	64e2                	ld	s1,24(sp)
    80003c1e:	6942                	ld	s2,16(sp)
    80003c20:	69a2                	ld	s3,8(sp)
    80003c22:	6a02                	ld	s4,0(sp)
    80003c24:	6145                	addi	sp,sp,48
    80003c26:	8082                	ret
      addr = balloc(ip->dev);
    80003c28:	0009a503          	lw	a0,0(s3)
    80003c2c:	00000097          	auipc	ra,0x0
    80003c30:	e14080e7          	jalr	-492(ra) # 80003a40 <balloc>
    80003c34:	0005091b          	sext.w	s2,a0
      if(addr){
    80003c38:	fc090ae3          	beqz	s2,80003c0c <bmap+0x9a>
        a[bn] = addr;
    80003c3c:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003c40:	8552                	mv	a0,s4
    80003c42:	00001097          	auipc	ra,0x1
    80003c46:	ef6080e7          	jalr	-266(ra) # 80004b38 <log_write>
    80003c4a:	b7c9                	j	80003c0c <bmap+0x9a>
  panic("bmap: out of range");
    80003c4c:	00005517          	auipc	a0,0x5
    80003c50:	9a450513          	addi	a0,a0,-1628 # 800085f0 <syscalls+0x140>
    80003c54:	ffffd097          	auipc	ra,0xffffd
    80003c58:	8ec080e7          	jalr	-1812(ra) # 80000540 <panic>

0000000080003c5c <iget>:
{
    80003c5c:	7179                	addi	sp,sp,-48
    80003c5e:	f406                	sd	ra,40(sp)
    80003c60:	f022                	sd	s0,32(sp)
    80003c62:	ec26                	sd	s1,24(sp)
    80003c64:	e84a                	sd	s2,16(sp)
    80003c66:	e44e                	sd	s3,8(sp)
    80003c68:	e052                	sd	s4,0(sp)
    80003c6a:	1800                	addi	s0,sp,48
    80003c6c:	89aa                	mv	s3,a0
    80003c6e:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003c70:	0001f517          	auipc	a0,0x1f
    80003c74:	0c850513          	addi	a0,a0,200 # 80022d38 <itable>
    80003c78:	ffffd097          	auipc	ra,0xffffd
    80003c7c:	f5e080e7          	jalr	-162(ra) # 80000bd6 <acquire>
  empty = 0;
    80003c80:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c82:	0001f497          	auipc	s1,0x1f
    80003c86:	0ce48493          	addi	s1,s1,206 # 80022d50 <itable+0x18>
    80003c8a:	00021697          	auipc	a3,0x21
    80003c8e:	b5668693          	addi	a3,a3,-1194 # 800247e0 <log>
    80003c92:	a039                	j	80003ca0 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003c94:	02090b63          	beqz	s2,80003cca <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c98:	08848493          	addi	s1,s1,136
    80003c9c:	02d48a63          	beq	s1,a3,80003cd0 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003ca0:	449c                	lw	a5,8(s1)
    80003ca2:	fef059e3          	blez	a5,80003c94 <iget+0x38>
    80003ca6:	4098                	lw	a4,0(s1)
    80003ca8:	ff3716e3          	bne	a4,s3,80003c94 <iget+0x38>
    80003cac:	40d8                	lw	a4,4(s1)
    80003cae:	ff4713e3          	bne	a4,s4,80003c94 <iget+0x38>
      ip->ref++;
    80003cb2:	2785                	addiw	a5,a5,1
    80003cb4:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003cb6:	0001f517          	auipc	a0,0x1f
    80003cba:	08250513          	addi	a0,a0,130 # 80022d38 <itable>
    80003cbe:	ffffd097          	auipc	ra,0xffffd
    80003cc2:	fcc080e7          	jalr	-52(ra) # 80000c8a <release>
      return ip;
    80003cc6:	8926                	mv	s2,s1
    80003cc8:	a03d                	j	80003cf6 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003cca:	f7f9                	bnez	a5,80003c98 <iget+0x3c>
    80003ccc:	8926                	mv	s2,s1
    80003cce:	b7e9                	j	80003c98 <iget+0x3c>
  if(empty == 0)
    80003cd0:	02090c63          	beqz	s2,80003d08 <iget+0xac>
  ip->dev = dev;
    80003cd4:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003cd8:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003cdc:	4785                	li	a5,1
    80003cde:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003ce2:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003ce6:	0001f517          	auipc	a0,0x1f
    80003cea:	05250513          	addi	a0,a0,82 # 80022d38 <itable>
    80003cee:	ffffd097          	auipc	ra,0xffffd
    80003cf2:	f9c080e7          	jalr	-100(ra) # 80000c8a <release>
}
    80003cf6:	854a                	mv	a0,s2
    80003cf8:	70a2                	ld	ra,40(sp)
    80003cfa:	7402                	ld	s0,32(sp)
    80003cfc:	64e2                	ld	s1,24(sp)
    80003cfe:	6942                	ld	s2,16(sp)
    80003d00:	69a2                	ld	s3,8(sp)
    80003d02:	6a02                	ld	s4,0(sp)
    80003d04:	6145                	addi	sp,sp,48
    80003d06:	8082                	ret
    panic("iget: no inodes");
    80003d08:	00005517          	auipc	a0,0x5
    80003d0c:	90050513          	addi	a0,a0,-1792 # 80008608 <syscalls+0x158>
    80003d10:	ffffd097          	auipc	ra,0xffffd
    80003d14:	830080e7          	jalr	-2000(ra) # 80000540 <panic>

0000000080003d18 <fsinit>:
fsinit(int dev) {
    80003d18:	7179                	addi	sp,sp,-48
    80003d1a:	f406                	sd	ra,40(sp)
    80003d1c:	f022                	sd	s0,32(sp)
    80003d1e:	ec26                	sd	s1,24(sp)
    80003d20:	e84a                	sd	s2,16(sp)
    80003d22:	e44e                	sd	s3,8(sp)
    80003d24:	1800                	addi	s0,sp,48
    80003d26:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003d28:	4585                	li	a1,1
    80003d2a:	00000097          	auipc	ra,0x0
    80003d2e:	a54080e7          	jalr	-1452(ra) # 8000377e <bread>
    80003d32:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003d34:	0001f997          	auipc	s3,0x1f
    80003d38:	fe498993          	addi	s3,s3,-28 # 80022d18 <sb>
    80003d3c:	02000613          	li	a2,32
    80003d40:	05850593          	addi	a1,a0,88
    80003d44:	854e                	mv	a0,s3
    80003d46:	ffffd097          	auipc	ra,0xffffd
    80003d4a:	fe8080e7          	jalr	-24(ra) # 80000d2e <memmove>
  brelse(bp);
    80003d4e:	8526                	mv	a0,s1
    80003d50:	00000097          	auipc	ra,0x0
    80003d54:	b5e080e7          	jalr	-1186(ra) # 800038ae <brelse>
  if(sb.magic != FSMAGIC)
    80003d58:	0009a703          	lw	a4,0(s3)
    80003d5c:	102037b7          	lui	a5,0x10203
    80003d60:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003d64:	02f71263          	bne	a4,a5,80003d88 <fsinit+0x70>
  initlog(dev, &sb);
    80003d68:	0001f597          	auipc	a1,0x1f
    80003d6c:	fb058593          	addi	a1,a1,-80 # 80022d18 <sb>
    80003d70:	854a                	mv	a0,s2
    80003d72:	00001097          	auipc	ra,0x1
    80003d76:	b4a080e7          	jalr	-1206(ra) # 800048bc <initlog>
}
    80003d7a:	70a2                	ld	ra,40(sp)
    80003d7c:	7402                	ld	s0,32(sp)
    80003d7e:	64e2                	ld	s1,24(sp)
    80003d80:	6942                	ld	s2,16(sp)
    80003d82:	69a2                	ld	s3,8(sp)
    80003d84:	6145                	addi	sp,sp,48
    80003d86:	8082                	ret
    panic("invalid file system");
    80003d88:	00005517          	auipc	a0,0x5
    80003d8c:	89050513          	addi	a0,a0,-1904 # 80008618 <syscalls+0x168>
    80003d90:	ffffc097          	auipc	ra,0xffffc
    80003d94:	7b0080e7          	jalr	1968(ra) # 80000540 <panic>

0000000080003d98 <iinit>:
{
    80003d98:	7179                	addi	sp,sp,-48
    80003d9a:	f406                	sd	ra,40(sp)
    80003d9c:	f022                	sd	s0,32(sp)
    80003d9e:	ec26                	sd	s1,24(sp)
    80003da0:	e84a                	sd	s2,16(sp)
    80003da2:	e44e                	sd	s3,8(sp)
    80003da4:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003da6:	00005597          	auipc	a1,0x5
    80003daa:	88a58593          	addi	a1,a1,-1910 # 80008630 <syscalls+0x180>
    80003dae:	0001f517          	auipc	a0,0x1f
    80003db2:	f8a50513          	addi	a0,a0,-118 # 80022d38 <itable>
    80003db6:	ffffd097          	auipc	ra,0xffffd
    80003dba:	d90080e7          	jalr	-624(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003dbe:	0001f497          	auipc	s1,0x1f
    80003dc2:	fa248493          	addi	s1,s1,-94 # 80022d60 <itable+0x28>
    80003dc6:	00021997          	auipc	s3,0x21
    80003dca:	a2a98993          	addi	s3,s3,-1494 # 800247f0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003dce:	00005917          	auipc	s2,0x5
    80003dd2:	86a90913          	addi	s2,s2,-1942 # 80008638 <syscalls+0x188>
    80003dd6:	85ca                	mv	a1,s2
    80003dd8:	8526                	mv	a0,s1
    80003dda:	00001097          	auipc	ra,0x1
    80003dde:	e42080e7          	jalr	-446(ra) # 80004c1c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003de2:	08848493          	addi	s1,s1,136
    80003de6:	ff3498e3          	bne	s1,s3,80003dd6 <iinit+0x3e>
}
    80003dea:	70a2                	ld	ra,40(sp)
    80003dec:	7402                	ld	s0,32(sp)
    80003dee:	64e2                	ld	s1,24(sp)
    80003df0:	6942                	ld	s2,16(sp)
    80003df2:	69a2                	ld	s3,8(sp)
    80003df4:	6145                	addi	sp,sp,48
    80003df6:	8082                	ret

0000000080003df8 <ialloc>:
{
    80003df8:	715d                	addi	sp,sp,-80
    80003dfa:	e486                	sd	ra,72(sp)
    80003dfc:	e0a2                	sd	s0,64(sp)
    80003dfe:	fc26                	sd	s1,56(sp)
    80003e00:	f84a                	sd	s2,48(sp)
    80003e02:	f44e                	sd	s3,40(sp)
    80003e04:	f052                	sd	s4,32(sp)
    80003e06:	ec56                	sd	s5,24(sp)
    80003e08:	e85a                	sd	s6,16(sp)
    80003e0a:	e45e                	sd	s7,8(sp)
    80003e0c:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003e0e:	0001f717          	auipc	a4,0x1f
    80003e12:	f1672703          	lw	a4,-234(a4) # 80022d24 <sb+0xc>
    80003e16:	4785                	li	a5,1
    80003e18:	04e7fa63          	bgeu	a5,a4,80003e6c <ialloc+0x74>
    80003e1c:	8aaa                	mv	s5,a0
    80003e1e:	8bae                	mv	s7,a1
    80003e20:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003e22:	0001fa17          	auipc	s4,0x1f
    80003e26:	ef6a0a13          	addi	s4,s4,-266 # 80022d18 <sb>
    80003e2a:	00048b1b          	sext.w	s6,s1
    80003e2e:	0044d593          	srli	a1,s1,0x4
    80003e32:	018a2783          	lw	a5,24(s4)
    80003e36:	9dbd                	addw	a1,a1,a5
    80003e38:	8556                	mv	a0,s5
    80003e3a:	00000097          	auipc	ra,0x0
    80003e3e:	944080e7          	jalr	-1724(ra) # 8000377e <bread>
    80003e42:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003e44:	05850993          	addi	s3,a0,88
    80003e48:	00f4f793          	andi	a5,s1,15
    80003e4c:	079a                	slli	a5,a5,0x6
    80003e4e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003e50:	00099783          	lh	a5,0(s3)
    80003e54:	c3a1                	beqz	a5,80003e94 <ialloc+0x9c>
    brelse(bp);
    80003e56:	00000097          	auipc	ra,0x0
    80003e5a:	a58080e7          	jalr	-1448(ra) # 800038ae <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003e5e:	0485                	addi	s1,s1,1
    80003e60:	00ca2703          	lw	a4,12(s4)
    80003e64:	0004879b          	sext.w	a5,s1
    80003e68:	fce7e1e3          	bltu	a5,a4,80003e2a <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003e6c:	00004517          	auipc	a0,0x4
    80003e70:	7d450513          	addi	a0,a0,2004 # 80008640 <syscalls+0x190>
    80003e74:	ffffc097          	auipc	ra,0xffffc
    80003e78:	716080e7          	jalr	1814(ra) # 8000058a <printf>
  return 0;
    80003e7c:	4501                	li	a0,0
}
    80003e7e:	60a6                	ld	ra,72(sp)
    80003e80:	6406                	ld	s0,64(sp)
    80003e82:	74e2                	ld	s1,56(sp)
    80003e84:	7942                	ld	s2,48(sp)
    80003e86:	79a2                	ld	s3,40(sp)
    80003e88:	7a02                	ld	s4,32(sp)
    80003e8a:	6ae2                	ld	s5,24(sp)
    80003e8c:	6b42                	ld	s6,16(sp)
    80003e8e:	6ba2                	ld	s7,8(sp)
    80003e90:	6161                	addi	sp,sp,80
    80003e92:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003e94:	04000613          	li	a2,64
    80003e98:	4581                	li	a1,0
    80003e9a:	854e                	mv	a0,s3
    80003e9c:	ffffd097          	auipc	ra,0xffffd
    80003ea0:	e36080e7          	jalr	-458(ra) # 80000cd2 <memset>
      dip->type = type;
    80003ea4:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003ea8:	854a                	mv	a0,s2
    80003eaa:	00001097          	auipc	ra,0x1
    80003eae:	c8e080e7          	jalr	-882(ra) # 80004b38 <log_write>
      brelse(bp);
    80003eb2:	854a                	mv	a0,s2
    80003eb4:	00000097          	auipc	ra,0x0
    80003eb8:	9fa080e7          	jalr	-1542(ra) # 800038ae <brelse>
      return iget(dev, inum);
    80003ebc:	85da                	mv	a1,s6
    80003ebe:	8556                	mv	a0,s5
    80003ec0:	00000097          	auipc	ra,0x0
    80003ec4:	d9c080e7          	jalr	-612(ra) # 80003c5c <iget>
    80003ec8:	bf5d                	j	80003e7e <ialloc+0x86>

0000000080003eca <iupdate>:
{
    80003eca:	1101                	addi	sp,sp,-32
    80003ecc:	ec06                	sd	ra,24(sp)
    80003ece:	e822                	sd	s0,16(sp)
    80003ed0:	e426                	sd	s1,8(sp)
    80003ed2:	e04a                	sd	s2,0(sp)
    80003ed4:	1000                	addi	s0,sp,32
    80003ed6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003ed8:	415c                	lw	a5,4(a0)
    80003eda:	0047d79b          	srliw	a5,a5,0x4
    80003ede:	0001f597          	auipc	a1,0x1f
    80003ee2:	e525a583          	lw	a1,-430(a1) # 80022d30 <sb+0x18>
    80003ee6:	9dbd                	addw	a1,a1,a5
    80003ee8:	4108                	lw	a0,0(a0)
    80003eea:	00000097          	auipc	ra,0x0
    80003eee:	894080e7          	jalr	-1900(ra) # 8000377e <bread>
    80003ef2:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ef4:	05850793          	addi	a5,a0,88
    80003ef8:	40d8                	lw	a4,4(s1)
    80003efa:	8b3d                	andi	a4,a4,15
    80003efc:	071a                	slli	a4,a4,0x6
    80003efe:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003f00:	04449703          	lh	a4,68(s1)
    80003f04:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003f08:	04649703          	lh	a4,70(s1)
    80003f0c:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003f10:	04849703          	lh	a4,72(s1)
    80003f14:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003f18:	04a49703          	lh	a4,74(s1)
    80003f1c:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003f20:	44f8                	lw	a4,76(s1)
    80003f22:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003f24:	03400613          	li	a2,52
    80003f28:	05048593          	addi	a1,s1,80
    80003f2c:	00c78513          	addi	a0,a5,12
    80003f30:	ffffd097          	auipc	ra,0xffffd
    80003f34:	dfe080e7          	jalr	-514(ra) # 80000d2e <memmove>
  log_write(bp);
    80003f38:	854a                	mv	a0,s2
    80003f3a:	00001097          	auipc	ra,0x1
    80003f3e:	bfe080e7          	jalr	-1026(ra) # 80004b38 <log_write>
  brelse(bp);
    80003f42:	854a                	mv	a0,s2
    80003f44:	00000097          	auipc	ra,0x0
    80003f48:	96a080e7          	jalr	-1686(ra) # 800038ae <brelse>
}
    80003f4c:	60e2                	ld	ra,24(sp)
    80003f4e:	6442                	ld	s0,16(sp)
    80003f50:	64a2                	ld	s1,8(sp)
    80003f52:	6902                	ld	s2,0(sp)
    80003f54:	6105                	addi	sp,sp,32
    80003f56:	8082                	ret

0000000080003f58 <idup>:
{
    80003f58:	1101                	addi	sp,sp,-32
    80003f5a:	ec06                	sd	ra,24(sp)
    80003f5c:	e822                	sd	s0,16(sp)
    80003f5e:	e426                	sd	s1,8(sp)
    80003f60:	1000                	addi	s0,sp,32
    80003f62:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003f64:	0001f517          	auipc	a0,0x1f
    80003f68:	dd450513          	addi	a0,a0,-556 # 80022d38 <itable>
    80003f6c:	ffffd097          	auipc	ra,0xffffd
    80003f70:	c6a080e7          	jalr	-918(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003f74:	449c                	lw	a5,8(s1)
    80003f76:	2785                	addiw	a5,a5,1
    80003f78:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003f7a:	0001f517          	auipc	a0,0x1f
    80003f7e:	dbe50513          	addi	a0,a0,-578 # 80022d38 <itable>
    80003f82:	ffffd097          	auipc	ra,0xffffd
    80003f86:	d08080e7          	jalr	-760(ra) # 80000c8a <release>
}
    80003f8a:	8526                	mv	a0,s1
    80003f8c:	60e2                	ld	ra,24(sp)
    80003f8e:	6442                	ld	s0,16(sp)
    80003f90:	64a2                	ld	s1,8(sp)
    80003f92:	6105                	addi	sp,sp,32
    80003f94:	8082                	ret

0000000080003f96 <ilock>:
{
    80003f96:	1101                	addi	sp,sp,-32
    80003f98:	ec06                	sd	ra,24(sp)
    80003f9a:	e822                	sd	s0,16(sp)
    80003f9c:	e426                	sd	s1,8(sp)
    80003f9e:	e04a                	sd	s2,0(sp)
    80003fa0:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003fa2:	c115                	beqz	a0,80003fc6 <ilock+0x30>
    80003fa4:	84aa                	mv	s1,a0
    80003fa6:	451c                	lw	a5,8(a0)
    80003fa8:	00f05f63          	blez	a5,80003fc6 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003fac:	0541                	addi	a0,a0,16
    80003fae:	00001097          	auipc	ra,0x1
    80003fb2:	ca8080e7          	jalr	-856(ra) # 80004c56 <acquiresleep>
  if(ip->valid == 0){
    80003fb6:	40bc                	lw	a5,64(s1)
    80003fb8:	cf99                	beqz	a5,80003fd6 <ilock+0x40>
}
    80003fba:	60e2                	ld	ra,24(sp)
    80003fbc:	6442                	ld	s0,16(sp)
    80003fbe:	64a2                	ld	s1,8(sp)
    80003fc0:	6902                	ld	s2,0(sp)
    80003fc2:	6105                	addi	sp,sp,32
    80003fc4:	8082                	ret
    panic("ilock");
    80003fc6:	00004517          	auipc	a0,0x4
    80003fca:	69250513          	addi	a0,a0,1682 # 80008658 <syscalls+0x1a8>
    80003fce:	ffffc097          	auipc	ra,0xffffc
    80003fd2:	572080e7          	jalr	1394(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003fd6:	40dc                	lw	a5,4(s1)
    80003fd8:	0047d79b          	srliw	a5,a5,0x4
    80003fdc:	0001f597          	auipc	a1,0x1f
    80003fe0:	d545a583          	lw	a1,-684(a1) # 80022d30 <sb+0x18>
    80003fe4:	9dbd                	addw	a1,a1,a5
    80003fe6:	4088                	lw	a0,0(s1)
    80003fe8:	fffff097          	auipc	ra,0xfffff
    80003fec:	796080e7          	jalr	1942(ra) # 8000377e <bread>
    80003ff0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ff2:	05850593          	addi	a1,a0,88
    80003ff6:	40dc                	lw	a5,4(s1)
    80003ff8:	8bbd                	andi	a5,a5,15
    80003ffa:	079a                	slli	a5,a5,0x6
    80003ffc:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003ffe:	00059783          	lh	a5,0(a1)
    80004002:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004006:	00259783          	lh	a5,2(a1)
    8000400a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000400e:	00459783          	lh	a5,4(a1)
    80004012:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80004016:	00659783          	lh	a5,6(a1)
    8000401a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000401e:	459c                	lw	a5,8(a1)
    80004020:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80004022:	03400613          	li	a2,52
    80004026:	05b1                	addi	a1,a1,12
    80004028:	05048513          	addi	a0,s1,80
    8000402c:	ffffd097          	auipc	ra,0xffffd
    80004030:	d02080e7          	jalr	-766(ra) # 80000d2e <memmove>
    brelse(bp);
    80004034:	854a                	mv	a0,s2
    80004036:	00000097          	auipc	ra,0x0
    8000403a:	878080e7          	jalr	-1928(ra) # 800038ae <brelse>
    ip->valid = 1;
    8000403e:	4785                	li	a5,1
    80004040:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80004042:	04449783          	lh	a5,68(s1)
    80004046:	fbb5                	bnez	a5,80003fba <ilock+0x24>
      panic("ilock: no type");
    80004048:	00004517          	auipc	a0,0x4
    8000404c:	61850513          	addi	a0,a0,1560 # 80008660 <syscalls+0x1b0>
    80004050:	ffffc097          	auipc	ra,0xffffc
    80004054:	4f0080e7          	jalr	1264(ra) # 80000540 <panic>

0000000080004058 <iunlock>:
{
    80004058:	1101                	addi	sp,sp,-32
    8000405a:	ec06                	sd	ra,24(sp)
    8000405c:	e822                	sd	s0,16(sp)
    8000405e:	e426                	sd	s1,8(sp)
    80004060:	e04a                	sd	s2,0(sp)
    80004062:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004064:	c905                	beqz	a0,80004094 <iunlock+0x3c>
    80004066:	84aa                	mv	s1,a0
    80004068:	01050913          	addi	s2,a0,16
    8000406c:	854a                	mv	a0,s2
    8000406e:	00001097          	auipc	ra,0x1
    80004072:	c84080e7          	jalr	-892(ra) # 80004cf2 <holdingsleep>
    80004076:	cd19                	beqz	a0,80004094 <iunlock+0x3c>
    80004078:	449c                	lw	a5,8(s1)
    8000407a:	00f05d63          	blez	a5,80004094 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000407e:	854a                	mv	a0,s2
    80004080:	00001097          	auipc	ra,0x1
    80004084:	c2e080e7          	jalr	-978(ra) # 80004cae <releasesleep>
}
    80004088:	60e2                	ld	ra,24(sp)
    8000408a:	6442                	ld	s0,16(sp)
    8000408c:	64a2                	ld	s1,8(sp)
    8000408e:	6902                	ld	s2,0(sp)
    80004090:	6105                	addi	sp,sp,32
    80004092:	8082                	ret
    panic("iunlock");
    80004094:	00004517          	auipc	a0,0x4
    80004098:	5dc50513          	addi	a0,a0,1500 # 80008670 <syscalls+0x1c0>
    8000409c:	ffffc097          	auipc	ra,0xffffc
    800040a0:	4a4080e7          	jalr	1188(ra) # 80000540 <panic>

00000000800040a4 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800040a4:	7179                	addi	sp,sp,-48
    800040a6:	f406                	sd	ra,40(sp)
    800040a8:	f022                	sd	s0,32(sp)
    800040aa:	ec26                	sd	s1,24(sp)
    800040ac:	e84a                	sd	s2,16(sp)
    800040ae:	e44e                	sd	s3,8(sp)
    800040b0:	e052                	sd	s4,0(sp)
    800040b2:	1800                	addi	s0,sp,48
    800040b4:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800040b6:	05050493          	addi	s1,a0,80
    800040ba:	08050913          	addi	s2,a0,128
    800040be:	a021                	j	800040c6 <itrunc+0x22>
    800040c0:	0491                	addi	s1,s1,4
    800040c2:	01248d63          	beq	s1,s2,800040dc <itrunc+0x38>
    if(ip->addrs[i]){
    800040c6:	408c                	lw	a1,0(s1)
    800040c8:	dde5                	beqz	a1,800040c0 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800040ca:	0009a503          	lw	a0,0(s3)
    800040ce:	00000097          	auipc	ra,0x0
    800040d2:	8f6080e7          	jalr	-1802(ra) # 800039c4 <bfree>
      ip->addrs[i] = 0;
    800040d6:	0004a023          	sw	zero,0(s1)
    800040da:	b7dd                	j	800040c0 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800040dc:	0809a583          	lw	a1,128(s3)
    800040e0:	e185                	bnez	a1,80004100 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800040e2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800040e6:	854e                	mv	a0,s3
    800040e8:	00000097          	auipc	ra,0x0
    800040ec:	de2080e7          	jalr	-542(ra) # 80003eca <iupdate>
}
    800040f0:	70a2                	ld	ra,40(sp)
    800040f2:	7402                	ld	s0,32(sp)
    800040f4:	64e2                	ld	s1,24(sp)
    800040f6:	6942                	ld	s2,16(sp)
    800040f8:	69a2                	ld	s3,8(sp)
    800040fa:	6a02                	ld	s4,0(sp)
    800040fc:	6145                	addi	sp,sp,48
    800040fe:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80004100:	0009a503          	lw	a0,0(s3)
    80004104:	fffff097          	auipc	ra,0xfffff
    80004108:	67a080e7          	jalr	1658(ra) # 8000377e <bread>
    8000410c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000410e:	05850493          	addi	s1,a0,88
    80004112:	45850913          	addi	s2,a0,1112
    80004116:	a021                	j	8000411e <itrunc+0x7a>
    80004118:	0491                	addi	s1,s1,4
    8000411a:	01248b63          	beq	s1,s2,80004130 <itrunc+0x8c>
      if(a[j])
    8000411e:	408c                	lw	a1,0(s1)
    80004120:	dde5                	beqz	a1,80004118 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80004122:	0009a503          	lw	a0,0(s3)
    80004126:	00000097          	auipc	ra,0x0
    8000412a:	89e080e7          	jalr	-1890(ra) # 800039c4 <bfree>
    8000412e:	b7ed                	j	80004118 <itrunc+0x74>
    brelse(bp);
    80004130:	8552                	mv	a0,s4
    80004132:	fffff097          	auipc	ra,0xfffff
    80004136:	77c080e7          	jalr	1916(ra) # 800038ae <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000413a:	0809a583          	lw	a1,128(s3)
    8000413e:	0009a503          	lw	a0,0(s3)
    80004142:	00000097          	auipc	ra,0x0
    80004146:	882080e7          	jalr	-1918(ra) # 800039c4 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000414a:	0809a023          	sw	zero,128(s3)
    8000414e:	bf51                	j	800040e2 <itrunc+0x3e>

0000000080004150 <iput>:
{
    80004150:	1101                	addi	sp,sp,-32
    80004152:	ec06                	sd	ra,24(sp)
    80004154:	e822                	sd	s0,16(sp)
    80004156:	e426                	sd	s1,8(sp)
    80004158:	e04a                	sd	s2,0(sp)
    8000415a:	1000                	addi	s0,sp,32
    8000415c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000415e:	0001f517          	auipc	a0,0x1f
    80004162:	bda50513          	addi	a0,a0,-1062 # 80022d38 <itable>
    80004166:	ffffd097          	auipc	ra,0xffffd
    8000416a:	a70080e7          	jalr	-1424(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000416e:	4498                	lw	a4,8(s1)
    80004170:	4785                	li	a5,1
    80004172:	02f70363          	beq	a4,a5,80004198 <iput+0x48>
  ip->ref--;
    80004176:	449c                	lw	a5,8(s1)
    80004178:	37fd                	addiw	a5,a5,-1
    8000417a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000417c:	0001f517          	auipc	a0,0x1f
    80004180:	bbc50513          	addi	a0,a0,-1092 # 80022d38 <itable>
    80004184:	ffffd097          	auipc	ra,0xffffd
    80004188:	b06080e7          	jalr	-1274(ra) # 80000c8a <release>
}
    8000418c:	60e2                	ld	ra,24(sp)
    8000418e:	6442                	ld	s0,16(sp)
    80004190:	64a2                	ld	s1,8(sp)
    80004192:	6902                	ld	s2,0(sp)
    80004194:	6105                	addi	sp,sp,32
    80004196:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004198:	40bc                	lw	a5,64(s1)
    8000419a:	dff1                	beqz	a5,80004176 <iput+0x26>
    8000419c:	04a49783          	lh	a5,74(s1)
    800041a0:	fbf9                	bnez	a5,80004176 <iput+0x26>
    acquiresleep(&ip->lock);
    800041a2:	01048913          	addi	s2,s1,16
    800041a6:	854a                	mv	a0,s2
    800041a8:	00001097          	auipc	ra,0x1
    800041ac:	aae080e7          	jalr	-1362(ra) # 80004c56 <acquiresleep>
    release(&itable.lock);
    800041b0:	0001f517          	auipc	a0,0x1f
    800041b4:	b8850513          	addi	a0,a0,-1144 # 80022d38 <itable>
    800041b8:	ffffd097          	auipc	ra,0xffffd
    800041bc:	ad2080e7          	jalr	-1326(ra) # 80000c8a <release>
    itrunc(ip);
    800041c0:	8526                	mv	a0,s1
    800041c2:	00000097          	auipc	ra,0x0
    800041c6:	ee2080e7          	jalr	-286(ra) # 800040a4 <itrunc>
    ip->type = 0;
    800041ca:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800041ce:	8526                	mv	a0,s1
    800041d0:	00000097          	auipc	ra,0x0
    800041d4:	cfa080e7          	jalr	-774(ra) # 80003eca <iupdate>
    ip->valid = 0;
    800041d8:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800041dc:	854a                	mv	a0,s2
    800041de:	00001097          	auipc	ra,0x1
    800041e2:	ad0080e7          	jalr	-1328(ra) # 80004cae <releasesleep>
    acquire(&itable.lock);
    800041e6:	0001f517          	auipc	a0,0x1f
    800041ea:	b5250513          	addi	a0,a0,-1198 # 80022d38 <itable>
    800041ee:	ffffd097          	auipc	ra,0xffffd
    800041f2:	9e8080e7          	jalr	-1560(ra) # 80000bd6 <acquire>
    800041f6:	b741                	j	80004176 <iput+0x26>

00000000800041f8 <iunlockput>:
{
    800041f8:	1101                	addi	sp,sp,-32
    800041fa:	ec06                	sd	ra,24(sp)
    800041fc:	e822                	sd	s0,16(sp)
    800041fe:	e426                	sd	s1,8(sp)
    80004200:	1000                	addi	s0,sp,32
    80004202:	84aa                	mv	s1,a0
  iunlock(ip);
    80004204:	00000097          	auipc	ra,0x0
    80004208:	e54080e7          	jalr	-428(ra) # 80004058 <iunlock>
  iput(ip);
    8000420c:	8526                	mv	a0,s1
    8000420e:	00000097          	auipc	ra,0x0
    80004212:	f42080e7          	jalr	-190(ra) # 80004150 <iput>
}
    80004216:	60e2                	ld	ra,24(sp)
    80004218:	6442                	ld	s0,16(sp)
    8000421a:	64a2                	ld	s1,8(sp)
    8000421c:	6105                	addi	sp,sp,32
    8000421e:	8082                	ret

0000000080004220 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004220:	1141                	addi	sp,sp,-16
    80004222:	e422                	sd	s0,8(sp)
    80004224:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004226:	411c                	lw	a5,0(a0)
    80004228:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000422a:	415c                	lw	a5,4(a0)
    8000422c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000422e:	04451783          	lh	a5,68(a0)
    80004232:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004236:	04a51783          	lh	a5,74(a0)
    8000423a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000423e:	04c56783          	lwu	a5,76(a0)
    80004242:	e99c                	sd	a5,16(a1)
}
    80004244:	6422                	ld	s0,8(sp)
    80004246:	0141                	addi	sp,sp,16
    80004248:	8082                	ret

000000008000424a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000424a:	457c                	lw	a5,76(a0)
    8000424c:	0ed7e963          	bltu	a5,a3,8000433e <readi+0xf4>
{
    80004250:	7159                	addi	sp,sp,-112
    80004252:	f486                	sd	ra,104(sp)
    80004254:	f0a2                	sd	s0,96(sp)
    80004256:	eca6                	sd	s1,88(sp)
    80004258:	e8ca                	sd	s2,80(sp)
    8000425a:	e4ce                	sd	s3,72(sp)
    8000425c:	e0d2                	sd	s4,64(sp)
    8000425e:	fc56                	sd	s5,56(sp)
    80004260:	f85a                	sd	s6,48(sp)
    80004262:	f45e                	sd	s7,40(sp)
    80004264:	f062                	sd	s8,32(sp)
    80004266:	ec66                	sd	s9,24(sp)
    80004268:	e86a                	sd	s10,16(sp)
    8000426a:	e46e                	sd	s11,8(sp)
    8000426c:	1880                	addi	s0,sp,112
    8000426e:	8b2a                	mv	s6,a0
    80004270:	8bae                	mv	s7,a1
    80004272:	8a32                	mv	s4,a2
    80004274:	84b6                	mv	s1,a3
    80004276:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80004278:	9f35                	addw	a4,a4,a3
    return 0;
    8000427a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000427c:	0ad76063          	bltu	a4,a3,8000431c <readi+0xd2>
  if(off + n > ip->size)
    80004280:	00e7f463          	bgeu	a5,a4,80004288 <readi+0x3e>
    n = ip->size - off;
    80004284:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004288:	0a0a8963          	beqz	s5,8000433a <readi+0xf0>
    8000428c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000428e:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004292:	5c7d                	li	s8,-1
    80004294:	a82d                	j	800042ce <readi+0x84>
    80004296:	020d1d93          	slli	s11,s10,0x20
    8000429a:	020ddd93          	srli	s11,s11,0x20
    8000429e:	05890613          	addi	a2,s2,88
    800042a2:	86ee                	mv	a3,s11
    800042a4:	963a                	add	a2,a2,a4
    800042a6:	85d2                	mv	a1,s4
    800042a8:	855e                	mv	a0,s7
    800042aa:	ffffe097          	auipc	ra,0xffffe
    800042ae:	4f6080e7          	jalr	1270(ra) # 800027a0 <either_copyout>
    800042b2:	05850d63          	beq	a0,s8,8000430c <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800042b6:	854a                	mv	a0,s2
    800042b8:	fffff097          	auipc	ra,0xfffff
    800042bc:	5f6080e7          	jalr	1526(ra) # 800038ae <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800042c0:	013d09bb          	addw	s3,s10,s3
    800042c4:	009d04bb          	addw	s1,s10,s1
    800042c8:	9a6e                	add	s4,s4,s11
    800042ca:	0559f763          	bgeu	s3,s5,80004318 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    800042ce:	00a4d59b          	srliw	a1,s1,0xa
    800042d2:	855a                	mv	a0,s6
    800042d4:	00000097          	auipc	ra,0x0
    800042d8:	89e080e7          	jalr	-1890(ra) # 80003b72 <bmap>
    800042dc:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800042e0:	cd85                	beqz	a1,80004318 <readi+0xce>
    bp = bread(ip->dev, addr);
    800042e2:	000b2503          	lw	a0,0(s6)
    800042e6:	fffff097          	auipc	ra,0xfffff
    800042ea:	498080e7          	jalr	1176(ra) # 8000377e <bread>
    800042ee:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800042f0:	3ff4f713          	andi	a4,s1,1023
    800042f4:	40ec87bb          	subw	a5,s9,a4
    800042f8:	413a86bb          	subw	a3,s5,s3
    800042fc:	8d3e                	mv	s10,a5
    800042fe:	2781                	sext.w	a5,a5
    80004300:	0006861b          	sext.w	a2,a3
    80004304:	f8f679e3          	bgeu	a2,a5,80004296 <readi+0x4c>
    80004308:	8d36                	mv	s10,a3
    8000430a:	b771                	j	80004296 <readi+0x4c>
      brelse(bp);
    8000430c:	854a                	mv	a0,s2
    8000430e:	fffff097          	auipc	ra,0xfffff
    80004312:	5a0080e7          	jalr	1440(ra) # 800038ae <brelse>
      tot = -1;
    80004316:	59fd                	li	s3,-1
  }
  return tot;
    80004318:	0009851b          	sext.w	a0,s3
}
    8000431c:	70a6                	ld	ra,104(sp)
    8000431e:	7406                	ld	s0,96(sp)
    80004320:	64e6                	ld	s1,88(sp)
    80004322:	6946                	ld	s2,80(sp)
    80004324:	69a6                	ld	s3,72(sp)
    80004326:	6a06                	ld	s4,64(sp)
    80004328:	7ae2                	ld	s5,56(sp)
    8000432a:	7b42                	ld	s6,48(sp)
    8000432c:	7ba2                	ld	s7,40(sp)
    8000432e:	7c02                	ld	s8,32(sp)
    80004330:	6ce2                	ld	s9,24(sp)
    80004332:	6d42                	ld	s10,16(sp)
    80004334:	6da2                	ld	s11,8(sp)
    80004336:	6165                	addi	sp,sp,112
    80004338:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000433a:	89d6                	mv	s3,s5
    8000433c:	bff1                	j	80004318 <readi+0xce>
    return 0;
    8000433e:	4501                	li	a0,0
}
    80004340:	8082                	ret

0000000080004342 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004342:	457c                	lw	a5,76(a0)
    80004344:	10d7e863          	bltu	a5,a3,80004454 <writei+0x112>
{
    80004348:	7159                	addi	sp,sp,-112
    8000434a:	f486                	sd	ra,104(sp)
    8000434c:	f0a2                	sd	s0,96(sp)
    8000434e:	eca6                	sd	s1,88(sp)
    80004350:	e8ca                	sd	s2,80(sp)
    80004352:	e4ce                	sd	s3,72(sp)
    80004354:	e0d2                	sd	s4,64(sp)
    80004356:	fc56                	sd	s5,56(sp)
    80004358:	f85a                	sd	s6,48(sp)
    8000435a:	f45e                	sd	s7,40(sp)
    8000435c:	f062                	sd	s8,32(sp)
    8000435e:	ec66                	sd	s9,24(sp)
    80004360:	e86a                	sd	s10,16(sp)
    80004362:	e46e                	sd	s11,8(sp)
    80004364:	1880                	addi	s0,sp,112
    80004366:	8aaa                	mv	s5,a0
    80004368:	8bae                	mv	s7,a1
    8000436a:	8a32                	mv	s4,a2
    8000436c:	8936                	mv	s2,a3
    8000436e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004370:	00e687bb          	addw	a5,a3,a4
    80004374:	0ed7e263          	bltu	a5,a3,80004458 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004378:	00043737          	lui	a4,0x43
    8000437c:	0ef76063          	bltu	a4,a5,8000445c <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004380:	0c0b0863          	beqz	s6,80004450 <writei+0x10e>
    80004384:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004386:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000438a:	5c7d                	li	s8,-1
    8000438c:	a091                	j	800043d0 <writei+0x8e>
    8000438e:	020d1d93          	slli	s11,s10,0x20
    80004392:	020ddd93          	srli	s11,s11,0x20
    80004396:	05848513          	addi	a0,s1,88
    8000439a:	86ee                	mv	a3,s11
    8000439c:	8652                	mv	a2,s4
    8000439e:	85de                	mv	a1,s7
    800043a0:	953a                	add	a0,a0,a4
    800043a2:	ffffe097          	auipc	ra,0xffffe
    800043a6:	454080e7          	jalr	1108(ra) # 800027f6 <either_copyin>
    800043aa:	07850263          	beq	a0,s8,8000440e <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800043ae:	8526                	mv	a0,s1
    800043b0:	00000097          	auipc	ra,0x0
    800043b4:	788080e7          	jalr	1928(ra) # 80004b38 <log_write>
    brelse(bp);
    800043b8:	8526                	mv	a0,s1
    800043ba:	fffff097          	auipc	ra,0xfffff
    800043be:	4f4080e7          	jalr	1268(ra) # 800038ae <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800043c2:	013d09bb          	addw	s3,s10,s3
    800043c6:	012d093b          	addw	s2,s10,s2
    800043ca:	9a6e                	add	s4,s4,s11
    800043cc:	0569f663          	bgeu	s3,s6,80004418 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    800043d0:	00a9559b          	srliw	a1,s2,0xa
    800043d4:	8556                	mv	a0,s5
    800043d6:	fffff097          	auipc	ra,0xfffff
    800043da:	79c080e7          	jalr	1948(ra) # 80003b72 <bmap>
    800043de:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800043e2:	c99d                	beqz	a1,80004418 <writei+0xd6>
    bp = bread(ip->dev, addr);
    800043e4:	000aa503          	lw	a0,0(s5)
    800043e8:	fffff097          	auipc	ra,0xfffff
    800043ec:	396080e7          	jalr	918(ra) # 8000377e <bread>
    800043f0:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800043f2:	3ff97713          	andi	a4,s2,1023
    800043f6:	40ec87bb          	subw	a5,s9,a4
    800043fa:	413b06bb          	subw	a3,s6,s3
    800043fe:	8d3e                	mv	s10,a5
    80004400:	2781                	sext.w	a5,a5
    80004402:	0006861b          	sext.w	a2,a3
    80004406:	f8f674e3          	bgeu	a2,a5,8000438e <writei+0x4c>
    8000440a:	8d36                	mv	s10,a3
    8000440c:	b749                	j	8000438e <writei+0x4c>
      brelse(bp);
    8000440e:	8526                	mv	a0,s1
    80004410:	fffff097          	auipc	ra,0xfffff
    80004414:	49e080e7          	jalr	1182(ra) # 800038ae <brelse>
  }

  if(off > ip->size)
    80004418:	04caa783          	lw	a5,76(s5)
    8000441c:	0127f463          	bgeu	a5,s2,80004424 <writei+0xe2>
    ip->size = off;
    80004420:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004424:	8556                	mv	a0,s5
    80004426:	00000097          	auipc	ra,0x0
    8000442a:	aa4080e7          	jalr	-1372(ra) # 80003eca <iupdate>

  return tot;
    8000442e:	0009851b          	sext.w	a0,s3
}
    80004432:	70a6                	ld	ra,104(sp)
    80004434:	7406                	ld	s0,96(sp)
    80004436:	64e6                	ld	s1,88(sp)
    80004438:	6946                	ld	s2,80(sp)
    8000443a:	69a6                	ld	s3,72(sp)
    8000443c:	6a06                	ld	s4,64(sp)
    8000443e:	7ae2                	ld	s5,56(sp)
    80004440:	7b42                	ld	s6,48(sp)
    80004442:	7ba2                	ld	s7,40(sp)
    80004444:	7c02                	ld	s8,32(sp)
    80004446:	6ce2                	ld	s9,24(sp)
    80004448:	6d42                	ld	s10,16(sp)
    8000444a:	6da2                	ld	s11,8(sp)
    8000444c:	6165                	addi	sp,sp,112
    8000444e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004450:	89da                	mv	s3,s6
    80004452:	bfc9                	j	80004424 <writei+0xe2>
    return -1;
    80004454:	557d                	li	a0,-1
}
    80004456:	8082                	ret
    return -1;
    80004458:	557d                	li	a0,-1
    8000445a:	bfe1                	j	80004432 <writei+0xf0>
    return -1;
    8000445c:	557d                	li	a0,-1
    8000445e:	bfd1                	j	80004432 <writei+0xf0>

0000000080004460 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004460:	1141                	addi	sp,sp,-16
    80004462:	e406                	sd	ra,8(sp)
    80004464:	e022                	sd	s0,0(sp)
    80004466:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004468:	4639                	li	a2,14
    8000446a:	ffffd097          	auipc	ra,0xffffd
    8000446e:	938080e7          	jalr	-1736(ra) # 80000da2 <strncmp>
}
    80004472:	60a2                	ld	ra,8(sp)
    80004474:	6402                	ld	s0,0(sp)
    80004476:	0141                	addi	sp,sp,16
    80004478:	8082                	ret

000000008000447a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000447a:	7139                	addi	sp,sp,-64
    8000447c:	fc06                	sd	ra,56(sp)
    8000447e:	f822                	sd	s0,48(sp)
    80004480:	f426                	sd	s1,40(sp)
    80004482:	f04a                	sd	s2,32(sp)
    80004484:	ec4e                	sd	s3,24(sp)
    80004486:	e852                	sd	s4,16(sp)
    80004488:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000448a:	04451703          	lh	a4,68(a0)
    8000448e:	4785                	li	a5,1
    80004490:	00f71a63          	bne	a4,a5,800044a4 <dirlookup+0x2a>
    80004494:	892a                	mv	s2,a0
    80004496:	89ae                	mv	s3,a1
    80004498:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000449a:	457c                	lw	a5,76(a0)
    8000449c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000449e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800044a0:	e79d                	bnez	a5,800044ce <dirlookup+0x54>
    800044a2:	a8a5                	j	8000451a <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800044a4:	00004517          	auipc	a0,0x4
    800044a8:	1d450513          	addi	a0,a0,468 # 80008678 <syscalls+0x1c8>
    800044ac:	ffffc097          	auipc	ra,0xffffc
    800044b0:	094080e7          	jalr	148(ra) # 80000540 <panic>
      panic("dirlookup read");
    800044b4:	00004517          	auipc	a0,0x4
    800044b8:	1dc50513          	addi	a0,a0,476 # 80008690 <syscalls+0x1e0>
    800044bc:	ffffc097          	auipc	ra,0xffffc
    800044c0:	084080e7          	jalr	132(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800044c4:	24c1                	addiw	s1,s1,16
    800044c6:	04c92783          	lw	a5,76(s2)
    800044ca:	04f4f763          	bgeu	s1,a5,80004518 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044ce:	4741                	li	a4,16
    800044d0:	86a6                	mv	a3,s1
    800044d2:	fc040613          	addi	a2,s0,-64
    800044d6:	4581                	li	a1,0
    800044d8:	854a                	mv	a0,s2
    800044da:	00000097          	auipc	ra,0x0
    800044de:	d70080e7          	jalr	-656(ra) # 8000424a <readi>
    800044e2:	47c1                	li	a5,16
    800044e4:	fcf518e3          	bne	a0,a5,800044b4 <dirlookup+0x3a>
    if(de.inum == 0)
    800044e8:	fc045783          	lhu	a5,-64(s0)
    800044ec:	dfe1                	beqz	a5,800044c4 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800044ee:	fc240593          	addi	a1,s0,-62
    800044f2:	854e                	mv	a0,s3
    800044f4:	00000097          	auipc	ra,0x0
    800044f8:	f6c080e7          	jalr	-148(ra) # 80004460 <namecmp>
    800044fc:	f561                	bnez	a0,800044c4 <dirlookup+0x4a>
      if(poff)
    800044fe:	000a0463          	beqz	s4,80004506 <dirlookup+0x8c>
        *poff = off;
    80004502:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004506:	fc045583          	lhu	a1,-64(s0)
    8000450a:	00092503          	lw	a0,0(s2)
    8000450e:	fffff097          	auipc	ra,0xfffff
    80004512:	74e080e7          	jalr	1870(ra) # 80003c5c <iget>
    80004516:	a011                	j	8000451a <dirlookup+0xa0>
  return 0;
    80004518:	4501                	li	a0,0
}
    8000451a:	70e2                	ld	ra,56(sp)
    8000451c:	7442                	ld	s0,48(sp)
    8000451e:	74a2                	ld	s1,40(sp)
    80004520:	7902                	ld	s2,32(sp)
    80004522:	69e2                	ld	s3,24(sp)
    80004524:	6a42                	ld	s4,16(sp)
    80004526:	6121                	addi	sp,sp,64
    80004528:	8082                	ret

000000008000452a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000452a:	711d                	addi	sp,sp,-96
    8000452c:	ec86                	sd	ra,88(sp)
    8000452e:	e8a2                	sd	s0,80(sp)
    80004530:	e4a6                	sd	s1,72(sp)
    80004532:	e0ca                	sd	s2,64(sp)
    80004534:	fc4e                	sd	s3,56(sp)
    80004536:	f852                	sd	s4,48(sp)
    80004538:	f456                	sd	s5,40(sp)
    8000453a:	f05a                	sd	s6,32(sp)
    8000453c:	ec5e                	sd	s7,24(sp)
    8000453e:	e862                	sd	s8,16(sp)
    80004540:	e466                	sd	s9,8(sp)
    80004542:	e06a                	sd	s10,0(sp)
    80004544:	1080                	addi	s0,sp,96
    80004546:	84aa                	mv	s1,a0
    80004548:	8b2e                	mv	s6,a1
    8000454a:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000454c:	00054703          	lbu	a4,0(a0)
    80004550:	02f00793          	li	a5,47
    80004554:	02f70363          	beq	a4,a5,8000457a <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004558:	ffffd097          	auipc	ra,0xffffd
    8000455c:	5ee080e7          	jalr	1518(ra) # 80001b46 <myproc>
    80004560:	1d053503          	ld	a0,464(a0)
    80004564:	00000097          	auipc	ra,0x0
    80004568:	9f4080e7          	jalr	-1548(ra) # 80003f58 <idup>
    8000456c:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000456e:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80004572:	4cb5                	li	s9,13
  len = path - s;
    80004574:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004576:	4c05                	li	s8,1
    80004578:	a87d                	j	80004636 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    8000457a:	4585                	li	a1,1
    8000457c:	4505                	li	a0,1
    8000457e:	fffff097          	auipc	ra,0xfffff
    80004582:	6de080e7          	jalr	1758(ra) # 80003c5c <iget>
    80004586:	8a2a                	mv	s4,a0
    80004588:	b7dd                	j	8000456e <namex+0x44>
      iunlockput(ip);
    8000458a:	8552                	mv	a0,s4
    8000458c:	00000097          	auipc	ra,0x0
    80004590:	c6c080e7          	jalr	-916(ra) # 800041f8 <iunlockput>
      return 0;
    80004594:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004596:	8552                	mv	a0,s4
    80004598:	60e6                	ld	ra,88(sp)
    8000459a:	6446                	ld	s0,80(sp)
    8000459c:	64a6                	ld	s1,72(sp)
    8000459e:	6906                	ld	s2,64(sp)
    800045a0:	79e2                	ld	s3,56(sp)
    800045a2:	7a42                	ld	s4,48(sp)
    800045a4:	7aa2                	ld	s5,40(sp)
    800045a6:	7b02                	ld	s6,32(sp)
    800045a8:	6be2                	ld	s7,24(sp)
    800045aa:	6c42                	ld	s8,16(sp)
    800045ac:	6ca2                	ld	s9,8(sp)
    800045ae:	6d02                	ld	s10,0(sp)
    800045b0:	6125                	addi	sp,sp,96
    800045b2:	8082                	ret
      iunlock(ip);
    800045b4:	8552                	mv	a0,s4
    800045b6:	00000097          	auipc	ra,0x0
    800045ba:	aa2080e7          	jalr	-1374(ra) # 80004058 <iunlock>
      return ip;
    800045be:	bfe1                	j	80004596 <namex+0x6c>
      iunlockput(ip);
    800045c0:	8552                	mv	a0,s4
    800045c2:	00000097          	auipc	ra,0x0
    800045c6:	c36080e7          	jalr	-970(ra) # 800041f8 <iunlockput>
      return 0;
    800045ca:	8a4e                	mv	s4,s3
    800045cc:	b7e9                	j	80004596 <namex+0x6c>
  len = path - s;
    800045ce:	40998633          	sub	a2,s3,s1
    800045d2:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    800045d6:	09acd863          	bge	s9,s10,80004666 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    800045da:	4639                	li	a2,14
    800045dc:	85a6                	mv	a1,s1
    800045de:	8556                	mv	a0,s5
    800045e0:	ffffc097          	auipc	ra,0xffffc
    800045e4:	74e080e7          	jalr	1870(ra) # 80000d2e <memmove>
    800045e8:	84ce                	mv	s1,s3
  while(*path == '/')
    800045ea:	0004c783          	lbu	a5,0(s1)
    800045ee:	01279763          	bne	a5,s2,800045fc <namex+0xd2>
    path++;
    800045f2:	0485                	addi	s1,s1,1
  while(*path == '/')
    800045f4:	0004c783          	lbu	a5,0(s1)
    800045f8:	ff278de3          	beq	a5,s2,800045f2 <namex+0xc8>
    ilock(ip);
    800045fc:	8552                	mv	a0,s4
    800045fe:	00000097          	auipc	ra,0x0
    80004602:	998080e7          	jalr	-1640(ra) # 80003f96 <ilock>
    if(ip->type != T_DIR){
    80004606:	044a1783          	lh	a5,68(s4)
    8000460a:	f98790e3          	bne	a5,s8,8000458a <namex+0x60>
    if(nameiparent && *path == '\0'){
    8000460e:	000b0563          	beqz	s6,80004618 <namex+0xee>
    80004612:	0004c783          	lbu	a5,0(s1)
    80004616:	dfd9                	beqz	a5,800045b4 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004618:	865e                	mv	a2,s7
    8000461a:	85d6                	mv	a1,s5
    8000461c:	8552                	mv	a0,s4
    8000461e:	00000097          	auipc	ra,0x0
    80004622:	e5c080e7          	jalr	-420(ra) # 8000447a <dirlookup>
    80004626:	89aa                	mv	s3,a0
    80004628:	dd41                	beqz	a0,800045c0 <namex+0x96>
    iunlockput(ip);
    8000462a:	8552                	mv	a0,s4
    8000462c:	00000097          	auipc	ra,0x0
    80004630:	bcc080e7          	jalr	-1076(ra) # 800041f8 <iunlockput>
    ip = next;
    80004634:	8a4e                	mv	s4,s3
  while(*path == '/')
    80004636:	0004c783          	lbu	a5,0(s1)
    8000463a:	01279763          	bne	a5,s2,80004648 <namex+0x11e>
    path++;
    8000463e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004640:	0004c783          	lbu	a5,0(s1)
    80004644:	ff278de3          	beq	a5,s2,8000463e <namex+0x114>
  if(*path == 0)
    80004648:	cb9d                	beqz	a5,8000467e <namex+0x154>
  while(*path != '/' && *path != 0)
    8000464a:	0004c783          	lbu	a5,0(s1)
    8000464e:	89a6                	mv	s3,s1
  len = path - s;
    80004650:	8d5e                	mv	s10,s7
    80004652:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80004654:	01278963          	beq	a5,s2,80004666 <namex+0x13c>
    80004658:	dbbd                	beqz	a5,800045ce <namex+0xa4>
    path++;
    8000465a:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    8000465c:	0009c783          	lbu	a5,0(s3)
    80004660:	ff279ce3          	bne	a5,s2,80004658 <namex+0x12e>
    80004664:	b7ad                	j	800045ce <namex+0xa4>
    memmove(name, s, len);
    80004666:	2601                	sext.w	a2,a2
    80004668:	85a6                	mv	a1,s1
    8000466a:	8556                	mv	a0,s5
    8000466c:	ffffc097          	auipc	ra,0xffffc
    80004670:	6c2080e7          	jalr	1730(ra) # 80000d2e <memmove>
    name[len] = 0;
    80004674:	9d56                	add	s10,s10,s5
    80004676:	000d0023          	sb	zero,0(s10)
    8000467a:	84ce                	mv	s1,s3
    8000467c:	b7bd                	j	800045ea <namex+0xc0>
  if(nameiparent){
    8000467e:	f00b0ce3          	beqz	s6,80004596 <namex+0x6c>
    iput(ip);
    80004682:	8552                	mv	a0,s4
    80004684:	00000097          	auipc	ra,0x0
    80004688:	acc080e7          	jalr	-1332(ra) # 80004150 <iput>
    return 0;
    8000468c:	4a01                	li	s4,0
    8000468e:	b721                	j	80004596 <namex+0x6c>

0000000080004690 <dirlink>:
{
    80004690:	7139                	addi	sp,sp,-64
    80004692:	fc06                	sd	ra,56(sp)
    80004694:	f822                	sd	s0,48(sp)
    80004696:	f426                	sd	s1,40(sp)
    80004698:	f04a                	sd	s2,32(sp)
    8000469a:	ec4e                	sd	s3,24(sp)
    8000469c:	e852                	sd	s4,16(sp)
    8000469e:	0080                	addi	s0,sp,64
    800046a0:	892a                	mv	s2,a0
    800046a2:	8a2e                	mv	s4,a1
    800046a4:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800046a6:	4601                	li	a2,0
    800046a8:	00000097          	auipc	ra,0x0
    800046ac:	dd2080e7          	jalr	-558(ra) # 8000447a <dirlookup>
    800046b0:	e93d                	bnez	a0,80004726 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800046b2:	04c92483          	lw	s1,76(s2)
    800046b6:	c49d                	beqz	s1,800046e4 <dirlink+0x54>
    800046b8:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800046ba:	4741                	li	a4,16
    800046bc:	86a6                	mv	a3,s1
    800046be:	fc040613          	addi	a2,s0,-64
    800046c2:	4581                	li	a1,0
    800046c4:	854a                	mv	a0,s2
    800046c6:	00000097          	auipc	ra,0x0
    800046ca:	b84080e7          	jalr	-1148(ra) # 8000424a <readi>
    800046ce:	47c1                	li	a5,16
    800046d0:	06f51163          	bne	a0,a5,80004732 <dirlink+0xa2>
    if(de.inum == 0)
    800046d4:	fc045783          	lhu	a5,-64(s0)
    800046d8:	c791                	beqz	a5,800046e4 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800046da:	24c1                	addiw	s1,s1,16
    800046dc:	04c92783          	lw	a5,76(s2)
    800046e0:	fcf4ede3          	bltu	s1,a5,800046ba <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800046e4:	4639                	li	a2,14
    800046e6:	85d2                	mv	a1,s4
    800046e8:	fc240513          	addi	a0,s0,-62
    800046ec:	ffffc097          	auipc	ra,0xffffc
    800046f0:	6f2080e7          	jalr	1778(ra) # 80000dde <strncpy>
  de.inum = inum;
    800046f4:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800046f8:	4741                	li	a4,16
    800046fa:	86a6                	mv	a3,s1
    800046fc:	fc040613          	addi	a2,s0,-64
    80004700:	4581                	li	a1,0
    80004702:	854a                	mv	a0,s2
    80004704:	00000097          	auipc	ra,0x0
    80004708:	c3e080e7          	jalr	-962(ra) # 80004342 <writei>
    8000470c:	1541                	addi	a0,a0,-16
    8000470e:	00a03533          	snez	a0,a0
    80004712:	40a00533          	neg	a0,a0
}
    80004716:	70e2                	ld	ra,56(sp)
    80004718:	7442                	ld	s0,48(sp)
    8000471a:	74a2                	ld	s1,40(sp)
    8000471c:	7902                	ld	s2,32(sp)
    8000471e:	69e2                	ld	s3,24(sp)
    80004720:	6a42                	ld	s4,16(sp)
    80004722:	6121                	addi	sp,sp,64
    80004724:	8082                	ret
    iput(ip);
    80004726:	00000097          	auipc	ra,0x0
    8000472a:	a2a080e7          	jalr	-1494(ra) # 80004150 <iput>
    return -1;
    8000472e:	557d                	li	a0,-1
    80004730:	b7dd                	j	80004716 <dirlink+0x86>
      panic("dirlink read");
    80004732:	00004517          	auipc	a0,0x4
    80004736:	f6e50513          	addi	a0,a0,-146 # 800086a0 <syscalls+0x1f0>
    8000473a:	ffffc097          	auipc	ra,0xffffc
    8000473e:	e06080e7          	jalr	-506(ra) # 80000540 <panic>

0000000080004742 <namei>:

struct inode*
namei(char *path)
{
    80004742:	1101                	addi	sp,sp,-32
    80004744:	ec06                	sd	ra,24(sp)
    80004746:	e822                	sd	s0,16(sp)
    80004748:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000474a:	fe040613          	addi	a2,s0,-32
    8000474e:	4581                	li	a1,0
    80004750:	00000097          	auipc	ra,0x0
    80004754:	dda080e7          	jalr	-550(ra) # 8000452a <namex>
}
    80004758:	60e2                	ld	ra,24(sp)
    8000475a:	6442                	ld	s0,16(sp)
    8000475c:	6105                	addi	sp,sp,32
    8000475e:	8082                	ret

0000000080004760 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004760:	1141                	addi	sp,sp,-16
    80004762:	e406                	sd	ra,8(sp)
    80004764:	e022                	sd	s0,0(sp)
    80004766:	0800                	addi	s0,sp,16
    80004768:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000476a:	4585                	li	a1,1
    8000476c:	00000097          	auipc	ra,0x0
    80004770:	dbe080e7          	jalr	-578(ra) # 8000452a <namex>
}
    80004774:	60a2                	ld	ra,8(sp)
    80004776:	6402                	ld	s0,0(sp)
    80004778:	0141                	addi	sp,sp,16
    8000477a:	8082                	ret

000000008000477c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000477c:	1101                	addi	sp,sp,-32
    8000477e:	ec06                	sd	ra,24(sp)
    80004780:	e822                	sd	s0,16(sp)
    80004782:	e426                	sd	s1,8(sp)
    80004784:	e04a                	sd	s2,0(sp)
    80004786:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004788:	00020917          	auipc	s2,0x20
    8000478c:	05890913          	addi	s2,s2,88 # 800247e0 <log>
    80004790:	01892583          	lw	a1,24(s2)
    80004794:	02892503          	lw	a0,40(s2)
    80004798:	fffff097          	auipc	ra,0xfffff
    8000479c:	fe6080e7          	jalr	-26(ra) # 8000377e <bread>
    800047a0:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800047a2:	02c92683          	lw	a3,44(s2)
    800047a6:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800047a8:	02d05863          	blez	a3,800047d8 <write_head+0x5c>
    800047ac:	00020797          	auipc	a5,0x20
    800047b0:	06478793          	addi	a5,a5,100 # 80024810 <log+0x30>
    800047b4:	05c50713          	addi	a4,a0,92
    800047b8:	36fd                	addiw	a3,a3,-1
    800047ba:	02069613          	slli	a2,a3,0x20
    800047be:	01e65693          	srli	a3,a2,0x1e
    800047c2:	00020617          	auipc	a2,0x20
    800047c6:	05260613          	addi	a2,a2,82 # 80024814 <log+0x34>
    800047ca:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800047cc:	4390                	lw	a2,0(a5)
    800047ce:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800047d0:	0791                	addi	a5,a5,4
    800047d2:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    800047d4:	fed79ce3          	bne	a5,a3,800047cc <write_head+0x50>
  }
  bwrite(buf);
    800047d8:	8526                	mv	a0,s1
    800047da:	fffff097          	auipc	ra,0xfffff
    800047de:	096080e7          	jalr	150(ra) # 80003870 <bwrite>
  brelse(buf);
    800047e2:	8526                	mv	a0,s1
    800047e4:	fffff097          	auipc	ra,0xfffff
    800047e8:	0ca080e7          	jalr	202(ra) # 800038ae <brelse>
}
    800047ec:	60e2                	ld	ra,24(sp)
    800047ee:	6442                	ld	s0,16(sp)
    800047f0:	64a2                	ld	s1,8(sp)
    800047f2:	6902                	ld	s2,0(sp)
    800047f4:	6105                	addi	sp,sp,32
    800047f6:	8082                	ret

00000000800047f8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800047f8:	00020797          	auipc	a5,0x20
    800047fc:	0147a783          	lw	a5,20(a5) # 8002480c <log+0x2c>
    80004800:	0af05d63          	blez	a5,800048ba <install_trans+0xc2>
{
    80004804:	7139                	addi	sp,sp,-64
    80004806:	fc06                	sd	ra,56(sp)
    80004808:	f822                	sd	s0,48(sp)
    8000480a:	f426                	sd	s1,40(sp)
    8000480c:	f04a                	sd	s2,32(sp)
    8000480e:	ec4e                	sd	s3,24(sp)
    80004810:	e852                	sd	s4,16(sp)
    80004812:	e456                	sd	s5,8(sp)
    80004814:	e05a                	sd	s6,0(sp)
    80004816:	0080                	addi	s0,sp,64
    80004818:	8b2a                	mv	s6,a0
    8000481a:	00020a97          	auipc	s5,0x20
    8000481e:	ff6a8a93          	addi	s5,s5,-10 # 80024810 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004822:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004824:	00020997          	auipc	s3,0x20
    80004828:	fbc98993          	addi	s3,s3,-68 # 800247e0 <log>
    8000482c:	a00d                	j	8000484e <install_trans+0x56>
    brelse(lbuf);
    8000482e:	854a                	mv	a0,s2
    80004830:	fffff097          	auipc	ra,0xfffff
    80004834:	07e080e7          	jalr	126(ra) # 800038ae <brelse>
    brelse(dbuf);
    80004838:	8526                	mv	a0,s1
    8000483a:	fffff097          	auipc	ra,0xfffff
    8000483e:	074080e7          	jalr	116(ra) # 800038ae <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004842:	2a05                	addiw	s4,s4,1
    80004844:	0a91                	addi	s5,s5,4
    80004846:	02c9a783          	lw	a5,44(s3)
    8000484a:	04fa5e63          	bge	s4,a5,800048a6 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000484e:	0189a583          	lw	a1,24(s3)
    80004852:	014585bb          	addw	a1,a1,s4
    80004856:	2585                	addiw	a1,a1,1
    80004858:	0289a503          	lw	a0,40(s3)
    8000485c:	fffff097          	auipc	ra,0xfffff
    80004860:	f22080e7          	jalr	-222(ra) # 8000377e <bread>
    80004864:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004866:	000aa583          	lw	a1,0(s5)
    8000486a:	0289a503          	lw	a0,40(s3)
    8000486e:	fffff097          	auipc	ra,0xfffff
    80004872:	f10080e7          	jalr	-240(ra) # 8000377e <bread>
    80004876:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004878:	40000613          	li	a2,1024
    8000487c:	05890593          	addi	a1,s2,88
    80004880:	05850513          	addi	a0,a0,88
    80004884:	ffffc097          	auipc	ra,0xffffc
    80004888:	4aa080e7          	jalr	1194(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    8000488c:	8526                	mv	a0,s1
    8000488e:	fffff097          	auipc	ra,0xfffff
    80004892:	fe2080e7          	jalr	-30(ra) # 80003870 <bwrite>
    if(recovering == 0)
    80004896:	f80b1ce3          	bnez	s6,8000482e <install_trans+0x36>
      bunpin(dbuf);
    8000489a:	8526                	mv	a0,s1
    8000489c:	fffff097          	auipc	ra,0xfffff
    800048a0:	0ec080e7          	jalr	236(ra) # 80003988 <bunpin>
    800048a4:	b769                	j	8000482e <install_trans+0x36>
}
    800048a6:	70e2                	ld	ra,56(sp)
    800048a8:	7442                	ld	s0,48(sp)
    800048aa:	74a2                	ld	s1,40(sp)
    800048ac:	7902                	ld	s2,32(sp)
    800048ae:	69e2                	ld	s3,24(sp)
    800048b0:	6a42                	ld	s4,16(sp)
    800048b2:	6aa2                	ld	s5,8(sp)
    800048b4:	6b02                	ld	s6,0(sp)
    800048b6:	6121                	addi	sp,sp,64
    800048b8:	8082                	ret
    800048ba:	8082                	ret

00000000800048bc <initlog>:
{
    800048bc:	7179                	addi	sp,sp,-48
    800048be:	f406                	sd	ra,40(sp)
    800048c0:	f022                	sd	s0,32(sp)
    800048c2:	ec26                	sd	s1,24(sp)
    800048c4:	e84a                	sd	s2,16(sp)
    800048c6:	e44e                	sd	s3,8(sp)
    800048c8:	1800                	addi	s0,sp,48
    800048ca:	892a                	mv	s2,a0
    800048cc:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800048ce:	00020497          	auipc	s1,0x20
    800048d2:	f1248493          	addi	s1,s1,-238 # 800247e0 <log>
    800048d6:	00004597          	auipc	a1,0x4
    800048da:	dda58593          	addi	a1,a1,-550 # 800086b0 <syscalls+0x200>
    800048de:	8526                	mv	a0,s1
    800048e0:	ffffc097          	auipc	ra,0xffffc
    800048e4:	266080e7          	jalr	614(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    800048e8:	0149a583          	lw	a1,20(s3)
    800048ec:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800048ee:	0109a783          	lw	a5,16(s3)
    800048f2:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800048f4:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800048f8:	854a                	mv	a0,s2
    800048fa:	fffff097          	auipc	ra,0xfffff
    800048fe:	e84080e7          	jalr	-380(ra) # 8000377e <bread>
  log.lh.n = lh->n;
    80004902:	4d34                	lw	a3,88(a0)
    80004904:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004906:	02d05663          	blez	a3,80004932 <initlog+0x76>
    8000490a:	05c50793          	addi	a5,a0,92
    8000490e:	00020717          	auipc	a4,0x20
    80004912:	f0270713          	addi	a4,a4,-254 # 80024810 <log+0x30>
    80004916:	36fd                	addiw	a3,a3,-1
    80004918:	02069613          	slli	a2,a3,0x20
    8000491c:	01e65693          	srli	a3,a2,0x1e
    80004920:	06050613          	addi	a2,a0,96
    80004924:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004926:	4390                	lw	a2,0(a5)
    80004928:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000492a:	0791                	addi	a5,a5,4
    8000492c:	0711                	addi	a4,a4,4
    8000492e:	fed79ce3          	bne	a5,a3,80004926 <initlog+0x6a>
  brelse(buf);
    80004932:	fffff097          	auipc	ra,0xfffff
    80004936:	f7c080e7          	jalr	-132(ra) # 800038ae <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000493a:	4505                	li	a0,1
    8000493c:	00000097          	auipc	ra,0x0
    80004940:	ebc080e7          	jalr	-324(ra) # 800047f8 <install_trans>
  log.lh.n = 0;
    80004944:	00020797          	auipc	a5,0x20
    80004948:	ec07a423          	sw	zero,-312(a5) # 8002480c <log+0x2c>
  write_head(); // clear the log
    8000494c:	00000097          	auipc	ra,0x0
    80004950:	e30080e7          	jalr	-464(ra) # 8000477c <write_head>
}
    80004954:	70a2                	ld	ra,40(sp)
    80004956:	7402                	ld	s0,32(sp)
    80004958:	64e2                	ld	s1,24(sp)
    8000495a:	6942                	ld	s2,16(sp)
    8000495c:	69a2                	ld	s3,8(sp)
    8000495e:	6145                	addi	sp,sp,48
    80004960:	8082                	ret

0000000080004962 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004962:	1101                	addi	sp,sp,-32
    80004964:	ec06                	sd	ra,24(sp)
    80004966:	e822                	sd	s0,16(sp)
    80004968:	e426                	sd	s1,8(sp)
    8000496a:	e04a                	sd	s2,0(sp)
    8000496c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000496e:	00020517          	auipc	a0,0x20
    80004972:	e7250513          	addi	a0,a0,-398 # 800247e0 <log>
    80004976:	ffffc097          	auipc	ra,0xffffc
    8000497a:	260080e7          	jalr	608(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    8000497e:	00020497          	auipc	s1,0x20
    80004982:	e6248493          	addi	s1,s1,-414 # 800247e0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004986:	4979                	li	s2,30
    80004988:	a039                	j	80004996 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000498a:	85a6                	mv	a1,s1
    8000498c:	8526                	mv	a0,s1
    8000498e:	ffffe097          	auipc	ra,0xffffe
    80004992:	98e080e7          	jalr	-1650(ra) # 8000231c <sleep>
    if(log.committing){
    80004996:	50dc                	lw	a5,36(s1)
    80004998:	fbed                	bnez	a5,8000498a <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000499a:	5098                	lw	a4,32(s1)
    8000499c:	2705                	addiw	a4,a4,1
    8000499e:	0007069b          	sext.w	a3,a4
    800049a2:	0027179b          	slliw	a5,a4,0x2
    800049a6:	9fb9                	addw	a5,a5,a4
    800049a8:	0017979b          	slliw	a5,a5,0x1
    800049ac:	54d8                	lw	a4,44(s1)
    800049ae:	9fb9                	addw	a5,a5,a4
    800049b0:	00f95963          	bge	s2,a5,800049c2 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800049b4:	85a6                	mv	a1,s1
    800049b6:	8526                	mv	a0,s1
    800049b8:	ffffe097          	auipc	ra,0xffffe
    800049bc:	964080e7          	jalr	-1692(ra) # 8000231c <sleep>
    800049c0:	bfd9                	j	80004996 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800049c2:	00020517          	auipc	a0,0x20
    800049c6:	e1e50513          	addi	a0,a0,-482 # 800247e0 <log>
    800049ca:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800049cc:	ffffc097          	auipc	ra,0xffffc
    800049d0:	2be080e7          	jalr	702(ra) # 80000c8a <release>
      break;
    }
  }
}
    800049d4:	60e2                	ld	ra,24(sp)
    800049d6:	6442                	ld	s0,16(sp)
    800049d8:	64a2                	ld	s1,8(sp)
    800049da:	6902                	ld	s2,0(sp)
    800049dc:	6105                	addi	sp,sp,32
    800049de:	8082                	ret

00000000800049e0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800049e0:	7139                	addi	sp,sp,-64
    800049e2:	fc06                	sd	ra,56(sp)
    800049e4:	f822                	sd	s0,48(sp)
    800049e6:	f426                	sd	s1,40(sp)
    800049e8:	f04a                	sd	s2,32(sp)
    800049ea:	ec4e                	sd	s3,24(sp)
    800049ec:	e852                	sd	s4,16(sp)
    800049ee:	e456                	sd	s5,8(sp)
    800049f0:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800049f2:	00020497          	auipc	s1,0x20
    800049f6:	dee48493          	addi	s1,s1,-530 # 800247e0 <log>
    800049fa:	8526                	mv	a0,s1
    800049fc:	ffffc097          	auipc	ra,0xffffc
    80004a00:	1da080e7          	jalr	474(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    80004a04:	509c                	lw	a5,32(s1)
    80004a06:	37fd                	addiw	a5,a5,-1
    80004a08:	0007891b          	sext.w	s2,a5
    80004a0c:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004a0e:	50dc                	lw	a5,36(s1)
    80004a10:	e7b9                	bnez	a5,80004a5e <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004a12:	04091e63          	bnez	s2,80004a6e <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004a16:	00020497          	auipc	s1,0x20
    80004a1a:	dca48493          	addi	s1,s1,-566 # 800247e0 <log>
    80004a1e:	4785                	li	a5,1
    80004a20:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004a22:	8526                	mv	a0,s1
    80004a24:	ffffc097          	auipc	ra,0xffffc
    80004a28:	266080e7          	jalr	614(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004a2c:	54dc                	lw	a5,44(s1)
    80004a2e:	06f04763          	bgtz	a5,80004a9c <end_op+0xbc>
    acquire(&log.lock);
    80004a32:	00020497          	auipc	s1,0x20
    80004a36:	dae48493          	addi	s1,s1,-594 # 800247e0 <log>
    80004a3a:	8526                	mv	a0,s1
    80004a3c:	ffffc097          	auipc	ra,0xffffc
    80004a40:	19a080e7          	jalr	410(ra) # 80000bd6 <acquire>
    log.committing = 0;
    80004a44:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004a48:	8526                	mv	a0,s1
    80004a4a:	ffffe097          	auipc	ra,0xffffe
    80004a4e:	946080e7          	jalr	-1722(ra) # 80002390 <wakeup>
    release(&log.lock);
    80004a52:	8526                	mv	a0,s1
    80004a54:	ffffc097          	auipc	ra,0xffffc
    80004a58:	236080e7          	jalr	566(ra) # 80000c8a <release>
}
    80004a5c:	a03d                	j	80004a8a <end_op+0xaa>
    panic("log.committing");
    80004a5e:	00004517          	auipc	a0,0x4
    80004a62:	c5a50513          	addi	a0,a0,-934 # 800086b8 <syscalls+0x208>
    80004a66:	ffffc097          	auipc	ra,0xffffc
    80004a6a:	ada080e7          	jalr	-1318(ra) # 80000540 <panic>
    wakeup(&log);
    80004a6e:	00020497          	auipc	s1,0x20
    80004a72:	d7248493          	addi	s1,s1,-654 # 800247e0 <log>
    80004a76:	8526                	mv	a0,s1
    80004a78:	ffffe097          	auipc	ra,0xffffe
    80004a7c:	918080e7          	jalr	-1768(ra) # 80002390 <wakeup>
  release(&log.lock);
    80004a80:	8526                	mv	a0,s1
    80004a82:	ffffc097          	auipc	ra,0xffffc
    80004a86:	208080e7          	jalr	520(ra) # 80000c8a <release>
}
    80004a8a:	70e2                	ld	ra,56(sp)
    80004a8c:	7442                	ld	s0,48(sp)
    80004a8e:	74a2                	ld	s1,40(sp)
    80004a90:	7902                	ld	s2,32(sp)
    80004a92:	69e2                	ld	s3,24(sp)
    80004a94:	6a42                	ld	s4,16(sp)
    80004a96:	6aa2                	ld	s5,8(sp)
    80004a98:	6121                	addi	sp,sp,64
    80004a9a:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a9c:	00020a97          	auipc	s5,0x20
    80004aa0:	d74a8a93          	addi	s5,s5,-652 # 80024810 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004aa4:	00020a17          	auipc	s4,0x20
    80004aa8:	d3ca0a13          	addi	s4,s4,-708 # 800247e0 <log>
    80004aac:	018a2583          	lw	a1,24(s4)
    80004ab0:	012585bb          	addw	a1,a1,s2
    80004ab4:	2585                	addiw	a1,a1,1
    80004ab6:	028a2503          	lw	a0,40(s4)
    80004aba:	fffff097          	auipc	ra,0xfffff
    80004abe:	cc4080e7          	jalr	-828(ra) # 8000377e <bread>
    80004ac2:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004ac4:	000aa583          	lw	a1,0(s5)
    80004ac8:	028a2503          	lw	a0,40(s4)
    80004acc:	fffff097          	auipc	ra,0xfffff
    80004ad0:	cb2080e7          	jalr	-846(ra) # 8000377e <bread>
    80004ad4:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004ad6:	40000613          	li	a2,1024
    80004ada:	05850593          	addi	a1,a0,88
    80004ade:	05848513          	addi	a0,s1,88
    80004ae2:	ffffc097          	auipc	ra,0xffffc
    80004ae6:	24c080e7          	jalr	588(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    80004aea:	8526                	mv	a0,s1
    80004aec:	fffff097          	auipc	ra,0xfffff
    80004af0:	d84080e7          	jalr	-636(ra) # 80003870 <bwrite>
    brelse(from);
    80004af4:	854e                	mv	a0,s3
    80004af6:	fffff097          	auipc	ra,0xfffff
    80004afa:	db8080e7          	jalr	-584(ra) # 800038ae <brelse>
    brelse(to);
    80004afe:	8526                	mv	a0,s1
    80004b00:	fffff097          	auipc	ra,0xfffff
    80004b04:	dae080e7          	jalr	-594(ra) # 800038ae <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004b08:	2905                	addiw	s2,s2,1
    80004b0a:	0a91                	addi	s5,s5,4
    80004b0c:	02ca2783          	lw	a5,44(s4)
    80004b10:	f8f94ee3          	blt	s2,a5,80004aac <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004b14:	00000097          	auipc	ra,0x0
    80004b18:	c68080e7          	jalr	-920(ra) # 8000477c <write_head>
    install_trans(0); // Now install writes to home locations
    80004b1c:	4501                	li	a0,0
    80004b1e:	00000097          	auipc	ra,0x0
    80004b22:	cda080e7          	jalr	-806(ra) # 800047f8 <install_trans>
    log.lh.n = 0;
    80004b26:	00020797          	auipc	a5,0x20
    80004b2a:	ce07a323          	sw	zero,-794(a5) # 8002480c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004b2e:	00000097          	auipc	ra,0x0
    80004b32:	c4e080e7          	jalr	-946(ra) # 8000477c <write_head>
    80004b36:	bdf5                	j	80004a32 <end_op+0x52>

0000000080004b38 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004b38:	1101                	addi	sp,sp,-32
    80004b3a:	ec06                	sd	ra,24(sp)
    80004b3c:	e822                	sd	s0,16(sp)
    80004b3e:	e426                	sd	s1,8(sp)
    80004b40:	e04a                	sd	s2,0(sp)
    80004b42:	1000                	addi	s0,sp,32
    80004b44:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004b46:	00020917          	auipc	s2,0x20
    80004b4a:	c9a90913          	addi	s2,s2,-870 # 800247e0 <log>
    80004b4e:	854a                	mv	a0,s2
    80004b50:	ffffc097          	auipc	ra,0xffffc
    80004b54:	086080e7          	jalr	134(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004b58:	02c92603          	lw	a2,44(s2)
    80004b5c:	47f5                	li	a5,29
    80004b5e:	06c7c563          	blt	a5,a2,80004bc8 <log_write+0x90>
    80004b62:	00020797          	auipc	a5,0x20
    80004b66:	c9a7a783          	lw	a5,-870(a5) # 800247fc <log+0x1c>
    80004b6a:	37fd                	addiw	a5,a5,-1
    80004b6c:	04f65e63          	bge	a2,a5,80004bc8 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004b70:	00020797          	auipc	a5,0x20
    80004b74:	c907a783          	lw	a5,-880(a5) # 80024800 <log+0x20>
    80004b78:	06f05063          	blez	a5,80004bd8 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004b7c:	4781                	li	a5,0
    80004b7e:	06c05563          	blez	a2,80004be8 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004b82:	44cc                	lw	a1,12(s1)
    80004b84:	00020717          	auipc	a4,0x20
    80004b88:	c8c70713          	addi	a4,a4,-884 # 80024810 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004b8c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004b8e:	4314                	lw	a3,0(a4)
    80004b90:	04b68c63          	beq	a3,a1,80004be8 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004b94:	2785                	addiw	a5,a5,1
    80004b96:	0711                	addi	a4,a4,4
    80004b98:	fef61be3          	bne	a2,a5,80004b8e <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004b9c:	0621                	addi	a2,a2,8
    80004b9e:	060a                	slli	a2,a2,0x2
    80004ba0:	00020797          	auipc	a5,0x20
    80004ba4:	c4078793          	addi	a5,a5,-960 # 800247e0 <log>
    80004ba8:	97b2                	add	a5,a5,a2
    80004baa:	44d8                	lw	a4,12(s1)
    80004bac:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004bae:	8526                	mv	a0,s1
    80004bb0:	fffff097          	auipc	ra,0xfffff
    80004bb4:	d9c080e7          	jalr	-612(ra) # 8000394c <bpin>
    log.lh.n++;
    80004bb8:	00020717          	auipc	a4,0x20
    80004bbc:	c2870713          	addi	a4,a4,-984 # 800247e0 <log>
    80004bc0:	575c                	lw	a5,44(a4)
    80004bc2:	2785                	addiw	a5,a5,1
    80004bc4:	d75c                	sw	a5,44(a4)
    80004bc6:	a82d                	j	80004c00 <log_write+0xc8>
    panic("too big a transaction");
    80004bc8:	00004517          	auipc	a0,0x4
    80004bcc:	b0050513          	addi	a0,a0,-1280 # 800086c8 <syscalls+0x218>
    80004bd0:	ffffc097          	auipc	ra,0xffffc
    80004bd4:	970080e7          	jalr	-1680(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    80004bd8:	00004517          	auipc	a0,0x4
    80004bdc:	b0850513          	addi	a0,a0,-1272 # 800086e0 <syscalls+0x230>
    80004be0:	ffffc097          	auipc	ra,0xffffc
    80004be4:	960080e7          	jalr	-1696(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    80004be8:	00878693          	addi	a3,a5,8
    80004bec:	068a                	slli	a3,a3,0x2
    80004bee:	00020717          	auipc	a4,0x20
    80004bf2:	bf270713          	addi	a4,a4,-1038 # 800247e0 <log>
    80004bf6:	9736                	add	a4,a4,a3
    80004bf8:	44d4                	lw	a3,12(s1)
    80004bfa:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004bfc:	faf609e3          	beq	a2,a5,80004bae <log_write+0x76>
  }
  release(&log.lock);
    80004c00:	00020517          	auipc	a0,0x20
    80004c04:	be050513          	addi	a0,a0,-1056 # 800247e0 <log>
    80004c08:	ffffc097          	auipc	ra,0xffffc
    80004c0c:	082080e7          	jalr	130(ra) # 80000c8a <release>
}
    80004c10:	60e2                	ld	ra,24(sp)
    80004c12:	6442                	ld	s0,16(sp)
    80004c14:	64a2                	ld	s1,8(sp)
    80004c16:	6902                	ld	s2,0(sp)
    80004c18:	6105                	addi	sp,sp,32
    80004c1a:	8082                	ret

0000000080004c1c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004c1c:	1101                	addi	sp,sp,-32
    80004c1e:	ec06                	sd	ra,24(sp)
    80004c20:	e822                	sd	s0,16(sp)
    80004c22:	e426                	sd	s1,8(sp)
    80004c24:	e04a                	sd	s2,0(sp)
    80004c26:	1000                	addi	s0,sp,32
    80004c28:	84aa                	mv	s1,a0
    80004c2a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004c2c:	00004597          	auipc	a1,0x4
    80004c30:	ad458593          	addi	a1,a1,-1324 # 80008700 <syscalls+0x250>
    80004c34:	0521                	addi	a0,a0,8
    80004c36:	ffffc097          	auipc	ra,0xffffc
    80004c3a:	f10080e7          	jalr	-240(ra) # 80000b46 <initlock>
  lk->name = name;
    80004c3e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004c42:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004c46:	0204a423          	sw	zero,40(s1)
}
    80004c4a:	60e2                	ld	ra,24(sp)
    80004c4c:	6442                	ld	s0,16(sp)
    80004c4e:	64a2                	ld	s1,8(sp)
    80004c50:	6902                	ld	s2,0(sp)
    80004c52:	6105                	addi	sp,sp,32
    80004c54:	8082                	ret

0000000080004c56 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004c56:	1101                	addi	sp,sp,-32
    80004c58:	ec06                	sd	ra,24(sp)
    80004c5a:	e822                	sd	s0,16(sp)
    80004c5c:	e426                	sd	s1,8(sp)
    80004c5e:	e04a                	sd	s2,0(sp)
    80004c60:	1000                	addi	s0,sp,32
    80004c62:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004c64:	00850913          	addi	s2,a0,8
    80004c68:	854a                	mv	a0,s2
    80004c6a:	ffffc097          	auipc	ra,0xffffc
    80004c6e:	f6c080e7          	jalr	-148(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    80004c72:	409c                	lw	a5,0(s1)
    80004c74:	cb89                	beqz	a5,80004c86 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004c76:	85ca                	mv	a1,s2
    80004c78:	8526                	mv	a0,s1
    80004c7a:	ffffd097          	auipc	ra,0xffffd
    80004c7e:	6a2080e7          	jalr	1698(ra) # 8000231c <sleep>
  while (lk->locked) {
    80004c82:	409c                	lw	a5,0(s1)
    80004c84:	fbed                	bnez	a5,80004c76 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004c86:	4785                	li	a5,1
    80004c88:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004c8a:	ffffd097          	auipc	ra,0xffffd
    80004c8e:	ebc080e7          	jalr	-324(ra) # 80001b46 <myproc>
    80004c92:	0b052783          	lw	a5,176(a0)
    80004c96:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004c98:	854a                	mv	a0,s2
    80004c9a:	ffffc097          	auipc	ra,0xffffc
    80004c9e:	ff0080e7          	jalr	-16(ra) # 80000c8a <release>
}
    80004ca2:	60e2                	ld	ra,24(sp)
    80004ca4:	6442                	ld	s0,16(sp)
    80004ca6:	64a2                	ld	s1,8(sp)
    80004ca8:	6902                	ld	s2,0(sp)
    80004caa:	6105                	addi	sp,sp,32
    80004cac:	8082                	ret

0000000080004cae <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004cae:	1101                	addi	sp,sp,-32
    80004cb0:	ec06                	sd	ra,24(sp)
    80004cb2:	e822                	sd	s0,16(sp)
    80004cb4:	e426                	sd	s1,8(sp)
    80004cb6:	e04a                	sd	s2,0(sp)
    80004cb8:	1000                	addi	s0,sp,32
    80004cba:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004cbc:	00850913          	addi	s2,a0,8
    80004cc0:	854a                	mv	a0,s2
    80004cc2:	ffffc097          	auipc	ra,0xffffc
    80004cc6:	f14080e7          	jalr	-236(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004cca:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004cce:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004cd2:	8526                	mv	a0,s1
    80004cd4:	ffffd097          	auipc	ra,0xffffd
    80004cd8:	6bc080e7          	jalr	1724(ra) # 80002390 <wakeup>
  release(&lk->lk);
    80004cdc:	854a                	mv	a0,s2
    80004cde:	ffffc097          	auipc	ra,0xffffc
    80004ce2:	fac080e7          	jalr	-84(ra) # 80000c8a <release>
}
    80004ce6:	60e2                	ld	ra,24(sp)
    80004ce8:	6442                	ld	s0,16(sp)
    80004cea:	64a2                	ld	s1,8(sp)
    80004cec:	6902                	ld	s2,0(sp)
    80004cee:	6105                	addi	sp,sp,32
    80004cf0:	8082                	ret

0000000080004cf2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004cf2:	7179                	addi	sp,sp,-48
    80004cf4:	f406                	sd	ra,40(sp)
    80004cf6:	f022                	sd	s0,32(sp)
    80004cf8:	ec26                	sd	s1,24(sp)
    80004cfa:	e84a                	sd	s2,16(sp)
    80004cfc:	e44e                	sd	s3,8(sp)
    80004cfe:	1800                	addi	s0,sp,48
    80004d00:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004d02:	00850913          	addi	s2,a0,8
    80004d06:	854a                	mv	a0,s2
    80004d08:	ffffc097          	auipc	ra,0xffffc
    80004d0c:	ece080e7          	jalr	-306(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004d10:	409c                	lw	a5,0(s1)
    80004d12:	ef99                	bnez	a5,80004d30 <holdingsleep+0x3e>
    80004d14:	4481                	li	s1,0
  release(&lk->lk);
    80004d16:	854a                	mv	a0,s2
    80004d18:	ffffc097          	auipc	ra,0xffffc
    80004d1c:	f72080e7          	jalr	-142(ra) # 80000c8a <release>
  return r;
}
    80004d20:	8526                	mv	a0,s1
    80004d22:	70a2                	ld	ra,40(sp)
    80004d24:	7402                	ld	s0,32(sp)
    80004d26:	64e2                	ld	s1,24(sp)
    80004d28:	6942                	ld	s2,16(sp)
    80004d2a:	69a2                	ld	s3,8(sp)
    80004d2c:	6145                	addi	sp,sp,48
    80004d2e:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004d30:	0284a983          	lw	s3,40(s1)
    80004d34:	ffffd097          	auipc	ra,0xffffd
    80004d38:	e12080e7          	jalr	-494(ra) # 80001b46 <myproc>
    80004d3c:	0b052483          	lw	s1,176(a0)
    80004d40:	413484b3          	sub	s1,s1,s3
    80004d44:	0014b493          	seqz	s1,s1
    80004d48:	b7f9                	j	80004d16 <holdingsleep+0x24>

0000000080004d4a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004d4a:	1141                	addi	sp,sp,-16
    80004d4c:	e406                	sd	ra,8(sp)
    80004d4e:	e022                	sd	s0,0(sp)
    80004d50:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004d52:	00004597          	auipc	a1,0x4
    80004d56:	9be58593          	addi	a1,a1,-1602 # 80008710 <syscalls+0x260>
    80004d5a:	00020517          	auipc	a0,0x20
    80004d5e:	bce50513          	addi	a0,a0,-1074 # 80024928 <ftable>
    80004d62:	ffffc097          	auipc	ra,0xffffc
    80004d66:	de4080e7          	jalr	-540(ra) # 80000b46 <initlock>
}
    80004d6a:	60a2                	ld	ra,8(sp)
    80004d6c:	6402                	ld	s0,0(sp)
    80004d6e:	0141                	addi	sp,sp,16
    80004d70:	8082                	ret

0000000080004d72 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004d72:	1101                	addi	sp,sp,-32
    80004d74:	ec06                	sd	ra,24(sp)
    80004d76:	e822                	sd	s0,16(sp)
    80004d78:	e426                	sd	s1,8(sp)
    80004d7a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004d7c:	00020517          	auipc	a0,0x20
    80004d80:	bac50513          	addi	a0,a0,-1108 # 80024928 <ftable>
    80004d84:	ffffc097          	auipc	ra,0xffffc
    80004d88:	e52080e7          	jalr	-430(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004d8c:	00020497          	auipc	s1,0x20
    80004d90:	bb448493          	addi	s1,s1,-1100 # 80024940 <ftable+0x18>
    80004d94:	00021717          	auipc	a4,0x21
    80004d98:	b4c70713          	addi	a4,a4,-1204 # 800258e0 <disk>
    if(f->ref == 0){
    80004d9c:	40dc                	lw	a5,4(s1)
    80004d9e:	cf99                	beqz	a5,80004dbc <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004da0:	02848493          	addi	s1,s1,40
    80004da4:	fee49ce3          	bne	s1,a4,80004d9c <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004da8:	00020517          	auipc	a0,0x20
    80004dac:	b8050513          	addi	a0,a0,-1152 # 80024928 <ftable>
    80004db0:	ffffc097          	auipc	ra,0xffffc
    80004db4:	eda080e7          	jalr	-294(ra) # 80000c8a <release>
  return 0;
    80004db8:	4481                	li	s1,0
    80004dba:	a819                	j	80004dd0 <filealloc+0x5e>
      f->ref = 1;
    80004dbc:	4785                	li	a5,1
    80004dbe:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004dc0:	00020517          	auipc	a0,0x20
    80004dc4:	b6850513          	addi	a0,a0,-1176 # 80024928 <ftable>
    80004dc8:	ffffc097          	auipc	ra,0xffffc
    80004dcc:	ec2080e7          	jalr	-318(ra) # 80000c8a <release>
}
    80004dd0:	8526                	mv	a0,s1
    80004dd2:	60e2                	ld	ra,24(sp)
    80004dd4:	6442                	ld	s0,16(sp)
    80004dd6:	64a2                	ld	s1,8(sp)
    80004dd8:	6105                	addi	sp,sp,32
    80004dda:	8082                	ret

0000000080004ddc <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004ddc:	1101                	addi	sp,sp,-32
    80004dde:	ec06                	sd	ra,24(sp)
    80004de0:	e822                	sd	s0,16(sp)
    80004de2:	e426                	sd	s1,8(sp)
    80004de4:	1000                	addi	s0,sp,32
    80004de6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004de8:	00020517          	auipc	a0,0x20
    80004dec:	b4050513          	addi	a0,a0,-1216 # 80024928 <ftable>
    80004df0:	ffffc097          	auipc	ra,0xffffc
    80004df4:	de6080e7          	jalr	-538(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004df8:	40dc                	lw	a5,4(s1)
    80004dfa:	02f05263          	blez	a5,80004e1e <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004dfe:	2785                	addiw	a5,a5,1
    80004e00:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004e02:	00020517          	auipc	a0,0x20
    80004e06:	b2650513          	addi	a0,a0,-1242 # 80024928 <ftable>
    80004e0a:	ffffc097          	auipc	ra,0xffffc
    80004e0e:	e80080e7          	jalr	-384(ra) # 80000c8a <release>
  return f;
}
    80004e12:	8526                	mv	a0,s1
    80004e14:	60e2                	ld	ra,24(sp)
    80004e16:	6442                	ld	s0,16(sp)
    80004e18:	64a2                	ld	s1,8(sp)
    80004e1a:	6105                	addi	sp,sp,32
    80004e1c:	8082                	ret
    panic("filedup");
    80004e1e:	00004517          	auipc	a0,0x4
    80004e22:	8fa50513          	addi	a0,a0,-1798 # 80008718 <syscalls+0x268>
    80004e26:	ffffb097          	auipc	ra,0xffffb
    80004e2a:	71a080e7          	jalr	1818(ra) # 80000540 <panic>

0000000080004e2e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004e2e:	7139                	addi	sp,sp,-64
    80004e30:	fc06                	sd	ra,56(sp)
    80004e32:	f822                	sd	s0,48(sp)
    80004e34:	f426                	sd	s1,40(sp)
    80004e36:	f04a                	sd	s2,32(sp)
    80004e38:	ec4e                	sd	s3,24(sp)
    80004e3a:	e852                	sd	s4,16(sp)
    80004e3c:	e456                	sd	s5,8(sp)
    80004e3e:	0080                	addi	s0,sp,64
    80004e40:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004e42:	00020517          	auipc	a0,0x20
    80004e46:	ae650513          	addi	a0,a0,-1306 # 80024928 <ftable>
    80004e4a:	ffffc097          	auipc	ra,0xffffc
    80004e4e:	d8c080e7          	jalr	-628(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004e52:	40dc                	lw	a5,4(s1)
    80004e54:	06f05163          	blez	a5,80004eb6 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004e58:	37fd                	addiw	a5,a5,-1
    80004e5a:	0007871b          	sext.w	a4,a5
    80004e5e:	c0dc                	sw	a5,4(s1)
    80004e60:	06e04363          	bgtz	a4,80004ec6 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004e64:	0004a903          	lw	s2,0(s1)
    80004e68:	0094ca83          	lbu	s5,9(s1)
    80004e6c:	0104ba03          	ld	s4,16(s1)
    80004e70:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004e74:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004e78:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004e7c:	00020517          	auipc	a0,0x20
    80004e80:	aac50513          	addi	a0,a0,-1364 # 80024928 <ftable>
    80004e84:	ffffc097          	auipc	ra,0xffffc
    80004e88:	e06080e7          	jalr	-506(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004e8c:	4785                	li	a5,1
    80004e8e:	04f90d63          	beq	s2,a5,80004ee8 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004e92:	3979                	addiw	s2,s2,-2
    80004e94:	4785                	li	a5,1
    80004e96:	0527e063          	bltu	a5,s2,80004ed6 <fileclose+0xa8>
    begin_op();
    80004e9a:	00000097          	auipc	ra,0x0
    80004e9e:	ac8080e7          	jalr	-1336(ra) # 80004962 <begin_op>
    iput(ff.ip);
    80004ea2:	854e                	mv	a0,s3
    80004ea4:	fffff097          	auipc	ra,0xfffff
    80004ea8:	2ac080e7          	jalr	684(ra) # 80004150 <iput>
    end_op();
    80004eac:	00000097          	auipc	ra,0x0
    80004eb0:	b34080e7          	jalr	-1228(ra) # 800049e0 <end_op>
    80004eb4:	a00d                	j	80004ed6 <fileclose+0xa8>
    panic("fileclose");
    80004eb6:	00004517          	auipc	a0,0x4
    80004eba:	86a50513          	addi	a0,a0,-1942 # 80008720 <syscalls+0x270>
    80004ebe:	ffffb097          	auipc	ra,0xffffb
    80004ec2:	682080e7          	jalr	1666(ra) # 80000540 <panic>
    release(&ftable.lock);
    80004ec6:	00020517          	auipc	a0,0x20
    80004eca:	a6250513          	addi	a0,a0,-1438 # 80024928 <ftable>
    80004ece:	ffffc097          	auipc	ra,0xffffc
    80004ed2:	dbc080e7          	jalr	-580(ra) # 80000c8a <release>
  }
}
    80004ed6:	70e2                	ld	ra,56(sp)
    80004ed8:	7442                	ld	s0,48(sp)
    80004eda:	74a2                	ld	s1,40(sp)
    80004edc:	7902                	ld	s2,32(sp)
    80004ede:	69e2                	ld	s3,24(sp)
    80004ee0:	6a42                	ld	s4,16(sp)
    80004ee2:	6aa2                	ld	s5,8(sp)
    80004ee4:	6121                	addi	sp,sp,64
    80004ee6:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004ee8:	85d6                	mv	a1,s5
    80004eea:	8552                	mv	a0,s4
    80004eec:	00000097          	auipc	ra,0x0
    80004ef0:	34c080e7          	jalr	844(ra) # 80005238 <pipeclose>
    80004ef4:	b7cd                	j	80004ed6 <fileclose+0xa8>

0000000080004ef6 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004ef6:	715d                	addi	sp,sp,-80
    80004ef8:	e486                	sd	ra,72(sp)
    80004efa:	e0a2                	sd	s0,64(sp)
    80004efc:	fc26                	sd	s1,56(sp)
    80004efe:	f84a                	sd	s2,48(sp)
    80004f00:	f44e                	sd	s3,40(sp)
    80004f02:	0880                	addi	s0,sp,80
    80004f04:	84aa                	mv	s1,a0
    80004f06:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004f08:	ffffd097          	auipc	ra,0xffffd
    80004f0c:	c3e080e7          	jalr	-962(ra) # 80001b46 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004f10:	409c                	lw	a5,0(s1)
    80004f12:	37f9                	addiw	a5,a5,-2
    80004f14:	4705                	li	a4,1
    80004f16:	04f76763          	bltu	a4,a5,80004f64 <filestat+0x6e>
    80004f1a:	892a                	mv	s2,a0
    ilock(f->ip);
    80004f1c:	6c88                	ld	a0,24(s1)
    80004f1e:	fffff097          	auipc	ra,0xfffff
    80004f22:	078080e7          	jalr	120(ra) # 80003f96 <ilock>
    stati(f->ip, &st);
    80004f26:	fb840593          	addi	a1,s0,-72
    80004f2a:	6c88                	ld	a0,24(s1)
    80004f2c:	fffff097          	auipc	ra,0xfffff
    80004f30:	2f4080e7          	jalr	756(ra) # 80004220 <stati>
    iunlock(f->ip);
    80004f34:	6c88                	ld	a0,24(s1)
    80004f36:	fffff097          	auipc	ra,0xfffff
    80004f3a:	122080e7          	jalr	290(ra) # 80004058 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004f3e:	46e1                	li	a3,24
    80004f40:	fb840613          	addi	a2,s0,-72
    80004f44:	85ce                	mv	a1,s3
    80004f46:	0d093503          	ld	a0,208(s2)
    80004f4a:	ffffc097          	auipc	ra,0xffffc
    80004f4e:	722080e7          	jalr	1826(ra) # 8000166c <copyout>
    80004f52:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004f56:	60a6                	ld	ra,72(sp)
    80004f58:	6406                	ld	s0,64(sp)
    80004f5a:	74e2                	ld	s1,56(sp)
    80004f5c:	7942                	ld	s2,48(sp)
    80004f5e:	79a2                	ld	s3,40(sp)
    80004f60:	6161                	addi	sp,sp,80
    80004f62:	8082                	ret
  return -1;
    80004f64:	557d                	li	a0,-1
    80004f66:	bfc5                	j	80004f56 <filestat+0x60>

0000000080004f68 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004f68:	7179                	addi	sp,sp,-48
    80004f6a:	f406                	sd	ra,40(sp)
    80004f6c:	f022                	sd	s0,32(sp)
    80004f6e:	ec26                	sd	s1,24(sp)
    80004f70:	e84a                	sd	s2,16(sp)
    80004f72:	e44e                	sd	s3,8(sp)
    80004f74:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004f76:	00854783          	lbu	a5,8(a0)
    80004f7a:	c3d5                	beqz	a5,8000501e <fileread+0xb6>
    80004f7c:	84aa                	mv	s1,a0
    80004f7e:	89ae                	mv	s3,a1
    80004f80:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004f82:	411c                	lw	a5,0(a0)
    80004f84:	4705                	li	a4,1
    80004f86:	04e78963          	beq	a5,a4,80004fd8 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004f8a:	470d                	li	a4,3
    80004f8c:	04e78d63          	beq	a5,a4,80004fe6 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004f90:	4709                	li	a4,2
    80004f92:	06e79e63          	bne	a5,a4,8000500e <fileread+0xa6>
    ilock(f->ip);
    80004f96:	6d08                	ld	a0,24(a0)
    80004f98:	fffff097          	auipc	ra,0xfffff
    80004f9c:	ffe080e7          	jalr	-2(ra) # 80003f96 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004fa0:	874a                	mv	a4,s2
    80004fa2:	5094                	lw	a3,32(s1)
    80004fa4:	864e                	mv	a2,s3
    80004fa6:	4585                	li	a1,1
    80004fa8:	6c88                	ld	a0,24(s1)
    80004faa:	fffff097          	auipc	ra,0xfffff
    80004fae:	2a0080e7          	jalr	672(ra) # 8000424a <readi>
    80004fb2:	892a                	mv	s2,a0
    80004fb4:	00a05563          	blez	a0,80004fbe <fileread+0x56>
      f->off += r;
    80004fb8:	509c                	lw	a5,32(s1)
    80004fba:	9fa9                	addw	a5,a5,a0
    80004fbc:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004fbe:	6c88                	ld	a0,24(s1)
    80004fc0:	fffff097          	auipc	ra,0xfffff
    80004fc4:	098080e7          	jalr	152(ra) # 80004058 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004fc8:	854a                	mv	a0,s2
    80004fca:	70a2                	ld	ra,40(sp)
    80004fcc:	7402                	ld	s0,32(sp)
    80004fce:	64e2                	ld	s1,24(sp)
    80004fd0:	6942                	ld	s2,16(sp)
    80004fd2:	69a2                	ld	s3,8(sp)
    80004fd4:	6145                	addi	sp,sp,48
    80004fd6:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004fd8:	6908                	ld	a0,16(a0)
    80004fda:	00000097          	auipc	ra,0x0
    80004fde:	3c6080e7          	jalr	966(ra) # 800053a0 <piperead>
    80004fe2:	892a                	mv	s2,a0
    80004fe4:	b7d5                	j	80004fc8 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004fe6:	02451783          	lh	a5,36(a0)
    80004fea:	03079693          	slli	a3,a5,0x30
    80004fee:	92c1                	srli	a3,a3,0x30
    80004ff0:	4725                	li	a4,9
    80004ff2:	02d76863          	bltu	a4,a3,80005022 <fileread+0xba>
    80004ff6:	0792                	slli	a5,a5,0x4
    80004ff8:	00020717          	auipc	a4,0x20
    80004ffc:	89070713          	addi	a4,a4,-1904 # 80024888 <devsw>
    80005000:	97ba                	add	a5,a5,a4
    80005002:	639c                	ld	a5,0(a5)
    80005004:	c38d                	beqz	a5,80005026 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80005006:	4505                	li	a0,1
    80005008:	9782                	jalr	a5
    8000500a:	892a                	mv	s2,a0
    8000500c:	bf75                	j	80004fc8 <fileread+0x60>
    panic("fileread");
    8000500e:	00003517          	auipc	a0,0x3
    80005012:	72250513          	addi	a0,a0,1826 # 80008730 <syscalls+0x280>
    80005016:	ffffb097          	auipc	ra,0xffffb
    8000501a:	52a080e7          	jalr	1322(ra) # 80000540 <panic>
    return -1;
    8000501e:	597d                	li	s2,-1
    80005020:	b765                	j	80004fc8 <fileread+0x60>
      return -1;
    80005022:	597d                	li	s2,-1
    80005024:	b755                	j	80004fc8 <fileread+0x60>
    80005026:	597d                	li	s2,-1
    80005028:	b745                	j	80004fc8 <fileread+0x60>

000000008000502a <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000502a:	715d                	addi	sp,sp,-80
    8000502c:	e486                	sd	ra,72(sp)
    8000502e:	e0a2                	sd	s0,64(sp)
    80005030:	fc26                	sd	s1,56(sp)
    80005032:	f84a                	sd	s2,48(sp)
    80005034:	f44e                	sd	s3,40(sp)
    80005036:	f052                	sd	s4,32(sp)
    80005038:	ec56                	sd	s5,24(sp)
    8000503a:	e85a                	sd	s6,16(sp)
    8000503c:	e45e                	sd	s7,8(sp)
    8000503e:	e062                	sd	s8,0(sp)
    80005040:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80005042:	00954783          	lbu	a5,9(a0)
    80005046:	10078663          	beqz	a5,80005152 <filewrite+0x128>
    8000504a:	892a                	mv	s2,a0
    8000504c:	8b2e                	mv	s6,a1
    8000504e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80005050:	411c                	lw	a5,0(a0)
    80005052:	4705                	li	a4,1
    80005054:	02e78263          	beq	a5,a4,80005078 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005058:	470d                	li	a4,3
    8000505a:	02e78663          	beq	a5,a4,80005086 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000505e:	4709                	li	a4,2
    80005060:	0ee79163          	bne	a5,a4,80005142 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005064:	0ac05d63          	blez	a2,8000511e <filewrite+0xf4>
    int i = 0;
    80005068:	4981                	li	s3,0
    8000506a:	6b85                	lui	s7,0x1
    8000506c:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80005070:	6c05                	lui	s8,0x1
    80005072:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80005076:	a861                	j	8000510e <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80005078:	6908                	ld	a0,16(a0)
    8000507a:	00000097          	auipc	ra,0x0
    8000507e:	22e080e7          	jalr	558(ra) # 800052a8 <pipewrite>
    80005082:	8a2a                	mv	s4,a0
    80005084:	a045                	j	80005124 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005086:	02451783          	lh	a5,36(a0)
    8000508a:	03079693          	slli	a3,a5,0x30
    8000508e:	92c1                	srli	a3,a3,0x30
    80005090:	4725                	li	a4,9
    80005092:	0cd76263          	bltu	a4,a3,80005156 <filewrite+0x12c>
    80005096:	0792                	slli	a5,a5,0x4
    80005098:	0001f717          	auipc	a4,0x1f
    8000509c:	7f070713          	addi	a4,a4,2032 # 80024888 <devsw>
    800050a0:	97ba                	add	a5,a5,a4
    800050a2:	679c                	ld	a5,8(a5)
    800050a4:	cbdd                	beqz	a5,8000515a <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800050a6:	4505                	li	a0,1
    800050a8:	9782                	jalr	a5
    800050aa:	8a2a                	mv	s4,a0
    800050ac:	a8a5                	j	80005124 <filewrite+0xfa>
    800050ae:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800050b2:	00000097          	auipc	ra,0x0
    800050b6:	8b0080e7          	jalr	-1872(ra) # 80004962 <begin_op>
      ilock(f->ip);
    800050ba:	01893503          	ld	a0,24(s2)
    800050be:	fffff097          	auipc	ra,0xfffff
    800050c2:	ed8080e7          	jalr	-296(ra) # 80003f96 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800050c6:	8756                	mv	a4,s5
    800050c8:	02092683          	lw	a3,32(s2)
    800050cc:	01698633          	add	a2,s3,s6
    800050d0:	4585                	li	a1,1
    800050d2:	01893503          	ld	a0,24(s2)
    800050d6:	fffff097          	auipc	ra,0xfffff
    800050da:	26c080e7          	jalr	620(ra) # 80004342 <writei>
    800050de:	84aa                	mv	s1,a0
    800050e0:	00a05763          	blez	a0,800050ee <filewrite+0xc4>
        f->off += r;
    800050e4:	02092783          	lw	a5,32(s2)
    800050e8:	9fa9                	addw	a5,a5,a0
    800050ea:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800050ee:	01893503          	ld	a0,24(s2)
    800050f2:	fffff097          	auipc	ra,0xfffff
    800050f6:	f66080e7          	jalr	-154(ra) # 80004058 <iunlock>
      end_op();
    800050fa:	00000097          	auipc	ra,0x0
    800050fe:	8e6080e7          	jalr	-1818(ra) # 800049e0 <end_op>

      if(r != n1){
    80005102:	009a9f63          	bne	s5,s1,80005120 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005106:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000510a:	0149db63          	bge	s3,s4,80005120 <filewrite+0xf6>
      int n1 = n - i;
    8000510e:	413a04bb          	subw	s1,s4,s3
    80005112:	0004879b          	sext.w	a5,s1
    80005116:	f8fbdce3          	bge	s7,a5,800050ae <filewrite+0x84>
    8000511a:	84e2                	mv	s1,s8
    8000511c:	bf49                	j	800050ae <filewrite+0x84>
    int i = 0;
    8000511e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005120:	013a1f63          	bne	s4,s3,8000513e <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005124:	8552                	mv	a0,s4
    80005126:	60a6                	ld	ra,72(sp)
    80005128:	6406                	ld	s0,64(sp)
    8000512a:	74e2                	ld	s1,56(sp)
    8000512c:	7942                	ld	s2,48(sp)
    8000512e:	79a2                	ld	s3,40(sp)
    80005130:	7a02                	ld	s4,32(sp)
    80005132:	6ae2                	ld	s5,24(sp)
    80005134:	6b42                	ld	s6,16(sp)
    80005136:	6ba2                	ld	s7,8(sp)
    80005138:	6c02                	ld	s8,0(sp)
    8000513a:	6161                	addi	sp,sp,80
    8000513c:	8082                	ret
    ret = (i == n ? n : -1);
    8000513e:	5a7d                	li	s4,-1
    80005140:	b7d5                	j	80005124 <filewrite+0xfa>
    panic("filewrite");
    80005142:	00003517          	auipc	a0,0x3
    80005146:	5fe50513          	addi	a0,a0,1534 # 80008740 <syscalls+0x290>
    8000514a:	ffffb097          	auipc	ra,0xffffb
    8000514e:	3f6080e7          	jalr	1014(ra) # 80000540 <panic>
    return -1;
    80005152:	5a7d                	li	s4,-1
    80005154:	bfc1                	j	80005124 <filewrite+0xfa>
      return -1;
    80005156:	5a7d                	li	s4,-1
    80005158:	b7f1                	j	80005124 <filewrite+0xfa>
    8000515a:	5a7d                	li	s4,-1
    8000515c:	b7e1                	j	80005124 <filewrite+0xfa>

000000008000515e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000515e:	7179                	addi	sp,sp,-48
    80005160:	f406                	sd	ra,40(sp)
    80005162:	f022                	sd	s0,32(sp)
    80005164:	ec26                	sd	s1,24(sp)
    80005166:	e84a                	sd	s2,16(sp)
    80005168:	e44e                	sd	s3,8(sp)
    8000516a:	e052                	sd	s4,0(sp)
    8000516c:	1800                	addi	s0,sp,48
    8000516e:	84aa                	mv	s1,a0
    80005170:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005172:	0005b023          	sd	zero,0(a1)
    80005176:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000517a:	00000097          	auipc	ra,0x0
    8000517e:	bf8080e7          	jalr	-1032(ra) # 80004d72 <filealloc>
    80005182:	e088                	sd	a0,0(s1)
    80005184:	c551                	beqz	a0,80005210 <pipealloc+0xb2>
    80005186:	00000097          	auipc	ra,0x0
    8000518a:	bec080e7          	jalr	-1044(ra) # 80004d72 <filealloc>
    8000518e:	00aa3023          	sd	a0,0(s4)
    80005192:	c92d                	beqz	a0,80005204 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005194:	ffffc097          	auipc	ra,0xffffc
    80005198:	952080e7          	jalr	-1710(ra) # 80000ae6 <kalloc>
    8000519c:	892a                	mv	s2,a0
    8000519e:	c125                	beqz	a0,800051fe <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800051a0:	4985                	li	s3,1
    800051a2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800051a6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800051aa:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800051ae:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800051b2:	00003597          	auipc	a1,0x3
    800051b6:	59e58593          	addi	a1,a1,1438 # 80008750 <syscalls+0x2a0>
    800051ba:	ffffc097          	auipc	ra,0xffffc
    800051be:	98c080e7          	jalr	-1652(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    800051c2:	609c                	ld	a5,0(s1)
    800051c4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800051c8:	609c                	ld	a5,0(s1)
    800051ca:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800051ce:	609c                	ld	a5,0(s1)
    800051d0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800051d4:	609c                	ld	a5,0(s1)
    800051d6:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800051da:	000a3783          	ld	a5,0(s4)
    800051de:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800051e2:	000a3783          	ld	a5,0(s4)
    800051e6:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800051ea:	000a3783          	ld	a5,0(s4)
    800051ee:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800051f2:	000a3783          	ld	a5,0(s4)
    800051f6:	0127b823          	sd	s2,16(a5)
  return 0;
    800051fa:	4501                	li	a0,0
    800051fc:	a025                	j	80005224 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800051fe:	6088                	ld	a0,0(s1)
    80005200:	e501                	bnez	a0,80005208 <pipealloc+0xaa>
    80005202:	a039                	j	80005210 <pipealloc+0xb2>
    80005204:	6088                	ld	a0,0(s1)
    80005206:	c51d                	beqz	a0,80005234 <pipealloc+0xd6>
    fileclose(*f0);
    80005208:	00000097          	auipc	ra,0x0
    8000520c:	c26080e7          	jalr	-986(ra) # 80004e2e <fileclose>
  if(*f1)
    80005210:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005214:	557d                	li	a0,-1
  if(*f1)
    80005216:	c799                	beqz	a5,80005224 <pipealloc+0xc6>
    fileclose(*f1);
    80005218:	853e                	mv	a0,a5
    8000521a:	00000097          	auipc	ra,0x0
    8000521e:	c14080e7          	jalr	-1004(ra) # 80004e2e <fileclose>
  return -1;
    80005222:	557d                	li	a0,-1
}
    80005224:	70a2                	ld	ra,40(sp)
    80005226:	7402                	ld	s0,32(sp)
    80005228:	64e2                	ld	s1,24(sp)
    8000522a:	6942                	ld	s2,16(sp)
    8000522c:	69a2                	ld	s3,8(sp)
    8000522e:	6a02                	ld	s4,0(sp)
    80005230:	6145                	addi	sp,sp,48
    80005232:	8082                	ret
  return -1;
    80005234:	557d                	li	a0,-1
    80005236:	b7fd                	j	80005224 <pipealloc+0xc6>

0000000080005238 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005238:	1101                	addi	sp,sp,-32
    8000523a:	ec06                	sd	ra,24(sp)
    8000523c:	e822                	sd	s0,16(sp)
    8000523e:	e426                	sd	s1,8(sp)
    80005240:	e04a                	sd	s2,0(sp)
    80005242:	1000                	addi	s0,sp,32
    80005244:	84aa                	mv	s1,a0
    80005246:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005248:	ffffc097          	auipc	ra,0xffffc
    8000524c:	98e080e7          	jalr	-1650(ra) # 80000bd6 <acquire>
  if(writable){
    80005250:	02090d63          	beqz	s2,8000528a <pipeclose+0x52>
    pi->writeopen = 0;
    80005254:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005258:	21848513          	addi	a0,s1,536
    8000525c:	ffffd097          	auipc	ra,0xffffd
    80005260:	134080e7          	jalr	308(ra) # 80002390 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005264:	2204b783          	ld	a5,544(s1)
    80005268:	eb95                	bnez	a5,8000529c <pipeclose+0x64>
    release(&pi->lock);
    8000526a:	8526                	mv	a0,s1
    8000526c:	ffffc097          	auipc	ra,0xffffc
    80005270:	a1e080e7          	jalr	-1506(ra) # 80000c8a <release>
    kfree((char*)pi);
    80005274:	8526                	mv	a0,s1
    80005276:	ffffb097          	auipc	ra,0xffffb
    8000527a:	772080e7          	jalr	1906(ra) # 800009e8 <kfree>
  } else
    release(&pi->lock);
}
    8000527e:	60e2                	ld	ra,24(sp)
    80005280:	6442                	ld	s0,16(sp)
    80005282:	64a2                	ld	s1,8(sp)
    80005284:	6902                	ld	s2,0(sp)
    80005286:	6105                	addi	sp,sp,32
    80005288:	8082                	ret
    pi->readopen = 0;
    8000528a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000528e:	21c48513          	addi	a0,s1,540
    80005292:	ffffd097          	auipc	ra,0xffffd
    80005296:	0fe080e7          	jalr	254(ra) # 80002390 <wakeup>
    8000529a:	b7e9                	j	80005264 <pipeclose+0x2c>
    release(&pi->lock);
    8000529c:	8526                	mv	a0,s1
    8000529e:	ffffc097          	auipc	ra,0xffffc
    800052a2:	9ec080e7          	jalr	-1556(ra) # 80000c8a <release>
}
    800052a6:	bfe1                	j	8000527e <pipeclose+0x46>

00000000800052a8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800052a8:	711d                	addi	sp,sp,-96
    800052aa:	ec86                	sd	ra,88(sp)
    800052ac:	e8a2                	sd	s0,80(sp)
    800052ae:	e4a6                	sd	s1,72(sp)
    800052b0:	e0ca                	sd	s2,64(sp)
    800052b2:	fc4e                	sd	s3,56(sp)
    800052b4:	f852                	sd	s4,48(sp)
    800052b6:	f456                	sd	s5,40(sp)
    800052b8:	f05a                	sd	s6,32(sp)
    800052ba:	ec5e                	sd	s7,24(sp)
    800052bc:	e862                	sd	s8,16(sp)
    800052be:	1080                	addi	s0,sp,96
    800052c0:	84aa                	mv	s1,a0
    800052c2:	8aae                	mv	s5,a1
    800052c4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800052c6:	ffffd097          	auipc	ra,0xffffd
    800052ca:	880080e7          	jalr	-1920(ra) # 80001b46 <myproc>
    800052ce:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800052d0:	8526                	mv	a0,s1
    800052d2:	ffffc097          	auipc	ra,0xffffc
    800052d6:	904080e7          	jalr	-1788(ra) # 80000bd6 <acquire>
  while(i < n){
    800052da:	0b405663          	blez	s4,80005386 <pipewrite+0xde>
  int i = 0;
    800052de:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800052e0:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800052e2:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800052e6:	21c48b93          	addi	s7,s1,540
    800052ea:	a089                	j	8000532c <pipewrite+0x84>
      release(&pi->lock);
    800052ec:	8526                	mv	a0,s1
    800052ee:	ffffc097          	auipc	ra,0xffffc
    800052f2:	99c080e7          	jalr	-1636(ra) # 80000c8a <release>
      return -1;
    800052f6:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800052f8:	854a                	mv	a0,s2
    800052fa:	60e6                	ld	ra,88(sp)
    800052fc:	6446                	ld	s0,80(sp)
    800052fe:	64a6                	ld	s1,72(sp)
    80005300:	6906                	ld	s2,64(sp)
    80005302:	79e2                	ld	s3,56(sp)
    80005304:	7a42                	ld	s4,48(sp)
    80005306:	7aa2                	ld	s5,40(sp)
    80005308:	7b02                	ld	s6,32(sp)
    8000530a:	6be2                	ld	s7,24(sp)
    8000530c:	6c42                	ld	s8,16(sp)
    8000530e:	6125                	addi	sp,sp,96
    80005310:	8082                	ret
      wakeup(&pi->nread);
    80005312:	8562                	mv	a0,s8
    80005314:	ffffd097          	auipc	ra,0xffffd
    80005318:	07c080e7          	jalr	124(ra) # 80002390 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000531c:	85a6                	mv	a1,s1
    8000531e:	855e                	mv	a0,s7
    80005320:	ffffd097          	auipc	ra,0xffffd
    80005324:	ffc080e7          	jalr	-4(ra) # 8000231c <sleep>
  while(i < n){
    80005328:	07495063          	bge	s2,s4,80005388 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    8000532c:	2204a783          	lw	a5,544(s1)
    80005330:	dfd5                	beqz	a5,800052ec <pipewrite+0x44>
    80005332:	854e                	mv	a0,s3
    80005334:	ffffd097          	auipc	ra,0xffffd
    80005338:	2ee080e7          	jalr	750(ra) # 80002622 <killed>
    8000533c:	f945                	bnez	a0,800052ec <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000533e:	2184a783          	lw	a5,536(s1)
    80005342:	21c4a703          	lw	a4,540(s1)
    80005346:	2007879b          	addiw	a5,a5,512
    8000534a:	fcf704e3          	beq	a4,a5,80005312 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000534e:	4685                	li	a3,1
    80005350:	01590633          	add	a2,s2,s5
    80005354:	faf40593          	addi	a1,s0,-81
    80005358:	0d09b503          	ld	a0,208(s3)
    8000535c:	ffffc097          	auipc	ra,0xffffc
    80005360:	39c080e7          	jalr	924(ra) # 800016f8 <copyin>
    80005364:	03650263          	beq	a0,s6,80005388 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005368:	21c4a783          	lw	a5,540(s1)
    8000536c:	0017871b          	addiw	a4,a5,1
    80005370:	20e4ae23          	sw	a4,540(s1)
    80005374:	1ff7f793          	andi	a5,a5,511
    80005378:	97a6                	add	a5,a5,s1
    8000537a:	faf44703          	lbu	a4,-81(s0)
    8000537e:	00e78c23          	sb	a4,24(a5)
      i++;
    80005382:	2905                	addiw	s2,s2,1
    80005384:	b755                	j	80005328 <pipewrite+0x80>
  int i = 0;
    80005386:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005388:	21848513          	addi	a0,s1,536
    8000538c:	ffffd097          	auipc	ra,0xffffd
    80005390:	004080e7          	jalr	4(ra) # 80002390 <wakeup>
  release(&pi->lock);
    80005394:	8526                	mv	a0,s1
    80005396:	ffffc097          	auipc	ra,0xffffc
    8000539a:	8f4080e7          	jalr	-1804(ra) # 80000c8a <release>
  return i;
    8000539e:	bfa9                	j	800052f8 <pipewrite+0x50>

00000000800053a0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800053a0:	715d                	addi	sp,sp,-80
    800053a2:	e486                	sd	ra,72(sp)
    800053a4:	e0a2                	sd	s0,64(sp)
    800053a6:	fc26                	sd	s1,56(sp)
    800053a8:	f84a                	sd	s2,48(sp)
    800053aa:	f44e                	sd	s3,40(sp)
    800053ac:	f052                	sd	s4,32(sp)
    800053ae:	ec56                	sd	s5,24(sp)
    800053b0:	e85a                	sd	s6,16(sp)
    800053b2:	0880                	addi	s0,sp,80
    800053b4:	84aa                	mv	s1,a0
    800053b6:	892e                	mv	s2,a1
    800053b8:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800053ba:	ffffc097          	auipc	ra,0xffffc
    800053be:	78c080e7          	jalr	1932(ra) # 80001b46 <myproc>
    800053c2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800053c4:	8526                	mv	a0,s1
    800053c6:	ffffc097          	auipc	ra,0xffffc
    800053ca:	810080e7          	jalr	-2032(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800053ce:	2184a703          	lw	a4,536(s1)
    800053d2:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800053d6:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800053da:	02f71763          	bne	a4,a5,80005408 <piperead+0x68>
    800053de:	2244a783          	lw	a5,548(s1)
    800053e2:	c39d                	beqz	a5,80005408 <piperead+0x68>
    if(killed(pr)){
    800053e4:	8552                	mv	a0,s4
    800053e6:	ffffd097          	auipc	ra,0xffffd
    800053ea:	23c080e7          	jalr	572(ra) # 80002622 <killed>
    800053ee:	e949                	bnez	a0,80005480 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800053f0:	85a6                	mv	a1,s1
    800053f2:	854e                	mv	a0,s3
    800053f4:	ffffd097          	auipc	ra,0xffffd
    800053f8:	f28080e7          	jalr	-216(ra) # 8000231c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800053fc:	2184a703          	lw	a4,536(s1)
    80005400:	21c4a783          	lw	a5,540(s1)
    80005404:	fcf70de3          	beq	a4,a5,800053de <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005408:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000540a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000540c:	05505463          	blez	s5,80005454 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80005410:	2184a783          	lw	a5,536(s1)
    80005414:	21c4a703          	lw	a4,540(s1)
    80005418:	02f70e63          	beq	a4,a5,80005454 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000541c:	0017871b          	addiw	a4,a5,1
    80005420:	20e4ac23          	sw	a4,536(s1)
    80005424:	1ff7f793          	andi	a5,a5,511
    80005428:	97a6                	add	a5,a5,s1
    8000542a:	0187c783          	lbu	a5,24(a5)
    8000542e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005432:	4685                	li	a3,1
    80005434:	fbf40613          	addi	a2,s0,-65
    80005438:	85ca                	mv	a1,s2
    8000543a:	0d0a3503          	ld	a0,208(s4)
    8000543e:	ffffc097          	auipc	ra,0xffffc
    80005442:	22e080e7          	jalr	558(ra) # 8000166c <copyout>
    80005446:	01650763          	beq	a0,s6,80005454 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000544a:	2985                	addiw	s3,s3,1
    8000544c:	0905                	addi	s2,s2,1
    8000544e:	fd3a91e3          	bne	s5,s3,80005410 <piperead+0x70>
    80005452:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005454:	21c48513          	addi	a0,s1,540
    80005458:	ffffd097          	auipc	ra,0xffffd
    8000545c:	f38080e7          	jalr	-200(ra) # 80002390 <wakeup>
  release(&pi->lock);
    80005460:	8526                	mv	a0,s1
    80005462:	ffffc097          	auipc	ra,0xffffc
    80005466:	828080e7          	jalr	-2008(ra) # 80000c8a <release>
  return i;
}
    8000546a:	854e                	mv	a0,s3
    8000546c:	60a6                	ld	ra,72(sp)
    8000546e:	6406                	ld	s0,64(sp)
    80005470:	74e2                	ld	s1,56(sp)
    80005472:	7942                	ld	s2,48(sp)
    80005474:	79a2                	ld	s3,40(sp)
    80005476:	7a02                	ld	s4,32(sp)
    80005478:	6ae2                	ld	s5,24(sp)
    8000547a:	6b42                	ld	s6,16(sp)
    8000547c:	6161                	addi	sp,sp,80
    8000547e:	8082                	ret
      release(&pi->lock);
    80005480:	8526                	mv	a0,s1
    80005482:	ffffc097          	auipc	ra,0xffffc
    80005486:	808080e7          	jalr	-2040(ra) # 80000c8a <release>
      return -1;
    8000548a:	59fd                	li	s3,-1
    8000548c:	bff9                	j	8000546a <piperead+0xca>

000000008000548e <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000548e:	1141                	addi	sp,sp,-16
    80005490:	e422                	sd	s0,8(sp)
    80005492:	0800                	addi	s0,sp,16
    80005494:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005496:	8905                	andi	a0,a0,1
    80005498:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    8000549a:	8b89                	andi	a5,a5,2
    8000549c:	c399                	beqz	a5,800054a2 <flags2perm+0x14>
      perm |= PTE_W;
    8000549e:	00456513          	ori	a0,a0,4
    return perm;
}
    800054a2:	6422                	ld	s0,8(sp)
    800054a4:	0141                	addi	sp,sp,16
    800054a6:	8082                	ret

00000000800054a8 <exec>:

int
exec(char *path, char **argv)
{
    800054a8:	de010113          	addi	sp,sp,-544
    800054ac:	20113c23          	sd	ra,536(sp)
    800054b0:	20813823          	sd	s0,528(sp)
    800054b4:	20913423          	sd	s1,520(sp)
    800054b8:	21213023          	sd	s2,512(sp)
    800054bc:	ffce                	sd	s3,504(sp)
    800054be:	fbd2                	sd	s4,496(sp)
    800054c0:	f7d6                	sd	s5,488(sp)
    800054c2:	f3da                	sd	s6,480(sp)
    800054c4:	efde                	sd	s7,472(sp)
    800054c6:	ebe2                	sd	s8,464(sp)
    800054c8:	e7e6                	sd	s9,456(sp)
    800054ca:	e3ea                	sd	s10,448(sp)
    800054cc:	ff6e                	sd	s11,440(sp)
    800054ce:	1400                	addi	s0,sp,544
    800054d0:	892a                	mv	s2,a0
    800054d2:	dea43423          	sd	a0,-536(s0)
    800054d6:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800054da:	ffffc097          	auipc	ra,0xffffc
    800054de:	66c080e7          	jalr	1644(ra) # 80001b46 <myproc>
    800054e2:	84aa                	mv	s1,a0

  begin_op();
    800054e4:	fffff097          	auipc	ra,0xfffff
    800054e8:	47e080e7          	jalr	1150(ra) # 80004962 <begin_op>

  if((ip = namei(path)) == 0){
    800054ec:	854a                	mv	a0,s2
    800054ee:	fffff097          	auipc	ra,0xfffff
    800054f2:	254080e7          	jalr	596(ra) # 80004742 <namei>
    800054f6:	c93d                	beqz	a0,8000556c <exec+0xc4>
    800054f8:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800054fa:	fffff097          	auipc	ra,0xfffff
    800054fe:	a9c080e7          	jalr	-1380(ra) # 80003f96 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005502:	04000713          	li	a4,64
    80005506:	4681                	li	a3,0
    80005508:	e5040613          	addi	a2,s0,-432
    8000550c:	4581                	li	a1,0
    8000550e:	8556                	mv	a0,s5
    80005510:	fffff097          	auipc	ra,0xfffff
    80005514:	d3a080e7          	jalr	-710(ra) # 8000424a <readi>
    80005518:	04000793          	li	a5,64
    8000551c:	00f51a63          	bne	a0,a5,80005530 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005520:	e5042703          	lw	a4,-432(s0)
    80005524:	464c47b7          	lui	a5,0x464c4
    80005528:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000552c:	04f70663          	beq	a4,a5,80005578 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005530:	8556                	mv	a0,s5
    80005532:	fffff097          	auipc	ra,0xfffff
    80005536:	cc6080e7          	jalr	-826(ra) # 800041f8 <iunlockput>
    end_op();
    8000553a:	fffff097          	auipc	ra,0xfffff
    8000553e:	4a6080e7          	jalr	1190(ra) # 800049e0 <end_op>
  }
  return -1;
    80005542:	557d                	li	a0,-1
}
    80005544:	21813083          	ld	ra,536(sp)
    80005548:	21013403          	ld	s0,528(sp)
    8000554c:	20813483          	ld	s1,520(sp)
    80005550:	20013903          	ld	s2,512(sp)
    80005554:	79fe                	ld	s3,504(sp)
    80005556:	7a5e                	ld	s4,496(sp)
    80005558:	7abe                	ld	s5,488(sp)
    8000555a:	7b1e                	ld	s6,480(sp)
    8000555c:	6bfe                	ld	s7,472(sp)
    8000555e:	6c5e                	ld	s8,464(sp)
    80005560:	6cbe                	ld	s9,456(sp)
    80005562:	6d1e                	ld	s10,448(sp)
    80005564:	7dfa                	ld	s11,440(sp)
    80005566:	22010113          	addi	sp,sp,544
    8000556a:	8082                	ret
    end_op();
    8000556c:	fffff097          	auipc	ra,0xfffff
    80005570:	474080e7          	jalr	1140(ra) # 800049e0 <end_op>
    return -1;
    80005574:	557d                	li	a0,-1
    80005576:	b7f9                	j	80005544 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80005578:	8526                	mv	a0,s1
    8000557a:	ffffc097          	auipc	ra,0xffffc
    8000557e:	690080e7          	jalr	1680(ra) # 80001c0a <proc_pagetable>
    80005582:	8b2a                	mv	s6,a0
    80005584:	d555                	beqz	a0,80005530 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005586:	e7042783          	lw	a5,-400(s0)
    8000558a:	e8845703          	lhu	a4,-376(s0)
    8000558e:	c735                	beqz	a4,800055fa <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005590:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005592:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005596:	6a05                	lui	s4,0x1
    80005598:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    8000559c:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    800055a0:	6d85                	lui	s11,0x1
    800055a2:	7d7d                	lui	s10,0xfffff
    800055a4:	ac81                	j	800057f4 <exec+0x34c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800055a6:	00003517          	auipc	a0,0x3
    800055aa:	1b250513          	addi	a0,a0,434 # 80008758 <syscalls+0x2a8>
    800055ae:	ffffb097          	auipc	ra,0xffffb
    800055b2:	f92080e7          	jalr	-110(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800055b6:	874a                	mv	a4,s2
    800055b8:	009c86bb          	addw	a3,s9,s1
    800055bc:	4581                	li	a1,0
    800055be:	8556                	mv	a0,s5
    800055c0:	fffff097          	auipc	ra,0xfffff
    800055c4:	c8a080e7          	jalr	-886(ra) # 8000424a <readi>
    800055c8:	2501                	sext.w	a0,a0
    800055ca:	1ca91263          	bne	s2,a0,8000578e <exec+0x2e6>
  for(i = 0; i < sz; i += PGSIZE){
    800055ce:	009d84bb          	addw	s1,s11,s1
    800055d2:	013d09bb          	addw	s3,s10,s3
    800055d6:	1f74ff63          	bgeu	s1,s7,800057d4 <exec+0x32c>
    pa = walkaddr(pagetable, va + i);
    800055da:	02049593          	slli	a1,s1,0x20
    800055de:	9181                	srli	a1,a1,0x20
    800055e0:	95e2                	add	a1,a1,s8
    800055e2:	855a                	mv	a0,s6
    800055e4:	ffffc097          	auipc	ra,0xffffc
    800055e8:	a78080e7          	jalr	-1416(ra) # 8000105c <walkaddr>
    800055ec:	862a                	mv	a2,a0
    if(pa == 0)
    800055ee:	dd45                	beqz	a0,800055a6 <exec+0xfe>
      n = PGSIZE;
    800055f0:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800055f2:	fd49f2e3          	bgeu	s3,s4,800055b6 <exec+0x10e>
      n = sz - i;
    800055f6:	894e                	mv	s2,s3
    800055f8:	bf7d                	j	800055b6 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800055fa:	4901                	li	s2,0
  iunlockput(ip);
    800055fc:	8556                	mv	a0,s5
    800055fe:	fffff097          	auipc	ra,0xfffff
    80005602:	bfa080e7          	jalr	-1030(ra) # 800041f8 <iunlockput>
  end_op();
    80005606:	fffff097          	auipc	ra,0xfffff
    8000560a:	3da080e7          	jalr	986(ra) # 800049e0 <end_op>
  p = myproc();
    8000560e:	ffffc097          	auipc	ra,0xffffc
    80005612:	538080e7          	jalr	1336(ra) # 80001b46 <myproc>
    80005616:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005618:	0c853d03          	ld	s10,200(a0)
  sz = PGROUNDUP(sz);
    8000561c:	6785                	lui	a5,0x1
    8000561e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80005620:	97ca                	add	a5,a5,s2
    80005622:	777d                	lui	a4,0xfffff
    80005624:	8ff9                	and	a5,a5,a4
    80005626:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000562a:	4691                	li	a3,4
    8000562c:	6609                	lui	a2,0x2
    8000562e:	963e                	add	a2,a2,a5
    80005630:	85be                	mv	a1,a5
    80005632:	855a                	mv	a0,s6
    80005634:	ffffc097          	auipc	ra,0xffffc
    80005638:	ddc080e7          	jalr	-548(ra) # 80001410 <uvmalloc>
    8000563c:	8c2a                	mv	s8,a0
  ip = 0;
    8000563e:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005640:	14050763          	beqz	a0,8000578e <exec+0x2e6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005644:	75f9                	lui	a1,0xffffe
    80005646:	95aa                	add	a1,a1,a0
    80005648:	855a                	mv	a0,s6
    8000564a:	ffffc097          	auipc	ra,0xffffc
    8000564e:	ff0080e7          	jalr	-16(ra) # 8000163a <uvmclear>
  stackbase = sp - PGSIZE;
    80005652:	7afd                	lui	s5,0xfffff
    80005654:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005656:	df043783          	ld	a5,-528(s0)
    8000565a:	6388                	ld	a0,0(a5)
    8000565c:	c925                	beqz	a0,800056cc <exec+0x224>
    8000565e:	e9040993          	addi	s3,s0,-368
    80005662:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005666:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005668:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000566a:	ffffb097          	auipc	ra,0xffffb
    8000566e:	7e4080e7          	jalr	2020(ra) # 80000e4e <strlen>
    80005672:	0015079b          	addiw	a5,a0,1
    80005676:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000567a:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000567e:	13596f63          	bltu	s2,s5,800057bc <exec+0x314>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005682:	df043d83          	ld	s11,-528(s0)
    80005686:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    8000568a:	8552                	mv	a0,s4
    8000568c:	ffffb097          	auipc	ra,0xffffb
    80005690:	7c2080e7          	jalr	1986(ra) # 80000e4e <strlen>
    80005694:	0015069b          	addiw	a3,a0,1
    80005698:	8652                	mv	a2,s4
    8000569a:	85ca                	mv	a1,s2
    8000569c:	855a                	mv	a0,s6
    8000569e:	ffffc097          	auipc	ra,0xffffc
    800056a2:	fce080e7          	jalr	-50(ra) # 8000166c <copyout>
    800056a6:	10054f63          	bltz	a0,800057c4 <exec+0x31c>
    ustack[argc] = sp;
    800056aa:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800056ae:	0485                	addi	s1,s1,1
    800056b0:	008d8793          	addi	a5,s11,8
    800056b4:	def43823          	sd	a5,-528(s0)
    800056b8:	008db503          	ld	a0,8(s11)
    800056bc:	c911                	beqz	a0,800056d0 <exec+0x228>
    if(argc >= MAXARG)
    800056be:	09a1                	addi	s3,s3,8
    800056c0:	fb9995e3          	bne	s3,s9,8000566a <exec+0x1c2>
  sz = sz1;
    800056c4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800056c8:	4a81                	li	s5,0
    800056ca:	a0d1                	j	8000578e <exec+0x2e6>
  sp = sz;
    800056cc:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800056ce:	4481                	li	s1,0
  ustack[argc] = 0;
    800056d0:	00349793          	slli	a5,s1,0x3
    800056d4:	f9078793          	addi	a5,a5,-112
    800056d8:	97a2                	add	a5,a5,s0
    800056da:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800056de:	00148693          	addi	a3,s1,1
    800056e2:	068e                	slli	a3,a3,0x3
    800056e4:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800056e8:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800056ec:	01597663          	bgeu	s2,s5,800056f8 <exec+0x250>
  sz = sz1;
    800056f0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800056f4:	4a81                	li	s5,0
    800056f6:	a861                	j	8000578e <exec+0x2e6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800056f8:	e9040613          	addi	a2,s0,-368
    800056fc:	85ca                	mv	a1,s2
    800056fe:	855a                	mv	a0,s6
    80005700:	ffffc097          	auipc	ra,0xffffc
    80005704:	f6c080e7          	jalr	-148(ra) # 8000166c <copyout>
    80005708:	0c054263          	bltz	a0,800057cc <exec+0x324>
  p->trapframe->a1 = sp;
    8000570c:	0d8bb783          	ld	a5,216(s7)
    80005710:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005714:	de843783          	ld	a5,-536(s0)
    80005718:	0007c703          	lbu	a4,0(a5)
    8000571c:	cf11                	beqz	a4,80005738 <exec+0x290>
    8000571e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005720:	02f00693          	li	a3,47
    80005724:	a039                	j	80005732 <exec+0x28a>
      last = s+1;
    80005726:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000572a:	0785                	addi	a5,a5,1
    8000572c:	fff7c703          	lbu	a4,-1(a5)
    80005730:	c701                	beqz	a4,80005738 <exec+0x290>
    if(*s == '/')
    80005732:	fed71ce3          	bne	a4,a3,8000572a <exec+0x282>
    80005736:	bfc5                	j	80005726 <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    80005738:	4641                	li	a2,16
    8000573a:	de843583          	ld	a1,-536(s0)
    8000573e:	1d8b8513          	addi	a0,s7,472
    80005742:	ffffb097          	auipc	ra,0xffffb
    80005746:	6da080e7          	jalr	1754(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    8000574a:	0d0bb503          	ld	a0,208(s7)
  p->pagetable = pagetable;
    8000574e:	0d6bb823          	sd	s6,208(s7)
  p->sz = sz;
    80005752:	0d8bb423          	sd	s8,200(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005756:	0d8bb783          	ld	a5,216(s7)
    8000575a:	e6843703          	ld	a4,-408(s0)
    8000575e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005760:	0d8bb783          	ld	a5,216(s7)
    80005764:	0327b823          	sd	s2,48(a5)
  for(int i=0;i<32;i++) {
    80005768:	018b8793          	addi	a5,s7,24
    8000576c:	098b8b93          	addi	s7,s7,152
    p->syscall_count[i]=0;
    80005770:	0007a023          	sw	zero,0(a5)
  for(int i=0;i<32;i++) {
    80005774:	0791                	addi	a5,a5,4
    80005776:	ff779de3          	bne	a5,s7,80005770 <exec+0x2c8>
  proc_freepagetable(oldpagetable, oldsz);
    8000577a:	85ea                	mv	a1,s10
    8000577c:	ffffc097          	auipc	ra,0xffffc
    80005780:	52a080e7          	jalr	1322(ra) # 80001ca6 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005784:	0004851b          	sext.w	a0,s1
    80005788:	bb75                	j	80005544 <exec+0x9c>
    8000578a:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    8000578e:	df843583          	ld	a1,-520(s0)
    80005792:	855a                	mv	a0,s6
    80005794:	ffffc097          	auipc	ra,0xffffc
    80005798:	512080e7          	jalr	1298(ra) # 80001ca6 <proc_freepagetable>
  if(ip){
    8000579c:	d80a9ae3          	bnez	s5,80005530 <exec+0x88>
  return -1;
    800057a0:	557d                	li	a0,-1
    800057a2:	b34d                	j	80005544 <exec+0x9c>
    800057a4:	df243c23          	sd	s2,-520(s0)
    800057a8:	b7dd                	j	8000578e <exec+0x2e6>
    800057aa:	df243c23          	sd	s2,-520(s0)
    800057ae:	b7c5                	j	8000578e <exec+0x2e6>
    800057b0:	df243c23          	sd	s2,-520(s0)
    800057b4:	bfe9                	j	8000578e <exec+0x2e6>
    800057b6:	df243c23          	sd	s2,-520(s0)
    800057ba:	bfd1                	j	8000578e <exec+0x2e6>
  sz = sz1;
    800057bc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800057c0:	4a81                	li	s5,0
    800057c2:	b7f1                	j	8000578e <exec+0x2e6>
  sz = sz1;
    800057c4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800057c8:	4a81                	li	s5,0
    800057ca:	b7d1                	j	8000578e <exec+0x2e6>
  sz = sz1;
    800057cc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800057d0:	4a81                	li	s5,0
    800057d2:	bf75                	j	8000578e <exec+0x2e6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800057d4:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800057d8:	e0843783          	ld	a5,-504(s0)
    800057dc:	0017869b          	addiw	a3,a5,1
    800057e0:	e0d43423          	sd	a3,-504(s0)
    800057e4:	e0043783          	ld	a5,-512(s0)
    800057e8:	0387879b          	addiw	a5,a5,56
    800057ec:	e8845703          	lhu	a4,-376(s0)
    800057f0:	e0e6d6e3          	bge	a3,a4,800055fc <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800057f4:	2781                	sext.w	a5,a5
    800057f6:	e0f43023          	sd	a5,-512(s0)
    800057fa:	03800713          	li	a4,56
    800057fe:	86be                	mv	a3,a5
    80005800:	e1840613          	addi	a2,s0,-488
    80005804:	4581                	li	a1,0
    80005806:	8556                	mv	a0,s5
    80005808:	fffff097          	auipc	ra,0xfffff
    8000580c:	a42080e7          	jalr	-1470(ra) # 8000424a <readi>
    80005810:	03800793          	li	a5,56
    80005814:	f6f51be3          	bne	a0,a5,8000578a <exec+0x2e2>
    if(ph.type != ELF_PROG_LOAD)
    80005818:	e1842783          	lw	a5,-488(s0)
    8000581c:	4705                	li	a4,1
    8000581e:	fae79de3          	bne	a5,a4,800057d8 <exec+0x330>
    if(ph.memsz < ph.filesz)
    80005822:	e4043483          	ld	s1,-448(s0)
    80005826:	e3843783          	ld	a5,-456(s0)
    8000582a:	f6f4ede3          	bltu	s1,a5,800057a4 <exec+0x2fc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000582e:	e2843783          	ld	a5,-472(s0)
    80005832:	94be                	add	s1,s1,a5
    80005834:	f6f4ebe3          	bltu	s1,a5,800057aa <exec+0x302>
    if(ph.vaddr % PGSIZE != 0)
    80005838:	de043703          	ld	a4,-544(s0)
    8000583c:	8ff9                	and	a5,a5,a4
    8000583e:	fbad                	bnez	a5,800057b0 <exec+0x308>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005840:	e1c42503          	lw	a0,-484(s0)
    80005844:	00000097          	auipc	ra,0x0
    80005848:	c4a080e7          	jalr	-950(ra) # 8000548e <flags2perm>
    8000584c:	86aa                	mv	a3,a0
    8000584e:	8626                	mv	a2,s1
    80005850:	85ca                	mv	a1,s2
    80005852:	855a                	mv	a0,s6
    80005854:	ffffc097          	auipc	ra,0xffffc
    80005858:	bbc080e7          	jalr	-1092(ra) # 80001410 <uvmalloc>
    8000585c:	dea43c23          	sd	a0,-520(s0)
    80005860:	d939                	beqz	a0,800057b6 <exec+0x30e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005862:	e2843c03          	ld	s8,-472(s0)
    80005866:	e2042c83          	lw	s9,-480(s0)
    8000586a:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000586e:	f60b83e3          	beqz	s7,800057d4 <exec+0x32c>
    80005872:	89de                	mv	s3,s7
    80005874:	4481                	li	s1,0
    80005876:	b395                	j	800055da <exec+0x132>

0000000080005878 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005878:	1101                	addi	sp,sp,-32
    8000587a:	ec06                	sd	ra,24(sp)
    8000587c:	e822                	sd	s0,16(sp)
    8000587e:	e426                	sd	s1,8(sp)
    80005880:	1000                	addi	s0,sp,32
    80005882:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005884:	ffffc097          	auipc	ra,0xffffc
    80005888:	2c2080e7          	jalr	706(ra) # 80001b46 <myproc>
    8000588c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000588e:	15050793          	addi	a5,a0,336
    80005892:	4501                	li	a0,0
    80005894:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005896:	6398                	ld	a4,0(a5)
    80005898:	cb19                	beqz	a4,800058ae <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000589a:	2505                	addiw	a0,a0,1
    8000589c:	07a1                	addi	a5,a5,8
    8000589e:	fed51ce3          	bne	a0,a3,80005896 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800058a2:	557d                	li	a0,-1
}
    800058a4:	60e2                	ld	ra,24(sp)
    800058a6:	6442                	ld	s0,16(sp)
    800058a8:	64a2                	ld	s1,8(sp)
    800058aa:	6105                	addi	sp,sp,32
    800058ac:	8082                	ret
      p->ofile[fd] = f;
    800058ae:	02a50793          	addi	a5,a0,42
    800058b2:	078e                	slli	a5,a5,0x3
    800058b4:	963e                	add	a2,a2,a5
    800058b6:	e204                	sd	s1,0(a2)
      return fd;
    800058b8:	b7f5                	j	800058a4 <fdalloc+0x2c>

00000000800058ba <argfd>:
{
    800058ba:	7179                	addi	sp,sp,-48
    800058bc:	f406                	sd	ra,40(sp)
    800058be:	f022                	sd	s0,32(sp)
    800058c0:	ec26                	sd	s1,24(sp)
    800058c2:	e84a                	sd	s2,16(sp)
    800058c4:	1800                	addi	s0,sp,48
    800058c6:	892e                	mv	s2,a1
    800058c8:	84b2                	mv	s1,a2
  argint(n, &fd);
    800058ca:	fdc40593          	addi	a1,s0,-36
    800058ce:	ffffe097          	auipc	ra,0xffffe
    800058d2:	8d0080e7          	jalr	-1840(ra) # 8000319e <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800058d6:	fdc42703          	lw	a4,-36(s0)
    800058da:	47bd                	li	a5,15
    800058dc:	02e7eb63          	bltu	a5,a4,80005912 <argfd+0x58>
    800058e0:	ffffc097          	auipc	ra,0xffffc
    800058e4:	266080e7          	jalr	614(ra) # 80001b46 <myproc>
    800058e8:	fdc42703          	lw	a4,-36(s0)
    800058ec:	02a70793          	addi	a5,a4,42 # fffffffffffff02a <end+0xffffffff7ffd960a>
    800058f0:	078e                	slli	a5,a5,0x3
    800058f2:	953e                	add	a0,a0,a5
    800058f4:	611c                	ld	a5,0(a0)
    800058f6:	c385                	beqz	a5,80005916 <argfd+0x5c>
  if(pfd)
    800058f8:	00090463          	beqz	s2,80005900 <argfd+0x46>
    *pfd = fd;
    800058fc:	00e92023          	sw	a4,0(s2)
  return 0;
    80005900:	4501                	li	a0,0
  if(pf)
    80005902:	c091                	beqz	s1,80005906 <argfd+0x4c>
    *pf = f;
    80005904:	e09c                	sd	a5,0(s1)
}
    80005906:	70a2                	ld	ra,40(sp)
    80005908:	7402                	ld	s0,32(sp)
    8000590a:	64e2                	ld	s1,24(sp)
    8000590c:	6942                	ld	s2,16(sp)
    8000590e:	6145                	addi	sp,sp,48
    80005910:	8082                	ret
    return -1;
    80005912:	557d                	li	a0,-1
    80005914:	bfcd                	j	80005906 <argfd+0x4c>
    80005916:	557d                	li	a0,-1
    80005918:	b7fd                	j	80005906 <argfd+0x4c>

000000008000591a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000591a:	715d                	addi	sp,sp,-80
    8000591c:	e486                	sd	ra,72(sp)
    8000591e:	e0a2                	sd	s0,64(sp)
    80005920:	fc26                	sd	s1,56(sp)
    80005922:	f84a                	sd	s2,48(sp)
    80005924:	f44e                	sd	s3,40(sp)
    80005926:	f052                	sd	s4,32(sp)
    80005928:	ec56                	sd	s5,24(sp)
    8000592a:	e85a                	sd	s6,16(sp)
    8000592c:	0880                	addi	s0,sp,80
    8000592e:	8b2e                	mv	s6,a1
    80005930:	89b2                	mv	s3,a2
    80005932:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005934:	fb040593          	addi	a1,s0,-80
    80005938:	fffff097          	auipc	ra,0xfffff
    8000593c:	e28080e7          	jalr	-472(ra) # 80004760 <nameiparent>
    80005940:	84aa                	mv	s1,a0
    80005942:	14050f63          	beqz	a0,80005aa0 <create+0x186>
    return 0;

  ilock(dp);
    80005946:	ffffe097          	auipc	ra,0xffffe
    8000594a:	650080e7          	jalr	1616(ra) # 80003f96 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000594e:	4601                	li	a2,0
    80005950:	fb040593          	addi	a1,s0,-80
    80005954:	8526                	mv	a0,s1
    80005956:	fffff097          	auipc	ra,0xfffff
    8000595a:	b24080e7          	jalr	-1244(ra) # 8000447a <dirlookup>
    8000595e:	8aaa                	mv	s5,a0
    80005960:	c931                	beqz	a0,800059b4 <create+0x9a>
    iunlockput(dp);
    80005962:	8526                	mv	a0,s1
    80005964:	fffff097          	auipc	ra,0xfffff
    80005968:	894080e7          	jalr	-1900(ra) # 800041f8 <iunlockput>
    ilock(ip);
    8000596c:	8556                	mv	a0,s5
    8000596e:	ffffe097          	auipc	ra,0xffffe
    80005972:	628080e7          	jalr	1576(ra) # 80003f96 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005976:	000b059b          	sext.w	a1,s6
    8000597a:	4789                	li	a5,2
    8000597c:	02f59563          	bne	a1,a5,800059a6 <create+0x8c>
    80005980:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffd9624>
    80005984:	37f9                	addiw	a5,a5,-2
    80005986:	17c2                	slli	a5,a5,0x30
    80005988:	93c1                	srli	a5,a5,0x30
    8000598a:	4705                	li	a4,1
    8000598c:	00f76d63          	bltu	a4,a5,800059a6 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005990:	8556                	mv	a0,s5
    80005992:	60a6                	ld	ra,72(sp)
    80005994:	6406                	ld	s0,64(sp)
    80005996:	74e2                	ld	s1,56(sp)
    80005998:	7942                	ld	s2,48(sp)
    8000599a:	79a2                	ld	s3,40(sp)
    8000599c:	7a02                	ld	s4,32(sp)
    8000599e:	6ae2                	ld	s5,24(sp)
    800059a0:	6b42                	ld	s6,16(sp)
    800059a2:	6161                	addi	sp,sp,80
    800059a4:	8082                	ret
    iunlockput(ip);
    800059a6:	8556                	mv	a0,s5
    800059a8:	fffff097          	auipc	ra,0xfffff
    800059ac:	850080e7          	jalr	-1968(ra) # 800041f8 <iunlockput>
    return 0;
    800059b0:	4a81                	li	s5,0
    800059b2:	bff9                	j	80005990 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800059b4:	85da                	mv	a1,s6
    800059b6:	4088                	lw	a0,0(s1)
    800059b8:	ffffe097          	auipc	ra,0xffffe
    800059bc:	440080e7          	jalr	1088(ra) # 80003df8 <ialloc>
    800059c0:	8a2a                	mv	s4,a0
    800059c2:	c539                	beqz	a0,80005a10 <create+0xf6>
  ilock(ip);
    800059c4:	ffffe097          	auipc	ra,0xffffe
    800059c8:	5d2080e7          	jalr	1490(ra) # 80003f96 <ilock>
  ip->major = major;
    800059cc:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800059d0:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800059d4:	4905                	li	s2,1
    800059d6:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800059da:	8552                	mv	a0,s4
    800059dc:	ffffe097          	auipc	ra,0xffffe
    800059e0:	4ee080e7          	jalr	1262(ra) # 80003eca <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800059e4:	000b059b          	sext.w	a1,s6
    800059e8:	03258b63          	beq	a1,s2,80005a1e <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    800059ec:	004a2603          	lw	a2,4(s4)
    800059f0:	fb040593          	addi	a1,s0,-80
    800059f4:	8526                	mv	a0,s1
    800059f6:	fffff097          	auipc	ra,0xfffff
    800059fa:	c9a080e7          	jalr	-870(ra) # 80004690 <dirlink>
    800059fe:	06054f63          	bltz	a0,80005a7c <create+0x162>
  iunlockput(dp);
    80005a02:	8526                	mv	a0,s1
    80005a04:	ffffe097          	auipc	ra,0xffffe
    80005a08:	7f4080e7          	jalr	2036(ra) # 800041f8 <iunlockput>
  return ip;
    80005a0c:	8ad2                	mv	s5,s4
    80005a0e:	b749                	j	80005990 <create+0x76>
    iunlockput(dp);
    80005a10:	8526                	mv	a0,s1
    80005a12:	ffffe097          	auipc	ra,0xffffe
    80005a16:	7e6080e7          	jalr	2022(ra) # 800041f8 <iunlockput>
    return 0;
    80005a1a:	8ad2                	mv	s5,s4
    80005a1c:	bf95                	j	80005990 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005a1e:	004a2603          	lw	a2,4(s4)
    80005a22:	00003597          	auipc	a1,0x3
    80005a26:	d5658593          	addi	a1,a1,-682 # 80008778 <syscalls+0x2c8>
    80005a2a:	8552                	mv	a0,s4
    80005a2c:	fffff097          	auipc	ra,0xfffff
    80005a30:	c64080e7          	jalr	-924(ra) # 80004690 <dirlink>
    80005a34:	04054463          	bltz	a0,80005a7c <create+0x162>
    80005a38:	40d0                	lw	a2,4(s1)
    80005a3a:	00003597          	auipc	a1,0x3
    80005a3e:	d4658593          	addi	a1,a1,-698 # 80008780 <syscalls+0x2d0>
    80005a42:	8552                	mv	a0,s4
    80005a44:	fffff097          	auipc	ra,0xfffff
    80005a48:	c4c080e7          	jalr	-948(ra) # 80004690 <dirlink>
    80005a4c:	02054863          	bltz	a0,80005a7c <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80005a50:	004a2603          	lw	a2,4(s4)
    80005a54:	fb040593          	addi	a1,s0,-80
    80005a58:	8526                	mv	a0,s1
    80005a5a:	fffff097          	auipc	ra,0xfffff
    80005a5e:	c36080e7          	jalr	-970(ra) # 80004690 <dirlink>
    80005a62:	00054d63          	bltz	a0,80005a7c <create+0x162>
    dp->nlink++;  // for ".."
    80005a66:	04a4d783          	lhu	a5,74(s1)
    80005a6a:	2785                	addiw	a5,a5,1
    80005a6c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005a70:	8526                	mv	a0,s1
    80005a72:	ffffe097          	auipc	ra,0xffffe
    80005a76:	458080e7          	jalr	1112(ra) # 80003eca <iupdate>
    80005a7a:	b761                	j	80005a02 <create+0xe8>
  ip->nlink = 0;
    80005a7c:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005a80:	8552                	mv	a0,s4
    80005a82:	ffffe097          	auipc	ra,0xffffe
    80005a86:	448080e7          	jalr	1096(ra) # 80003eca <iupdate>
  iunlockput(ip);
    80005a8a:	8552                	mv	a0,s4
    80005a8c:	ffffe097          	auipc	ra,0xffffe
    80005a90:	76c080e7          	jalr	1900(ra) # 800041f8 <iunlockput>
  iunlockput(dp);
    80005a94:	8526                	mv	a0,s1
    80005a96:	ffffe097          	auipc	ra,0xffffe
    80005a9a:	762080e7          	jalr	1890(ra) # 800041f8 <iunlockput>
  return 0;
    80005a9e:	bdcd                	j	80005990 <create+0x76>
    return 0;
    80005aa0:	8aaa                	mv	s5,a0
    80005aa2:	b5fd                	j	80005990 <create+0x76>

0000000080005aa4 <sys_dup>:
{
    80005aa4:	7179                	addi	sp,sp,-48
    80005aa6:	f406                	sd	ra,40(sp)
    80005aa8:	f022                	sd	s0,32(sp)
    80005aaa:	ec26                	sd	s1,24(sp)
    80005aac:	e84a                	sd	s2,16(sp)
    80005aae:	1800                	addi	s0,sp,48
  myproc()->syscall_count[SYS_dup]++;
    80005ab0:	ffffc097          	auipc	ra,0xffffc
    80005ab4:	096080e7          	jalr	150(ra) # 80001b46 <myproc>
    80005ab8:	413c                	lw	a5,64(a0)
    80005aba:	2785                	addiw	a5,a5,1
    80005abc:	c13c                	sw	a5,64(a0)
  if(argfd(0, 0, &f) < 0)
    80005abe:	fd840613          	addi	a2,s0,-40
    80005ac2:	4581                	li	a1,0
    80005ac4:	4501                	li	a0,0
    80005ac6:	00000097          	auipc	ra,0x0
    80005aca:	df4080e7          	jalr	-524(ra) # 800058ba <argfd>
    return -1;
    80005ace:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005ad0:	02054363          	bltz	a0,80005af6 <sys_dup+0x52>
  if((fd=fdalloc(f)) < 0)
    80005ad4:	fd843903          	ld	s2,-40(s0)
    80005ad8:	854a                	mv	a0,s2
    80005ada:	00000097          	auipc	ra,0x0
    80005ade:	d9e080e7          	jalr	-610(ra) # 80005878 <fdalloc>
    80005ae2:	84aa                	mv	s1,a0
    return -1;
    80005ae4:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005ae6:	00054863          	bltz	a0,80005af6 <sys_dup+0x52>
  filedup(f);
    80005aea:	854a                	mv	a0,s2
    80005aec:	fffff097          	auipc	ra,0xfffff
    80005af0:	2f0080e7          	jalr	752(ra) # 80004ddc <filedup>
  return fd;
    80005af4:	87a6                	mv	a5,s1
}
    80005af6:	853e                	mv	a0,a5
    80005af8:	70a2                	ld	ra,40(sp)
    80005afa:	7402                	ld	s0,32(sp)
    80005afc:	64e2                	ld	s1,24(sp)
    80005afe:	6942                	ld	s2,16(sp)
    80005b00:	6145                	addi	sp,sp,48
    80005b02:	8082                	ret

0000000080005b04 <sys_read>:
{
    80005b04:	7179                	addi	sp,sp,-48
    80005b06:	f406                	sd	ra,40(sp)
    80005b08:	f022                	sd	s0,32(sp)
    80005b0a:	1800                	addi	s0,sp,48
  myproc()->syscall_count[SYS_read]++;
    80005b0c:	ffffc097          	auipc	ra,0xffffc
    80005b10:	03a080e7          	jalr	58(ra) # 80001b46 <myproc>
    80005b14:	555c                	lw	a5,44(a0)
    80005b16:	2785                	addiw	a5,a5,1
    80005b18:	d55c                	sw	a5,44(a0)
  argaddr(1, &p);
    80005b1a:	fd840593          	addi	a1,s0,-40
    80005b1e:	4505                	li	a0,1
    80005b20:	ffffd097          	auipc	ra,0xffffd
    80005b24:	69e080e7          	jalr	1694(ra) # 800031be <argaddr>
  argint(2, &n);
    80005b28:	fe440593          	addi	a1,s0,-28
    80005b2c:	4509                	li	a0,2
    80005b2e:	ffffd097          	auipc	ra,0xffffd
    80005b32:	670080e7          	jalr	1648(ra) # 8000319e <argint>
  if(argfd(0, 0, &f) < 0)
    80005b36:	fe840613          	addi	a2,s0,-24
    80005b3a:	4581                	li	a1,0
    80005b3c:	4501                	li	a0,0
    80005b3e:	00000097          	auipc	ra,0x0
    80005b42:	d7c080e7          	jalr	-644(ra) # 800058ba <argfd>
    80005b46:	87aa                	mv	a5,a0
    return -1;
    80005b48:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005b4a:	0007cc63          	bltz	a5,80005b62 <sys_read+0x5e>
  return fileread(f, p, n);
    80005b4e:	fe442603          	lw	a2,-28(s0)
    80005b52:	fd843583          	ld	a1,-40(s0)
    80005b56:	fe843503          	ld	a0,-24(s0)
    80005b5a:	fffff097          	auipc	ra,0xfffff
    80005b5e:	40e080e7          	jalr	1038(ra) # 80004f68 <fileread>
}
    80005b62:	70a2                	ld	ra,40(sp)
    80005b64:	7402                	ld	s0,32(sp)
    80005b66:	6145                	addi	sp,sp,48
    80005b68:	8082                	ret

0000000080005b6a <sys_write>:
{
    80005b6a:	7179                	addi	sp,sp,-48
    80005b6c:	f406                	sd	ra,40(sp)
    80005b6e:	f022                	sd	s0,32(sp)
    80005b70:	1800                	addi	s0,sp,48
  myproc()->syscall_count[SYS_write]++;
    80005b72:	ffffc097          	auipc	ra,0xffffc
    80005b76:	fd4080e7          	jalr	-44(ra) # 80001b46 <myproc>
    80005b7a:	4d3c                	lw	a5,88(a0)
    80005b7c:	2785                	addiw	a5,a5,1
    80005b7e:	cd3c                	sw	a5,88(a0)
  argaddr(1, &p);
    80005b80:	fd840593          	addi	a1,s0,-40
    80005b84:	4505                	li	a0,1
    80005b86:	ffffd097          	auipc	ra,0xffffd
    80005b8a:	638080e7          	jalr	1592(ra) # 800031be <argaddr>
  argint(2, &n);
    80005b8e:	fe440593          	addi	a1,s0,-28
    80005b92:	4509                	li	a0,2
    80005b94:	ffffd097          	auipc	ra,0xffffd
    80005b98:	60a080e7          	jalr	1546(ra) # 8000319e <argint>
  if(argfd(0, 0, &f) < 0)
    80005b9c:	fe840613          	addi	a2,s0,-24
    80005ba0:	4581                	li	a1,0
    80005ba2:	4501                	li	a0,0
    80005ba4:	00000097          	auipc	ra,0x0
    80005ba8:	d16080e7          	jalr	-746(ra) # 800058ba <argfd>
    80005bac:	87aa                	mv	a5,a0
    return -1;
    80005bae:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005bb0:	0007cc63          	bltz	a5,80005bc8 <sys_write+0x5e>
  return filewrite(f, p, n);
    80005bb4:	fe442603          	lw	a2,-28(s0)
    80005bb8:	fd843583          	ld	a1,-40(s0)
    80005bbc:	fe843503          	ld	a0,-24(s0)
    80005bc0:	fffff097          	auipc	ra,0xfffff
    80005bc4:	46a080e7          	jalr	1130(ra) # 8000502a <filewrite>
}
    80005bc8:	70a2                	ld	ra,40(sp)
    80005bca:	7402                	ld	s0,32(sp)
    80005bcc:	6145                	addi	sp,sp,48
    80005bce:	8082                	ret

0000000080005bd0 <sys_close>:
{
    80005bd0:	1101                	addi	sp,sp,-32
    80005bd2:	ec06                	sd	ra,24(sp)
    80005bd4:	e822                	sd	s0,16(sp)
    80005bd6:	1000                	addi	s0,sp,32
  myproc()->syscall_count[SYS_close]++;
    80005bd8:	ffffc097          	auipc	ra,0xffffc
    80005bdc:	f6e080e7          	jalr	-146(ra) # 80001b46 <myproc>
    80005be0:	557c                	lw	a5,108(a0)
    80005be2:	2785                	addiw	a5,a5,1
    80005be4:	d57c                	sw	a5,108(a0)
  if(argfd(0, &fd, &f) < 0)
    80005be6:	fe040613          	addi	a2,s0,-32
    80005bea:	fec40593          	addi	a1,s0,-20
    80005bee:	4501                	li	a0,0
    80005bf0:	00000097          	auipc	ra,0x0
    80005bf4:	cca080e7          	jalr	-822(ra) # 800058ba <argfd>
    return -1;
    80005bf8:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005bfa:	02054563          	bltz	a0,80005c24 <sys_close+0x54>
  myproc()->ofile[fd] = 0;
    80005bfe:	ffffc097          	auipc	ra,0xffffc
    80005c02:	f48080e7          	jalr	-184(ra) # 80001b46 <myproc>
    80005c06:	fec42783          	lw	a5,-20(s0)
    80005c0a:	02a78793          	addi	a5,a5,42
    80005c0e:	078e                	slli	a5,a5,0x3
    80005c10:	953e                	add	a0,a0,a5
    80005c12:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005c16:	fe043503          	ld	a0,-32(s0)
    80005c1a:	fffff097          	auipc	ra,0xfffff
    80005c1e:	214080e7          	jalr	532(ra) # 80004e2e <fileclose>
  return 0;
    80005c22:	4781                	li	a5,0
}
    80005c24:	853e                	mv	a0,a5
    80005c26:	60e2                	ld	ra,24(sp)
    80005c28:	6442                	ld	s0,16(sp)
    80005c2a:	6105                	addi	sp,sp,32
    80005c2c:	8082                	ret

0000000080005c2e <sys_fstat>:
{
    80005c2e:	1101                	addi	sp,sp,-32
    80005c30:	ec06                	sd	ra,24(sp)
    80005c32:	e822                	sd	s0,16(sp)
    80005c34:	1000                	addi	s0,sp,32
  myproc()->syscall_count[SYS_fstat]++;
    80005c36:	ffffc097          	auipc	ra,0xffffc
    80005c3a:	f10080e7          	jalr	-240(ra) # 80001b46 <myproc>
    80005c3e:	5d1c                	lw	a5,56(a0)
    80005c40:	2785                	addiw	a5,a5,1
    80005c42:	dd1c                	sw	a5,56(a0)
  argaddr(1, &st);
    80005c44:	fe040593          	addi	a1,s0,-32
    80005c48:	4505                	li	a0,1
    80005c4a:	ffffd097          	auipc	ra,0xffffd
    80005c4e:	574080e7          	jalr	1396(ra) # 800031be <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005c52:	fe840613          	addi	a2,s0,-24
    80005c56:	4581                	li	a1,0
    80005c58:	4501                	li	a0,0
    80005c5a:	00000097          	auipc	ra,0x0
    80005c5e:	c60080e7          	jalr	-928(ra) # 800058ba <argfd>
    80005c62:	87aa                	mv	a5,a0
    return -1;
    80005c64:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005c66:	0007ca63          	bltz	a5,80005c7a <sys_fstat+0x4c>
  return filestat(f, st);
    80005c6a:	fe043583          	ld	a1,-32(s0)
    80005c6e:	fe843503          	ld	a0,-24(s0)
    80005c72:	fffff097          	auipc	ra,0xfffff
    80005c76:	284080e7          	jalr	644(ra) # 80004ef6 <filestat>
}
    80005c7a:	60e2                	ld	ra,24(sp)
    80005c7c:	6442                	ld	s0,16(sp)
    80005c7e:	6105                	addi	sp,sp,32
    80005c80:	8082                	ret

0000000080005c82 <sys_link>:
{
    80005c82:	7169                	addi	sp,sp,-304
    80005c84:	f606                	sd	ra,296(sp)
    80005c86:	f222                	sd	s0,288(sp)
    80005c88:	ee26                	sd	s1,280(sp)
    80005c8a:	ea4a                	sd	s2,272(sp)
    80005c8c:	1a00                	addi	s0,sp,304
  myproc()->syscall_count[SYS_link]++;
    80005c8e:	ffffc097          	auipc	ra,0xffffc
    80005c92:	eb8080e7          	jalr	-328(ra) # 80001b46 <myproc>
    80005c96:	517c                	lw	a5,100(a0)
    80005c98:	2785                	addiw	a5,a5,1
    80005c9a:	d17c                	sw	a5,100(a0)
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005c9c:	08000613          	li	a2,128
    80005ca0:	ed040593          	addi	a1,s0,-304
    80005ca4:	4501                	li	a0,0
    80005ca6:	ffffd097          	auipc	ra,0xffffd
    80005caa:	538080e7          	jalr	1336(ra) # 800031de <argstr>
    return -1;
    80005cae:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005cb0:	10054e63          	bltz	a0,80005dcc <sys_link+0x14a>
    80005cb4:	08000613          	li	a2,128
    80005cb8:	f5040593          	addi	a1,s0,-176
    80005cbc:	4505                	li	a0,1
    80005cbe:	ffffd097          	auipc	ra,0xffffd
    80005cc2:	520080e7          	jalr	1312(ra) # 800031de <argstr>
    return -1;
    80005cc6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005cc8:	10054263          	bltz	a0,80005dcc <sys_link+0x14a>
  begin_op();
    80005ccc:	fffff097          	auipc	ra,0xfffff
    80005cd0:	c96080e7          	jalr	-874(ra) # 80004962 <begin_op>
  if((ip = namei(old)) == 0){
    80005cd4:	ed040513          	addi	a0,s0,-304
    80005cd8:	fffff097          	auipc	ra,0xfffff
    80005cdc:	a6a080e7          	jalr	-1430(ra) # 80004742 <namei>
    80005ce0:	84aa                	mv	s1,a0
    80005ce2:	c551                	beqz	a0,80005d6e <sys_link+0xec>
  ilock(ip);
    80005ce4:	ffffe097          	auipc	ra,0xffffe
    80005ce8:	2b2080e7          	jalr	690(ra) # 80003f96 <ilock>
  if(ip->type == T_DIR){
    80005cec:	04449703          	lh	a4,68(s1)
    80005cf0:	4785                	li	a5,1
    80005cf2:	08f70463          	beq	a4,a5,80005d7a <sys_link+0xf8>
  ip->nlink++;
    80005cf6:	04a4d783          	lhu	a5,74(s1)
    80005cfa:	2785                	addiw	a5,a5,1
    80005cfc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005d00:	8526                	mv	a0,s1
    80005d02:	ffffe097          	auipc	ra,0xffffe
    80005d06:	1c8080e7          	jalr	456(ra) # 80003eca <iupdate>
  iunlock(ip);
    80005d0a:	8526                	mv	a0,s1
    80005d0c:	ffffe097          	auipc	ra,0xffffe
    80005d10:	34c080e7          	jalr	844(ra) # 80004058 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005d14:	fd040593          	addi	a1,s0,-48
    80005d18:	f5040513          	addi	a0,s0,-176
    80005d1c:	fffff097          	auipc	ra,0xfffff
    80005d20:	a44080e7          	jalr	-1468(ra) # 80004760 <nameiparent>
    80005d24:	892a                	mv	s2,a0
    80005d26:	c935                	beqz	a0,80005d9a <sys_link+0x118>
  ilock(dp);
    80005d28:	ffffe097          	auipc	ra,0xffffe
    80005d2c:	26e080e7          	jalr	622(ra) # 80003f96 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005d30:	00092703          	lw	a4,0(s2)
    80005d34:	409c                	lw	a5,0(s1)
    80005d36:	04f71d63          	bne	a4,a5,80005d90 <sys_link+0x10e>
    80005d3a:	40d0                	lw	a2,4(s1)
    80005d3c:	fd040593          	addi	a1,s0,-48
    80005d40:	854a                	mv	a0,s2
    80005d42:	fffff097          	auipc	ra,0xfffff
    80005d46:	94e080e7          	jalr	-1714(ra) # 80004690 <dirlink>
    80005d4a:	04054363          	bltz	a0,80005d90 <sys_link+0x10e>
  iunlockput(dp);
    80005d4e:	854a                	mv	a0,s2
    80005d50:	ffffe097          	auipc	ra,0xffffe
    80005d54:	4a8080e7          	jalr	1192(ra) # 800041f8 <iunlockput>
  iput(ip);
    80005d58:	8526                	mv	a0,s1
    80005d5a:	ffffe097          	auipc	ra,0xffffe
    80005d5e:	3f6080e7          	jalr	1014(ra) # 80004150 <iput>
  end_op();
    80005d62:	fffff097          	auipc	ra,0xfffff
    80005d66:	c7e080e7          	jalr	-898(ra) # 800049e0 <end_op>
  return 0;
    80005d6a:	4781                	li	a5,0
    80005d6c:	a085                	j	80005dcc <sys_link+0x14a>
    end_op();
    80005d6e:	fffff097          	auipc	ra,0xfffff
    80005d72:	c72080e7          	jalr	-910(ra) # 800049e0 <end_op>
    return -1;
    80005d76:	57fd                	li	a5,-1
    80005d78:	a891                	j	80005dcc <sys_link+0x14a>
    iunlockput(ip);
    80005d7a:	8526                	mv	a0,s1
    80005d7c:	ffffe097          	auipc	ra,0xffffe
    80005d80:	47c080e7          	jalr	1148(ra) # 800041f8 <iunlockput>
    end_op();
    80005d84:	fffff097          	auipc	ra,0xfffff
    80005d88:	c5c080e7          	jalr	-932(ra) # 800049e0 <end_op>
    return -1;
    80005d8c:	57fd                	li	a5,-1
    80005d8e:	a83d                	j	80005dcc <sys_link+0x14a>
    iunlockput(dp);
    80005d90:	854a                	mv	a0,s2
    80005d92:	ffffe097          	auipc	ra,0xffffe
    80005d96:	466080e7          	jalr	1126(ra) # 800041f8 <iunlockput>
  ilock(ip);
    80005d9a:	8526                	mv	a0,s1
    80005d9c:	ffffe097          	auipc	ra,0xffffe
    80005da0:	1fa080e7          	jalr	506(ra) # 80003f96 <ilock>
  ip->nlink--;
    80005da4:	04a4d783          	lhu	a5,74(s1)
    80005da8:	37fd                	addiw	a5,a5,-1
    80005daa:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005dae:	8526                	mv	a0,s1
    80005db0:	ffffe097          	auipc	ra,0xffffe
    80005db4:	11a080e7          	jalr	282(ra) # 80003eca <iupdate>
  iunlockput(ip);
    80005db8:	8526                	mv	a0,s1
    80005dba:	ffffe097          	auipc	ra,0xffffe
    80005dbe:	43e080e7          	jalr	1086(ra) # 800041f8 <iunlockput>
  end_op();
    80005dc2:	fffff097          	auipc	ra,0xfffff
    80005dc6:	c1e080e7          	jalr	-994(ra) # 800049e0 <end_op>
  return -1;
    80005dca:	57fd                	li	a5,-1
}
    80005dcc:	853e                	mv	a0,a5
    80005dce:	70b2                	ld	ra,296(sp)
    80005dd0:	7412                	ld	s0,288(sp)
    80005dd2:	64f2                	ld	s1,280(sp)
    80005dd4:	6952                	ld	s2,272(sp)
    80005dd6:	6155                	addi	sp,sp,304
    80005dd8:	8082                	ret

0000000080005dda <sys_unlink>:
{
    80005dda:	7151                	addi	sp,sp,-240
    80005ddc:	f586                	sd	ra,232(sp)
    80005dde:	f1a2                	sd	s0,224(sp)
    80005de0:	eda6                	sd	s1,216(sp)
    80005de2:	e9ca                	sd	s2,208(sp)
    80005de4:	e5ce                	sd	s3,200(sp)
    80005de6:	1980                	addi	s0,sp,240
  myproc()->syscall_count[SYS_unlink]++;
    80005de8:	ffffc097          	auipc	ra,0xffffc
    80005dec:	d5e080e7          	jalr	-674(ra) # 80001b46 <myproc>
    80005df0:	513c                	lw	a5,96(a0)
    80005df2:	2785                	addiw	a5,a5,1
    80005df4:	d13c                	sw	a5,96(a0)
  if(argstr(0, path, MAXPATH) < 0)
    80005df6:	08000613          	li	a2,128
    80005dfa:	f3040593          	addi	a1,s0,-208
    80005dfe:	4501                	li	a0,0
    80005e00:	ffffd097          	auipc	ra,0xffffd
    80005e04:	3de080e7          	jalr	990(ra) # 800031de <argstr>
    80005e08:	18054163          	bltz	a0,80005f8a <sys_unlink+0x1b0>
  begin_op();
    80005e0c:	fffff097          	auipc	ra,0xfffff
    80005e10:	b56080e7          	jalr	-1194(ra) # 80004962 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005e14:	fb040593          	addi	a1,s0,-80
    80005e18:	f3040513          	addi	a0,s0,-208
    80005e1c:	fffff097          	auipc	ra,0xfffff
    80005e20:	944080e7          	jalr	-1724(ra) # 80004760 <nameiparent>
    80005e24:	84aa                	mv	s1,a0
    80005e26:	c979                	beqz	a0,80005efc <sys_unlink+0x122>
  ilock(dp);
    80005e28:	ffffe097          	auipc	ra,0xffffe
    80005e2c:	16e080e7          	jalr	366(ra) # 80003f96 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005e30:	00003597          	auipc	a1,0x3
    80005e34:	94858593          	addi	a1,a1,-1720 # 80008778 <syscalls+0x2c8>
    80005e38:	fb040513          	addi	a0,s0,-80
    80005e3c:	ffffe097          	auipc	ra,0xffffe
    80005e40:	624080e7          	jalr	1572(ra) # 80004460 <namecmp>
    80005e44:	14050a63          	beqz	a0,80005f98 <sys_unlink+0x1be>
    80005e48:	00003597          	auipc	a1,0x3
    80005e4c:	93858593          	addi	a1,a1,-1736 # 80008780 <syscalls+0x2d0>
    80005e50:	fb040513          	addi	a0,s0,-80
    80005e54:	ffffe097          	auipc	ra,0xffffe
    80005e58:	60c080e7          	jalr	1548(ra) # 80004460 <namecmp>
    80005e5c:	12050e63          	beqz	a0,80005f98 <sys_unlink+0x1be>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005e60:	f2c40613          	addi	a2,s0,-212
    80005e64:	fb040593          	addi	a1,s0,-80
    80005e68:	8526                	mv	a0,s1
    80005e6a:	ffffe097          	auipc	ra,0xffffe
    80005e6e:	610080e7          	jalr	1552(ra) # 8000447a <dirlookup>
    80005e72:	892a                	mv	s2,a0
    80005e74:	12050263          	beqz	a0,80005f98 <sys_unlink+0x1be>
  ilock(ip);
    80005e78:	ffffe097          	auipc	ra,0xffffe
    80005e7c:	11e080e7          	jalr	286(ra) # 80003f96 <ilock>
  if(ip->nlink < 1)
    80005e80:	04a91783          	lh	a5,74(s2)
    80005e84:	08f05263          	blez	a5,80005f08 <sys_unlink+0x12e>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005e88:	04491703          	lh	a4,68(s2)
    80005e8c:	4785                	li	a5,1
    80005e8e:	08f70563          	beq	a4,a5,80005f18 <sys_unlink+0x13e>
  memset(&de, 0, sizeof(de));
    80005e92:	4641                	li	a2,16
    80005e94:	4581                	li	a1,0
    80005e96:	fc040513          	addi	a0,s0,-64
    80005e9a:	ffffb097          	auipc	ra,0xffffb
    80005e9e:	e38080e7          	jalr	-456(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005ea2:	4741                	li	a4,16
    80005ea4:	f2c42683          	lw	a3,-212(s0)
    80005ea8:	fc040613          	addi	a2,s0,-64
    80005eac:	4581                	li	a1,0
    80005eae:	8526                	mv	a0,s1
    80005eb0:	ffffe097          	auipc	ra,0xffffe
    80005eb4:	492080e7          	jalr	1170(ra) # 80004342 <writei>
    80005eb8:	47c1                	li	a5,16
    80005eba:	0af51563          	bne	a0,a5,80005f64 <sys_unlink+0x18a>
  if(ip->type == T_DIR){
    80005ebe:	04491703          	lh	a4,68(s2)
    80005ec2:	4785                	li	a5,1
    80005ec4:	0af70863          	beq	a4,a5,80005f74 <sys_unlink+0x19a>
  iunlockput(dp);
    80005ec8:	8526                	mv	a0,s1
    80005eca:	ffffe097          	auipc	ra,0xffffe
    80005ece:	32e080e7          	jalr	814(ra) # 800041f8 <iunlockput>
  ip->nlink--;
    80005ed2:	04a95783          	lhu	a5,74(s2)
    80005ed6:	37fd                	addiw	a5,a5,-1
    80005ed8:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005edc:	854a                	mv	a0,s2
    80005ede:	ffffe097          	auipc	ra,0xffffe
    80005ee2:	fec080e7          	jalr	-20(ra) # 80003eca <iupdate>
  iunlockput(ip);
    80005ee6:	854a                	mv	a0,s2
    80005ee8:	ffffe097          	auipc	ra,0xffffe
    80005eec:	310080e7          	jalr	784(ra) # 800041f8 <iunlockput>
  end_op();
    80005ef0:	fffff097          	auipc	ra,0xfffff
    80005ef4:	af0080e7          	jalr	-1296(ra) # 800049e0 <end_op>
  return 0;
    80005ef8:	4501                	li	a0,0
    80005efa:	a84d                	j	80005fac <sys_unlink+0x1d2>
    end_op();
    80005efc:	fffff097          	auipc	ra,0xfffff
    80005f00:	ae4080e7          	jalr	-1308(ra) # 800049e0 <end_op>
    return -1;
    80005f04:	557d                	li	a0,-1
    80005f06:	a05d                	j	80005fac <sys_unlink+0x1d2>
    panic("unlink: nlink < 1");
    80005f08:	00003517          	auipc	a0,0x3
    80005f0c:	88050513          	addi	a0,a0,-1920 # 80008788 <syscalls+0x2d8>
    80005f10:	ffffa097          	auipc	ra,0xffffa
    80005f14:	630080e7          	jalr	1584(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005f18:	04c92703          	lw	a4,76(s2)
    80005f1c:	02000793          	li	a5,32
    80005f20:	f6e7f9e3          	bgeu	a5,a4,80005e92 <sys_unlink+0xb8>
    80005f24:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005f28:	4741                	li	a4,16
    80005f2a:	86ce                	mv	a3,s3
    80005f2c:	f1840613          	addi	a2,s0,-232
    80005f30:	4581                	li	a1,0
    80005f32:	854a                	mv	a0,s2
    80005f34:	ffffe097          	auipc	ra,0xffffe
    80005f38:	316080e7          	jalr	790(ra) # 8000424a <readi>
    80005f3c:	47c1                	li	a5,16
    80005f3e:	00f51b63          	bne	a0,a5,80005f54 <sys_unlink+0x17a>
    if(de.inum != 0)
    80005f42:	f1845783          	lhu	a5,-232(s0)
    80005f46:	e7a1                	bnez	a5,80005f8e <sys_unlink+0x1b4>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005f48:	29c1                	addiw	s3,s3,16
    80005f4a:	04c92783          	lw	a5,76(s2)
    80005f4e:	fcf9ede3          	bltu	s3,a5,80005f28 <sys_unlink+0x14e>
    80005f52:	b781                	j	80005e92 <sys_unlink+0xb8>
      panic("isdirempty: readi");
    80005f54:	00003517          	auipc	a0,0x3
    80005f58:	84c50513          	addi	a0,a0,-1972 # 800087a0 <syscalls+0x2f0>
    80005f5c:	ffffa097          	auipc	ra,0xffffa
    80005f60:	5e4080e7          	jalr	1508(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005f64:	00003517          	auipc	a0,0x3
    80005f68:	85450513          	addi	a0,a0,-1964 # 800087b8 <syscalls+0x308>
    80005f6c:	ffffa097          	auipc	ra,0xffffa
    80005f70:	5d4080e7          	jalr	1492(ra) # 80000540 <panic>
    dp->nlink--;
    80005f74:	04a4d783          	lhu	a5,74(s1)
    80005f78:	37fd                	addiw	a5,a5,-1
    80005f7a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005f7e:	8526                	mv	a0,s1
    80005f80:	ffffe097          	auipc	ra,0xffffe
    80005f84:	f4a080e7          	jalr	-182(ra) # 80003eca <iupdate>
    80005f88:	b781                	j	80005ec8 <sys_unlink+0xee>
    return -1;
    80005f8a:	557d                	li	a0,-1
    80005f8c:	a005                	j	80005fac <sys_unlink+0x1d2>
    iunlockput(ip);
    80005f8e:	854a                	mv	a0,s2
    80005f90:	ffffe097          	auipc	ra,0xffffe
    80005f94:	268080e7          	jalr	616(ra) # 800041f8 <iunlockput>
  iunlockput(dp);
    80005f98:	8526                	mv	a0,s1
    80005f9a:	ffffe097          	auipc	ra,0xffffe
    80005f9e:	25e080e7          	jalr	606(ra) # 800041f8 <iunlockput>
  end_op();
    80005fa2:	fffff097          	auipc	ra,0xfffff
    80005fa6:	a3e080e7          	jalr	-1474(ra) # 800049e0 <end_op>
  return -1;
    80005faa:	557d                	li	a0,-1
}
    80005fac:	70ae                	ld	ra,232(sp)
    80005fae:	740e                	ld	s0,224(sp)
    80005fb0:	64ee                	ld	s1,216(sp)
    80005fb2:	694e                	ld	s2,208(sp)
    80005fb4:	69ae                	ld	s3,200(sp)
    80005fb6:	616d                	addi	sp,sp,240
    80005fb8:	8082                	ret

0000000080005fba <sys_open>:

uint64
sys_open(void)
{
    80005fba:	7131                	addi	sp,sp,-192
    80005fbc:	fd06                	sd	ra,184(sp)
    80005fbe:	f922                	sd	s0,176(sp)
    80005fc0:	f526                	sd	s1,168(sp)
    80005fc2:	f14a                	sd	s2,160(sp)
    80005fc4:	ed4e                	sd	s3,152(sp)
    80005fc6:	0180                	addi	s0,sp,192
  myproc()->syscall_count[SYS_open]++;
    80005fc8:	ffffc097          	auipc	ra,0xffffc
    80005fcc:	b7e080e7          	jalr	-1154(ra) # 80001b46 <myproc>
    80005fd0:	497c                	lw	a5,84(a0)
    80005fd2:	2785                	addiw	a5,a5,1
    80005fd4:	c97c                	sw	a5,84(a0)
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005fd6:	f4c40593          	addi	a1,s0,-180
    80005fda:	4505                	li	a0,1
    80005fdc:	ffffd097          	auipc	ra,0xffffd
    80005fe0:	1c2080e7          	jalr	450(ra) # 8000319e <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005fe4:	08000613          	li	a2,128
    80005fe8:	f5040593          	addi	a1,s0,-176
    80005fec:	4501                	li	a0,0
    80005fee:	ffffd097          	auipc	ra,0xffffd
    80005ff2:	1f0080e7          	jalr	496(ra) # 800031de <argstr>
    80005ff6:	87aa                	mv	a5,a0
    return -1;
    80005ff8:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005ffa:	0a07c963          	bltz	a5,800060ac <sys_open+0xf2>

  begin_op();
    80005ffe:	fffff097          	auipc	ra,0xfffff
    80006002:	964080e7          	jalr	-1692(ra) # 80004962 <begin_op>

  if(omode & O_CREATE){
    80006006:	f4c42783          	lw	a5,-180(s0)
    8000600a:	2007f793          	andi	a5,a5,512
    8000600e:	cfc5                	beqz	a5,800060c6 <sys_open+0x10c>
    ip = create(path, T_FILE, 0, 0);
    80006010:	4681                	li	a3,0
    80006012:	4601                	li	a2,0
    80006014:	4589                	li	a1,2
    80006016:	f5040513          	addi	a0,s0,-176
    8000601a:	00000097          	auipc	ra,0x0
    8000601e:	900080e7          	jalr	-1792(ra) # 8000591a <create>
    80006022:	84aa                	mv	s1,a0
    if(ip == 0){
    80006024:	c959                	beqz	a0,800060ba <sys_open+0x100>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80006026:	04449703          	lh	a4,68(s1)
    8000602a:	478d                	li	a5,3
    8000602c:	00f71763          	bne	a4,a5,8000603a <sys_open+0x80>
    80006030:	0464d703          	lhu	a4,70(s1)
    80006034:	47a5                	li	a5,9
    80006036:	0ce7ed63          	bltu	a5,a4,80006110 <sys_open+0x156>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000603a:	fffff097          	auipc	ra,0xfffff
    8000603e:	d38080e7          	jalr	-712(ra) # 80004d72 <filealloc>
    80006042:	89aa                	mv	s3,a0
    80006044:	10050363          	beqz	a0,8000614a <sys_open+0x190>
    80006048:	00000097          	auipc	ra,0x0
    8000604c:	830080e7          	jalr	-2000(ra) # 80005878 <fdalloc>
    80006050:	892a                	mv	s2,a0
    80006052:	0e054763          	bltz	a0,80006140 <sys_open+0x186>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80006056:	04449703          	lh	a4,68(s1)
    8000605a:	478d                	li	a5,3
    8000605c:	0cf70563          	beq	a4,a5,80006126 <sys_open+0x16c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80006060:	4789                	li	a5,2
    80006062:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80006066:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000606a:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000606e:	f4c42783          	lw	a5,-180(s0)
    80006072:	0017c713          	xori	a4,a5,1
    80006076:	8b05                	andi	a4,a4,1
    80006078:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000607c:	0037f713          	andi	a4,a5,3
    80006080:	00e03733          	snez	a4,a4
    80006084:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006088:	4007f793          	andi	a5,a5,1024
    8000608c:	c791                	beqz	a5,80006098 <sys_open+0xde>
    8000608e:	04449703          	lh	a4,68(s1)
    80006092:	4789                	li	a5,2
    80006094:	0af70063          	beq	a4,a5,80006134 <sys_open+0x17a>
    itrunc(ip);
  }

  iunlock(ip);
    80006098:	8526                	mv	a0,s1
    8000609a:	ffffe097          	auipc	ra,0xffffe
    8000609e:	fbe080e7          	jalr	-66(ra) # 80004058 <iunlock>
  end_op();
    800060a2:	fffff097          	auipc	ra,0xfffff
    800060a6:	93e080e7          	jalr	-1730(ra) # 800049e0 <end_op>

  return fd;
    800060aa:	854a                	mv	a0,s2
}
    800060ac:	70ea                	ld	ra,184(sp)
    800060ae:	744a                	ld	s0,176(sp)
    800060b0:	74aa                	ld	s1,168(sp)
    800060b2:	790a                	ld	s2,160(sp)
    800060b4:	69ea                	ld	s3,152(sp)
    800060b6:	6129                	addi	sp,sp,192
    800060b8:	8082                	ret
      end_op();
    800060ba:	fffff097          	auipc	ra,0xfffff
    800060be:	926080e7          	jalr	-1754(ra) # 800049e0 <end_op>
      return -1;
    800060c2:	557d                	li	a0,-1
    800060c4:	b7e5                	j	800060ac <sys_open+0xf2>
    if((ip = namei(path)) == 0){
    800060c6:	f5040513          	addi	a0,s0,-176
    800060ca:	ffffe097          	auipc	ra,0xffffe
    800060ce:	678080e7          	jalr	1656(ra) # 80004742 <namei>
    800060d2:	84aa                	mv	s1,a0
    800060d4:	c905                	beqz	a0,80006104 <sys_open+0x14a>
    ilock(ip);
    800060d6:	ffffe097          	auipc	ra,0xffffe
    800060da:	ec0080e7          	jalr	-320(ra) # 80003f96 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800060de:	04449703          	lh	a4,68(s1)
    800060e2:	4785                	li	a5,1
    800060e4:	f4f711e3          	bne	a4,a5,80006026 <sys_open+0x6c>
    800060e8:	f4c42783          	lw	a5,-180(s0)
    800060ec:	d7b9                	beqz	a5,8000603a <sys_open+0x80>
      iunlockput(ip);
    800060ee:	8526                	mv	a0,s1
    800060f0:	ffffe097          	auipc	ra,0xffffe
    800060f4:	108080e7          	jalr	264(ra) # 800041f8 <iunlockput>
      end_op();
    800060f8:	fffff097          	auipc	ra,0xfffff
    800060fc:	8e8080e7          	jalr	-1816(ra) # 800049e0 <end_op>
      return -1;
    80006100:	557d                	li	a0,-1
    80006102:	b76d                	j	800060ac <sys_open+0xf2>
      end_op();
    80006104:	fffff097          	auipc	ra,0xfffff
    80006108:	8dc080e7          	jalr	-1828(ra) # 800049e0 <end_op>
      return -1;
    8000610c:	557d                	li	a0,-1
    8000610e:	bf79                	j	800060ac <sys_open+0xf2>
    iunlockput(ip);
    80006110:	8526                	mv	a0,s1
    80006112:	ffffe097          	auipc	ra,0xffffe
    80006116:	0e6080e7          	jalr	230(ra) # 800041f8 <iunlockput>
    end_op();
    8000611a:	fffff097          	auipc	ra,0xfffff
    8000611e:	8c6080e7          	jalr	-1850(ra) # 800049e0 <end_op>
    return -1;
    80006122:	557d                	li	a0,-1
    80006124:	b761                	j	800060ac <sys_open+0xf2>
    f->type = FD_DEVICE;
    80006126:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    8000612a:	04649783          	lh	a5,70(s1)
    8000612e:	02f99223          	sh	a5,36(s3)
    80006132:	bf25                	j	8000606a <sys_open+0xb0>
    itrunc(ip);
    80006134:	8526                	mv	a0,s1
    80006136:	ffffe097          	auipc	ra,0xffffe
    8000613a:	f6e080e7          	jalr	-146(ra) # 800040a4 <itrunc>
    8000613e:	bfa9                	j	80006098 <sys_open+0xde>
      fileclose(f);
    80006140:	854e                	mv	a0,s3
    80006142:	fffff097          	auipc	ra,0xfffff
    80006146:	cec080e7          	jalr	-788(ra) # 80004e2e <fileclose>
    iunlockput(ip);
    8000614a:	8526                	mv	a0,s1
    8000614c:	ffffe097          	auipc	ra,0xffffe
    80006150:	0ac080e7          	jalr	172(ra) # 800041f8 <iunlockput>
    end_op();
    80006154:	fffff097          	auipc	ra,0xfffff
    80006158:	88c080e7          	jalr	-1908(ra) # 800049e0 <end_op>
    return -1;
    8000615c:	557d                	li	a0,-1
    8000615e:	b7b9                	j	800060ac <sys_open+0xf2>

0000000080006160 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006160:	7175                	addi	sp,sp,-144
    80006162:	e506                	sd	ra,136(sp)
    80006164:	e122                	sd	s0,128(sp)
    80006166:	0900                	addi	s0,sp,144
  myproc()->syscall_count[SYS_mkdir]++;
    80006168:	ffffc097          	auipc	ra,0xffffc
    8000616c:	9de080e7          	jalr	-1570(ra) # 80001b46 <myproc>
    80006170:	553c                	lw	a5,104(a0)
    80006172:	2785                	addiw	a5,a5,1
    80006174:	d53c                	sw	a5,104(a0)
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006176:	ffffe097          	auipc	ra,0xffffe
    8000617a:	7ec080e7          	jalr	2028(ra) # 80004962 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000617e:	08000613          	li	a2,128
    80006182:	f7040593          	addi	a1,s0,-144
    80006186:	4501                	li	a0,0
    80006188:	ffffd097          	auipc	ra,0xffffd
    8000618c:	056080e7          	jalr	86(ra) # 800031de <argstr>
    80006190:	02054963          	bltz	a0,800061c2 <sys_mkdir+0x62>
    80006194:	4681                	li	a3,0
    80006196:	4601                	li	a2,0
    80006198:	4585                	li	a1,1
    8000619a:	f7040513          	addi	a0,s0,-144
    8000619e:	fffff097          	auipc	ra,0xfffff
    800061a2:	77c080e7          	jalr	1916(ra) # 8000591a <create>
    800061a6:	cd11                	beqz	a0,800061c2 <sys_mkdir+0x62>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800061a8:	ffffe097          	auipc	ra,0xffffe
    800061ac:	050080e7          	jalr	80(ra) # 800041f8 <iunlockput>
  end_op();
    800061b0:	fffff097          	auipc	ra,0xfffff
    800061b4:	830080e7          	jalr	-2000(ra) # 800049e0 <end_op>
  return 0;
    800061b8:	4501                	li	a0,0
}
    800061ba:	60aa                	ld	ra,136(sp)
    800061bc:	640a                	ld	s0,128(sp)
    800061be:	6149                	addi	sp,sp,144
    800061c0:	8082                	ret
    end_op();
    800061c2:	fffff097          	auipc	ra,0xfffff
    800061c6:	81e080e7          	jalr	-2018(ra) # 800049e0 <end_op>
    return -1;
    800061ca:	557d                	li	a0,-1
    800061cc:	b7fd                	j	800061ba <sys_mkdir+0x5a>

00000000800061ce <sys_mknod>:

uint64
sys_mknod(void)
{
    800061ce:	7135                	addi	sp,sp,-160
    800061d0:	ed06                	sd	ra,152(sp)
    800061d2:	e922                	sd	s0,144(sp)
    800061d4:	1100                	addi	s0,sp,160
  myproc()->syscall_count[SYS_mknod]++;
    800061d6:	ffffc097          	auipc	ra,0xffffc
    800061da:	970080e7          	jalr	-1680(ra) # 80001b46 <myproc>
    800061de:	4d7c                	lw	a5,92(a0)
    800061e0:	2785                	addiw	a5,a5,1
    800061e2:	cd7c                	sw	a5,92(a0)
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800061e4:	ffffe097          	auipc	ra,0xffffe
    800061e8:	77e080e7          	jalr	1918(ra) # 80004962 <begin_op>
  argint(1, &major);
    800061ec:	f6c40593          	addi	a1,s0,-148
    800061f0:	4505                	li	a0,1
    800061f2:	ffffd097          	auipc	ra,0xffffd
    800061f6:	fac080e7          	jalr	-84(ra) # 8000319e <argint>
  argint(2, &minor);
    800061fa:	f6840593          	addi	a1,s0,-152
    800061fe:	4509                	li	a0,2
    80006200:	ffffd097          	auipc	ra,0xffffd
    80006204:	f9e080e7          	jalr	-98(ra) # 8000319e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006208:	08000613          	li	a2,128
    8000620c:	f7040593          	addi	a1,s0,-144
    80006210:	4501                	li	a0,0
    80006212:	ffffd097          	auipc	ra,0xffffd
    80006216:	fcc080e7          	jalr	-52(ra) # 800031de <argstr>
    8000621a:	02054b63          	bltz	a0,80006250 <sys_mknod+0x82>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000621e:	f6841683          	lh	a3,-152(s0)
    80006222:	f6c41603          	lh	a2,-148(s0)
    80006226:	458d                	li	a1,3
    80006228:	f7040513          	addi	a0,s0,-144
    8000622c:	fffff097          	auipc	ra,0xfffff
    80006230:	6ee080e7          	jalr	1774(ra) # 8000591a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006234:	cd11                	beqz	a0,80006250 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006236:	ffffe097          	auipc	ra,0xffffe
    8000623a:	fc2080e7          	jalr	-62(ra) # 800041f8 <iunlockput>
  end_op();
    8000623e:	ffffe097          	auipc	ra,0xffffe
    80006242:	7a2080e7          	jalr	1954(ra) # 800049e0 <end_op>
  return 0;
    80006246:	4501                	li	a0,0
}
    80006248:	60ea                	ld	ra,152(sp)
    8000624a:	644a                	ld	s0,144(sp)
    8000624c:	610d                	addi	sp,sp,160
    8000624e:	8082                	ret
    end_op();
    80006250:	ffffe097          	auipc	ra,0xffffe
    80006254:	790080e7          	jalr	1936(ra) # 800049e0 <end_op>
    return -1;
    80006258:	557d                	li	a0,-1
    8000625a:	b7fd                	j	80006248 <sys_mknod+0x7a>

000000008000625c <sys_chdir>:

uint64
sys_chdir(void)
{
    8000625c:	7135                	addi	sp,sp,-160
    8000625e:	ed06                	sd	ra,152(sp)
    80006260:	e922                	sd	s0,144(sp)
    80006262:	e526                	sd	s1,136(sp)
    80006264:	e14a                	sd	s2,128(sp)
    80006266:	1100                	addi	s0,sp,160
  myproc()->syscall_count[SYS_chdir]++;
    80006268:	ffffc097          	auipc	ra,0xffffc
    8000626c:	8de080e7          	jalr	-1826(ra) # 80001b46 <myproc>
    80006270:	5d5c                	lw	a5,60(a0)
    80006272:	2785                	addiw	a5,a5,1
    80006274:	dd5c                	sw	a5,60(a0)
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006276:	ffffc097          	auipc	ra,0xffffc
    8000627a:	8d0080e7          	jalr	-1840(ra) # 80001b46 <myproc>
    8000627e:	892a                	mv	s2,a0
  
  begin_op();
    80006280:	ffffe097          	auipc	ra,0xffffe
    80006284:	6e2080e7          	jalr	1762(ra) # 80004962 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006288:	08000613          	li	a2,128
    8000628c:	f6040593          	addi	a1,s0,-160
    80006290:	4501                	li	a0,0
    80006292:	ffffd097          	auipc	ra,0xffffd
    80006296:	f4c080e7          	jalr	-180(ra) # 800031de <argstr>
    8000629a:	04054b63          	bltz	a0,800062f0 <sys_chdir+0x94>
    8000629e:	f6040513          	addi	a0,s0,-160
    800062a2:	ffffe097          	auipc	ra,0xffffe
    800062a6:	4a0080e7          	jalr	1184(ra) # 80004742 <namei>
    800062aa:	84aa                	mv	s1,a0
    800062ac:	c131                	beqz	a0,800062f0 <sys_chdir+0x94>
    end_op();
    return -1;
  }
  ilock(ip);
    800062ae:	ffffe097          	auipc	ra,0xffffe
    800062b2:	ce8080e7          	jalr	-792(ra) # 80003f96 <ilock>
  if(ip->type != T_DIR){
    800062b6:	04449703          	lh	a4,68(s1)
    800062ba:	4785                	li	a5,1
    800062bc:	04f71063          	bne	a4,a5,800062fc <sys_chdir+0xa0>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800062c0:	8526                	mv	a0,s1
    800062c2:	ffffe097          	auipc	ra,0xffffe
    800062c6:	d96080e7          	jalr	-618(ra) # 80004058 <iunlock>
  iput(p->cwd);
    800062ca:	1d093503          	ld	a0,464(s2)
    800062ce:	ffffe097          	auipc	ra,0xffffe
    800062d2:	e82080e7          	jalr	-382(ra) # 80004150 <iput>
  end_op();
    800062d6:	ffffe097          	auipc	ra,0xffffe
    800062da:	70a080e7          	jalr	1802(ra) # 800049e0 <end_op>
  p->cwd = ip;
    800062de:	1c993823          	sd	s1,464(s2)
  return 0;
    800062e2:	4501                	li	a0,0
}
    800062e4:	60ea                	ld	ra,152(sp)
    800062e6:	644a                	ld	s0,144(sp)
    800062e8:	64aa                	ld	s1,136(sp)
    800062ea:	690a                	ld	s2,128(sp)
    800062ec:	610d                	addi	sp,sp,160
    800062ee:	8082                	ret
    end_op();
    800062f0:	ffffe097          	auipc	ra,0xffffe
    800062f4:	6f0080e7          	jalr	1776(ra) # 800049e0 <end_op>
    return -1;
    800062f8:	557d                	li	a0,-1
    800062fa:	b7ed                	j	800062e4 <sys_chdir+0x88>
    iunlockput(ip);
    800062fc:	8526                	mv	a0,s1
    800062fe:	ffffe097          	auipc	ra,0xffffe
    80006302:	efa080e7          	jalr	-262(ra) # 800041f8 <iunlockput>
    end_op();
    80006306:	ffffe097          	auipc	ra,0xffffe
    8000630a:	6da080e7          	jalr	1754(ra) # 800049e0 <end_op>
    return -1;
    8000630e:	557d                	li	a0,-1
    80006310:	bfd1                	j	800062e4 <sys_chdir+0x88>

0000000080006312 <sys_exec>:

uint64
sys_exec(void)
{
    80006312:	7145                	addi	sp,sp,-464
    80006314:	e786                	sd	ra,456(sp)
    80006316:	e3a2                	sd	s0,448(sp)
    80006318:	ff26                	sd	s1,440(sp)
    8000631a:	fb4a                	sd	s2,432(sp)
    8000631c:	f74e                	sd	s3,424(sp)
    8000631e:	f352                	sd	s4,416(sp)
    80006320:	ef56                	sd	s5,408(sp)
    80006322:	0b80                	addi	s0,sp,464
  myproc()->syscall_count[SYS_exec]++;
    80006324:	ffffc097          	auipc	ra,0xffffc
    80006328:	822080e7          	jalr	-2014(ra) # 80001b46 <myproc>
    8000632c:	595c                	lw	a5,52(a0)
    8000632e:	2785                	addiw	a5,a5,1
    80006330:	d95c                	sw	a5,52(a0)
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80006332:	e3840593          	addi	a1,s0,-456
    80006336:	4505                	li	a0,1
    80006338:	ffffd097          	auipc	ra,0xffffd
    8000633c:	e86080e7          	jalr	-378(ra) # 800031be <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80006340:	08000613          	li	a2,128
    80006344:	f4040593          	addi	a1,s0,-192
    80006348:	4501                	li	a0,0
    8000634a:	ffffd097          	auipc	ra,0xffffd
    8000634e:	e94080e7          	jalr	-364(ra) # 800031de <argstr>
    80006352:	87aa                	mv	a5,a0
    return -1;
    80006354:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80006356:	0c07c363          	bltz	a5,8000641c <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
    8000635a:	10000613          	li	a2,256
    8000635e:	4581                	li	a1,0
    80006360:	e4040513          	addi	a0,s0,-448
    80006364:	ffffb097          	auipc	ra,0xffffb
    80006368:	96e080e7          	jalr	-1682(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000636c:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006370:	89a6                	mv	s3,s1
    80006372:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006374:	02000a13          	li	s4,32
    80006378:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000637c:	00391513          	slli	a0,s2,0x3
    80006380:	e3040593          	addi	a1,s0,-464
    80006384:	e3843783          	ld	a5,-456(s0)
    80006388:	953e                	add	a0,a0,a5
    8000638a:	ffffd097          	auipc	ra,0xffffd
    8000638e:	d76080e7          	jalr	-650(ra) # 80003100 <fetchaddr>
    80006392:	02054a63          	bltz	a0,800063c6 <sys_exec+0xb4>
      goto bad;
    }
    if(uarg == 0){
    80006396:	e3043783          	ld	a5,-464(s0)
    8000639a:	c3b9                	beqz	a5,800063e0 <sys_exec+0xce>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000639c:	ffffa097          	auipc	ra,0xffffa
    800063a0:	74a080e7          	jalr	1866(ra) # 80000ae6 <kalloc>
    800063a4:	85aa                	mv	a1,a0
    800063a6:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800063aa:	cd11                	beqz	a0,800063c6 <sys_exec+0xb4>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800063ac:	6605                	lui	a2,0x1
    800063ae:	e3043503          	ld	a0,-464(s0)
    800063b2:	ffffd097          	auipc	ra,0xffffd
    800063b6:	da0080e7          	jalr	-608(ra) # 80003152 <fetchstr>
    800063ba:	00054663          	bltz	a0,800063c6 <sys_exec+0xb4>
    if(i >= NELEM(argv)){
    800063be:	0905                	addi	s2,s2,1
    800063c0:	09a1                	addi	s3,s3,8
    800063c2:	fb491be3          	bne	s2,s4,80006378 <sys_exec+0x66>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800063c6:	f4040913          	addi	s2,s0,-192
    800063ca:	6088                	ld	a0,0(s1)
    800063cc:	c539                	beqz	a0,8000641a <sys_exec+0x108>
    kfree(argv[i]);
    800063ce:	ffffa097          	auipc	ra,0xffffa
    800063d2:	61a080e7          	jalr	1562(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800063d6:	04a1                	addi	s1,s1,8
    800063d8:	ff2499e3          	bne	s1,s2,800063ca <sys_exec+0xb8>
  return -1;
    800063dc:	557d                	li	a0,-1
    800063de:	a83d                	j	8000641c <sys_exec+0x10a>
      argv[i] = 0;
    800063e0:	0a8e                	slli	s5,s5,0x3
    800063e2:	fc0a8793          	addi	a5,s5,-64
    800063e6:	00878ab3          	add	s5,a5,s0
    800063ea:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    800063ee:	e4040593          	addi	a1,s0,-448
    800063f2:	f4040513          	addi	a0,s0,-192
    800063f6:	fffff097          	auipc	ra,0xfffff
    800063fa:	0b2080e7          	jalr	178(ra) # 800054a8 <exec>
    800063fe:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006400:	f4040993          	addi	s3,s0,-192
    80006404:	6088                	ld	a0,0(s1)
    80006406:	c901                	beqz	a0,80006416 <sys_exec+0x104>
    kfree(argv[i]);
    80006408:	ffffa097          	auipc	ra,0xffffa
    8000640c:	5e0080e7          	jalr	1504(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006410:	04a1                	addi	s1,s1,8
    80006412:	ff3499e3          	bne	s1,s3,80006404 <sys_exec+0xf2>
  return ret;
    80006416:	854a                	mv	a0,s2
    80006418:	a011                	j	8000641c <sys_exec+0x10a>
  return -1;
    8000641a:	557d                	li	a0,-1
}
    8000641c:	60be                	ld	ra,456(sp)
    8000641e:	641e                	ld	s0,448(sp)
    80006420:	74fa                	ld	s1,440(sp)
    80006422:	795a                	ld	s2,432(sp)
    80006424:	79ba                	ld	s3,424(sp)
    80006426:	7a1a                	ld	s4,416(sp)
    80006428:	6afa                	ld	s5,408(sp)
    8000642a:	6179                	addi	sp,sp,464
    8000642c:	8082                	ret

000000008000642e <sys_pipe>:

uint64
sys_pipe(void)
{
    8000642e:	7139                	addi	sp,sp,-64
    80006430:	fc06                	sd	ra,56(sp)
    80006432:	f822                	sd	s0,48(sp)
    80006434:	f426                	sd	s1,40(sp)
    80006436:	0080                	addi	s0,sp,64
  myproc()->syscall_count[SYS_pipe]++;
    80006438:	ffffb097          	auipc	ra,0xffffb
    8000643c:	70e080e7          	jalr	1806(ra) # 80001b46 <myproc>
    80006440:	551c                	lw	a5,40(a0)
    80006442:	2785                	addiw	a5,a5,1
    80006444:	d51c                	sw	a5,40(a0)
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006446:	ffffb097          	auipc	ra,0xffffb
    8000644a:	700080e7          	jalr	1792(ra) # 80001b46 <myproc>
    8000644e:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006450:	fd840593          	addi	a1,s0,-40
    80006454:	4501                	li	a0,0
    80006456:	ffffd097          	auipc	ra,0xffffd
    8000645a:	d68080e7          	jalr	-664(ra) # 800031be <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000645e:	fc840593          	addi	a1,s0,-56
    80006462:	fd040513          	addi	a0,s0,-48
    80006466:	fffff097          	auipc	ra,0xfffff
    8000646a:	cf8080e7          	jalr	-776(ra) # 8000515e <pipealloc>
    return -1;
    8000646e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006470:	0c054763          	bltz	a0,8000653e <sys_pipe+0x110>
  fd0 = -1;
    80006474:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006478:	fd043503          	ld	a0,-48(s0)
    8000647c:	fffff097          	auipc	ra,0xfffff
    80006480:	3fc080e7          	jalr	1020(ra) # 80005878 <fdalloc>
    80006484:	fca42223          	sw	a0,-60(s0)
    80006488:	08054e63          	bltz	a0,80006524 <sys_pipe+0xf6>
    8000648c:	fc843503          	ld	a0,-56(s0)
    80006490:	fffff097          	auipc	ra,0xfffff
    80006494:	3e8080e7          	jalr	1000(ra) # 80005878 <fdalloc>
    80006498:	fca42023          	sw	a0,-64(s0)
    8000649c:	06054a63          	bltz	a0,80006510 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800064a0:	4691                	li	a3,4
    800064a2:	fc440613          	addi	a2,s0,-60
    800064a6:	fd843583          	ld	a1,-40(s0)
    800064aa:	68e8                	ld	a0,208(s1)
    800064ac:	ffffb097          	auipc	ra,0xffffb
    800064b0:	1c0080e7          	jalr	448(ra) # 8000166c <copyout>
    800064b4:	02054063          	bltz	a0,800064d4 <sys_pipe+0xa6>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800064b8:	4691                	li	a3,4
    800064ba:	fc040613          	addi	a2,s0,-64
    800064be:	fd843583          	ld	a1,-40(s0)
    800064c2:	0591                	addi	a1,a1,4
    800064c4:	68e8                	ld	a0,208(s1)
    800064c6:	ffffb097          	auipc	ra,0xffffb
    800064ca:	1a6080e7          	jalr	422(ra) # 8000166c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800064ce:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800064d0:	06055763          	bgez	a0,8000653e <sys_pipe+0x110>
    p->ofile[fd0] = 0;
    800064d4:	fc442783          	lw	a5,-60(s0)
    800064d8:	02a78793          	addi	a5,a5,42
    800064dc:	078e                	slli	a5,a5,0x3
    800064de:	97a6                	add	a5,a5,s1
    800064e0:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800064e4:	fc042783          	lw	a5,-64(s0)
    800064e8:	02a78793          	addi	a5,a5,42
    800064ec:	078e                	slli	a5,a5,0x3
    800064ee:	94be                	add	s1,s1,a5
    800064f0:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800064f4:	fd043503          	ld	a0,-48(s0)
    800064f8:	fffff097          	auipc	ra,0xfffff
    800064fc:	936080e7          	jalr	-1738(ra) # 80004e2e <fileclose>
    fileclose(wf);
    80006500:	fc843503          	ld	a0,-56(s0)
    80006504:	fffff097          	auipc	ra,0xfffff
    80006508:	92a080e7          	jalr	-1750(ra) # 80004e2e <fileclose>
    return -1;
    8000650c:	57fd                	li	a5,-1
    8000650e:	a805                	j	8000653e <sys_pipe+0x110>
    if(fd0 >= 0)
    80006510:	fc442783          	lw	a5,-60(s0)
    80006514:	0007c863          	bltz	a5,80006524 <sys_pipe+0xf6>
      p->ofile[fd0] = 0;
    80006518:	02a78793          	addi	a5,a5,42
    8000651c:	078e                	slli	a5,a5,0x3
    8000651e:	97a6                	add	a5,a5,s1
    80006520:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80006524:	fd043503          	ld	a0,-48(s0)
    80006528:	fffff097          	auipc	ra,0xfffff
    8000652c:	906080e7          	jalr	-1786(ra) # 80004e2e <fileclose>
    fileclose(wf);
    80006530:	fc843503          	ld	a0,-56(s0)
    80006534:	fffff097          	auipc	ra,0xfffff
    80006538:	8fa080e7          	jalr	-1798(ra) # 80004e2e <fileclose>
    return -1;
    8000653c:	57fd                	li	a5,-1
}
    8000653e:	853e                	mv	a0,a5
    80006540:	70e2                	ld	ra,56(sp)
    80006542:	7442                	ld	s0,48(sp)
    80006544:	74a2                	ld	s1,40(sp)
    80006546:	6121                	addi	sp,sp,64
    80006548:	8082                	ret
    8000654a:	0000                	unimp
    8000654c:	0000                	unimp
	...

0000000080006550 <kernelvec>:
    80006550:	7111                	addi	sp,sp,-256
    80006552:	e006                	sd	ra,0(sp)
    80006554:	e40a                	sd	sp,8(sp)
    80006556:	e80e                	sd	gp,16(sp)
    80006558:	ec12                	sd	tp,24(sp)
    8000655a:	f016                	sd	t0,32(sp)
    8000655c:	f41a                	sd	t1,40(sp)
    8000655e:	f81e                	sd	t2,48(sp)
    80006560:	fc22                	sd	s0,56(sp)
    80006562:	e0a6                	sd	s1,64(sp)
    80006564:	e4aa                	sd	a0,72(sp)
    80006566:	e8ae                	sd	a1,80(sp)
    80006568:	ecb2                	sd	a2,88(sp)
    8000656a:	f0b6                	sd	a3,96(sp)
    8000656c:	f4ba                	sd	a4,104(sp)
    8000656e:	f8be                	sd	a5,112(sp)
    80006570:	fcc2                	sd	a6,120(sp)
    80006572:	e146                	sd	a7,128(sp)
    80006574:	e54a                	sd	s2,136(sp)
    80006576:	e94e                	sd	s3,144(sp)
    80006578:	ed52                	sd	s4,152(sp)
    8000657a:	f156                	sd	s5,160(sp)
    8000657c:	f55a                	sd	s6,168(sp)
    8000657e:	f95e                	sd	s7,176(sp)
    80006580:	fd62                	sd	s8,184(sp)
    80006582:	e1e6                	sd	s9,192(sp)
    80006584:	e5ea                	sd	s10,200(sp)
    80006586:	e9ee                	sd	s11,208(sp)
    80006588:	edf2                	sd	t3,216(sp)
    8000658a:	f1f6                	sd	t4,224(sp)
    8000658c:	f5fa                	sd	t5,232(sp)
    8000658e:	f9fe                	sd	t6,240(sp)
    80006590:	a3bfc0ef          	jal	ra,80002fca <kerneltrap>
    80006594:	6082                	ld	ra,0(sp)
    80006596:	6122                	ld	sp,8(sp)
    80006598:	61c2                	ld	gp,16(sp)
    8000659a:	7282                	ld	t0,32(sp)
    8000659c:	7322                	ld	t1,40(sp)
    8000659e:	73c2                	ld	t2,48(sp)
    800065a0:	7462                	ld	s0,56(sp)
    800065a2:	6486                	ld	s1,64(sp)
    800065a4:	6526                	ld	a0,72(sp)
    800065a6:	65c6                	ld	a1,80(sp)
    800065a8:	6666                	ld	a2,88(sp)
    800065aa:	7686                	ld	a3,96(sp)
    800065ac:	7726                	ld	a4,104(sp)
    800065ae:	77c6                	ld	a5,112(sp)
    800065b0:	7866                	ld	a6,120(sp)
    800065b2:	688a                	ld	a7,128(sp)
    800065b4:	692a                	ld	s2,136(sp)
    800065b6:	69ca                	ld	s3,144(sp)
    800065b8:	6a6a                	ld	s4,152(sp)
    800065ba:	7a8a                	ld	s5,160(sp)
    800065bc:	7b2a                	ld	s6,168(sp)
    800065be:	7bca                	ld	s7,176(sp)
    800065c0:	7c6a                	ld	s8,184(sp)
    800065c2:	6c8e                	ld	s9,192(sp)
    800065c4:	6d2e                	ld	s10,200(sp)
    800065c6:	6dce                	ld	s11,208(sp)
    800065c8:	6e6e                	ld	t3,216(sp)
    800065ca:	7e8e                	ld	t4,224(sp)
    800065cc:	7f2e                	ld	t5,232(sp)
    800065ce:	7fce                	ld	t6,240(sp)
    800065d0:	6111                	addi	sp,sp,256
    800065d2:	10200073          	sret
    800065d6:	00000013          	nop
    800065da:	00000013          	nop
    800065de:	0001                	nop

00000000800065e0 <timervec>:
    800065e0:	34051573          	csrrw	a0,mscratch,a0
    800065e4:	e10c                	sd	a1,0(a0)
    800065e6:	e510                	sd	a2,8(a0)
    800065e8:	e914                	sd	a3,16(a0)
    800065ea:	6d0c                	ld	a1,24(a0)
    800065ec:	7110                	ld	a2,32(a0)
    800065ee:	6194                	ld	a3,0(a1)
    800065f0:	96b2                	add	a3,a3,a2
    800065f2:	e194                	sd	a3,0(a1)
    800065f4:	4589                	li	a1,2
    800065f6:	14459073          	csrw	sip,a1
    800065fa:	6914                	ld	a3,16(a0)
    800065fc:	6510                	ld	a2,8(a0)
    800065fe:	610c                	ld	a1,0(a0)
    80006600:	34051573          	csrrw	a0,mscratch,a0
    80006604:	30200073          	mret
	...

000000008000660a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000660a:	1141                	addi	sp,sp,-16
    8000660c:	e422                	sd	s0,8(sp)
    8000660e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006610:	0c0007b7          	lui	a5,0xc000
    80006614:	4705                	li	a4,1
    80006616:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006618:	c3d8                	sw	a4,4(a5)
}
    8000661a:	6422                	ld	s0,8(sp)
    8000661c:	0141                	addi	sp,sp,16
    8000661e:	8082                	ret

0000000080006620 <plicinithart>:

void
plicinithart(void)
{
    80006620:	1141                	addi	sp,sp,-16
    80006622:	e406                	sd	ra,8(sp)
    80006624:	e022                	sd	s0,0(sp)
    80006626:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006628:	ffffb097          	auipc	ra,0xffffb
    8000662c:	4f2080e7          	jalr	1266(ra) # 80001b1a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006630:	0085171b          	slliw	a4,a0,0x8
    80006634:	0c0027b7          	lui	a5,0xc002
    80006638:	97ba                	add	a5,a5,a4
    8000663a:	40200713          	li	a4,1026
    8000663e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006642:	00d5151b          	slliw	a0,a0,0xd
    80006646:	0c2017b7          	lui	a5,0xc201
    8000664a:	97aa                	add	a5,a5,a0
    8000664c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006650:	60a2                	ld	ra,8(sp)
    80006652:	6402                	ld	s0,0(sp)
    80006654:	0141                	addi	sp,sp,16
    80006656:	8082                	ret

0000000080006658 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006658:	1141                	addi	sp,sp,-16
    8000665a:	e406                	sd	ra,8(sp)
    8000665c:	e022                	sd	s0,0(sp)
    8000665e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006660:	ffffb097          	auipc	ra,0xffffb
    80006664:	4ba080e7          	jalr	1210(ra) # 80001b1a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006668:	00d5151b          	slliw	a0,a0,0xd
    8000666c:	0c2017b7          	lui	a5,0xc201
    80006670:	97aa                	add	a5,a5,a0
  return irq;
}
    80006672:	43c8                	lw	a0,4(a5)
    80006674:	60a2                	ld	ra,8(sp)
    80006676:	6402                	ld	s0,0(sp)
    80006678:	0141                	addi	sp,sp,16
    8000667a:	8082                	ret

000000008000667c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000667c:	1101                	addi	sp,sp,-32
    8000667e:	ec06                	sd	ra,24(sp)
    80006680:	e822                	sd	s0,16(sp)
    80006682:	e426                	sd	s1,8(sp)
    80006684:	1000                	addi	s0,sp,32
    80006686:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006688:	ffffb097          	auipc	ra,0xffffb
    8000668c:	492080e7          	jalr	1170(ra) # 80001b1a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006690:	00d5151b          	slliw	a0,a0,0xd
    80006694:	0c2017b7          	lui	a5,0xc201
    80006698:	97aa                	add	a5,a5,a0
    8000669a:	c3c4                	sw	s1,4(a5)
}
    8000669c:	60e2                	ld	ra,24(sp)
    8000669e:	6442                	ld	s0,16(sp)
    800066a0:	64a2                	ld	s1,8(sp)
    800066a2:	6105                	addi	sp,sp,32
    800066a4:	8082                	ret

00000000800066a6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800066a6:	1141                	addi	sp,sp,-16
    800066a8:	e406                	sd	ra,8(sp)
    800066aa:	e022                	sd	s0,0(sp)
    800066ac:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800066ae:	479d                	li	a5,7
    800066b0:	04a7cc63          	blt	a5,a0,80006708 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800066b4:	0001f797          	auipc	a5,0x1f
    800066b8:	22c78793          	addi	a5,a5,556 # 800258e0 <disk>
    800066bc:	97aa                	add	a5,a5,a0
    800066be:	0187c783          	lbu	a5,24(a5)
    800066c2:	ebb9                	bnez	a5,80006718 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800066c4:	00451693          	slli	a3,a0,0x4
    800066c8:	0001f797          	auipc	a5,0x1f
    800066cc:	21878793          	addi	a5,a5,536 # 800258e0 <disk>
    800066d0:	6398                	ld	a4,0(a5)
    800066d2:	9736                	add	a4,a4,a3
    800066d4:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800066d8:	6398                	ld	a4,0(a5)
    800066da:	9736                	add	a4,a4,a3
    800066dc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800066e0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800066e4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800066e8:	97aa                	add	a5,a5,a0
    800066ea:	4705                	li	a4,1
    800066ec:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800066f0:	0001f517          	auipc	a0,0x1f
    800066f4:	20850513          	addi	a0,a0,520 # 800258f8 <disk+0x18>
    800066f8:	ffffc097          	auipc	ra,0xffffc
    800066fc:	c98080e7          	jalr	-872(ra) # 80002390 <wakeup>
}
    80006700:	60a2                	ld	ra,8(sp)
    80006702:	6402                	ld	s0,0(sp)
    80006704:	0141                	addi	sp,sp,16
    80006706:	8082                	ret
    panic("free_desc 1");
    80006708:	00002517          	auipc	a0,0x2
    8000670c:	0c050513          	addi	a0,a0,192 # 800087c8 <syscalls+0x318>
    80006710:	ffffa097          	auipc	ra,0xffffa
    80006714:	e30080e7          	jalr	-464(ra) # 80000540 <panic>
    panic("free_desc 2");
    80006718:	00002517          	auipc	a0,0x2
    8000671c:	0c050513          	addi	a0,a0,192 # 800087d8 <syscalls+0x328>
    80006720:	ffffa097          	auipc	ra,0xffffa
    80006724:	e20080e7          	jalr	-480(ra) # 80000540 <panic>

0000000080006728 <virtio_disk_init>:
{
    80006728:	1101                	addi	sp,sp,-32
    8000672a:	ec06                	sd	ra,24(sp)
    8000672c:	e822                	sd	s0,16(sp)
    8000672e:	e426                	sd	s1,8(sp)
    80006730:	e04a                	sd	s2,0(sp)
    80006732:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006734:	00002597          	auipc	a1,0x2
    80006738:	0b458593          	addi	a1,a1,180 # 800087e8 <syscalls+0x338>
    8000673c:	0001f517          	auipc	a0,0x1f
    80006740:	2cc50513          	addi	a0,a0,716 # 80025a08 <disk+0x128>
    80006744:	ffffa097          	auipc	ra,0xffffa
    80006748:	402080e7          	jalr	1026(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000674c:	100017b7          	lui	a5,0x10001
    80006750:	4398                	lw	a4,0(a5)
    80006752:	2701                	sext.w	a4,a4
    80006754:	747277b7          	lui	a5,0x74727
    80006758:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000675c:	14f71b63          	bne	a4,a5,800068b2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006760:	100017b7          	lui	a5,0x10001
    80006764:	43dc                	lw	a5,4(a5)
    80006766:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006768:	4709                	li	a4,2
    8000676a:	14e79463          	bne	a5,a4,800068b2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000676e:	100017b7          	lui	a5,0x10001
    80006772:	479c                	lw	a5,8(a5)
    80006774:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006776:	12e79e63          	bne	a5,a4,800068b2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000677a:	100017b7          	lui	a5,0x10001
    8000677e:	47d8                	lw	a4,12(a5)
    80006780:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006782:	554d47b7          	lui	a5,0x554d4
    80006786:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000678a:	12f71463          	bne	a4,a5,800068b2 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000678e:	100017b7          	lui	a5,0x10001
    80006792:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006796:	4705                	li	a4,1
    80006798:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000679a:	470d                	li	a4,3
    8000679c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000679e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800067a0:	c7ffe6b7          	lui	a3,0xc7ffe
    800067a4:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd8d3f>
    800067a8:	8f75                	and	a4,a4,a3
    800067aa:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800067ac:	472d                	li	a4,11
    800067ae:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800067b0:	5bbc                	lw	a5,112(a5)
    800067b2:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800067b6:	8ba1                	andi	a5,a5,8
    800067b8:	10078563          	beqz	a5,800068c2 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800067bc:	100017b7          	lui	a5,0x10001
    800067c0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800067c4:	43fc                	lw	a5,68(a5)
    800067c6:	2781                	sext.w	a5,a5
    800067c8:	10079563          	bnez	a5,800068d2 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800067cc:	100017b7          	lui	a5,0x10001
    800067d0:	5bdc                	lw	a5,52(a5)
    800067d2:	2781                	sext.w	a5,a5
  if(max == 0)
    800067d4:	10078763          	beqz	a5,800068e2 <virtio_disk_init+0x1ba>
  if(max < NUM)
    800067d8:	471d                	li	a4,7
    800067da:	10f77c63          	bgeu	a4,a5,800068f2 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    800067de:	ffffa097          	auipc	ra,0xffffa
    800067e2:	308080e7          	jalr	776(ra) # 80000ae6 <kalloc>
    800067e6:	0001f497          	auipc	s1,0x1f
    800067ea:	0fa48493          	addi	s1,s1,250 # 800258e0 <disk>
    800067ee:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800067f0:	ffffa097          	auipc	ra,0xffffa
    800067f4:	2f6080e7          	jalr	758(ra) # 80000ae6 <kalloc>
    800067f8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800067fa:	ffffa097          	auipc	ra,0xffffa
    800067fe:	2ec080e7          	jalr	748(ra) # 80000ae6 <kalloc>
    80006802:	87aa                	mv	a5,a0
    80006804:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006806:	6088                	ld	a0,0(s1)
    80006808:	cd6d                	beqz	a0,80006902 <virtio_disk_init+0x1da>
    8000680a:	0001f717          	auipc	a4,0x1f
    8000680e:	0de73703          	ld	a4,222(a4) # 800258e8 <disk+0x8>
    80006812:	cb65                	beqz	a4,80006902 <virtio_disk_init+0x1da>
    80006814:	c7fd                	beqz	a5,80006902 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80006816:	6605                	lui	a2,0x1
    80006818:	4581                	li	a1,0
    8000681a:	ffffa097          	auipc	ra,0xffffa
    8000681e:	4b8080e7          	jalr	1208(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006822:	0001f497          	auipc	s1,0x1f
    80006826:	0be48493          	addi	s1,s1,190 # 800258e0 <disk>
    8000682a:	6605                	lui	a2,0x1
    8000682c:	4581                	li	a1,0
    8000682e:	6488                	ld	a0,8(s1)
    80006830:	ffffa097          	auipc	ra,0xffffa
    80006834:	4a2080e7          	jalr	1186(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    80006838:	6605                	lui	a2,0x1
    8000683a:	4581                	li	a1,0
    8000683c:	6888                	ld	a0,16(s1)
    8000683e:	ffffa097          	auipc	ra,0xffffa
    80006842:	494080e7          	jalr	1172(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006846:	100017b7          	lui	a5,0x10001
    8000684a:	4721                	li	a4,8
    8000684c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000684e:	4098                	lw	a4,0(s1)
    80006850:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006854:	40d8                	lw	a4,4(s1)
    80006856:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000685a:	6498                	ld	a4,8(s1)
    8000685c:	0007069b          	sext.w	a3,a4
    80006860:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006864:	9701                	srai	a4,a4,0x20
    80006866:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000686a:	6898                	ld	a4,16(s1)
    8000686c:	0007069b          	sext.w	a3,a4
    80006870:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006874:	9701                	srai	a4,a4,0x20
    80006876:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000687a:	4705                	li	a4,1
    8000687c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000687e:	00e48c23          	sb	a4,24(s1)
    80006882:	00e48ca3          	sb	a4,25(s1)
    80006886:	00e48d23          	sb	a4,26(s1)
    8000688a:	00e48da3          	sb	a4,27(s1)
    8000688e:	00e48e23          	sb	a4,28(s1)
    80006892:	00e48ea3          	sb	a4,29(s1)
    80006896:	00e48f23          	sb	a4,30(s1)
    8000689a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000689e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800068a2:	0727a823          	sw	s2,112(a5)
}
    800068a6:	60e2                	ld	ra,24(sp)
    800068a8:	6442                	ld	s0,16(sp)
    800068aa:	64a2                	ld	s1,8(sp)
    800068ac:	6902                	ld	s2,0(sp)
    800068ae:	6105                	addi	sp,sp,32
    800068b0:	8082                	ret
    panic("could not find virtio disk");
    800068b2:	00002517          	auipc	a0,0x2
    800068b6:	f4650513          	addi	a0,a0,-186 # 800087f8 <syscalls+0x348>
    800068ba:	ffffa097          	auipc	ra,0xffffa
    800068be:	c86080e7          	jalr	-890(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    800068c2:	00002517          	auipc	a0,0x2
    800068c6:	f5650513          	addi	a0,a0,-170 # 80008818 <syscalls+0x368>
    800068ca:	ffffa097          	auipc	ra,0xffffa
    800068ce:	c76080e7          	jalr	-906(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    800068d2:	00002517          	auipc	a0,0x2
    800068d6:	f6650513          	addi	a0,a0,-154 # 80008838 <syscalls+0x388>
    800068da:	ffffa097          	auipc	ra,0xffffa
    800068de:	c66080e7          	jalr	-922(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    800068e2:	00002517          	auipc	a0,0x2
    800068e6:	f7650513          	addi	a0,a0,-138 # 80008858 <syscalls+0x3a8>
    800068ea:	ffffa097          	auipc	ra,0xffffa
    800068ee:	c56080e7          	jalr	-938(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    800068f2:	00002517          	auipc	a0,0x2
    800068f6:	f8650513          	addi	a0,a0,-122 # 80008878 <syscalls+0x3c8>
    800068fa:	ffffa097          	auipc	ra,0xffffa
    800068fe:	c46080e7          	jalr	-954(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    80006902:	00002517          	auipc	a0,0x2
    80006906:	f9650513          	addi	a0,a0,-106 # 80008898 <syscalls+0x3e8>
    8000690a:	ffffa097          	auipc	ra,0xffffa
    8000690e:	c36080e7          	jalr	-970(ra) # 80000540 <panic>

0000000080006912 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006912:	7119                	addi	sp,sp,-128
    80006914:	fc86                	sd	ra,120(sp)
    80006916:	f8a2                	sd	s0,112(sp)
    80006918:	f4a6                	sd	s1,104(sp)
    8000691a:	f0ca                	sd	s2,96(sp)
    8000691c:	ecce                	sd	s3,88(sp)
    8000691e:	e8d2                	sd	s4,80(sp)
    80006920:	e4d6                	sd	s5,72(sp)
    80006922:	e0da                	sd	s6,64(sp)
    80006924:	fc5e                	sd	s7,56(sp)
    80006926:	f862                	sd	s8,48(sp)
    80006928:	f466                	sd	s9,40(sp)
    8000692a:	f06a                	sd	s10,32(sp)
    8000692c:	ec6e                	sd	s11,24(sp)
    8000692e:	0100                	addi	s0,sp,128
    80006930:	8aaa                	mv	s5,a0
    80006932:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006934:	00c52d03          	lw	s10,12(a0)
    80006938:	001d1d1b          	slliw	s10,s10,0x1
    8000693c:	1d02                	slli	s10,s10,0x20
    8000693e:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006942:	0001f517          	auipc	a0,0x1f
    80006946:	0c650513          	addi	a0,a0,198 # 80025a08 <disk+0x128>
    8000694a:	ffffa097          	auipc	ra,0xffffa
    8000694e:	28c080e7          	jalr	652(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80006952:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006954:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006956:	0001fb97          	auipc	s7,0x1f
    8000695a:	f8ab8b93          	addi	s7,s7,-118 # 800258e0 <disk>
  for(int i = 0; i < 3; i++){
    8000695e:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006960:	0001fc97          	auipc	s9,0x1f
    80006964:	0a8c8c93          	addi	s9,s9,168 # 80025a08 <disk+0x128>
    80006968:	a08d                	j	800069ca <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000696a:	00fb8733          	add	a4,s7,a5
    8000696e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006972:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006974:	0207c563          	bltz	a5,8000699e <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    80006978:	2905                	addiw	s2,s2,1
    8000697a:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    8000697c:	05690c63          	beq	s2,s6,800069d4 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006980:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006982:	0001f717          	auipc	a4,0x1f
    80006986:	f5e70713          	addi	a4,a4,-162 # 800258e0 <disk>
    8000698a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000698c:	01874683          	lbu	a3,24(a4)
    80006990:	fee9                	bnez	a3,8000696a <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006992:	2785                	addiw	a5,a5,1
    80006994:	0705                	addi	a4,a4,1
    80006996:	fe979be3          	bne	a5,s1,8000698c <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000699a:	57fd                	li	a5,-1
    8000699c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000699e:	01205d63          	blez	s2,800069b8 <virtio_disk_rw+0xa6>
    800069a2:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800069a4:	000a2503          	lw	a0,0(s4)
    800069a8:	00000097          	auipc	ra,0x0
    800069ac:	cfe080e7          	jalr	-770(ra) # 800066a6 <free_desc>
      for(int j = 0; j < i; j++)
    800069b0:	2d85                	addiw	s11,s11,1
    800069b2:	0a11                	addi	s4,s4,4
    800069b4:	ff2d98e3          	bne	s11,s2,800069a4 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800069b8:	85e6                	mv	a1,s9
    800069ba:	0001f517          	auipc	a0,0x1f
    800069be:	f3e50513          	addi	a0,a0,-194 # 800258f8 <disk+0x18>
    800069c2:	ffffc097          	auipc	ra,0xffffc
    800069c6:	95a080e7          	jalr	-1702(ra) # 8000231c <sleep>
  for(int i = 0; i < 3; i++){
    800069ca:	f8040a13          	addi	s4,s0,-128
{
    800069ce:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800069d0:	894e                	mv	s2,s3
    800069d2:	b77d                	j	80006980 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800069d4:	f8042503          	lw	a0,-128(s0)
    800069d8:	00a50713          	addi	a4,a0,10
    800069dc:	0712                	slli	a4,a4,0x4

  if(write)
    800069de:	0001f797          	auipc	a5,0x1f
    800069e2:	f0278793          	addi	a5,a5,-254 # 800258e0 <disk>
    800069e6:	00e786b3          	add	a3,a5,a4
    800069ea:	01803633          	snez	a2,s8
    800069ee:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800069f0:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800069f4:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800069f8:	f6070613          	addi	a2,a4,-160
    800069fc:	6394                	ld	a3,0(a5)
    800069fe:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006a00:	00870593          	addi	a1,a4,8
    80006a04:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006a06:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006a08:	0007b803          	ld	a6,0(a5)
    80006a0c:	9642                	add	a2,a2,a6
    80006a0e:	46c1                	li	a3,16
    80006a10:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006a12:	4585                	li	a1,1
    80006a14:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006a18:	f8442683          	lw	a3,-124(s0)
    80006a1c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006a20:	0692                	slli	a3,a3,0x4
    80006a22:	9836                	add	a6,a6,a3
    80006a24:	058a8613          	addi	a2,s5,88
    80006a28:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80006a2c:	0007b803          	ld	a6,0(a5)
    80006a30:	96c2                	add	a3,a3,a6
    80006a32:	40000613          	li	a2,1024
    80006a36:	c690                	sw	a2,8(a3)
  if(write)
    80006a38:	001c3613          	seqz	a2,s8
    80006a3c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006a40:	00166613          	ori	a2,a2,1
    80006a44:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006a48:	f8842603          	lw	a2,-120(s0)
    80006a4c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006a50:	00250693          	addi	a3,a0,2
    80006a54:	0692                	slli	a3,a3,0x4
    80006a56:	96be                	add	a3,a3,a5
    80006a58:	58fd                	li	a7,-1
    80006a5a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006a5e:	0612                	slli	a2,a2,0x4
    80006a60:	9832                	add	a6,a6,a2
    80006a62:	f9070713          	addi	a4,a4,-112
    80006a66:	973e                	add	a4,a4,a5
    80006a68:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80006a6c:	6398                	ld	a4,0(a5)
    80006a6e:	9732                	add	a4,a4,a2
    80006a70:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006a72:	4609                	li	a2,2
    80006a74:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006a78:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006a7c:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006a80:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006a84:	6794                	ld	a3,8(a5)
    80006a86:	0026d703          	lhu	a4,2(a3)
    80006a8a:	8b1d                	andi	a4,a4,7
    80006a8c:	0706                	slli	a4,a4,0x1
    80006a8e:	96ba                	add	a3,a3,a4
    80006a90:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006a94:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006a98:	6798                	ld	a4,8(a5)
    80006a9a:	00275783          	lhu	a5,2(a4)
    80006a9e:	2785                	addiw	a5,a5,1
    80006aa0:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006aa4:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006aa8:	100017b7          	lui	a5,0x10001
    80006aac:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006ab0:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80006ab4:	0001f917          	auipc	s2,0x1f
    80006ab8:	f5490913          	addi	s2,s2,-172 # 80025a08 <disk+0x128>
  while(b->disk == 1) {
    80006abc:	4485                	li	s1,1
    80006abe:	00b79c63          	bne	a5,a1,80006ad6 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006ac2:	85ca                	mv	a1,s2
    80006ac4:	8556                	mv	a0,s5
    80006ac6:	ffffc097          	auipc	ra,0xffffc
    80006aca:	856080e7          	jalr	-1962(ra) # 8000231c <sleep>
  while(b->disk == 1) {
    80006ace:	004aa783          	lw	a5,4(s5)
    80006ad2:	fe9788e3          	beq	a5,s1,80006ac2 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006ad6:	f8042903          	lw	s2,-128(s0)
    80006ada:	00290713          	addi	a4,s2,2
    80006ade:	0712                	slli	a4,a4,0x4
    80006ae0:	0001f797          	auipc	a5,0x1f
    80006ae4:	e0078793          	addi	a5,a5,-512 # 800258e0 <disk>
    80006ae8:	97ba                	add	a5,a5,a4
    80006aea:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006aee:	0001f997          	auipc	s3,0x1f
    80006af2:	df298993          	addi	s3,s3,-526 # 800258e0 <disk>
    80006af6:	00491713          	slli	a4,s2,0x4
    80006afa:	0009b783          	ld	a5,0(s3)
    80006afe:	97ba                	add	a5,a5,a4
    80006b00:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006b04:	854a                	mv	a0,s2
    80006b06:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006b0a:	00000097          	auipc	ra,0x0
    80006b0e:	b9c080e7          	jalr	-1124(ra) # 800066a6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006b12:	8885                	andi	s1,s1,1
    80006b14:	f0ed                	bnez	s1,80006af6 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006b16:	0001f517          	auipc	a0,0x1f
    80006b1a:	ef250513          	addi	a0,a0,-270 # 80025a08 <disk+0x128>
    80006b1e:	ffffa097          	auipc	ra,0xffffa
    80006b22:	16c080e7          	jalr	364(ra) # 80000c8a <release>
}
    80006b26:	70e6                	ld	ra,120(sp)
    80006b28:	7446                	ld	s0,112(sp)
    80006b2a:	74a6                	ld	s1,104(sp)
    80006b2c:	7906                	ld	s2,96(sp)
    80006b2e:	69e6                	ld	s3,88(sp)
    80006b30:	6a46                	ld	s4,80(sp)
    80006b32:	6aa6                	ld	s5,72(sp)
    80006b34:	6b06                	ld	s6,64(sp)
    80006b36:	7be2                	ld	s7,56(sp)
    80006b38:	7c42                	ld	s8,48(sp)
    80006b3a:	7ca2                	ld	s9,40(sp)
    80006b3c:	7d02                	ld	s10,32(sp)
    80006b3e:	6de2                	ld	s11,24(sp)
    80006b40:	6109                	addi	sp,sp,128
    80006b42:	8082                	ret

0000000080006b44 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006b44:	1101                	addi	sp,sp,-32
    80006b46:	ec06                	sd	ra,24(sp)
    80006b48:	e822                	sd	s0,16(sp)
    80006b4a:	e426                	sd	s1,8(sp)
    80006b4c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006b4e:	0001f497          	auipc	s1,0x1f
    80006b52:	d9248493          	addi	s1,s1,-622 # 800258e0 <disk>
    80006b56:	0001f517          	auipc	a0,0x1f
    80006b5a:	eb250513          	addi	a0,a0,-334 # 80025a08 <disk+0x128>
    80006b5e:	ffffa097          	auipc	ra,0xffffa
    80006b62:	078080e7          	jalr	120(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006b66:	10001737          	lui	a4,0x10001
    80006b6a:	533c                	lw	a5,96(a4)
    80006b6c:	8b8d                	andi	a5,a5,3
    80006b6e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006b70:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006b74:	689c                	ld	a5,16(s1)
    80006b76:	0204d703          	lhu	a4,32(s1)
    80006b7a:	0027d783          	lhu	a5,2(a5)
    80006b7e:	04f70863          	beq	a4,a5,80006bce <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006b82:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006b86:	6898                	ld	a4,16(s1)
    80006b88:	0204d783          	lhu	a5,32(s1)
    80006b8c:	8b9d                	andi	a5,a5,7
    80006b8e:	078e                	slli	a5,a5,0x3
    80006b90:	97ba                	add	a5,a5,a4
    80006b92:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006b94:	00278713          	addi	a4,a5,2
    80006b98:	0712                	slli	a4,a4,0x4
    80006b9a:	9726                	add	a4,a4,s1
    80006b9c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006ba0:	e721                	bnez	a4,80006be8 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006ba2:	0789                	addi	a5,a5,2
    80006ba4:	0792                	slli	a5,a5,0x4
    80006ba6:	97a6                	add	a5,a5,s1
    80006ba8:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006baa:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006bae:	ffffb097          	auipc	ra,0xffffb
    80006bb2:	7e2080e7          	jalr	2018(ra) # 80002390 <wakeup>

    disk.used_idx += 1;
    80006bb6:	0204d783          	lhu	a5,32(s1)
    80006bba:	2785                	addiw	a5,a5,1
    80006bbc:	17c2                	slli	a5,a5,0x30
    80006bbe:	93c1                	srli	a5,a5,0x30
    80006bc0:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006bc4:	6898                	ld	a4,16(s1)
    80006bc6:	00275703          	lhu	a4,2(a4)
    80006bca:	faf71ce3          	bne	a4,a5,80006b82 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006bce:	0001f517          	auipc	a0,0x1f
    80006bd2:	e3a50513          	addi	a0,a0,-454 # 80025a08 <disk+0x128>
    80006bd6:	ffffa097          	auipc	ra,0xffffa
    80006bda:	0b4080e7          	jalr	180(ra) # 80000c8a <release>
}
    80006bde:	60e2                	ld	ra,24(sp)
    80006be0:	6442                	ld	s0,16(sp)
    80006be2:	64a2                	ld	s1,8(sp)
    80006be4:	6105                	addi	sp,sp,32
    80006be6:	8082                	ret
      panic("virtio_disk_intr status");
    80006be8:	00002517          	auipc	a0,0x2
    80006bec:	cc850513          	addi	a0,a0,-824 # 800088b0 <syscalls+0x400>
    80006bf0:	ffffa097          	auipc	ra,0xffffa
    80006bf4:	950080e7          	jalr	-1712(ra) # 80000540 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
