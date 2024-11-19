
user/_alarmtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <periodic>:
}

volatile static int count;

void periodic()
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    count = count + 1;
   8:	00001797          	auipc	a5,0x1
   c:	ff87a783          	lw	a5,-8(a5) # 1000 <count>
  10:	2785                	addiw	a5,a5,1
  12:	00001717          	auipc	a4,0x1
  16:	fef72723          	sw	a5,-18(a4) # 1000 <count>
    printf("alarm!\n");
  1a:	00001517          	auipc	a0,0x1
  1e:	ce650513          	addi	a0,a0,-794 # d00 <malloc+0xf4>
  22:	00001097          	auipc	ra,0x1
  26:	b32080e7          	jalr	-1230(ra) # b54 <printf>
    sigreturn();
  2a:	00001097          	auipc	ra,0x1
  2e:	840080e7          	jalr	-1984(ra) # 86a <sigreturn>
}
  32:	60a2                	ld	ra,8(sp)
  34:	6402                	ld	s0,0(sp)
  36:	0141                	addi	sp,sp,16
  38:	8082                	ret

000000000000003a <alarm_handler>:
    else
        printf("test3 passed\n");
}

void alarm_handler()
{
  3a:	1141                	addi	sp,sp,-16
  3c:	e406                	sd	ra,8(sp)
  3e:	e022                	sd	s0,0(sp)
  40:	0800                	addi	s0,sp,16
  count++;
  42:	00001717          	auipc	a4,0x1
  46:	fbe70713          	addi	a4,a4,-66 # 1000 <count>
  4a:	00001797          	auipc	a5,0x1
  4e:	fb67a783          	lw	a5,-74(a5) # 1000 <count>
  52:	2785                	addiw	a5,a5,1
  54:	c31c                	sw	a5,0(a4)
  printf("Alarm fired! Count: %d\n", count);
  56:	430c                	lw	a1,0(a4)
  58:	00001517          	auipc	a0,0x1
  5c:	cb050513          	addi	a0,a0,-848 # d08 <malloc+0xfc>
  60:	00001097          	auipc	ra,0x1
  64:	af4080e7          	jalr	-1292(ra) # b54 <printf>
  sigreturn();
  68:	00001097          	auipc	ra,0x1
  6c:	802080e7          	jalr	-2046(ra) # 86a <sigreturn>
}
  70:	60a2                	ld	ra,8(sp)
  72:	6402                	ld	s0,0(sp)
  74:	0141                	addi	sp,sp,16
  76:	8082                	ret

0000000000000078 <slow_handler>:
{
  78:	1101                	addi	sp,sp,-32
  7a:	ec06                	sd	ra,24(sp)
  7c:	e822                	sd	s0,16(sp)
  7e:	e426                	sd	s1,8(sp)
  80:	1000                	addi	s0,sp,32
    count++;
  82:	00001497          	auipc	s1,0x1
  86:	f7e48493          	addi	s1,s1,-130 # 1000 <count>
  8a:	00001797          	auipc	a5,0x1
  8e:	f767a783          	lw	a5,-138(a5) # 1000 <count>
  92:	2785                	addiw	a5,a5,1
  94:	c09c                	sw	a5,0(s1)
    printf("alarm!\n");
  96:	00001517          	auipc	a0,0x1
  9a:	c6a50513          	addi	a0,a0,-918 # d00 <malloc+0xf4>
  9e:	00001097          	auipc	ra,0x1
  a2:	ab6080e7          	jalr	-1354(ra) # b54 <printf>
    if (count > 1)
  a6:	4098                	lw	a4,0(s1)
  a8:	2701                	sext.w	a4,a4
  aa:	4685                	li	a3,1
  ac:	1dcd67b7          	lui	a5,0x1dcd6
  b0:	50078793          	addi	a5,a5,1280 # 1dcd6500 <base+0x1dcd54f0>
  b4:	02e6c463          	blt	a3,a4,dc <slow_handler+0x64>
        asm volatile("nop"); // avoid compiler optimizing away loop
  b8:	0001                	nop
    for (int i = 0; i < 1000 * 500000; i++)
  ba:	37fd                	addiw	a5,a5,-1
  bc:	fff5                	bnez	a5,b8 <slow_handler+0x40>
    sigalarm(0, 0);
  be:	4581                	li	a1,0
  c0:	4501                	li	a0,0
  c2:	00000097          	auipc	ra,0x0
  c6:	7a0080e7          	jalr	1952(ra) # 862 <sigalarm>
    sigreturn();
  ca:	00000097          	auipc	ra,0x0
  ce:	7a0080e7          	jalr	1952(ra) # 86a <sigreturn>
}
  d2:	60e2                	ld	ra,24(sp)
  d4:	6442                	ld	s0,16(sp)
  d6:	64a2                	ld	s1,8(sp)
  d8:	6105                	addi	sp,sp,32
  da:	8082                	ret
        printf("test2 failed: alarm handler called more than once\n");
  dc:	00001517          	auipc	a0,0x1
  e0:	c4450513          	addi	a0,a0,-956 # d20 <malloc+0x114>
  e4:	00001097          	auipc	ra,0x1
  e8:	a70080e7          	jalr	-1424(ra) # b54 <printf>
        exit(1);
  ec:	4505                	li	a0,1
  ee:	00000097          	auipc	ra,0x0
  f2:	6c4080e7          	jalr	1732(ra) # 7b2 <exit>

00000000000000f6 <dummy_handler>:
{
  f6:	1141                	addi	sp,sp,-16
  f8:	e406                	sd	ra,8(sp)
  fa:	e022                	sd	s0,0(sp)
  fc:	0800                	addi	s0,sp,16
    sigalarm(0, 0);
  fe:	4581                	li	a1,0
 100:	4501                	li	a0,0
 102:	00000097          	auipc	ra,0x0
 106:	760080e7          	jalr	1888(ra) # 862 <sigalarm>
    sigreturn();
 10a:	00000097          	auipc	ra,0x0
 10e:	760080e7          	jalr	1888(ra) # 86a <sigreturn>
}
 112:	60a2                	ld	ra,8(sp)
 114:	6402                	ld	s0,0(sp)
 116:	0141                	addi	sp,sp,16
 118:	8082                	ret

000000000000011a <test0>:
{
 11a:	7139                	addi	sp,sp,-64
 11c:	fc06                	sd	ra,56(sp)
 11e:	f822                	sd	s0,48(sp)
 120:	f426                	sd	s1,40(sp)
 122:	f04a                	sd	s2,32(sp)
 124:	ec4e                	sd	s3,24(sp)
 126:	e852                	sd	s4,16(sp)
 128:	e456                	sd	s5,8(sp)
 12a:	0080                	addi	s0,sp,64
    printf("test0 start\n");
 12c:	00001517          	auipc	a0,0x1
 130:	c2c50513          	addi	a0,a0,-980 # d58 <malloc+0x14c>
 134:	00001097          	auipc	ra,0x1
 138:	a20080e7          	jalr	-1504(ra) # b54 <printf>
    count = 0;
 13c:	00001797          	auipc	a5,0x1
 140:	ec07a223          	sw	zero,-316(a5) # 1000 <count>
    sigalarm(2, periodic);
 144:	00000597          	auipc	a1,0x0
 148:	ebc58593          	addi	a1,a1,-324 # 0 <periodic>
 14c:	4509                	li	a0,2
 14e:	00000097          	auipc	ra,0x0
 152:	714080e7          	jalr	1812(ra) # 862 <sigalarm>
    for (i = 0; i < 1000 * 500000; i++)
 156:	4481                	li	s1,0
        if ((i % 1000000) == 0)
 158:	000f4937          	lui	s2,0xf4
 15c:	2409091b          	addiw	s2,s2,576 # f4240 <base+0xf3230>
            write(2, ".", 1);
 160:	00001a97          	auipc	s5,0x1
 164:	c08a8a93          	addi	s5,s5,-1016 # d68 <malloc+0x15c>
        if (count > 0)
 168:	00001a17          	auipc	s4,0x1
 16c:	e98a0a13          	addi	s4,s4,-360 # 1000 <count>
    for (i = 0; i < 1000 * 500000; i++)
 170:	1dcd69b7          	lui	s3,0x1dcd6
 174:	50098993          	addi	s3,s3,1280 # 1dcd6500 <base+0x1dcd54f0>
 178:	a809                	j	18a <test0+0x70>
        if (count > 0)
 17a:	000a2783          	lw	a5,0(s4)
 17e:	2781                	sext.w	a5,a5
 180:	02f04063          	bgtz	a5,1a0 <test0+0x86>
    for (i = 0; i < 1000 * 500000; i++)
 184:	2485                	addiw	s1,s1,1
 186:	01348d63          	beq	s1,s3,1a0 <test0+0x86>
        if ((i % 1000000) == 0)
 18a:	0324e7bb          	remw	a5,s1,s2
 18e:	f7f5                	bnez	a5,17a <test0+0x60>
            write(2, ".", 1);
 190:	4605                	li	a2,1
 192:	85d6                	mv	a1,s5
 194:	4509                	li	a0,2
 196:	00000097          	auipc	ra,0x0
 19a:	63c080e7          	jalr	1596(ra) # 7d2 <write>
 19e:	bff1                	j	17a <test0+0x60>
    sigalarm(0, 0);
 1a0:	4581                	li	a1,0
 1a2:	4501                	li	a0,0
 1a4:	00000097          	auipc	ra,0x0
 1a8:	6be080e7          	jalr	1726(ra) # 862 <sigalarm>
    if (count > 0)
 1ac:	00001797          	auipc	a5,0x1
 1b0:	e547a783          	lw	a5,-428(a5) # 1000 <count>
 1b4:	02f05363          	blez	a5,1da <test0+0xc0>
        printf("test0 passed\n");
 1b8:	00001517          	auipc	a0,0x1
 1bc:	bb850513          	addi	a0,a0,-1096 # d70 <malloc+0x164>
 1c0:	00001097          	auipc	ra,0x1
 1c4:	994080e7          	jalr	-1644(ra) # b54 <printf>
}
 1c8:	70e2                	ld	ra,56(sp)
 1ca:	7442                	ld	s0,48(sp)
 1cc:	74a2                	ld	s1,40(sp)
 1ce:	7902                	ld	s2,32(sp)
 1d0:	69e2                	ld	s3,24(sp)
 1d2:	6a42                	ld	s4,16(sp)
 1d4:	6aa2                	ld	s5,8(sp)
 1d6:	6121                	addi	sp,sp,64
 1d8:	8082                	ret
        printf("\ntest0 failed: the kernel never called the alarm handler\n");
 1da:	00001517          	auipc	a0,0x1
 1de:	ba650513          	addi	a0,a0,-1114 # d80 <malloc+0x174>
 1e2:	00001097          	auipc	ra,0x1
 1e6:	972080e7          	jalr	-1678(ra) # b54 <printf>
}
 1ea:	bff9                	j	1c8 <test0+0xae>

00000000000001ec <foo>:
{
 1ec:	1101                	addi	sp,sp,-32
 1ee:	ec06                	sd	ra,24(sp)
 1f0:	e822                	sd	s0,16(sp)
 1f2:	e426                	sd	s1,8(sp)
 1f4:	1000                	addi	s0,sp,32
 1f6:	84ae                	mv	s1,a1
    if ((i % 2500000) == 0)
 1f8:	002627b7          	lui	a5,0x262
 1fc:	5a07879b          	addiw	a5,a5,1440 # 2625a0 <base+0x261590>
 200:	02f5653b          	remw	a0,a0,a5
 204:	c909                	beqz	a0,216 <foo+0x2a>
    *j += 1;
 206:	409c                	lw	a5,0(s1)
 208:	2785                	addiw	a5,a5,1
 20a:	c09c                	sw	a5,0(s1)
}
 20c:	60e2                	ld	ra,24(sp)
 20e:	6442                	ld	s0,16(sp)
 210:	64a2                	ld	s1,8(sp)
 212:	6105                	addi	sp,sp,32
 214:	8082                	ret
        write(2, ".", 1);
 216:	4605                	li	a2,1
 218:	00001597          	auipc	a1,0x1
 21c:	b5058593          	addi	a1,a1,-1200 # d68 <malloc+0x15c>
 220:	4509                	li	a0,2
 222:	00000097          	auipc	ra,0x0
 226:	5b0080e7          	jalr	1456(ra) # 7d2 <write>
 22a:	bff1                	j	206 <foo+0x1a>

000000000000022c <test1>:
{
 22c:	7139                	addi	sp,sp,-64
 22e:	fc06                	sd	ra,56(sp)
 230:	f822                	sd	s0,48(sp)
 232:	f426                	sd	s1,40(sp)
 234:	f04a                	sd	s2,32(sp)
 236:	ec4e                	sd	s3,24(sp)
 238:	e852                	sd	s4,16(sp)
 23a:	0080                	addi	s0,sp,64
    printf("test1 start\n");
 23c:	00001517          	auipc	a0,0x1
 240:	b8450513          	addi	a0,a0,-1148 # dc0 <malloc+0x1b4>
 244:	00001097          	auipc	ra,0x1
 248:	910080e7          	jalr	-1776(ra) # b54 <printf>
    count = 0;
 24c:	00001797          	auipc	a5,0x1
 250:	da07aa23          	sw	zero,-588(a5) # 1000 <count>
    j = 0;
 254:	fc042623          	sw	zero,-52(s0)
    sigalarm(2, periodic);
 258:	00000597          	auipc	a1,0x0
 25c:	da858593          	addi	a1,a1,-600 # 0 <periodic>
 260:	4509                	li	a0,2
 262:	00000097          	auipc	ra,0x0
 266:	600080e7          	jalr	1536(ra) # 862 <sigalarm>
    for (i = 0; i < 500000000; i++)
 26a:	4481                	li	s1,0
        if (count >= 10)
 26c:	00001a17          	auipc	s4,0x1
 270:	d94a0a13          	addi	s4,s4,-620 # 1000 <count>
 274:	49a5                	li	s3,9
    for (i = 0; i < 500000000; i++)
 276:	1dcd6937          	lui	s2,0x1dcd6
 27a:	50090913          	addi	s2,s2,1280 # 1dcd6500 <base+0x1dcd54f0>
        if (count >= 10)
 27e:	000a2783          	lw	a5,0(s4)
 282:	2781                	sext.w	a5,a5
 284:	00f9cc63          	blt	s3,a5,29c <test1+0x70>
        foo(i, &j);
 288:	fcc40593          	addi	a1,s0,-52
 28c:	8526                	mv	a0,s1
 28e:	00000097          	auipc	ra,0x0
 292:	f5e080e7          	jalr	-162(ra) # 1ec <foo>
    for (i = 0; i < 500000000; i++)
 296:	2485                	addiw	s1,s1,1
 298:	ff2493e3          	bne	s1,s2,27e <test1+0x52>
    if (count < 10)
 29c:	00001717          	auipc	a4,0x1
 2a0:	d6472703          	lw	a4,-668(a4) # 1000 <count>
 2a4:	47a5                	li	a5,9
 2a6:	02e7d663          	bge	a5,a4,2d2 <test1+0xa6>
    else if (i != j)
 2aa:	fcc42783          	lw	a5,-52(s0)
 2ae:	02978b63          	beq	a5,s1,2e4 <test1+0xb8>
        printf("\ntest1 failed: foo() executed fewer times than it was called\n");
 2b2:	00001517          	auipc	a0,0x1
 2b6:	b4e50513          	addi	a0,a0,-1202 # e00 <malloc+0x1f4>
 2ba:	00001097          	auipc	ra,0x1
 2be:	89a080e7          	jalr	-1894(ra) # b54 <printf>
}
 2c2:	70e2                	ld	ra,56(sp)
 2c4:	7442                	ld	s0,48(sp)
 2c6:	74a2                	ld	s1,40(sp)
 2c8:	7902                	ld	s2,32(sp)
 2ca:	69e2                	ld	s3,24(sp)
 2cc:	6a42                	ld	s4,16(sp)
 2ce:	6121                	addi	sp,sp,64
 2d0:	8082                	ret
        printf("\ntest1 failed: too few calls to the handler\n");
 2d2:	00001517          	auipc	a0,0x1
 2d6:	afe50513          	addi	a0,a0,-1282 # dd0 <malloc+0x1c4>
 2da:	00001097          	auipc	ra,0x1
 2de:	87a080e7          	jalr	-1926(ra) # b54 <printf>
 2e2:	b7c5                	j	2c2 <test1+0x96>
        printf("test1 passed\n");
 2e4:	00001517          	auipc	a0,0x1
 2e8:	b5c50513          	addi	a0,a0,-1188 # e40 <malloc+0x234>
 2ec:	00001097          	auipc	ra,0x1
 2f0:	868080e7          	jalr	-1944(ra) # b54 <printf>
}
 2f4:	b7f9                	j	2c2 <test1+0x96>

00000000000002f6 <test2>:
{
 2f6:	715d                	addi	sp,sp,-80
 2f8:	e486                	sd	ra,72(sp)
 2fa:	e0a2                	sd	s0,64(sp)
 2fc:	fc26                	sd	s1,56(sp)
 2fe:	f84a                	sd	s2,48(sp)
 300:	f44e                	sd	s3,40(sp)
 302:	f052                	sd	s4,32(sp)
 304:	ec56                	sd	s5,24(sp)
 306:	0880                	addi	s0,sp,80
    printf("test2 start\n");
 308:	00001517          	auipc	a0,0x1
 30c:	b4850513          	addi	a0,a0,-1208 # e50 <malloc+0x244>
 310:	00001097          	auipc	ra,0x1
 314:	844080e7          	jalr	-1980(ra) # b54 <printf>
    if ((pid = fork()) < 0)
 318:	00000097          	auipc	ra,0x0
 31c:	492080e7          	jalr	1170(ra) # 7aa <fork>
 320:	04054263          	bltz	a0,364 <test2+0x6e>
 324:	84aa                	mv	s1,a0
    if (pid == 0)
 326:	e539                	bnez	a0,374 <test2+0x7e>
        count = 0;
 328:	00001797          	auipc	a5,0x1
 32c:	cc07ac23          	sw	zero,-808(a5) # 1000 <count>
        sigalarm(2, slow_handler);
 330:	00000597          	auipc	a1,0x0
 334:	d4858593          	addi	a1,a1,-696 # 78 <slow_handler>
 338:	4509                	li	a0,2
 33a:	00000097          	auipc	ra,0x0
 33e:	528080e7          	jalr	1320(ra) # 862 <sigalarm>
            if ((i % 1000000) == 0)
 342:	000f4937          	lui	s2,0xf4
 346:	2409091b          	addiw	s2,s2,576 # f4240 <base+0xf3230>
                write(2, ".", 1);
 34a:	00001a97          	auipc	s5,0x1
 34e:	a1ea8a93          	addi	s5,s5,-1506 # d68 <malloc+0x15c>
            if (count > 0)
 352:	00001a17          	auipc	s4,0x1
 356:	caea0a13          	addi	s4,s4,-850 # 1000 <count>
        for (i = 0; i < 1000 * 500000; i++)
 35a:	1dcd69b7          	lui	s3,0x1dcd6
 35e:	50098993          	addi	s3,s3,1280 # 1dcd6500 <base+0x1dcd54f0>
 362:	a099                	j	3a8 <test2+0xb2>
        printf("test2: fork failed\n");
 364:	00001517          	auipc	a0,0x1
 368:	afc50513          	addi	a0,a0,-1284 # e60 <malloc+0x254>
 36c:	00000097          	auipc	ra,0x0
 370:	7e8080e7          	jalr	2024(ra) # b54 <printf>
    wait(&status);
 374:	fbc40513          	addi	a0,s0,-68
 378:	00000097          	auipc	ra,0x0
 37c:	442080e7          	jalr	1090(ra) # 7ba <wait>
    if (status == 0)
 380:	fbc42783          	lw	a5,-68(s0)
 384:	c7a5                	beqz	a5,3ec <test2+0xf6>
}
 386:	60a6                	ld	ra,72(sp)
 388:	6406                	ld	s0,64(sp)
 38a:	74e2                	ld	s1,56(sp)
 38c:	7942                	ld	s2,48(sp)
 38e:	79a2                	ld	s3,40(sp)
 390:	7a02                	ld	s4,32(sp)
 392:	6ae2                	ld	s5,24(sp)
 394:	6161                	addi	sp,sp,80
 396:	8082                	ret
            if (count > 0)
 398:	000a2783          	lw	a5,0(s4)
 39c:	2781                	sext.w	a5,a5
 39e:	02f04063          	bgtz	a5,3be <test2+0xc8>
        for (i = 0; i < 1000 * 500000; i++)
 3a2:	2485                	addiw	s1,s1,1
 3a4:	01348d63          	beq	s1,s3,3be <test2+0xc8>
            if ((i % 1000000) == 0)
 3a8:	0324e7bb          	remw	a5,s1,s2
 3ac:	f7f5                	bnez	a5,398 <test2+0xa2>
                write(2, ".", 1);
 3ae:	4605                	li	a2,1
 3b0:	85d6                	mv	a1,s5
 3b2:	4509                	li	a0,2
 3b4:	00000097          	auipc	ra,0x0
 3b8:	41e080e7          	jalr	1054(ra) # 7d2 <write>
 3bc:	bff1                	j	398 <test2+0xa2>
        if (count == 0)
 3be:	00001797          	auipc	a5,0x1
 3c2:	c427a783          	lw	a5,-958(a5) # 1000 <count>
 3c6:	ef91                	bnez	a5,3e2 <test2+0xec>
            printf("\ntest2 failed: alarm not called\n");
 3c8:	00001517          	auipc	a0,0x1
 3cc:	ab050513          	addi	a0,a0,-1360 # e78 <malloc+0x26c>
 3d0:	00000097          	auipc	ra,0x0
 3d4:	784080e7          	jalr	1924(ra) # b54 <printf>
            exit(1);
 3d8:	4505                	li	a0,1
 3da:	00000097          	auipc	ra,0x0
 3de:	3d8080e7          	jalr	984(ra) # 7b2 <exit>
        exit(0);
 3e2:	4501                	li	a0,0
 3e4:	00000097          	auipc	ra,0x0
 3e8:	3ce080e7          	jalr	974(ra) # 7b2 <exit>
        printf("test2 passed\n");
 3ec:	00001517          	auipc	a0,0x1
 3f0:	ab450513          	addi	a0,a0,-1356 # ea0 <malloc+0x294>
 3f4:	00000097          	auipc	ra,0x0
 3f8:	760080e7          	jalr	1888(ra) # b54 <printf>
}
 3fc:	b769                	j	386 <test2+0x90>

00000000000003fe <test3>:
{
 3fe:	1141                	addi	sp,sp,-16
 400:	e406                	sd	ra,8(sp)
 402:	e022                	sd	s0,0(sp)
 404:	0800                	addi	s0,sp,16
    sigalarm(1, dummy_handler);
 406:	00000597          	auipc	a1,0x0
 40a:	cf058593          	addi	a1,a1,-784 # f6 <dummy_handler>
 40e:	4505                	li	a0,1
 410:	00000097          	auipc	ra,0x0
 414:	452080e7          	jalr	1106(ra) # 862 <sigalarm>
    printf("test3 start\n");
 418:	00001517          	auipc	a0,0x1
 41c:	a9850513          	addi	a0,a0,-1384 # eb0 <malloc+0x2a4>
 420:	00000097          	auipc	ra,0x0
 424:	734080e7          	jalr	1844(ra) # b54 <printf>
    asm volatile("lui a5, 0");
 428:	000007b7          	lui	a5,0x0
    asm volatile("addi a0, a5, 0xac" : : : "a0");
 42c:	0ac78513          	addi	a0,a5,172 # ac <slow_handler+0x34>
 430:	1dcd67b7          	lui	a5,0x1dcd6
 434:	50078793          	addi	a5,a5,1280 # 1dcd6500 <base+0x1dcd54f0>
    for (int i = 0; i < 500000000; i++)
 438:	37fd                	addiw	a5,a5,-1
 43a:	fffd                	bnez	a5,438 <test3+0x3a>
    asm volatile("mv %0, a0" : "=r"(a0));
 43c:	872a                	mv	a4,a0
    if (a0 != 0xac)
 43e:	0ac00793          	li	a5,172
 442:	00f70e63          	beq	a4,a5,45e <test3+0x60>
        printf("test3 failed: register a0 changed\n");
 446:	00001517          	auipc	a0,0x1
 44a:	a7a50513          	addi	a0,a0,-1414 # ec0 <malloc+0x2b4>
 44e:	00000097          	auipc	ra,0x0
 452:	706080e7          	jalr	1798(ra) # b54 <printf>
}
 456:	60a2                	ld	ra,8(sp)
 458:	6402                	ld	s0,0(sp)
 45a:	0141                	addi	sp,sp,16
 45c:	8082                	ret
        printf("test3 passed\n");
 45e:	00001517          	auipc	a0,0x1
 462:	a8a50513          	addi	a0,a0,-1398 # ee8 <malloc+0x2dc>
 466:	00000097          	auipc	ra,0x0
 46a:	6ee080e7          	jalr	1774(ra) # b54 <printf>
}
 46e:	b7e5                	j	456 <test3+0x58>

0000000000000470 <test4>:

void test4()
{
 470:	7179                	addi	sp,sp,-48
 472:	f406                	sd	ra,40(sp)
 474:	f022                	sd	s0,32(sp)
 476:	ec26                	sd	s1,24(sp)
 478:	e84a                	sd	s2,16(sp)
 47a:	e44e                	sd	s3,8(sp)
 47c:	e052                	sd	s4,0(sp)
 47e:	1800                	addi	s0,sp,48
  printf("Setting alarm for every 2 ticks\n");
 480:	00001517          	auipc	a0,0x1
 484:	a7850513          	addi	a0,a0,-1416 # ef8 <malloc+0x2ec>
 488:	00000097          	auipc	ra,0x0
 48c:	6cc080e7          	jalr	1740(ra) # b54 <printf>
  sigalarm(2, alarm_handler);  // Set an alarm that triggers every 2 ticks
 490:	00000597          	auipc	a1,0x0
 494:	baa58593          	addi	a1,a1,-1110 # 3a <alarm_handler>
 498:	4509                	li	a0,2
 49a:	00000097          	auipc	ra,0x0
 49e:	3c8080e7          	jalr	968(ra) # 862 <sigalarm>

  int i;
  for (i = 0; i < 100000000; i++) {
 4a2:	4481                	li	s1,0
    if ((i % 10000000) == 0) {
 4a4:	009899b7          	lui	s3,0x989
 4a8:	6809899b          	addiw	s3,s3,1664 # 989680 <base+0x988670>
      printf(".");
 4ac:	00001a17          	auipc	s4,0x1
 4b0:	8bca0a13          	addi	s4,s4,-1860 # d68 <malloc+0x15c>
  for (i = 0; i < 100000000; i++) {
 4b4:	05f5e937          	lui	s2,0x5f5e
 4b8:	10090913          	addi	s2,s2,256 # 5f5e100 <base+0x5f5d0f0>
 4bc:	a021                	j	4c4 <test4+0x54>
 4be:	2485                	addiw	s1,s1,1
 4c0:	01248b63          	beq	s1,s2,4d6 <test4+0x66>
    if ((i % 10000000) == 0) {
 4c4:	0334e7bb          	remw	a5,s1,s3
 4c8:	fbfd                	bnez	a5,4be <test4+0x4e>
      printf(".");
 4ca:	8552                	mv	a0,s4
 4cc:	00000097          	auipc	ra,0x0
 4d0:	688080e7          	jalr	1672(ra) # b54 <printf>
 4d4:	b7ed                	j	4be <test4+0x4e>
    }
  }
  
  sigalarm(0, 0);  // Disable the alarm
 4d6:	4581                	li	a1,0
 4d8:	4501                	li	a0,0
 4da:	00000097          	auipc	ra,0x0
 4de:	388080e7          	jalr	904(ra) # 862 <sigalarm>
  printf("\nTest completed.\n");
 4e2:	00001517          	auipc	a0,0x1
 4e6:	a3e50513          	addi	a0,a0,-1474 # f20 <malloc+0x314>
 4ea:	00000097          	auipc	ra,0x0
 4ee:	66a080e7          	jalr	1642(ra) # b54 <printf>

  exit(0);
 4f2:	4501                	li	a0,0
 4f4:	00000097          	auipc	ra,0x0
 4f8:	2be080e7          	jalr	702(ra) # 7b2 <exit>

00000000000004fc <main>:
{
 4fc:	1141                	addi	sp,sp,-16
 4fe:	e406                	sd	ra,8(sp)
 500:	e022                	sd	s0,0(sp)
 502:	0800                	addi	s0,sp,16
    test0();
 504:	00000097          	auipc	ra,0x0
 508:	c16080e7          	jalr	-1002(ra) # 11a <test0>
    test1();
 50c:	00000097          	auipc	ra,0x0
 510:	d20080e7          	jalr	-736(ra) # 22c <test1>
    test2();
 514:	00000097          	auipc	ra,0x0
 518:	de2080e7          	jalr	-542(ra) # 2f6 <test2>
    test3();
 51c:	00000097          	auipc	ra,0x0
 520:	ee2080e7          	jalr	-286(ra) # 3fe <test3>
    test4();
 524:	00000097          	auipc	ra,0x0
 528:	f4c080e7          	jalr	-180(ra) # 470 <test4>

000000000000052c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 52c:	1141                	addi	sp,sp,-16
 52e:	e406                	sd	ra,8(sp)
 530:	e022                	sd	s0,0(sp)
 532:	0800                	addi	s0,sp,16
  extern int main();
  main();
 534:	00000097          	auipc	ra,0x0
 538:	fc8080e7          	jalr	-56(ra) # 4fc <main>
  exit(0);
 53c:	4501                	li	a0,0
 53e:	00000097          	auipc	ra,0x0
 542:	274080e7          	jalr	628(ra) # 7b2 <exit>

0000000000000546 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 546:	1141                	addi	sp,sp,-16
 548:	e422                	sd	s0,8(sp)
 54a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 54c:	87aa                	mv	a5,a0
 54e:	0585                	addi	a1,a1,1
 550:	0785                	addi	a5,a5,1
 552:	fff5c703          	lbu	a4,-1(a1)
 556:	fee78fa3          	sb	a4,-1(a5)
 55a:	fb75                	bnez	a4,54e <strcpy+0x8>
    ;
  return os;
}
 55c:	6422                	ld	s0,8(sp)
 55e:	0141                	addi	sp,sp,16
 560:	8082                	ret

0000000000000562 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 562:	1141                	addi	sp,sp,-16
 564:	e422                	sd	s0,8(sp)
 566:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 568:	00054783          	lbu	a5,0(a0)
 56c:	cb91                	beqz	a5,580 <strcmp+0x1e>
 56e:	0005c703          	lbu	a4,0(a1)
 572:	00f71763          	bne	a4,a5,580 <strcmp+0x1e>
    p++, q++;
 576:	0505                	addi	a0,a0,1
 578:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 57a:	00054783          	lbu	a5,0(a0)
 57e:	fbe5                	bnez	a5,56e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 580:	0005c503          	lbu	a0,0(a1)
}
 584:	40a7853b          	subw	a0,a5,a0
 588:	6422                	ld	s0,8(sp)
 58a:	0141                	addi	sp,sp,16
 58c:	8082                	ret

000000000000058e <strlen>:

uint
strlen(const char *s)
{
 58e:	1141                	addi	sp,sp,-16
 590:	e422                	sd	s0,8(sp)
 592:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 594:	00054783          	lbu	a5,0(a0)
 598:	cf91                	beqz	a5,5b4 <strlen+0x26>
 59a:	0505                	addi	a0,a0,1
 59c:	87aa                	mv	a5,a0
 59e:	4685                	li	a3,1
 5a0:	9e89                	subw	a3,a3,a0
 5a2:	00f6853b          	addw	a0,a3,a5
 5a6:	0785                	addi	a5,a5,1
 5a8:	fff7c703          	lbu	a4,-1(a5)
 5ac:	fb7d                	bnez	a4,5a2 <strlen+0x14>
    ;
  return n;
}
 5ae:	6422                	ld	s0,8(sp)
 5b0:	0141                	addi	sp,sp,16
 5b2:	8082                	ret
  for(n = 0; s[n]; n++)
 5b4:	4501                	li	a0,0
 5b6:	bfe5                	j	5ae <strlen+0x20>

00000000000005b8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 5b8:	1141                	addi	sp,sp,-16
 5ba:	e422                	sd	s0,8(sp)
 5bc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 5be:	ca19                	beqz	a2,5d4 <memset+0x1c>
 5c0:	87aa                	mv	a5,a0
 5c2:	1602                	slli	a2,a2,0x20
 5c4:	9201                	srli	a2,a2,0x20
 5c6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 5ca:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 5ce:	0785                	addi	a5,a5,1
 5d0:	fee79de3          	bne	a5,a4,5ca <memset+0x12>
  }
  return dst;
}
 5d4:	6422                	ld	s0,8(sp)
 5d6:	0141                	addi	sp,sp,16
 5d8:	8082                	ret

00000000000005da <strchr>:

char*
strchr(const char *s, char c)
{
 5da:	1141                	addi	sp,sp,-16
 5dc:	e422                	sd	s0,8(sp)
 5de:	0800                	addi	s0,sp,16
  for(; *s; s++)
 5e0:	00054783          	lbu	a5,0(a0)
 5e4:	cb99                	beqz	a5,5fa <strchr+0x20>
    if(*s == c)
 5e6:	00f58763          	beq	a1,a5,5f4 <strchr+0x1a>
  for(; *s; s++)
 5ea:	0505                	addi	a0,a0,1
 5ec:	00054783          	lbu	a5,0(a0)
 5f0:	fbfd                	bnez	a5,5e6 <strchr+0xc>
      return (char*)s;
  return 0;
 5f2:	4501                	li	a0,0
}
 5f4:	6422                	ld	s0,8(sp)
 5f6:	0141                	addi	sp,sp,16
 5f8:	8082                	ret
  return 0;
 5fa:	4501                	li	a0,0
 5fc:	bfe5                	j	5f4 <strchr+0x1a>

00000000000005fe <gets>:

char*
gets(char *buf, int max)
{
 5fe:	711d                	addi	sp,sp,-96
 600:	ec86                	sd	ra,88(sp)
 602:	e8a2                	sd	s0,80(sp)
 604:	e4a6                	sd	s1,72(sp)
 606:	e0ca                	sd	s2,64(sp)
 608:	fc4e                	sd	s3,56(sp)
 60a:	f852                	sd	s4,48(sp)
 60c:	f456                	sd	s5,40(sp)
 60e:	f05a                	sd	s6,32(sp)
 610:	ec5e                	sd	s7,24(sp)
 612:	1080                	addi	s0,sp,96
 614:	8baa                	mv	s7,a0
 616:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 618:	892a                	mv	s2,a0
 61a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 61c:	4aa9                	li	s5,10
 61e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 620:	89a6                	mv	s3,s1
 622:	2485                	addiw	s1,s1,1
 624:	0344d863          	bge	s1,s4,654 <gets+0x56>
    cc = read(0, &c, 1);
 628:	4605                	li	a2,1
 62a:	faf40593          	addi	a1,s0,-81
 62e:	4501                	li	a0,0
 630:	00000097          	auipc	ra,0x0
 634:	19a080e7          	jalr	410(ra) # 7ca <read>
    if(cc < 1)
 638:	00a05e63          	blez	a0,654 <gets+0x56>
    buf[i++] = c;
 63c:	faf44783          	lbu	a5,-81(s0)
 640:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 644:	01578763          	beq	a5,s5,652 <gets+0x54>
 648:	0905                	addi	s2,s2,1
 64a:	fd679be3          	bne	a5,s6,620 <gets+0x22>
  for(i=0; i+1 < max; ){
 64e:	89a6                	mv	s3,s1
 650:	a011                	j	654 <gets+0x56>
 652:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 654:	99de                	add	s3,s3,s7
 656:	00098023          	sb	zero,0(s3)
  return buf;
}
 65a:	855e                	mv	a0,s7
 65c:	60e6                	ld	ra,88(sp)
 65e:	6446                	ld	s0,80(sp)
 660:	64a6                	ld	s1,72(sp)
 662:	6906                	ld	s2,64(sp)
 664:	79e2                	ld	s3,56(sp)
 666:	7a42                	ld	s4,48(sp)
 668:	7aa2                	ld	s5,40(sp)
 66a:	7b02                	ld	s6,32(sp)
 66c:	6be2                	ld	s7,24(sp)
 66e:	6125                	addi	sp,sp,96
 670:	8082                	ret

0000000000000672 <stat>:

int
stat(const char *n, struct stat *st)
{
 672:	1101                	addi	sp,sp,-32
 674:	ec06                	sd	ra,24(sp)
 676:	e822                	sd	s0,16(sp)
 678:	e426                	sd	s1,8(sp)
 67a:	e04a                	sd	s2,0(sp)
 67c:	1000                	addi	s0,sp,32
 67e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 680:	4581                	li	a1,0
 682:	00000097          	auipc	ra,0x0
 686:	170080e7          	jalr	368(ra) # 7f2 <open>
  if(fd < 0)
 68a:	02054563          	bltz	a0,6b4 <stat+0x42>
 68e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 690:	85ca                	mv	a1,s2
 692:	00000097          	auipc	ra,0x0
 696:	178080e7          	jalr	376(ra) # 80a <fstat>
 69a:	892a                	mv	s2,a0
  close(fd);
 69c:	8526                	mv	a0,s1
 69e:	00000097          	auipc	ra,0x0
 6a2:	13c080e7          	jalr	316(ra) # 7da <close>
  return r;
}
 6a6:	854a                	mv	a0,s2
 6a8:	60e2                	ld	ra,24(sp)
 6aa:	6442                	ld	s0,16(sp)
 6ac:	64a2                	ld	s1,8(sp)
 6ae:	6902                	ld	s2,0(sp)
 6b0:	6105                	addi	sp,sp,32
 6b2:	8082                	ret
    return -1;
 6b4:	597d                	li	s2,-1
 6b6:	bfc5                	j	6a6 <stat+0x34>

00000000000006b8 <atoi>:

int
atoi(const char *s)
{
 6b8:	1141                	addi	sp,sp,-16
 6ba:	e422                	sd	s0,8(sp)
 6bc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 6be:	00054683          	lbu	a3,0(a0)
 6c2:	fd06879b          	addiw	a5,a3,-48
 6c6:	0ff7f793          	zext.b	a5,a5
 6ca:	4625                	li	a2,9
 6cc:	02f66863          	bltu	a2,a5,6fc <atoi+0x44>
 6d0:	872a                	mv	a4,a0
  n = 0;
 6d2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 6d4:	0705                	addi	a4,a4,1
 6d6:	0025179b          	slliw	a5,a0,0x2
 6da:	9fa9                	addw	a5,a5,a0
 6dc:	0017979b          	slliw	a5,a5,0x1
 6e0:	9fb5                	addw	a5,a5,a3
 6e2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 6e6:	00074683          	lbu	a3,0(a4)
 6ea:	fd06879b          	addiw	a5,a3,-48
 6ee:	0ff7f793          	zext.b	a5,a5
 6f2:	fef671e3          	bgeu	a2,a5,6d4 <atoi+0x1c>
  return n;
}
 6f6:	6422                	ld	s0,8(sp)
 6f8:	0141                	addi	sp,sp,16
 6fa:	8082                	ret
  n = 0;
 6fc:	4501                	li	a0,0
 6fe:	bfe5                	j	6f6 <atoi+0x3e>

0000000000000700 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 700:	1141                	addi	sp,sp,-16
 702:	e422                	sd	s0,8(sp)
 704:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 706:	02b57463          	bgeu	a0,a1,72e <memmove+0x2e>
    while(n-- > 0)
 70a:	00c05f63          	blez	a2,728 <memmove+0x28>
 70e:	1602                	slli	a2,a2,0x20
 710:	9201                	srli	a2,a2,0x20
 712:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 716:	872a                	mv	a4,a0
      *dst++ = *src++;
 718:	0585                	addi	a1,a1,1
 71a:	0705                	addi	a4,a4,1
 71c:	fff5c683          	lbu	a3,-1(a1)
 720:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 724:	fee79ae3          	bne	a5,a4,718 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 728:	6422                	ld	s0,8(sp)
 72a:	0141                	addi	sp,sp,16
 72c:	8082                	ret
    dst += n;
 72e:	00c50733          	add	a4,a0,a2
    src += n;
 732:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 734:	fec05ae3          	blez	a2,728 <memmove+0x28>
 738:	fff6079b          	addiw	a5,a2,-1
 73c:	1782                	slli	a5,a5,0x20
 73e:	9381                	srli	a5,a5,0x20
 740:	fff7c793          	not	a5,a5
 744:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 746:	15fd                	addi	a1,a1,-1
 748:	177d                	addi	a4,a4,-1
 74a:	0005c683          	lbu	a3,0(a1)
 74e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 752:	fee79ae3          	bne	a5,a4,746 <memmove+0x46>
 756:	bfc9                	j	728 <memmove+0x28>

0000000000000758 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 758:	1141                	addi	sp,sp,-16
 75a:	e422                	sd	s0,8(sp)
 75c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 75e:	ca05                	beqz	a2,78e <memcmp+0x36>
 760:	fff6069b          	addiw	a3,a2,-1
 764:	1682                	slli	a3,a3,0x20
 766:	9281                	srli	a3,a3,0x20
 768:	0685                	addi	a3,a3,1
 76a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 76c:	00054783          	lbu	a5,0(a0)
 770:	0005c703          	lbu	a4,0(a1)
 774:	00e79863          	bne	a5,a4,784 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 778:	0505                	addi	a0,a0,1
    p2++;
 77a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 77c:	fed518e3          	bne	a0,a3,76c <memcmp+0x14>
  }
  return 0;
 780:	4501                	li	a0,0
 782:	a019                	j	788 <memcmp+0x30>
      return *p1 - *p2;
 784:	40e7853b          	subw	a0,a5,a4
}
 788:	6422                	ld	s0,8(sp)
 78a:	0141                	addi	sp,sp,16
 78c:	8082                	ret
  return 0;
 78e:	4501                	li	a0,0
 790:	bfe5                	j	788 <memcmp+0x30>

0000000000000792 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 792:	1141                	addi	sp,sp,-16
 794:	e406                	sd	ra,8(sp)
 796:	e022                	sd	s0,0(sp)
 798:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 79a:	00000097          	auipc	ra,0x0
 79e:	f66080e7          	jalr	-154(ra) # 700 <memmove>
}
 7a2:	60a2                	ld	ra,8(sp)
 7a4:	6402                	ld	s0,0(sp)
 7a6:	0141                	addi	sp,sp,16
 7a8:	8082                	ret

00000000000007aa <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 7aa:	4885                	li	a7,1
 ecall
 7ac:	00000073          	ecall
 ret
 7b0:	8082                	ret

00000000000007b2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 7b2:	4889                	li	a7,2
 ecall
 7b4:	00000073          	ecall
 ret
 7b8:	8082                	ret

00000000000007ba <wait>:
.global wait
wait:
 li a7, SYS_wait
 7ba:	488d                	li	a7,3
 ecall
 7bc:	00000073          	ecall
 ret
 7c0:	8082                	ret

00000000000007c2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 7c2:	4891                	li	a7,4
 ecall
 7c4:	00000073          	ecall
 ret
 7c8:	8082                	ret

00000000000007ca <read>:
.global read
read:
 li a7, SYS_read
 7ca:	4895                	li	a7,5
 ecall
 7cc:	00000073          	ecall
 ret
 7d0:	8082                	ret

00000000000007d2 <write>:
.global write
write:
 li a7, SYS_write
 7d2:	48c1                	li	a7,16
 ecall
 7d4:	00000073          	ecall
 ret
 7d8:	8082                	ret

00000000000007da <close>:
.global close
close:
 li a7, SYS_close
 7da:	48d5                	li	a7,21
 ecall
 7dc:	00000073          	ecall
 ret
 7e0:	8082                	ret

00000000000007e2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 7e2:	4899                	li	a7,6
 ecall
 7e4:	00000073          	ecall
 ret
 7e8:	8082                	ret

00000000000007ea <exec>:
.global exec
exec:
 li a7, SYS_exec
 7ea:	489d                	li	a7,7
 ecall
 7ec:	00000073          	ecall
 ret
 7f0:	8082                	ret

00000000000007f2 <open>:
.global open
open:
 li a7, SYS_open
 7f2:	48bd                	li	a7,15
 ecall
 7f4:	00000073          	ecall
 ret
 7f8:	8082                	ret

00000000000007fa <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 7fa:	48c5                	li	a7,17
 ecall
 7fc:	00000073          	ecall
 ret
 800:	8082                	ret

0000000000000802 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 802:	48c9                	li	a7,18
 ecall
 804:	00000073          	ecall
 ret
 808:	8082                	ret

000000000000080a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 80a:	48a1                	li	a7,8
 ecall
 80c:	00000073          	ecall
 ret
 810:	8082                	ret

0000000000000812 <link>:
.global link
link:
 li a7, SYS_link
 812:	48cd                	li	a7,19
 ecall
 814:	00000073          	ecall
 ret
 818:	8082                	ret

000000000000081a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 81a:	48d1                	li	a7,20
 ecall
 81c:	00000073          	ecall
 ret
 820:	8082                	ret

0000000000000822 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 822:	48a5                	li	a7,9
 ecall
 824:	00000073          	ecall
 ret
 828:	8082                	ret

000000000000082a <dup>:
.global dup
dup:
 li a7, SYS_dup
 82a:	48a9                	li	a7,10
 ecall
 82c:	00000073          	ecall
 ret
 830:	8082                	ret

0000000000000832 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 832:	48ad                	li	a7,11
 ecall
 834:	00000073          	ecall
 ret
 838:	8082                	ret

000000000000083a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 83a:	48b1                	li	a7,12
 ecall
 83c:	00000073          	ecall
 ret
 840:	8082                	ret

0000000000000842 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 842:	48b5                	li	a7,13
 ecall
 844:	00000073          	ecall
 ret
 848:	8082                	ret

000000000000084a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 84a:	48b9                	li	a7,14
 ecall
 84c:	00000073          	ecall
 ret
 850:	8082                	ret

0000000000000852 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 852:	48d9                	li	a7,22
 ecall
 854:	00000073          	ecall
 ret
 858:	8082                	ret

000000000000085a <getSysCount>:
.global getSysCount
getSysCount:
 li a7, SYS_getSysCount
 85a:	48dd                	li	a7,23
 ecall
 85c:	00000073          	ecall
 ret
 860:	8082                	ret

0000000000000862 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 862:	48e1                	li	a7,24
 ecall
 864:	00000073          	ecall
 ret
 868:	8082                	ret

000000000000086a <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 86a:	48e5                	li	a7,25
 ecall
 86c:	00000073          	ecall
 ret
 870:	8082                	ret

0000000000000872 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 872:	48e9                	li	a7,26
 ecall
 874:	00000073          	ecall
 ret
 878:	8082                	ret

000000000000087a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 87a:	1101                	addi	sp,sp,-32
 87c:	ec06                	sd	ra,24(sp)
 87e:	e822                	sd	s0,16(sp)
 880:	1000                	addi	s0,sp,32
 882:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 886:	4605                	li	a2,1
 888:	fef40593          	addi	a1,s0,-17
 88c:	00000097          	auipc	ra,0x0
 890:	f46080e7          	jalr	-186(ra) # 7d2 <write>
}
 894:	60e2                	ld	ra,24(sp)
 896:	6442                	ld	s0,16(sp)
 898:	6105                	addi	sp,sp,32
 89a:	8082                	ret

000000000000089c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 89c:	7139                	addi	sp,sp,-64
 89e:	fc06                	sd	ra,56(sp)
 8a0:	f822                	sd	s0,48(sp)
 8a2:	f426                	sd	s1,40(sp)
 8a4:	f04a                	sd	s2,32(sp)
 8a6:	ec4e                	sd	s3,24(sp)
 8a8:	0080                	addi	s0,sp,64
 8aa:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 8ac:	c299                	beqz	a3,8b2 <printint+0x16>
 8ae:	0805c963          	bltz	a1,940 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 8b2:	2581                	sext.w	a1,a1
  neg = 0;
 8b4:	4881                	li	a7,0
 8b6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 8ba:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 8bc:	2601                	sext.w	a2,a2
 8be:	00000517          	auipc	a0,0x0
 8c2:	6da50513          	addi	a0,a0,1754 # f98 <digits>
 8c6:	883a                	mv	a6,a4
 8c8:	2705                	addiw	a4,a4,1
 8ca:	02c5f7bb          	remuw	a5,a1,a2
 8ce:	1782                	slli	a5,a5,0x20
 8d0:	9381                	srli	a5,a5,0x20
 8d2:	97aa                	add	a5,a5,a0
 8d4:	0007c783          	lbu	a5,0(a5)
 8d8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 8dc:	0005879b          	sext.w	a5,a1
 8e0:	02c5d5bb          	divuw	a1,a1,a2
 8e4:	0685                	addi	a3,a3,1
 8e6:	fec7f0e3          	bgeu	a5,a2,8c6 <printint+0x2a>
  if(neg)
 8ea:	00088c63          	beqz	a7,902 <printint+0x66>
    buf[i++] = '-';
 8ee:	fd070793          	addi	a5,a4,-48
 8f2:	00878733          	add	a4,a5,s0
 8f6:	02d00793          	li	a5,45
 8fa:	fef70823          	sb	a5,-16(a4)
 8fe:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 902:	02e05863          	blez	a4,932 <printint+0x96>
 906:	fc040793          	addi	a5,s0,-64
 90a:	00e78933          	add	s2,a5,a4
 90e:	fff78993          	addi	s3,a5,-1
 912:	99ba                	add	s3,s3,a4
 914:	377d                	addiw	a4,a4,-1
 916:	1702                	slli	a4,a4,0x20
 918:	9301                	srli	a4,a4,0x20
 91a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 91e:	fff94583          	lbu	a1,-1(s2)
 922:	8526                	mv	a0,s1
 924:	00000097          	auipc	ra,0x0
 928:	f56080e7          	jalr	-170(ra) # 87a <putc>
  while(--i >= 0)
 92c:	197d                	addi	s2,s2,-1
 92e:	ff3918e3          	bne	s2,s3,91e <printint+0x82>
}
 932:	70e2                	ld	ra,56(sp)
 934:	7442                	ld	s0,48(sp)
 936:	74a2                	ld	s1,40(sp)
 938:	7902                	ld	s2,32(sp)
 93a:	69e2                	ld	s3,24(sp)
 93c:	6121                	addi	sp,sp,64
 93e:	8082                	ret
    x = -xx;
 940:	40b005bb          	negw	a1,a1
    neg = 1;
 944:	4885                	li	a7,1
    x = -xx;
 946:	bf85                	j	8b6 <printint+0x1a>

0000000000000948 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 948:	7119                	addi	sp,sp,-128
 94a:	fc86                	sd	ra,120(sp)
 94c:	f8a2                	sd	s0,112(sp)
 94e:	f4a6                	sd	s1,104(sp)
 950:	f0ca                	sd	s2,96(sp)
 952:	ecce                	sd	s3,88(sp)
 954:	e8d2                	sd	s4,80(sp)
 956:	e4d6                	sd	s5,72(sp)
 958:	e0da                	sd	s6,64(sp)
 95a:	fc5e                	sd	s7,56(sp)
 95c:	f862                	sd	s8,48(sp)
 95e:	f466                	sd	s9,40(sp)
 960:	f06a                	sd	s10,32(sp)
 962:	ec6e                	sd	s11,24(sp)
 964:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 966:	0005c903          	lbu	s2,0(a1)
 96a:	18090f63          	beqz	s2,b08 <vprintf+0x1c0>
 96e:	8aaa                	mv	s5,a0
 970:	8b32                	mv	s6,a2
 972:	00158493          	addi	s1,a1,1
  state = 0;
 976:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 978:	02500a13          	li	s4,37
 97c:	4c55                	li	s8,21
 97e:	00000c97          	auipc	s9,0x0
 982:	5c2c8c93          	addi	s9,s9,1474 # f40 <malloc+0x334>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 986:	02800d93          	li	s11,40
  putc(fd, 'x');
 98a:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 98c:	00000b97          	auipc	s7,0x0
 990:	60cb8b93          	addi	s7,s7,1548 # f98 <digits>
 994:	a839                	j	9b2 <vprintf+0x6a>
        putc(fd, c);
 996:	85ca                	mv	a1,s2
 998:	8556                	mv	a0,s5
 99a:	00000097          	auipc	ra,0x0
 99e:	ee0080e7          	jalr	-288(ra) # 87a <putc>
 9a2:	a019                	j	9a8 <vprintf+0x60>
    } else if(state == '%'){
 9a4:	01498d63          	beq	s3,s4,9be <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 9a8:	0485                	addi	s1,s1,1
 9aa:	fff4c903          	lbu	s2,-1(s1)
 9ae:	14090d63          	beqz	s2,b08 <vprintf+0x1c0>
    if(state == 0){
 9b2:	fe0999e3          	bnez	s3,9a4 <vprintf+0x5c>
      if(c == '%'){
 9b6:	ff4910e3          	bne	s2,s4,996 <vprintf+0x4e>
        state = '%';
 9ba:	89d2                	mv	s3,s4
 9bc:	b7f5                	j	9a8 <vprintf+0x60>
      if(c == 'd'){
 9be:	11490c63          	beq	s2,s4,ad6 <vprintf+0x18e>
 9c2:	f9d9079b          	addiw	a5,s2,-99
 9c6:	0ff7f793          	zext.b	a5,a5
 9ca:	10fc6e63          	bltu	s8,a5,ae6 <vprintf+0x19e>
 9ce:	f9d9079b          	addiw	a5,s2,-99
 9d2:	0ff7f713          	zext.b	a4,a5
 9d6:	10ec6863          	bltu	s8,a4,ae6 <vprintf+0x19e>
 9da:	00271793          	slli	a5,a4,0x2
 9de:	97e6                	add	a5,a5,s9
 9e0:	439c                	lw	a5,0(a5)
 9e2:	97e6                	add	a5,a5,s9
 9e4:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 9e6:	008b0913          	addi	s2,s6,8
 9ea:	4685                	li	a3,1
 9ec:	4629                	li	a2,10
 9ee:	000b2583          	lw	a1,0(s6)
 9f2:	8556                	mv	a0,s5
 9f4:	00000097          	auipc	ra,0x0
 9f8:	ea8080e7          	jalr	-344(ra) # 89c <printint>
 9fc:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 9fe:	4981                	li	s3,0
 a00:	b765                	j	9a8 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 a02:	008b0913          	addi	s2,s6,8
 a06:	4681                	li	a3,0
 a08:	4629                	li	a2,10
 a0a:	000b2583          	lw	a1,0(s6)
 a0e:	8556                	mv	a0,s5
 a10:	00000097          	auipc	ra,0x0
 a14:	e8c080e7          	jalr	-372(ra) # 89c <printint>
 a18:	8b4a                	mv	s6,s2
      state = 0;
 a1a:	4981                	li	s3,0
 a1c:	b771                	j	9a8 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 a1e:	008b0913          	addi	s2,s6,8
 a22:	4681                	li	a3,0
 a24:	866a                	mv	a2,s10
 a26:	000b2583          	lw	a1,0(s6)
 a2a:	8556                	mv	a0,s5
 a2c:	00000097          	auipc	ra,0x0
 a30:	e70080e7          	jalr	-400(ra) # 89c <printint>
 a34:	8b4a                	mv	s6,s2
      state = 0;
 a36:	4981                	li	s3,0
 a38:	bf85                	j	9a8 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 a3a:	008b0793          	addi	a5,s6,8
 a3e:	f8f43423          	sd	a5,-120(s0)
 a42:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 a46:	03000593          	li	a1,48
 a4a:	8556                	mv	a0,s5
 a4c:	00000097          	auipc	ra,0x0
 a50:	e2e080e7          	jalr	-466(ra) # 87a <putc>
  putc(fd, 'x');
 a54:	07800593          	li	a1,120
 a58:	8556                	mv	a0,s5
 a5a:	00000097          	auipc	ra,0x0
 a5e:	e20080e7          	jalr	-480(ra) # 87a <putc>
 a62:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 a64:	03c9d793          	srli	a5,s3,0x3c
 a68:	97de                	add	a5,a5,s7
 a6a:	0007c583          	lbu	a1,0(a5)
 a6e:	8556                	mv	a0,s5
 a70:	00000097          	auipc	ra,0x0
 a74:	e0a080e7          	jalr	-502(ra) # 87a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 a78:	0992                	slli	s3,s3,0x4
 a7a:	397d                	addiw	s2,s2,-1
 a7c:	fe0914e3          	bnez	s2,a64 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 a80:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 a84:	4981                	li	s3,0
 a86:	b70d                	j	9a8 <vprintf+0x60>
        s = va_arg(ap, char*);
 a88:	008b0913          	addi	s2,s6,8
 a8c:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 a90:	02098163          	beqz	s3,ab2 <vprintf+0x16a>
        while(*s != 0){
 a94:	0009c583          	lbu	a1,0(s3)
 a98:	c5ad                	beqz	a1,b02 <vprintf+0x1ba>
          putc(fd, *s);
 a9a:	8556                	mv	a0,s5
 a9c:	00000097          	auipc	ra,0x0
 aa0:	dde080e7          	jalr	-546(ra) # 87a <putc>
          s++;
 aa4:	0985                	addi	s3,s3,1
        while(*s != 0){
 aa6:	0009c583          	lbu	a1,0(s3)
 aaa:	f9e5                	bnez	a1,a9a <vprintf+0x152>
        s = va_arg(ap, char*);
 aac:	8b4a                	mv	s6,s2
      state = 0;
 aae:	4981                	li	s3,0
 ab0:	bde5                	j	9a8 <vprintf+0x60>
          s = "(null)";
 ab2:	00000997          	auipc	s3,0x0
 ab6:	48698993          	addi	s3,s3,1158 # f38 <malloc+0x32c>
        while(*s != 0){
 aba:	85ee                	mv	a1,s11
 abc:	bff9                	j	a9a <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 abe:	008b0913          	addi	s2,s6,8
 ac2:	000b4583          	lbu	a1,0(s6)
 ac6:	8556                	mv	a0,s5
 ac8:	00000097          	auipc	ra,0x0
 acc:	db2080e7          	jalr	-590(ra) # 87a <putc>
 ad0:	8b4a                	mv	s6,s2
      state = 0;
 ad2:	4981                	li	s3,0
 ad4:	bdd1                	j	9a8 <vprintf+0x60>
        putc(fd, c);
 ad6:	85d2                	mv	a1,s4
 ad8:	8556                	mv	a0,s5
 ada:	00000097          	auipc	ra,0x0
 ade:	da0080e7          	jalr	-608(ra) # 87a <putc>
      state = 0;
 ae2:	4981                	li	s3,0
 ae4:	b5d1                	j	9a8 <vprintf+0x60>
        putc(fd, '%');
 ae6:	85d2                	mv	a1,s4
 ae8:	8556                	mv	a0,s5
 aea:	00000097          	auipc	ra,0x0
 aee:	d90080e7          	jalr	-624(ra) # 87a <putc>
        putc(fd, c);
 af2:	85ca                	mv	a1,s2
 af4:	8556                	mv	a0,s5
 af6:	00000097          	auipc	ra,0x0
 afa:	d84080e7          	jalr	-636(ra) # 87a <putc>
      state = 0;
 afe:	4981                	li	s3,0
 b00:	b565                	j	9a8 <vprintf+0x60>
        s = va_arg(ap, char*);
 b02:	8b4a                	mv	s6,s2
      state = 0;
 b04:	4981                	li	s3,0
 b06:	b54d                	j	9a8 <vprintf+0x60>
    }
  }
}
 b08:	70e6                	ld	ra,120(sp)
 b0a:	7446                	ld	s0,112(sp)
 b0c:	74a6                	ld	s1,104(sp)
 b0e:	7906                	ld	s2,96(sp)
 b10:	69e6                	ld	s3,88(sp)
 b12:	6a46                	ld	s4,80(sp)
 b14:	6aa6                	ld	s5,72(sp)
 b16:	6b06                	ld	s6,64(sp)
 b18:	7be2                	ld	s7,56(sp)
 b1a:	7c42                	ld	s8,48(sp)
 b1c:	7ca2                	ld	s9,40(sp)
 b1e:	7d02                	ld	s10,32(sp)
 b20:	6de2                	ld	s11,24(sp)
 b22:	6109                	addi	sp,sp,128
 b24:	8082                	ret

0000000000000b26 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 b26:	715d                	addi	sp,sp,-80
 b28:	ec06                	sd	ra,24(sp)
 b2a:	e822                	sd	s0,16(sp)
 b2c:	1000                	addi	s0,sp,32
 b2e:	e010                	sd	a2,0(s0)
 b30:	e414                	sd	a3,8(s0)
 b32:	e818                	sd	a4,16(s0)
 b34:	ec1c                	sd	a5,24(s0)
 b36:	03043023          	sd	a6,32(s0)
 b3a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 b3e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 b42:	8622                	mv	a2,s0
 b44:	00000097          	auipc	ra,0x0
 b48:	e04080e7          	jalr	-508(ra) # 948 <vprintf>
}
 b4c:	60e2                	ld	ra,24(sp)
 b4e:	6442                	ld	s0,16(sp)
 b50:	6161                	addi	sp,sp,80
 b52:	8082                	ret

0000000000000b54 <printf>:

void
printf(const char *fmt, ...)
{
 b54:	711d                	addi	sp,sp,-96
 b56:	ec06                	sd	ra,24(sp)
 b58:	e822                	sd	s0,16(sp)
 b5a:	1000                	addi	s0,sp,32
 b5c:	e40c                	sd	a1,8(s0)
 b5e:	e810                	sd	a2,16(s0)
 b60:	ec14                	sd	a3,24(s0)
 b62:	f018                	sd	a4,32(s0)
 b64:	f41c                	sd	a5,40(s0)
 b66:	03043823          	sd	a6,48(s0)
 b6a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 b6e:	00840613          	addi	a2,s0,8
 b72:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 b76:	85aa                	mv	a1,a0
 b78:	4505                	li	a0,1
 b7a:	00000097          	auipc	ra,0x0
 b7e:	dce080e7          	jalr	-562(ra) # 948 <vprintf>
}
 b82:	60e2                	ld	ra,24(sp)
 b84:	6442                	ld	s0,16(sp)
 b86:	6125                	addi	sp,sp,96
 b88:	8082                	ret

0000000000000b8a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b8a:	1141                	addi	sp,sp,-16
 b8c:	e422                	sd	s0,8(sp)
 b8e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b90:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b94:	00000797          	auipc	a5,0x0
 b98:	4747b783          	ld	a5,1140(a5) # 1008 <freep>
 b9c:	a02d                	j	bc6 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 b9e:	4618                	lw	a4,8(a2)
 ba0:	9f2d                	addw	a4,a4,a1
 ba2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 ba6:	6398                	ld	a4,0(a5)
 ba8:	6310                	ld	a2,0(a4)
 baa:	a83d                	j	be8 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 bac:	ff852703          	lw	a4,-8(a0)
 bb0:	9f31                	addw	a4,a4,a2
 bb2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 bb4:	ff053683          	ld	a3,-16(a0)
 bb8:	a091                	j	bfc <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 bba:	6398                	ld	a4,0(a5)
 bbc:	00e7e463          	bltu	a5,a4,bc4 <free+0x3a>
 bc0:	00e6ea63          	bltu	a3,a4,bd4 <free+0x4a>
{
 bc4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 bc6:	fed7fae3          	bgeu	a5,a3,bba <free+0x30>
 bca:	6398                	ld	a4,0(a5)
 bcc:	00e6e463          	bltu	a3,a4,bd4 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 bd0:	fee7eae3          	bltu	a5,a4,bc4 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 bd4:	ff852583          	lw	a1,-8(a0)
 bd8:	6390                	ld	a2,0(a5)
 bda:	02059813          	slli	a6,a1,0x20
 bde:	01c85713          	srli	a4,a6,0x1c
 be2:	9736                	add	a4,a4,a3
 be4:	fae60de3          	beq	a2,a4,b9e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 be8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 bec:	4790                	lw	a2,8(a5)
 bee:	02061593          	slli	a1,a2,0x20
 bf2:	01c5d713          	srli	a4,a1,0x1c
 bf6:	973e                	add	a4,a4,a5
 bf8:	fae68ae3          	beq	a3,a4,bac <free+0x22>
    p->s.ptr = bp->s.ptr;
 bfc:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 bfe:	00000717          	auipc	a4,0x0
 c02:	40f73523          	sd	a5,1034(a4) # 1008 <freep>
}
 c06:	6422                	ld	s0,8(sp)
 c08:	0141                	addi	sp,sp,16
 c0a:	8082                	ret

0000000000000c0c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 c0c:	7139                	addi	sp,sp,-64
 c0e:	fc06                	sd	ra,56(sp)
 c10:	f822                	sd	s0,48(sp)
 c12:	f426                	sd	s1,40(sp)
 c14:	f04a                	sd	s2,32(sp)
 c16:	ec4e                	sd	s3,24(sp)
 c18:	e852                	sd	s4,16(sp)
 c1a:	e456                	sd	s5,8(sp)
 c1c:	e05a                	sd	s6,0(sp)
 c1e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 c20:	02051493          	slli	s1,a0,0x20
 c24:	9081                	srli	s1,s1,0x20
 c26:	04bd                	addi	s1,s1,15
 c28:	8091                	srli	s1,s1,0x4
 c2a:	0014899b          	addiw	s3,s1,1
 c2e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 c30:	00000517          	auipc	a0,0x0
 c34:	3d853503          	ld	a0,984(a0) # 1008 <freep>
 c38:	c515                	beqz	a0,c64 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c3a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c3c:	4798                	lw	a4,8(a5)
 c3e:	02977f63          	bgeu	a4,s1,c7c <malloc+0x70>
 c42:	8a4e                	mv	s4,s3
 c44:	0009871b          	sext.w	a4,s3
 c48:	6685                	lui	a3,0x1
 c4a:	00d77363          	bgeu	a4,a3,c50 <malloc+0x44>
 c4e:	6a05                	lui	s4,0x1
 c50:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 c54:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 c58:	00000917          	auipc	s2,0x0
 c5c:	3b090913          	addi	s2,s2,944 # 1008 <freep>
  if(p == (char*)-1)
 c60:	5afd                	li	s5,-1
 c62:	a895                	j	cd6 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 c64:	00000797          	auipc	a5,0x0
 c68:	3ac78793          	addi	a5,a5,940 # 1010 <base>
 c6c:	00000717          	auipc	a4,0x0
 c70:	38f73e23          	sd	a5,924(a4) # 1008 <freep>
 c74:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 c76:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 c7a:	b7e1                	j	c42 <malloc+0x36>
      if(p->s.size == nunits)
 c7c:	02e48c63          	beq	s1,a4,cb4 <malloc+0xa8>
        p->s.size -= nunits;
 c80:	4137073b          	subw	a4,a4,s3
 c84:	c798                	sw	a4,8(a5)
        p += p->s.size;
 c86:	02071693          	slli	a3,a4,0x20
 c8a:	01c6d713          	srli	a4,a3,0x1c
 c8e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 c90:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 c94:	00000717          	auipc	a4,0x0
 c98:	36a73a23          	sd	a0,884(a4) # 1008 <freep>
      return (void*)(p + 1);
 c9c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 ca0:	70e2                	ld	ra,56(sp)
 ca2:	7442                	ld	s0,48(sp)
 ca4:	74a2                	ld	s1,40(sp)
 ca6:	7902                	ld	s2,32(sp)
 ca8:	69e2                	ld	s3,24(sp)
 caa:	6a42                	ld	s4,16(sp)
 cac:	6aa2                	ld	s5,8(sp)
 cae:	6b02                	ld	s6,0(sp)
 cb0:	6121                	addi	sp,sp,64
 cb2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 cb4:	6398                	ld	a4,0(a5)
 cb6:	e118                	sd	a4,0(a0)
 cb8:	bff1                	j	c94 <malloc+0x88>
  hp->s.size = nu;
 cba:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 cbe:	0541                	addi	a0,a0,16
 cc0:	00000097          	auipc	ra,0x0
 cc4:	eca080e7          	jalr	-310(ra) # b8a <free>
  return freep;
 cc8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 ccc:	d971                	beqz	a0,ca0 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 cce:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 cd0:	4798                	lw	a4,8(a5)
 cd2:	fa9775e3          	bgeu	a4,s1,c7c <malloc+0x70>
    if(p == freep)
 cd6:	00093703          	ld	a4,0(s2)
 cda:	853e                	mv	a0,a5
 cdc:	fef719e3          	bne	a4,a5,cce <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 ce0:	8552                	mv	a0,s4
 ce2:	00000097          	auipc	ra,0x0
 ce6:	b58080e7          	jalr	-1192(ra) # 83a <sbrk>
  if(p == (char*)-1)
 cea:	fd5518e3          	bne	a0,s5,cba <malloc+0xae>
        return 0;
 cee:	4501                	li	a0,0
 cf0:	bf45                	j	ca0 <malloc+0x94>
