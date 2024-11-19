
user/_syscount:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <getSyscallName>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user.h"
// Function to get the syscall name from the mask
const char* getSyscallName(int mask) {
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
    switch (mask) {
   6:	8005071b          	addiw	a4,a0,-2048
   a:	16070263          	beqz	a4,16e <getSyscallName+0x16e>
   e:	87aa                	mv	a5,a0
  10:	6705                	lui	a4,0x1
  12:	80070713          	addi	a4,a4,-2048 # 800 <vprintf+0x128>
  16:	08a74b63          	blt	a4,a0,ac <getSyscallName+0xac>
  1a:	02000713          	li	a4,32
  1e:	02a74d63          	blt	a4,a0,58 <getSyscallName+0x58>
        case 1 << 17: return "unlink";
        case 1 << 18: return "fchmod";
        case 1 << 19: return "link";
        case 1 << 20: return "mkdir";
        case 1 << 21: return "close";
        default: return "unknown";
  22:	00001517          	auipc	a0,0x1
  26:	a7650513          	addi	a0,a0,-1418 # a98 <malloc+0xfc>
    switch (mask) {
  2a:	06f05e63          	blez	a5,a6 <getSyscallName+0xa6>
  2e:	02f76063          	bltu	a4,a5,4e <getSyscallName+0x4e>
  32:	078a                	slli	a5,a5,0x2
  34:	00001717          	auipc	a4,0x1
  38:	b8870713          	addi	a4,a4,-1144 # bbc <malloc+0x220>
  3c:	97ba                	add	a5,a5,a4
  3e:	439c                	lw	a5,0(a5)
  40:	97ba                	add	a5,a5,a4
  42:	8782                	jr	a5
  44:	00001517          	auipc	a0,0x1
  48:	afc50513          	addi	a0,a0,-1284 # b40 <malloc+0x1a4>
  4c:	a8a9                	j	a6 <getSyscallName+0xa6>
        default: return "unknown";
  4e:	00001517          	auipc	a0,0x1
  52:	a4a50513          	addi	a0,a0,-1462 # a98 <malloc+0xfc>
  56:	a881                	j	a6 <getSyscallName+0xa6>
    switch (mask) {
  58:	10000713          	li	a4,256
  5c:	12e50363          	beq	a0,a4,182 <getSyscallName+0x182>
  60:	02a75363          	bge	a4,a0,86 <getSyscallName+0x86>
  64:	20000713          	li	a4,512
        case 1 << 9: return "dup";
  68:	00001517          	auipc	a0,0x1
  6c:	a7050513          	addi	a0,a0,-1424 # ad8 <malloc+0x13c>
    switch (mask) {
  70:	02e78b63          	beq	a5,a4,a6 <getSyscallName+0xa6>
  74:	40000713          	li	a4,1024
  78:	10e79f63          	bne	a5,a4,196 <getSyscallName+0x196>
        case 1 << 10: return "getpid";
  7c:	00001517          	auipc	a0,0x1
  80:	a6450513          	addi	a0,a0,-1436 # ae0 <malloc+0x144>
  84:	a00d                	j	a6 <getSyscallName+0xa6>
    switch (mask) {
  86:	04000713          	li	a4,64
        case 1 << 6: return "exec";
  8a:	00001517          	auipc	a0,0x1
  8e:	a3650513          	addi	a0,a0,-1482 # ac0 <malloc+0x124>
    switch (mask) {
  92:	00e78a63          	beq	a5,a4,a6 <getSyscallName+0xa6>
  96:	08000713          	li	a4,128
  9a:	0ee79963          	bne	a5,a4,18c <getSyscallName+0x18c>
        case 1 << 7: return "fstat";
  9e:	00001517          	auipc	a0,0x1
  a2:	a2a50513          	addi	a0,a0,-1494 # ac8 <malloc+0x12c>
    }
}
  a6:	6422                	ld	s0,8(sp)
  a8:	0141                	addi	sp,sp,16
  aa:	8082                	ret
    switch (mask) {
  ac:	00020737          	lui	a4,0x20
  b0:	0ee50863          	beq	a0,a4,1a0 <getSyscallName+0x1a0>
  b4:	02a75563          	bge	a4,a0,de <getSyscallName+0xde>
  b8:	00100737          	lui	a4,0x100
        case 1 << 20: return "mkdir";
  bc:	00001517          	auipc	a0,0x1
  c0:	a7450513          	addi	a0,a0,-1420 # b30 <malloc+0x194>
    switch (mask) {
  c4:	fee781e3          	beq	a5,a4,a6 <getSyscallName+0xa6>
  c8:	04f75e63          	bge	a4,a5,124 <getSyscallName+0x124>
  cc:	00200737          	lui	a4,0x200
  d0:	10e79163          	bne	a5,a4,1d2 <getSyscallName+0x1d2>
        case 1 << 21: return "close";
  d4:	00001517          	auipc	a0,0x1
  d8:	a6450513          	addi	a0,a0,-1436 # b38 <malloc+0x19c>
  dc:	b7e9                	j	a6 <getSyscallName+0xa6>
    switch (mask) {
  de:	6711                	lui	a4,0x4
  e0:	0ce50563          	beq	a0,a4,1aa <getSyscallName+0x1aa>
  e4:	02a75163          	bge	a4,a0,106 <getSyscallName+0x106>
  e8:	6721                	lui	a4,0x8
        case 1 << 15: return "write";
  ea:	00001517          	auipc	a0,0x1
  ee:	a1e50513          	addi	a0,a0,-1506 # b08 <malloc+0x16c>
    switch (mask) {
  f2:	fae78ae3          	beq	a5,a4,a6 <getSyscallName+0xa6>
  f6:	6741                	lui	a4,0x10
  f8:	0ce79363          	bne	a5,a4,1be <getSyscallName+0x1be>
        case 1 << 16: return "mknod";
  fc:	00001517          	auipc	a0,0x1
 100:	a1450513          	addi	a0,a0,-1516 # b10 <malloc+0x174>
 104:	b74d                	j	a6 <getSyscallName+0xa6>
    switch (mask) {
 106:	6705                	lui	a4,0x1
        case 1 << 12: return "sleep";
 108:	00001517          	auipc	a0,0x1
 10c:	9e850513          	addi	a0,a0,-1560 # af0 <malloc+0x154>
    switch (mask) {
 110:	f8e78be3          	beq	a5,a4,a6 <getSyscallName+0xa6>
 114:	6709                	lui	a4,0x2
 116:	08e79f63          	bne	a5,a4,1b4 <getSyscallName+0x1b4>
        case 1 << 13: return "uptime";
 11a:	00001517          	auipc	a0,0x1
 11e:	9de50513          	addi	a0,a0,-1570 # af8 <malloc+0x15c>
 122:	b751                	j	a6 <getSyscallName+0xa6>
    switch (mask) {
 124:	00040737          	lui	a4,0x40
        case 1 << 18: return "fchmod";
 128:	00001517          	auipc	a0,0x1
 12c:	9f850513          	addi	a0,a0,-1544 # b20 <malloc+0x184>
    switch (mask) {
 130:	f6e78be3          	beq	a5,a4,a6 <getSyscallName+0xa6>
 134:	00080737          	lui	a4,0x80
 138:	08e79863          	bne	a5,a4,1c8 <getSyscallName+0x1c8>
        case 1 << 19: return "link";
 13c:	00001517          	auipc	a0,0x1
 140:	9ec50513          	addi	a0,a0,-1556 # b28 <malloc+0x18c>
 144:	b78d                	j	a6 <getSyscallName+0xa6>
        case 1 << 2: return "wait";
 146:	00001517          	auipc	a0,0x1
 14a:	95a50513          	addi	a0,a0,-1702 # aa0 <malloc+0x104>
 14e:	bfa1                	j	a6 <getSyscallName+0xa6>
        case 1 << 3: return "pipe";
 150:	00001517          	auipc	a0,0x1
 154:	95850513          	addi	a0,a0,-1704 # aa8 <malloc+0x10c>
 158:	b7b9                	j	a6 <getSyscallName+0xa6>
        case 1 << 4: return "read";
 15a:	00001517          	auipc	a0,0x1
 15e:	95650513          	addi	a0,a0,-1706 # ab0 <malloc+0x114>
 162:	b791                	j	a6 <getSyscallName+0xa6>
        case 1 << 5: return "kill";
 164:	00001517          	auipc	a0,0x1
 168:	95450513          	addi	a0,a0,-1708 # ab8 <malloc+0x11c>
 16c:	bf2d                	j	a6 <getSyscallName+0xa6>
        case 1 << 11: return "sbrk";
 16e:	00001517          	auipc	a0,0x1
 172:	97a50513          	addi	a0,a0,-1670 # ae8 <malloc+0x14c>
 176:	bf05                	j	a6 <getSyscallName+0xa6>
        case 1 << 0: return "fork";
 178:	00001517          	auipc	a0,0x1
 17c:	91850513          	addi	a0,a0,-1768 # a90 <malloc+0xf4>
 180:	b71d                	j	a6 <getSyscallName+0xa6>
        case 1 << 8: return "chdir";
 182:	00001517          	auipc	a0,0x1
 186:	94e50513          	addi	a0,a0,-1714 # ad0 <malloc+0x134>
 18a:	bf31                	j	a6 <getSyscallName+0xa6>
        default: return "unknown";
 18c:	00001517          	auipc	a0,0x1
 190:	90c50513          	addi	a0,a0,-1780 # a98 <malloc+0xfc>
 194:	bf09                	j	a6 <getSyscallName+0xa6>
 196:	00001517          	auipc	a0,0x1
 19a:	90250513          	addi	a0,a0,-1790 # a98 <malloc+0xfc>
 19e:	b721                	j	a6 <getSyscallName+0xa6>
        case 1 << 17: return "unlink";
 1a0:	00001517          	auipc	a0,0x1
 1a4:	97850513          	addi	a0,a0,-1672 # b18 <malloc+0x17c>
 1a8:	bdfd                	j	a6 <getSyscallName+0xa6>
        case 1 << 14: return "open";
 1aa:	00001517          	auipc	a0,0x1
 1ae:	95650513          	addi	a0,a0,-1706 # b00 <malloc+0x164>
 1b2:	bdd5                	j	a6 <getSyscallName+0xa6>
        default: return "unknown";
 1b4:	00001517          	auipc	a0,0x1
 1b8:	8e450513          	addi	a0,a0,-1820 # a98 <malloc+0xfc>
 1bc:	b5ed                	j	a6 <getSyscallName+0xa6>
 1be:	00001517          	auipc	a0,0x1
 1c2:	8da50513          	addi	a0,a0,-1830 # a98 <malloc+0xfc>
 1c6:	b5c5                	j	a6 <getSyscallName+0xa6>
 1c8:	00001517          	auipc	a0,0x1
 1cc:	8d050513          	addi	a0,a0,-1840 # a98 <malloc+0xfc>
 1d0:	bdd9                	j	a6 <getSyscallName+0xa6>
 1d2:	00001517          	auipc	a0,0x1
 1d6:	8c650513          	addi	a0,a0,-1850 # a98 <malloc+0xfc>
 1da:	b5f1                	j	a6 <getSyscallName+0xa6>

00000000000001dc <main>:

int main(int argc, char *argv[]) {
 1dc:	7179                	addi	sp,sp,-48
 1de:	f406                	sd	ra,40(sp)
 1e0:	f022                	sd	s0,32(sp)
 1e2:	ec26                	sd	s1,24(sp)
 1e4:	e84a                	sd	s2,16(sp)
 1e6:	e44e                	sd	s3,8(sp)
 1e8:	e052                	sd	s4,0(sp)
 1ea:	1800                	addi	s0,sp,48
    if (argc < 3) {
 1ec:	4789                	li	a5,2
 1ee:	00a7cf63          	blt	a5,a0,20c <main+0x30>
        printf("Usage: syscount <mask> <command> [args]\n");
 1f2:	00001517          	auipc	a0,0x1
 1f6:	95650513          	addi	a0,a0,-1706 # b48 <malloc+0x1ac>
 1fa:	00000097          	auipc	ra,0x0
 1fe:	6ea080e7          	jalr	1770(ra) # 8e4 <printf>
        exit(1);
 202:	4505                	li	a0,1
 204:	00000097          	auipc	ra,0x0
 208:	33e080e7          	jalr	830(ra) # 542 <exit>
 20c:	892e                	mv	s2,a1
    }

    int mask = atoi(argv[1]);
 20e:	6588                	ld	a0,8(a1)
 210:	00000097          	auipc	ra,0x0
 214:	238080e7          	jalr	568(ra) # 448 <atoi>
 218:	84aa                	mv	s1,a0
    if (mask <= 0 || (mask & (mask - 1)) != 0) {
 21a:	00a05763          	blez	a0,228 <main+0x4c>
 21e:	fff5079b          	addiw	a5,a0,-1
 222:	8fe9                	and	a5,a5,a0
 224:	2781                	sext.w	a5,a5
 226:	cf91                	beqz	a5,242 <main+0x66>
        printf("Error: Mask must be a power of 2.\n");
 228:	00001517          	auipc	a0,0x1
 22c:	95050513          	addi	a0,a0,-1712 # b78 <malloc+0x1dc>
 230:	00000097          	auipc	ra,0x0
 234:	6b4080e7          	jalr	1716(ra) # 8e4 <printf>
        exit(1);
 238:	4505                	li	a0,1
 23a:	00000097          	auipc	ra,0x0
 23e:	308080e7          	jalr	776(ra) # 542 <exit>
    }

    int pid = fork();
 242:	00000097          	auipc	ra,0x0
 246:	2f8080e7          	jalr	760(ra) # 53a <fork>
 24a:	89aa                	mv	s3,a0
    int ct2=getSysCount(mask);
 24c:	8526                	mv	a0,s1
 24e:	00000097          	auipc	ra,0x0
 252:	39c080e7          	jalr	924(ra) # 5ea <getSysCount>
 256:	8a2a                	mv	s4,a0

    if (pid == 0) {
 258:	00099f63          	bnez	s3,276 <main+0x9a>
        // Child process executes the command
        exec(argv[2], argv + 2);
 25c:	01090593          	addi	a1,s2,16
 260:	01093503          	ld	a0,16(s2)
 264:	00000097          	auipc	ra,0x0
 268:	316080e7          	jalr	790(ra) # 57a <exec>
        exit(0);
 26c:	4501                	li	a0,0
 26e:	00000097          	auipc	ra,0x0
 272:	2d4080e7          	jalr	724(ra) # 542 <exit>
    } else {
        wait(0);
 276:	4501                	li	a0,0
 278:	00000097          	auipc	ra,0x0
 27c:	2d2080e7          	jalr	722(ra) # 54a <wait>

        // Get the syscall count
        int ct1= getSysCount(mask);
 280:	8526                	mv	a0,s1
 282:	00000097          	auipc	ra,0x0
 286:	368080e7          	jalr	872(ra) # 5ea <getSysCount>
 28a:	892a                	mv	s2,a0
        const char* syscall_name = getSyscallName(mask/2);
 28c:	4509                	li	a0,2
 28e:	02a4c53b          	divw	a0,s1,a0
 292:	00000097          	auipc	ra,0x0
 296:	d6e080e7          	jalr	-658(ra) # 0 <getSyscallName>
 29a:	862a                	mv	a2,a0
        int answer=ct1-ct2;
        printf("PID %d called %s %d times.\n", pid, syscall_name, answer);
 29c:	414906bb          	subw	a3,s2,s4
 2a0:	85ce                	mv	a1,s3
 2a2:	00001517          	auipc	a0,0x1
 2a6:	8fe50513          	addi	a0,a0,-1794 # ba0 <malloc+0x204>
 2aa:	00000097          	auipc	ra,0x0
 2ae:	63a080e7          	jalr	1594(ra) # 8e4 <printf>
    }

    exit(0);
 2b2:	4501                	li	a0,0
 2b4:	00000097          	auipc	ra,0x0
 2b8:	28e080e7          	jalr	654(ra) # 542 <exit>

00000000000002bc <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 2bc:	1141                	addi	sp,sp,-16
 2be:	e406                	sd	ra,8(sp)
 2c0:	e022                	sd	s0,0(sp)
 2c2:	0800                	addi	s0,sp,16
  extern int main();
  main();
 2c4:	00000097          	auipc	ra,0x0
 2c8:	f18080e7          	jalr	-232(ra) # 1dc <main>
  exit(0);
 2cc:	4501                	li	a0,0
 2ce:	00000097          	auipc	ra,0x0
 2d2:	274080e7          	jalr	628(ra) # 542 <exit>

00000000000002d6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 2d6:	1141                	addi	sp,sp,-16
 2d8:	e422                	sd	s0,8(sp)
 2da:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2dc:	87aa                	mv	a5,a0
 2de:	0585                	addi	a1,a1,1
 2e0:	0785                	addi	a5,a5,1
 2e2:	fff5c703          	lbu	a4,-1(a1)
 2e6:	fee78fa3          	sb	a4,-1(a5)
 2ea:	fb75                	bnez	a4,2de <strcpy+0x8>
    ;
  return os;
}
 2ec:	6422                	ld	s0,8(sp)
 2ee:	0141                	addi	sp,sp,16
 2f0:	8082                	ret

00000000000002f2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2f2:	1141                	addi	sp,sp,-16
 2f4:	e422                	sd	s0,8(sp)
 2f6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2f8:	00054783          	lbu	a5,0(a0)
 2fc:	cb91                	beqz	a5,310 <strcmp+0x1e>
 2fe:	0005c703          	lbu	a4,0(a1)
 302:	00f71763          	bne	a4,a5,310 <strcmp+0x1e>
    p++, q++;
 306:	0505                	addi	a0,a0,1
 308:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 30a:	00054783          	lbu	a5,0(a0)
 30e:	fbe5                	bnez	a5,2fe <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 310:	0005c503          	lbu	a0,0(a1)
}
 314:	40a7853b          	subw	a0,a5,a0
 318:	6422                	ld	s0,8(sp)
 31a:	0141                	addi	sp,sp,16
 31c:	8082                	ret

000000000000031e <strlen>:

uint
strlen(const char *s)
{
 31e:	1141                	addi	sp,sp,-16
 320:	e422                	sd	s0,8(sp)
 322:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 324:	00054783          	lbu	a5,0(a0)
 328:	cf91                	beqz	a5,344 <strlen+0x26>
 32a:	0505                	addi	a0,a0,1
 32c:	87aa                	mv	a5,a0
 32e:	4685                	li	a3,1
 330:	9e89                	subw	a3,a3,a0
 332:	00f6853b          	addw	a0,a3,a5
 336:	0785                	addi	a5,a5,1
 338:	fff7c703          	lbu	a4,-1(a5)
 33c:	fb7d                	bnez	a4,332 <strlen+0x14>
    ;
  return n;
}
 33e:	6422                	ld	s0,8(sp)
 340:	0141                	addi	sp,sp,16
 342:	8082                	ret
  for(n = 0; s[n]; n++)
 344:	4501                	li	a0,0
 346:	bfe5                	j	33e <strlen+0x20>

0000000000000348 <memset>:

void*
memset(void *dst, int c, uint n)
{
 348:	1141                	addi	sp,sp,-16
 34a:	e422                	sd	s0,8(sp)
 34c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 34e:	ca19                	beqz	a2,364 <memset+0x1c>
 350:	87aa                	mv	a5,a0
 352:	1602                	slli	a2,a2,0x20
 354:	9201                	srli	a2,a2,0x20
 356:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 35a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 35e:	0785                	addi	a5,a5,1
 360:	fee79de3          	bne	a5,a4,35a <memset+0x12>
  }
  return dst;
}
 364:	6422                	ld	s0,8(sp)
 366:	0141                	addi	sp,sp,16
 368:	8082                	ret

000000000000036a <strchr>:

char*
strchr(const char *s, char c)
{
 36a:	1141                	addi	sp,sp,-16
 36c:	e422                	sd	s0,8(sp)
 36e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 370:	00054783          	lbu	a5,0(a0)
 374:	cb99                	beqz	a5,38a <strchr+0x20>
    if(*s == c)
 376:	00f58763          	beq	a1,a5,384 <strchr+0x1a>
  for(; *s; s++)
 37a:	0505                	addi	a0,a0,1
 37c:	00054783          	lbu	a5,0(a0)
 380:	fbfd                	bnez	a5,376 <strchr+0xc>
      return (char*)s;
  return 0;
 382:	4501                	li	a0,0
}
 384:	6422                	ld	s0,8(sp)
 386:	0141                	addi	sp,sp,16
 388:	8082                	ret
  return 0;
 38a:	4501                	li	a0,0
 38c:	bfe5                	j	384 <strchr+0x1a>

000000000000038e <gets>:

char*
gets(char *buf, int max)
{
 38e:	711d                	addi	sp,sp,-96
 390:	ec86                	sd	ra,88(sp)
 392:	e8a2                	sd	s0,80(sp)
 394:	e4a6                	sd	s1,72(sp)
 396:	e0ca                	sd	s2,64(sp)
 398:	fc4e                	sd	s3,56(sp)
 39a:	f852                	sd	s4,48(sp)
 39c:	f456                	sd	s5,40(sp)
 39e:	f05a                	sd	s6,32(sp)
 3a0:	ec5e                	sd	s7,24(sp)
 3a2:	1080                	addi	s0,sp,96
 3a4:	8baa                	mv	s7,a0
 3a6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3a8:	892a                	mv	s2,a0
 3aa:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3ac:	4aa9                	li	s5,10
 3ae:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3b0:	89a6                	mv	s3,s1
 3b2:	2485                	addiw	s1,s1,1
 3b4:	0344d863          	bge	s1,s4,3e4 <gets+0x56>
    cc = read(0, &c, 1);
 3b8:	4605                	li	a2,1
 3ba:	faf40593          	addi	a1,s0,-81
 3be:	4501                	li	a0,0
 3c0:	00000097          	auipc	ra,0x0
 3c4:	19a080e7          	jalr	410(ra) # 55a <read>
    if(cc < 1)
 3c8:	00a05e63          	blez	a0,3e4 <gets+0x56>
    buf[i++] = c;
 3cc:	faf44783          	lbu	a5,-81(s0)
 3d0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3d4:	01578763          	beq	a5,s5,3e2 <gets+0x54>
 3d8:	0905                	addi	s2,s2,1
 3da:	fd679be3          	bne	a5,s6,3b0 <gets+0x22>
  for(i=0; i+1 < max; ){
 3de:	89a6                	mv	s3,s1
 3e0:	a011                	j	3e4 <gets+0x56>
 3e2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3e4:	99de                	add	s3,s3,s7
 3e6:	00098023          	sb	zero,0(s3)
  return buf;
}
 3ea:	855e                	mv	a0,s7
 3ec:	60e6                	ld	ra,88(sp)
 3ee:	6446                	ld	s0,80(sp)
 3f0:	64a6                	ld	s1,72(sp)
 3f2:	6906                	ld	s2,64(sp)
 3f4:	79e2                	ld	s3,56(sp)
 3f6:	7a42                	ld	s4,48(sp)
 3f8:	7aa2                	ld	s5,40(sp)
 3fa:	7b02                	ld	s6,32(sp)
 3fc:	6be2                	ld	s7,24(sp)
 3fe:	6125                	addi	sp,sp,96
 400:	8082                	ret

0000000000000402 <stat>:

int
stat(const char *n, struct stat *st)
{
 402:	1101                	addi	sp,sp,-32
 404:	ec06                	sd	ra,24(sp)
 406:	e822                	sd	s0,16(sp)
 408:	e426                	sd	s1,8(sp)
 40a:	e04a                	sd	s2,0(sp)
 40c:	1000                	addi	s0,sp,32
 40e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 410:	4581                	li	a1,0
 412:	00000097          	auipc	ra,0x0
 416:	170080e7          	jalr	368(ra) # 582 <open>
  if(fd < 0)
 41a:	02054563          	bltz	a0,444 <stat+0x42>
 41e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 420:	85ca                	mv	a1,s2
 422:	00000097          	auipc	ra,0x0
 426:	178080e7          	jalr	376(ra) # 59a <fstat>
 42a:	892a                	mv	s2,a0
  close(fd);
 42c:	8526                	mv	a0,s1
 42e:	00000097          	auipc	ra,0x0
 432:	13c080e7          	jalr	316(ra) # 56a <close>
  return r;
}
 436:	854a                	mv	a0,s2
 438:	60e2                	ld	ra,24(sp)
 43a:	6442                	ld	s0,16(sp)
 43c:	64a2                	ld	s1,8(sp)
 43e:	6902                	ld	s2,0(sp)
 440:	6105                	addi	sp,sp,32
 442:	8082                	ret
    return -1;
 444:	597d                	li	s2,-1
 446:	bfc5                	j	436 <stat+0x34>

0000000000000448 <atoi>:

int
atoi(const char *s)
{
 448:	1141                	addi	sp,sp,-16
 44a:	e422                	sd	s0,8(sp)
 44c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 44e:	00054683          	lbu	a3,0(a0)
 452:	fd06879b          	addiw	a5,a3,-48
 456:	0ff7f793          	zext.b	a5,a5
 45a:	4625                	li	a2,9
 45c:	02f66863          	bltu	a2,a5,48c <atoi+0x44>
 460:	872a                	mv	a4,a0
  n = 0;
 462:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 464:	0705                	addi	a4,a4,1 # 80001 <base+0x7eff1>
 466:	0025179b          	slliw	a5,a0,0x2
 46a:	9fa9                	addw	a5,a5,a0
 46c:	0017979b          	slliw	a5,a5,0x1
 470:	9fb5                	addw	a5,a5,a3
 472:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 476:	00074683          	lbu	a3,0(a4)
 47a:	fd06879b          	addiw	a5,a3,-48
 47e:	0ff7f793          	zext.b	a5,a5
 482:	fef671e3          	bgeu	a2,a5,464 <atoi+0x1c>
  return n;
}
 486:	6422                	ld	s0,8(sp)
 488:	0141                	addi	sp,sp,16
 48a:	8082                	ret
  n = 0;
 48c:	4501                	li	a0,0
 48e:	bfe5                	j	486 <atoi+0x3e>

0000000000000490 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 490:	1141                	addi	sp,sp,-16
 492:	e422                	sd	s0,8(sp)
 494:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 496:	02b57463          	bgeu	a0,a1,4be <memmove+0x2e>
    while(n-- > 0)
 49a:	00c05f63          	blez	a2,4b8 <memmove+0x28>
 49e:	1602                	slli	a2,a2,0x20
 4a0:	9201                	srli	a2,a2,0x20
 4a2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4a6:	872a                	mv	a4,a0
      *dst++ = *src++;
 4a8:	0585                	addi	a1,a1,1
 4aa:	0705                	addi	a4,a4,1
 4ac:	fff5c683          	lbu	a3,-1(a1)
 4b0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4b4:	fee79ae3          	bne	a5,a4,4a8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4b8:	6422                	ld	s0,8(sp)
 4ba:	0141                	addi	sp,sp,16
 4bc:	8082                	ret
    dst += n;
 4be:	00c50733          	add	a4,a0,a2
    src += n;
 4c2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4c4:	fec05ae3          	blez	a2,4b8 <memmove+0x28>
 4c8:	fff6079b          	addiw	a5,a2,-1
 4cc:	1782                	slli	a5,a5,0x20
 4ce:	9381                	srli	a5,a5,0x20
 4d0:	fff7c793          	not	a5,a5
 4d4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4d6:	15fd                	addi	a1,a1,-1
 4d8:	177d                	addi	a4,a4,-1
 4da:	0005c683          	lbu	a3,0(a1)
 4de:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4e2:	fee79ae3          	bne	a5,a4,4d6 <memmove+0x46>
 4e6:	bfc9                	j	4b8 <memmove+0x28>

00000000000004e8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4e8:	1141                	addi	sp,sp,-16
 4ea:	e422                	sd	s0,8(sp)
 4ec:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4ee:	ca05                	beqz	a2,51e <memcmp+0x36>
 4f0:	fff6069b          	addiw	a3,a2,-1
 4f4:	1682                	slli	a3,a3,0x20
 4f6:	9281                	srli	a3,a3,0x20
 4f8:	0685                	addi	a3,a3,1
 4fa:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4fc:	00054783          	lbu	a5,0(a0)
 500:	0005c703          	lbu	a4,0(a1)
 504:	00e79863          	bne	a5,a4,514 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 508:	0505                	addi	a0,a0,1
    p2++;
 50a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 50c:	fed518e3          	bne	a0,a3,4fc <memcmp+0x14>
  }
  return 0;
 510:	4501                	li	a0,0
 512:	a019                	j	518 <memcmp+0x30>
      return *p1 - *p2;
 514:	40e7853b          	subw	a0,a5,a4
}
 518:	6422                	ld	s0,8(sp)
 51a:	0141                	addi	sp,sp,16
 51c:	8082                	ret
  return 0;
 51e:	4501                	li	a0,0
 520:	bfe5                	j	518 <memcmp+0x30>

0000000000000522 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 522:	1141                	addi	sp,sp,-16
 524:	e406                	sd	ra,8(sp)
 526:	e022                	sd	s0,0(sp)
 528:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 52a:	00000097          	auipc	ra,0x0
 52e:	f66080e7          	jalr	-154(ra) # 490 <memmove>
}
 532:	60a2                	ld	ra,8(sp)
 534:	6402                	ld	s0,0(sp)
 536:	0141                	addi	sp,sp,16
 538:	8082                	ret

000000000000053a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 53a:	4885                	li	a7,1
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <exit>:
.global exit
exit:
 li a7, SYS_exit
 542:	4889                	li	a7,2
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <wait>:
.global wait
wait:
 li a7, SYS_wait
 54a:	488d                	li	a7,3
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 552:	4891                	li	a7,4
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <read>:
.global read
read:
 li a7, SYS_read
 55a:	4895                	li	a7,5
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <write>:
.global write
write:
 li a7, SYS_write
 562:	48c1                	li	a7,16
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <close>:
.global close
close:
 li a7, SYS_close
 56a:	48d5                	li	a7,21
 ecall
 56c:	00000073          	ecall
 ret
 570:	8082                	ret

0000000000000572 <kill>:
.global kill
kill:
 li a7, SYS_kill
 572:	4899                	li	a7,6
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <exec>:
.global exec
exec:
 li a7, SYS_exec
 57a:	489d                	li	a7,7
 ecall
 57c:	00000073          	ecall
 ret
 580:	8082                	ret

0000000000000582 <open>:
.global open
open:
 li a7, SYS_open
 582:	48bd                	li	a7,15
 ecall
 584:	00000073          	ecall
 ret
 588:	8082                	ret

000000000000058a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 58a:	48c5                	li	a7,17
 ecall
 58c:	00000073          	ecall
 ret
 590:	8082                	ret

0000000000000592 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 592:	48c9                	li	a7,18
 ecall
 594:	00000073          	ecall
 ret
 598:	8082                	ret

000000000000059a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 59a:	48a1                	li	a7,8
 ecall
 59c:	00000073          	ecall
 ret
 5a0:	8082                	ret

00000000000005a2 <link>:
.global link
link:
 li a7, SYS_link
 5a2:	48cd                	li	a7,19
 ecall
 5a4:	00000073          	ecall
 ret
 5a8:	8082                	ret

00000000000005aa <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5aa:	48d1                	li	a7,20
 ecall
 5ac:	00000073          	ecall
 ret
 5b0:	8082                	ret

00000000000005b2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5b2:	48a5                	li	a7,9
 ecall
 5b4:	00000073          	ecall
 ret
 5b8:	8082                	ret

00000000000005ba <dup>:
.global dup
dup:
 li a7, SYS_dup
 5ba:	48a9                	li	a7,10
 ecall
 5bc:	00000073          	ecall
 ret
 5c0:	8082                	ret

00000000000005c2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5c2:	48ad                	li	a7,11
 ecall
 5c4:	00000073          	ecall
 ret
 5c8:	8082                	ret

00000000000005ca <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5ca:	48b1                	li	a7,12
 ecall
 5cc:	00000073          	ecall
 ret
 5d0:	8082                	ret

00000000000005d2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5d2:	48b5                	li	a7,13
 ecall
 5d4:	00000073          	ecall
 ret
 5d8:	8082                	ret

00000000000005da <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5da:	48b9                	li	a7,14
 ecall
 5dc:	00000073          	ecall
 ret
 5e0:	8082                	ret

00000000000005e2 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 5e2:	48d9                	li	a7,22
 ecall
 5e4:	00000073          	ecall
 ret
 5e8:	8082                	ret

00000000000005ea <getSysCount>:
.global getSysCount
getSysCount:
 li a7, SYS_getSysCount
 5ea:	48dd                	li	a7,23
 ecall
 5ec:	00000073          	ecall
 ret
 5f0:	8082                	ret

00000000000005f2 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 5f2:	48e1                	li	a7,24
 ecall
 5f4:	00000073          	ecall
 ret
 5f8:	8082                	ret

00000000000005fa <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 5fa:	48e5                	li	a7,25
 ecall
 5fc:	00000073          	ecall
 ret
 600:	8082                	ret

0000000000000602 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 602:	48e9                	li	a7,26
 ecall
 604:	00000073          	ecall
 ret
 608:	8082                	ret

000000000000060a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 60a:	1101                	addi	sp,sp,-32
 60c:	ec06                	sd	ra,24(sp)
 60e:	e822                	sd	s0,16(sp)
 610:	1000                	addi	s0,sp,32
 612:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 616:	4605                	li	a2,1
 618:	fef40593          	addi	a1,s0,-17
 61c:	00000097          	auipc	ra,0x0
 620:	f46080e7          	jalr	-186(ra) # 562 <write>
}
 624:	60e2                	ld	ra,24(sp)
 626:	6442                	ld	s0,16(sp)
 628:	6105                	addi	sp,sp,32
 62a:	8082                	ret

000000000000062c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 62c:	7139                	addi	sp,sp,-64
 62e:	fc06                	sd	ra,56(sp)
 630:	f822                	sd	s0,48(sp)
 632:	f426                	sd	s1,40(sp)
 634:	f04a                	sd	s2,32(sp)
 636:	ec4e                	sd	s3,24(sp)
 638:	0080                	addi	s0,sp,64
 63a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 63c:	c299                	beqz	a3,642 <printint+0x16>
 63e:	0805c963          	bltz	a1,6d0 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 642:	2581                	sext.w	a1,a1
  neg = 0;
 644:	4881                	li	a7,0
 646:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 64a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 64c:	2601                	sext.w	a2,a2
 64e:	00000517          	auipc	a0,0x0
 652:	65250513          	addi	a0,a0,1618 # ca0 <digits>
 656:	883a                	mv	a6,a4
 658:	2705                	addiw	a4,a4,1
 65a:	02c5f7bb          	remuw	a5,a1,a2
 65e:	1782                	slli	a5,a5,0x20
 660:	9381                	srli	a5,a5,0x20
 662:	97aa                	add	a5,a5,a0
 664:	0007c783          	lbu	a5,0(a5)
 668:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 66c:	0005879b          	sext.w	a5,a1
 670:	02c5d5bb          	divuw	a1,a1,a2
 674:	0685                	addi	a3,a3,1
 676:	fec7f0e3          	bgeu	a5,a2,656 <printint+0x2a>
  if(neg)
 67a:	00088c63          	beqz	a7,692 <printint+0x66>
    buf[i++] = '-';
 67e:	fd070793          	addi	a5,a4,-48
 682:	00878733          	add	a4,a5,s0
 686:	02d00793          	li	a5,45
 68a:	fef70823          	sb	a5,-16(a4)
 68e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 692:	02e05863          	blez	a4,6c2 <printint+0x96>
 696:	fc040793          	addi	a5,s0,-64
 69a:	00e78933          	add	s2,a5,a4
 69e:	fff78993          	addi	s3,a5,-1
 6a2:	99ba                	add	s3,s3,a4
 6a4:	377d                	addiw	a4,a4,-1
 6a6:	1702                	slli	a4,a4,0x20
 6a8:	9301                	srli	a4,a4,0x20
 6aa:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6ae:	fff94583          	lbu	a1,-1(s2)
 6b2:	8526                	mv	a0,s1
 6b4:	00000097          	auipc	ra,0x0
 6b8:	f56080e7          	jalr	-170(ra) # 60a <putc>
  while(--i >= 0)
 6bc:	197d                	addi	s2,s2,-1
 6be:	ff3918e3          	bne	s2,s3,6ae <printint+0x82>
}
 6c2:	70e2                	ld	ra,56(sp)
 6c4:	7442                	ld	s0,48(sp)
 6c6:	74a2                	ld	s1,40(sp)
 6c8:	7902                	ld	s2,32(sp)
 6ca:	69e2                	ld	s3,24(sp)
 6cc:	6121                	addi	sp,sp,64
 6ce:	8082                	ret
    x = -xx;
 6d0:	40b005bb          	negw	a1,a1
    neg = 1;
 6d4:	4885                	li	a7,1
    x = -xx;
 6d6:	bf85                	j	646 <printint+0x1a>

00000000000006d8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6d8:	7119                	addi	sp,sp,-128
 6da:	fc86                	sd	ra,120(sp)
 6dc:	f8a2                	sd	s0,112(sp)
 6de:	f4a6                	sd	s1,104(sp)
 6e0:	f0ca                	sd	s2,96(sp)
 6e2:	ecce                	sd	s3,88(sp)
 6e4:	e8d2                	sd	s4,80(sp)
 6e6:	e4d6                	sd	s5,72(sp)
 6e8:	e0da                	sd	s6,64(sp)
 6ea:	fc5e                	sd	s7,56(sp)
 6ec:	f862                	sd	s8,48(sp)
 6ee:	f466                	sd	s9,40(sp)
 6f0:	f06a                	sd	s10,32(sp)
 6f2:	ec6e                	sd	s11,24(sp)
 6f4:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6f6:	0005c903          	lbu	s2,0(a1)
 6fa:	18090f63          	beqz	s2,898 <vprintf+0x1c0>
 6fe:	8aaa                	mv	s5,a0
 700:	8b32                	mv	s6,a2
 702:	00158493          	addi	s1,a1,1
  state = 0;
 706:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 708:	02500a13          	li	s4,37
 70c:	4c55                	li	s8,21
 70e:	00000c97          	auipc	s9,0x0
 712:	53ac8c93          	addi	s9,s9,1338 # c48 <malloc+0x2ac>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 716:	02800d93          	li	s11,40
  putc(fd, 'x');
 71a:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 71c:	00000b97          	auipc	s7,0x0
 720:	584b8b93          	addi	s7,s7,1412 # ca0 <digits>
 724:	a839                	j	742 <vprintf+0x6a>
        putc(fd, c);
 726:	85ca                	mv	a1,s2
 728:	8556                	mv	a0,s5
 72a:	00000097          	auipc	ra,0x0
 72e:	ee0080e7          	jalr	-288(ra) # 60a <putc>
 732:	a019                	j	738 <vprintf+0x60>
    } else if(state == '%'){
 734:	01498d63          	beq	s3,s4,74e <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 738:	0485                	addi	s1,s1,1
 73a:	fff4c903          	lbu	s2,-1(s1)
 73e:	14090d63          	beqz	s2,898 <vprintf+0x1c0>
    if(state == 0){
 742:	fe0999e3          	bnez	s3,734 <vprintf+0x5c>
      if(c == '%'){
 746:	ff4910e3          	bne	s2,s4,726 <vprintf+0x4e>
        state = '%';
 74a:	89d2                	mv	s3,s4
 74c:	b7f5                	j	738 <vprintf+0x60>
      if(c == 'd'){
 74e:	11490c63          	beq	s2,s4,866 <vprintf+0x18e>
 752:	f9d9079b          	addiw	a5,s2,-99
 756:	0ff7f793          	zext.b	a5,a5
 75a:	10fc6e63          	bltu	s8,a5,876 <vprintf+0x19e>
 75e:	f9d9079b          	addiw	a5,s2,-99
 762:	0ff7f713          	zext.b	a4,a5
 766:	10ec6863          	bltu	s8,a4,876 <vprintf+0x19e>
 76a:	00271793          	slli	a5,a4,0x2
 76e:	97e6                	add	a5,a5,s9
 770:	439c                	lw	a5,0(a5)
 772:	97e6                	add	a5,a5,s9
 774:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 776:	008b0913          	addi	s2,s6,8
 77a:	4685                	li	a3,1
 77c:	4629                	li	a2,10
 77e:	000b2583          	lw	a1,0(s6)
 782:	8556                	mv	a0,s5
 784:	00000097          	auipc	ra,0x0
 788:	ea8080e7          	jalr	-344(ra) # 62c <printint>
 78c:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 78e:	4981                	li	s3,0
 790:	b765                	j	738 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 792:	008b0913          	addi	s2,s6,8
 796:	4681                	li	a3,0
 798:	4629                	li	a2,10
 79a:	000b2583          	lw	a1,0(s6)
 79e:	8556                	mv	a0,s5
 7a0:	00000097          	auipc	ra,0x0
 7a4:	e8c080e7          	jalr	-372(ra) # 62c <printint>
 7a8:	8b4a                	mv	s6,s2
      state = 0;
 7aa:	4981                	li	s3,0
 7ac:	b771                	j	738 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 7ae:	008b0913          	addi	s2,s6,8
 7b2:	4681                	li	a3,0
 7b4:	866a                	mv	a2,s10
 7b6:	000b2583          	lw	a1,0(s6)
 7ba:	8556                	mv	a0,s5
 7bc:	00000097          	auipc	ra,0x0
 7c0:	e70080e7          	jalr	-400(ra) # 62c <printint>
 7c4:	8b4a                	mv	s6,s2
      state = 0;
 7c6:	4981                	li	s3,0
 7c8:	bf85                	j	738 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 7ca:	008b0793          	addi	a5,s6,8
 7ce:	f8f43423          	sd	a5,-120(s0)
 7d2:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 7d6:	03000593          	li	a1,48
 7da:	8556                	mv	a0,s5
 7dc:	00000097          	auipc	ra,0x0
 7e0:	e2e080e7          	jalr	-466(ra) # 60a <putc>
  putc(fd, 'x');
 7e4:	07800593          	li	a1,120
 7e8:	8556                	mv	a0,s5
 7ea:	00000097          	auipc	ra,0x0
 7ee:	e20080e7          	jalr	-480(ra) # 60a <putc>
 7f2:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7f4:	03c9d793          	srli	a5,s3,0x3c
 7f8:	97de                	add	a5,a5,s7
 7fa:	0007c583          	lbu	a1,0(a5)
 7fe:	8556                	mv	a0,s5
 800:	00000097          	auipc	ra,0x0
 804:	e0a080e7          	jalr	-502(ra) # 60a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 808:	0992                	slli	s3,s3,0x4
 80a:	397d                	addiw	s2,s2,-1
 80c:	fe0914e3          	bnez	s2,7f4 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 810:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 814:	4981                	li	s3,0
 816:	b70d                	j	738 <vprintf+0x60>
        s = va_arg(ap, char*);
 818:	008b0913          	addi	s2,s6,8
 81c:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 820:	02098163          	beqz	s3,842 <vprintf+0x16a>
        while(*s != 0){
 824:	0009c583          	lbu	a1,0(s3)
 828:	c5ad                	beqz	a1,892 <vprintf+0x1ba>
          putc(fd, *s);
 82a:	8556                	mv	a0,s5
 82c:	00000097          	auipc	ra,0x0
 830:	dde080e7          	jalr	-546(ra) # 60a <putc>
          s++;
 834:	0985                	addi	s3,s3,1
        while(*s != 0){
 836:	0009c583          	lbu	a1,0(s3)
 83a:	f9e5                	bnez	a1,82a <vprintf+0x152>
        s = va_arg(ap, char*);
 83c:	8b4a                	mv	s6,s2
      state = 0;
 83e:	4981                	li	s3,0
 840:	bde5                	j	738 <vprintf+0x60>
          s = "(null)";
 842:	00000997          	auipc	s3,0x0
 846:	3fe98993          	addi	s3,s3,1022 # c40 <malloc+0x2a4>
        while(*s != 0){
 84a:	85ee                	mv	a1,s11
 84c:	bff9                	j	82a <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 84e:	008b0913          	addi	s2,s6,8
 852:	000b4583          	lbu	a1,0(s6)
 856:	8556                	mv	a0,s5
 858:	00000097          	auipc	ra,0x0
 85c:	db2080e7          	jalr	-590(ra) # 60a <putc>
 860:	8b4a                	mv	s6,s2
      state = 0;
 862:	4981                	li	s3,0
 864:	bdd1                	j	738 <vprintf+0x60>
        putc(fd, c);
 866:	85d2                	mv	a1,s4
 868:	8556                	mv	a0,s5
 86a:	00000097          	auipc	ra,0x0
 86e:	da0080e7          	jalr	-608(ra) # 60a <putc>
      state = 0;
 872:	4981                	li	s3,0
 874:	b5d1                	j	738 <vprintf+0x60>
        putc(fd, '%');
 876:	85d2                	mv	a1,s4
 878:	8556                	mv	a0,s5
 87a:	00000097          	auipc	ra,0x0
 87e:	d90080e7          	jalr	-624(ra) # 60a <putc>
        putc(fd, c);
 882:	85ca                	mv	a1,s2
 884:	8556                	mv	a0,s5
 886:	00000097          	auipc	ra,0x0
 88a:	d84080e7          	jalr	-636(ra) # 60a <putc>
      state = 0;
 88e:	4981                	li	s3,0
 890:	b565                	j	738 <vprintf+0x60>
        s = va_arg(ap, char*);
 892:	8b4a                	mv	s6,s2
      state = 0;
 894:	4981                	li	s3,0
 896:	b54d                	j	738 <vprintf+0x60>
    }
  }
}
 898:	70e6                	ld	ra,120(sp)
 89a:	7446                	ld	s0,112(sp)
 89c:	74a6                	ld	s1,104(sp)
 89e:	7906                	ld	s2,96(sp)
 8a0:	69e6                	ld	s3,88(sp)
 8a2:	6a46                	ld	s4,80(sp)
 8a4:	6aa6                	ld	s5,72(sp)
 8a6:	6b06                	ld	s6,64(sp)
 8a8:	7be2                	ld	s7,56(sp)
 8aa:	7c42                	ld	s8,48(sp)
 8ac:	7ca2                	ld	s9,40(sp)
 8ae:	7d02                	ld	s10,32(sp)
 8b0:	6de2                	ld	s11,24(sp)
 8b2:	6109                	addi	sp,sp,128
 8b4:	8082                	ret

00000000000008b6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8b6:	715d                	addi	sp,sp,-80
 8b8:	ec06                	sd	ra,24(sp)
 8ba:	e822                	sd	s0,16(sp)
 8bc:	1000                	addi	s0,sp,32
 8be:	e010                	sd	a2,0(s0)
 8c0:	e414                	sd	a3,8(s0)
 8c2:	e818                	sd	a4,16(s0)
 8c4:	ec1c                	sd	a5,24(s0)
 8c6:	03043023          	sd	a6,32(s0)
 8ca:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8ce:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8d2:	8622                	mv	a2,s0
 8d4:	00000097          	auipc	ra,0x0
 8d8:	e04080e7          	jalr	-508(ra) # 6d8 <vprintf>
}
 8dc:	60e2                	ld	ra,24(sp)
 8de:	6442                	ld	s0,16(sp)
 8e0:	6161                	addi	sp,sp,80
 8e2:	8082                	ret

00000000000008e4 <printf>:

void
printf(const char *fmt, ...)
{
 8e4:	711d                	addi	sp,sp,-96
 8e6:	ec06                	sd	ra,24(sp)
 8e8:	e822                	sd	s0,16(sp)
 8ea:	1000                	addi	s0,sp,32
 8ec:	e40c                	sd	a1,8(s0)
 8ee:	e810                	sd	a2,16(s0)
 8f0:	ec14                	sd	a3,24(s0)
 8f2:	f018                	sd	a4,32(s0)
 8f4:	f41c                	sd	a5,40(s0)
 8f6:	03043823          	sd	a6,48(s0)
 8fa:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8fe:	00840613          	addi	a2,s0,8
 902:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 906:	85aa                	mv	a1,a0
 908:	4505                	li	a0,1
 90a:	00000097          	auipc	ra,0x0
 90e:	dce080e7          	jalr	-562(ra) # 6d8 <vprintf>
}
 912:	60e2                	ld	ra,24(sp)
 914:	6442                	ld	s0,16(sp)
 916:	6125                	addi	sp,sp,96
 918:	8082                	ret

000000000000091a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 91a:	1141                	addi	sp,sp,-16
 91c:	e422                	sd	s0,8(sp)
 91e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 920:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 924:	00000797          	auipc	a5,0x0
 928:	6dc7b783          	ld	a5,1756(a5) # 1000 <freep>
 92c:	a02d                	j	956 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 92e:	4618                	lw	a4,8(a2)
 930:	9f2d                	addw	a4,a4,a1
 932:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 936:	6398                	ld	a4,0(a5)
 938:	6310                	ld	a2,0(a4)
 93a:	a83d                	j	978 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 93c:	ff852703          	lw	a4,-8(a0)
 940:	9f31                	addw	a4,a4,a2
 942:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 944:	ff053683          	ld	a3,-16(a0)
 948:	a091                	j	98c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 94a:	6398                	ld	a4,0(a5)
 94c:	00e7e463          	bltu	a5,a4,954 <free+0x3a>
 950:	00e6ea63          	bltu	a3,a4,964 <free+0x4a>
{
 954:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 956:	fed7fae3          	bgeu	a5,a3,94a <free+0x30>
 95a:	6398                	ld	a4,0(a5)
 95c:	00e6e463          	bltu	a3,a4,964 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 960:	fee7eae3          	bltu	a5,a4,954 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 964:	ff852583          	lw	a1,-8(a0)
 968:	6390                	ld	a2,0(a5)
 96a:	02059813          	slli	a6,a1,0x20
 96e:	01c85713          	srli	a4,a6,0x1c
 972:	9736                	add	a4,a4,a3
 974:	fae60de3          	beq	a2,a4,92e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 978:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 97c:	4790                	lw	a2,8(a5)
 97e:	02061593          	slli	a1,a2,0x20
 982:	01c5d713          	srli	a4,a1,0x1c
 986:	973e                	add	a4,a4,a5
 988:	fae68ae3          	beq	a3,a4,93c <free+0x22>
    p->s.ptr = bp->s.ptr;
 98c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 98e:	00000717          	auipc	a4,0x0
 992:	66f73923          	sd	a5,1650(a4) # 1000 <freep>
}
 996:	6422                	ld	s0,8(sp)
 998:	0141                	addi	sp,sp,16
 99a:	8082                	ret

000000000000099c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 99c:	7139                	addi	sp,sp,-64
 99e:	fc06                	sd	ra,56(sp)
 9a0:	f822                	sd	s0,48(sp)
 9a2:	f426                	sd	s1,40(sp)
 9a4:	f04a                	sd	s2,32(sp)
 9a6:	ec4e                	sd	s3,24(sp)
 9a8:	e852                	sd	s4,16(sp)
 9aa:	e456                	sd	s5,8(sp)
 9ac:	e05a                	sd	s6,0(sp)
 9ae:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9b0:	02051493          	slli	s1,a0,0x20
 9b4:	9081                	srli	s1,s1,0x20
 9b6:	04bd                	addi	s1,s1,15
 9b8:	8091                	srli	s1,s1,0x4
 9ba:	0014899b          	addiw	s3,s1,1
 9be:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9c0:	00000517          	auipc	a0,0x0
 9c4:	64053503          	ld	a0,1600(a0) # 1000 <freep>
 9c8:	c515                	beqz	a0,9f4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ca:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9cc:	4798                	lw	a4,8(a5)
 9ce:	02977f63          	bgeu	a4,s1,a0c <malloc+0x70>
 9d2:	8a4e                	mv	s4,s3
 9d4:	0009871b          	sext.w	a4,s3
 9d8:	6685                	lui	a3,0x1
 9da:	00d77363          	bgeu	a4,a3,9e0 <malloc+0x44>
 9de:	6a05                	lui	s4,0x1
 9e0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9e4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9e8:	00000917          	auipc	s2,0x0
 9ec:	61890913          	addi	s2,s2,1560 # 1000 <freep>
  if(p == (char*)-1)
 9f0:	5afd                	li	s5,-1
 9f2:	a895                	j	a66 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 9f4:	00000797          	auipc	a5,0x0
 9f8:	61c78793          	addi	a5,a5,1564 # 1010 <base>
 9fc:	00000717          	auipc	a4,0x0
 a00:	60f73223          	sd	a5,1540(a4) # 1000 <freep>
 a04:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a06:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a0a:	b7e1                	j	9d2 <malloc+0x36>
      if(p->s.size == nunits)
 a0c:	02e48c63          	beq	s1,a4,a44 <malloc+0xa8>
        p->s.size -= nunits;
 a10:	4137073b          	subw	a4,a4,s3
 a14:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a16:	02071693          	slli	a3,a4,0x20
 a1a:	01c6d713          	srli	a4,a3,0x1c
 a1e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a20:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a24:	00000717          	auipc	a4,0x0
 a28:	5ca73e23          	sd	a0,1500(a4) # 1000 <freep>
      return (void*)(p + 1);
 a2c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a30:	70e2                	ld	ra,56(sp)
 a32:	7442                	ld	s0,48(sp)
 a34:	74a2                	ld	s1,40(sp)
 a36:	7902                	ld	s2,32(sp)
 a38:	69e2                	ld	s3,24(sp)
 a3a:	6a42                	ld	s4,16(sp)
 a3c:	6aa2                	ld	s5,8(sp)
 a3e:	6b02                	ld	s6,0(sp)
 a40:	6121                	addi	sp,sp,64
 a42:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a44:	6398                	ld	a4,0(a5)
 a46:	e118                	sd	a4,0(a0)
 a48:	bff1                	j	a24 <malloc+0x88>
  hp->s.size = nu;
 a4a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a4e:	0541                	addi	a0,a0,16
 a50:	00000097          	auipc	ra,0x0
 a54:	eca080e7          	jalr	-310(ra) # 91a <free>
  return freep;
 a58:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a5c:	d971                	beqz	a0,a30 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a5e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a60:	4798                	lw	a4,8(a5)
 a62:	fa9775e3          	bgeu	a4,s1,a0c <malloc+0x70>
    if(p == freep)
 a66:	00093703          	ld	a4,0(s2)
 a6a:	853e                	mv	a0,a5
 a6c:	fef719e3          	bne	a4,a5,a5e <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 a70:	8552                	mv	a0,s4
 a72:	00000097          	auipc	ra,0x0
 a76:	b58080e7          	jalr	-1192(ra) # 5ca <sbrk>
  if(p == (char*)-1)
 a7a:	fd5518e3          	bne	a0,s5,a4a <malloc+0xae>
        return 0;
 a7e:	4501                	li	a0,0
 a80:	bf45                	j	a30 <malloc+0x94>
