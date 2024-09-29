#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "battery_monitor.h"

#define BUFFER_SIZE 1024

int get_high_cpu_processes(char *process_list[], int max_processes) {
    FILE *fp;
    char buffer[BUFFER_SIZE];
    int process_count = 0;

    // Command to get the top CPU-using processes for the user 'klein', excluding vi, neovim, vim, and root processes
    const char *command = "ps -eo user,pid,comm,%cpu --sort=-%cpu | grep '^klein' | grep -vE '(vi|vim|neovim|root)'";

    fp = popen(command, "r");
    if (fp == NULL) {
        log_message("Failed to run command to get high CPU processes");
        return -1;
    }

    while (fgets(buffer, sizeof(buffer), fp) != NULL && process_count < max_processes) {
        char user[50], command_name[100];
        int pid;
        float cpu_usage;

        // Parse the line to extract the user, PID, command name, and CPU usage
        sscanf(buffer, "%49s %d %99s %f", user, &pid, command_name, &cpu_usage);

        // Store the command in the process list
        process_list[process_count] = malloc(BUFFER_SIZE);
        snprintf(process_list[process_count], BUFFER_SIZE, "%d", pid);
        process_count++;
    }

    pclose(fp);
    return process_count;
}

void free_process_list(char *process_list[], int count) {
    for (int i = 0; i < count; i++) {
        free(process_list[i]);
    }
}
