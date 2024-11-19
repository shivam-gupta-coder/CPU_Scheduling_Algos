#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

struct spinlock tickslock;
uint ticks;

extern char trampoline[], uservec[], userret[];

extern void enqueue(struct proc *p, int priorityq);
extern void dequeue(struct proc *p, int priorityq);

extern struct proc *multique[4][NPROC];
extern int sizeofq[4];
extern int timesliceq[4];


// in kernelvec.S, calls kerneltrap().
void kernelvec();

extern int devintr();

void trapinit(void)
{
  initlock(&tickslock, "time");
}

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
  w_stvec((uint64)kernelvec);
}

//
// handle an interrupt, exception, or system call from user space.
// called from trampoline.S
//
void usertrap(void)
{
  int which_dev = 0;

  if ((r_sstatus() & SSTATUS_SPP) != 0)
    panic("usertrap: not from user mode");

  // send interrupts and exceptions to kerneltrap(),
  // since we're now in the kernel.
  w_stvec((uint64)kernelvec);

  struct proc *p = myproc();

  // save user program counter.
  p->trapframe->epc = r_sepc();

  if (r_scause() == 8)
  {
    // system call
    if (killed(p))
      exit(-1);

    p->trapframe->epc += 4;
    intr_on();

    syscall();
  }
  else if ((which_dev = devintr()) != 0)
  {
    // Handle timer interrupts (which_dev == 2)
    // if (which_dev == 2)
    // {
     
    // }
    // do nothing 
  }
  else
  {
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    setkilled(p);
  }

  if (killed(p))
    exit(-1);

  if (which_dev == 2)
  {
    struct proc* p=myproc();
 
     if (p != 0 && p->state == RUNNING)
    {
      p->cur_ticks++;
      if (p->ticks > 0 && p->cur_ticks >= p->ticks && p->in_alarm_handler == 0)
      {
        p->in_alarm_handler = 1;
        
        // Allocate and save the current trapframe before switching to the alarm handler
        struct trapframe *tf = kalloc();
        if (tf == 0)
        panic("usertrap: failed to allocate memory for alarm trapframe");
        memmove(tf, p->trapframe, sizeof(struct trapframe));
        p->alarm_tf = tf;

        // Set the process to jump to the handler and reset cur_ticks
        p->trapframe->epc = p->handler;
        p->cur_ticks = 0;
      }
    }

    
    #ifdef MLFQ
      p->queueticks++;
      struct proc*temp;
      if(ticks%48 == 0){
        // DO PRIORITY BOOST
        for(int level = 1;level < 4 ;level++){
          for (int j = 0; j<sizeofq[level];j++)
          {
            
            temp = multique[level][j];
            dequeue(temp, temp->queue_number); // Remove from the current queue
            enqueue(temp, 0);               // Insert at the end of queue 0
        
          }
        }
        // for(struct proc* i=0;i<&proc[NPROC];i++) {
        //   if(i->state!=RUNNABLE) i->queue_number=0;
        // }
      }

      if(p->queueticks >= timesliceq[p->queue_number]){
        // logic to move p to next queue.
        dequeue(p,p->queue_number);
        int npriority = p->queue_number + 1;
        if(npriority > 3 )npriority--;
        enqueue(p,npriority);
        
        // printf("data of queue %d nprio- %d sizeofq %d : |",p->queue_number,npriority,sizeofq[p->queue_number]);
        // for(int i=0;i<sizeofq[p->priority];i++){
        //   printf("%d  ",multique[1][i]->pid);
        // }
        // printf("|\n");
      
        yield();
      }

      // condition to check whether some other process is present above this process so current process should be prempted
      for(int i=0;i<p->queue_number;i++){
        if(sizeofq[i] > 0) yield();
      }
    #else
    yield();
    #endif 
  }
  usertrapret();
}
//
// return to user space
//
void usertrapret(void)
{
  struct proc *p = myproc();

  // we're about to switch the destination of traps from
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
  p->trapframe->kernel_trap = (uint64)usertrap;
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()

  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
  x |= SSTATUS_SPIE; // enable interrupts in user mode
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
  ((void (*)(uint64))trampoline_userret)(satp);
}

// interrupts and exceptions from kernel code go here via kernelvec,
// on whatever the current kernel stack is.
void kerneltrap()
{
  int which_dev = 0;
  uint64 sepc = r_sepc();
  uint64 sstatus = r_sstatus();
  uint64 scause = r_scause();

  if ((sstatus & SSTATUS_SPP) == 0)
    panic("kerneltrap: not from supervisor mode");
  if (intr_get() != 0)
    panic("kerneltrap: interrupts enabled");

  if ((which_dev = devintr()) == 0)
  {
    printf("scause %p\n", scause);
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    panic("kerneltrap");
  }

  // give up the CPU if this is a timer interrupt.
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    yield();

  // the yield() may have caused some traps to occur,
  // so restore trap registers for use by kernelvec.S's sepc instruction.
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
  acquire(&tickslock);
  ticks++;
  update_time();
  // for (struct proc *p = proc; p < &proc[NPROC]; p++)
  // {
  //   acquire(&p->lock);
  //   if (p->state == RUNNING)
  //   {
  //     printf("here");
  //     p->rtime++;
  //   }
  //   // if (p->state == SLEEPING)
  //   // {
  //   //   p->wtime++;
  //   // }
  //   release(&p->lock);
  // }
  wakeup(&ticks);
  release(&tickslock);
}

// check if it's an external interrupt or software interrupt,
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
      (scause & 0xff) == 9)
  {
    // this is a supervisor external interrupt, via PLIC.

    // irq indicates which device interrupted.
    int irq = plic_claim();

    if (irq == UART0_IRQ)
    {
      uartintr();
    }
    else if (irq == VIRTIO0_IRQ)
    {
      virtio_disk_intr();
    }
    else if (irq)
    {
      printf("unexpected interrupt irq=%d\n", irq);
    }

    // the PLIC allows each device to raise at most one
    // interrupt at a time; tell the PLIC the device is
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
  {
    // software interrupt from a machine-mode timer interrupt,
    // forwarded by timervec in kernelvec.S.

    if (cpuid() == 0)
    {
      clockintr();
    }

    // acknowledge the software interrupt by clearing
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  }
  else
  {
    return 0;
  }
}
