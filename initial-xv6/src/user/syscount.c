#include "kernel/types.h"
#include "kernel/stat.h"
#include "user.h"
// Function to get the syscall name from the mask
const char* getSyscallName(int mask) {
    switch (mask) {
        case 1 << 0: return "fork";
        case 1 << 1: return "exit";
        case 1 << 2: return "wait";
        case 1 << 3: return "pipe";
        case 1 << 4: return "read";
        case 1 << 5: return "kill";
        case 1 << 6: return "exec";
        case 1 << 7: return "fstat";
        case 1 << 8: return "chdir";
        case 1 << 9: return "dup";
        case 1 << 10: return "getpid";
        case 1 << 11: return "sbrk";
        case 1 << 12: return "sleep";
        case 1 << 13: return "uptime";
        case 1 << 14: return "open";
        case 1 << 15: return "write";
        case 1 << 16: return "mknod";
        case 1 << 17: return "unlink";
        case 1 << 18: return "fchmod";
        case 1 << 19: return "link";
        case 1 << 20: return "mkdir";
        case 1 << 21: return "close";
        default: return "unknown";
    }
}

int main(int argc, char *argv[]) {
    if (argc < 3) {
        printf("Usage: syscount <mask> <command> [args]\n");
        exit(1);
    }

    int mask = atoi(argv[1]);
    if (mask <= 0 || (mask & (mask - 1)) != 0) {
        printf("Error: Mask must be a power of 2.\n");
        exit(1);
    }

    int pid = fork();
    int ct2=getSysCount(mask);

    if (pid == 0) {
        // Child process executes the command
        exec(argv[2], argv + 2);
        exit(0);
    } else {
        wait(0);

        // Get the syscall count
        int ct1= getSysCount(mask);
        const char* syscall_name = getSyscallName(mask/2);
        int answer=ct1-ct2;
        printf("PID %d called %s %d times.\n", pid, syscall_name, answer);
    }

    exit(0);
}
