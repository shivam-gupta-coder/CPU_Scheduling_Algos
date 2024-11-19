#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "memlayout.h"
#include "syscall.h"
uint64
sys_exit(void)
{
  myproc()->syscall_count[SYS_exit]++;
  int n;
  argint(0, &n);
  exit(n);
  return 0; // not reached
}

uint64
sys_getpid(void)
{
  myproc()->syscall_count[SYS_getpid]++;
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  myproc()->syscall_count[SYS_fork]++;
  return fork();
}

uint64
sys_wait(void)
{
  myproc()->syscall_count[SYS_wait]++;
  uint64 p;
  argaddr(0, &p);
  return wait(p);
}

uint64
sys_sbrk(void)
{
  myproc()->syscall_count[SYS_sbrk]++;
  uint64 addr;
  int n;

  argint(0, &n);
  addr = myproc()->sz;
  if (growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  myproc()->syscall_count[SYS_sleep]++;
  int n;
  uint ticks0;

  argint(0, &n);
  acquire(&tickslock);
  ticks0 = ticks;
  while (ticks - ticks0 < n)
  {
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  myproc()->syscall_count[SYS_kill]++;
  int pid;

  argint(0, &pid);
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  myproc()->syscall_count[SYS_uptime]++;
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint64
sys_waitx(void)
{
  myproc()->syscall_count[SYS_waitx]++;
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
  argaddr(1, &addr1); // user virtual memory
  argaddr(2, &addr2);
  int ret = waitx(addr, &wtime, &rtime);
  struct proc *p = myproc();
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    return -1;
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    return -1;
  return ret;
}
int sys_getSysCount(void) {
  myproc()->syscall_count[SYS_getSysCount]++;
    int mask; // Get the mask argument
    argint(0,&mask);
    
    struct proc *p = myproc();
    // Find the syscall index from the mask
    int syscall_index = -1;
    for (int i = 0; i < 32; i++) {
        if (mask & (1 << i)) {
            syscall_index = i;
            break;
        }
    }

    if (syscall_index == -1 || syscall_index >= NELEM(p->syscall_count)) {
        return -1; // Invalid mask or syscall index
    }

    return p->syscall_count[syscall_index]; // Return the count for that syscall
}
uint64 sys_sigalarm(void)
{
  myproc()->syscall_count[SYS_sigalarm]++;
  uint64 addr;
  int ticks;
  argint(0, &ticks);
    // return -1;
  argaddr(1, &addr);
  myproc()->ticks = ticks;
  myproc()->handler = addr;
  return 0;
}
uint64 sys_sigreturn(void)
{
  myproc()->syscall_count[SYS_sigreturn]++;
  struct proc *p = myproc();
  memmove(p->trapframe, p->alarm_tf, PGSIZE);

  kfree(p->alarm_tf);
  p->alarm_tf = 0;
  p->alarm_on = 0;
  p->cur_ticks = 0;
  p->in_alarm_handler = 0;
  usertrapret();
  return 0;
}
uint64 sys_settickets(void) {
  myproc()->syscall_count[SYS_settickets]++;
  int n;
  argint(0, &n);
  myproc()->tickets = n;
  return 0;
}
// uint64
// sys_setpriority(void)
// {
//   int priority, pid;
//   argint(0, &priority);
//   argint(1, &pid);
//   return sys_setpriority(priority, pid); 
// }


