# xv6

# Explanation of implemented code

## System Calls 

### Gotta count ‘em all
Defined a daata structure (array) in struct proc named 'syscalls' to store the the number of times a particular system call was called. All system calls have been specified in sysproc.c . So in each of the implementations of these syscalls in sysproc.c I incremented their counts in my data structure. In `syscount.c`, I first obtain the correct syscall number from the mask provided. Then, I fork the process and exec for the provided program. This will result in the `syscount` of the child process being added to the parent, which is initially 0. So, now I just print the corresponding `syscount` from the parent process.

### WAKE ME UP WHEN MY TIMER ENDS 
Defined new parameters in 'proc.h' file named alarm_on (to check whether alarm is raised) , ticks (already given) , cur_ticks (current ticks of a process) and in_alarm_handler flag. 
Now in 'trap.c' file I am making changes to usertrap function. In the if(which_dev==2) code block, I am checking the state of process first and if it is in running state I first increment the current ticks of the process. Now if the current ticks of the process exceed the number of ticks since the last alarm the in_alarm_handler flag is set to 1 indicating that process is now inside alarm handler. When the process is interrupted, its CPU state (registers, program counter, etc.) is stored in its trapframe. Since we're about to change the execution flow to run the alarm handler, we need to save the current trapframe so that, after the alarm handler finishes, the process can resume from where it was interrupted.p->alarm_tf is then set to point to this saved trapframe, allowing it to be restored later.
p->trapframe->epc: This is the program counter (epc) in the trapframe, which determines where the process will resume execution when it returns to user space. By setting this to p->handler, we ensure that the next time the process runs, it will jump to the user-defined alarm handler function.
p->cur_ticks = 0: This resets the tick counter so that the process can start counting CPU time again after the alarm handler completes.
 sigreturn system call- added in sysproc.c Explanation- This  system call restores a process's state after its alarm handler finishes executing. It does this by copying the saved trapframe (which holds the CPU state before the alarm) back into the current trapframe, allowing the process to resume normal execution. The function then frees the memory used for storing the alarm's trapframe, resets the alarm-related fields (such as disabling the alarm and clearing tick counters), and finally returns control to user space for the process to continue where it left off.
 sigalarm system call- added in sysproc.c file. Explanation of code - This system call  increments the syscall count for SYS_sigalarm, retrieves the number of ticks until the alarm triggers and the address of the user-defined alarm handler from the arguments, and stores these values in the process's proc structure. Finally, it returns 0 to indicate success.

 ### SCHEDULING 

 1. LBS- Changes were made in proc.c file and proc.h file. Declared new parameters arrival_time (effectively equal to ctime of process) & tickets (allocated tickets). Intitially set tickets of all processes to 1 . This change was made in 'allocproc' function in proc.c file. To implement the specification major change was made in 'scheduler' function present in proc.c file.  Also rand() function was added to proc.c file which draws out a random number that acts as ticket number owned by winning process. 

Explanation of code wriiten under #ifdef LBS block in scheduler function: Calculate Total Tickets:
    The code iterates through all processes in the system, accumulating the total number of tickets from all RUNNABLE processes while ensuring thread safety with locks.
Random Lottery Selection:
    If there are tickets available, a random value is generated between 1 and the total number of tickets.
    It iterates again through the processes, summing their tickets until it finds a process whose cumulative ticket count meets or exceeds the random value, designating it as the winner.
Resolve Ties:
    If multiple RUNNABLE processes have the same number of tickets as the winner, it selects the one that arrived first.
Context Switch:
    The winning process's state is updated to RUNNING, and a context switch occurs to transfer control from the current process to the winner.

Additional Note- A set tickets function is also added to sys_proc.c file that allows us to vary the tickets of a process initially other than 1 .

2. MLFQ - For implementing MLFQ based scheduling changes have been made majorly to proc.h , proc.c and trap.c files.
Changes made to proc.h- Declared parameters queue_number (to decide priority of a process) and queue_ticks (how many ticks have passed since a process enetered a particular queue). They have been initially set to zero in allocproc function in proc.c file.
Changes made to proc.c- Declared a structure called multique which comprises of 4 queues having max size of NPROC. Declared an array of size 4 named sizeofq to store the sizes of the 4 queues present in mutlique data structure. To take care of time slices of different queues (prioritywise) we have made an array named timesliceq comprising of 4 values namely 1,4,8 and 16. Added functions enqueue (to add a process to a particular queue present  and setting queue_number of that process to that queue. Also queue_ticks have been set to 0) and dequeue(iterates through queue_number of the process that we want to dequeue and then adjusts the indexing of other processes in the queue accordingly after removing the specified process). Changes have been made to other functions as well. These are as follows -
fork- In this function I am adding the process to the queue before lock is released. 
kill- In this function when the state of the process becomes runnable I am adding it back again to its original queue number.
sleep- In this function since the state of process changes from running to sleeping we have to dequeue this process from its current queue.
wakeup- In this function since process is waking up from its sleep and its state is getting changed to runnable I am adding it to its original queue_number using enqueue function. 
freeproc- Removed the process from the queue.
Changes made in trap.c file-  Basically changes hve been made to trap.c to take care of priority boosts and preemptions. For priority boosting, we are checking every 48 ticks (when ticks%48==0) and iterating through our multique structure comprising of all queues and then dequeueing the processes (apart from those in queue 0) and enqueueing them to queue 0.  Also for handling time slice part, I compared the queue_ticks of the process with the given time slice and then demoted it accordingly.

Average running and waiting time recorded on implementing different scheduling policies -
1. LBS - Average rtime- 11 Average wtime-136
2. RR - Average rtime- 10 Average wtime- 135
3. MLFQ Average rtime- 10 Average wtime- 134

Implication of adding arrival times in LBS - We are adding arrival times because of the fact that we can have a scenario where same number of tickets are allocated to each process, in that case the process with least arrival time has to be picked. The pitfall to watch out for regarding this implementation is that if all processes have same tickets it will ultimately lead to FCFS (first come first serve) scheduling algorithm which is not very efficient. 

Analysis of MLFQ  

From the graph we can infer the behaviour of code and also the priority boosts along with preemption.
/home/shivamgupta/Desktop/mini-project-2-loser2208-master/initial-xv6/src/mlfq_timeline_for_1_CPU_one_Cpu2.png



