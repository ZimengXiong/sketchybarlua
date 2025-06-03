#include "../sketchybar.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/sysctl.h>
#include <string.h>

int main(int argc, char** argv) {
    float update_freq;
    if (argc < 3 || (sscanf(argv[2], "%f", &update_freq) != 1)) {
        printf("Usage: %s \"<event-name>\" \"<event_freq>\"\n", argv[0]);
        exit(1);
    }

    alarm(0);
    
    char event_message[512];
    snprintf(event_message, 512, "--add event '%s'", argv[1]);
    sketchybar(event_message);
    
    for (;;) {
        int pressure_level = 0;
        size_t size = sizeof(pressure_level);
        sysctlbyname("kern.memorystatus_vm_pressure_level", &pressure_level, &size, NULL, 0);
        
        char swap_output[256] = {0};
        FILE *fp = popen("sysctl vm.swapusage 2>/dev/null", "r");
        if (fp != NULL) {
            fgets(swap_output, sizeof(swap_output), fp);
            pclose(fp);
        }
        
        float total_swap = 0.0, used_swap = 0.0;
        char *total_ptr = strstr(swap_output, "total = ");
        char *used_ptr = strstr(swap_output, "used = ");
        
        if (total_ptr) {
            sscanf(total_ptr + 8, "%fM", &total_swap);
        }
        if (used_ptr) {
            sscanf(used_ptr + 7, "%fM", &used_swap);
        }
        
        float swap_percentage = (total_swap > 0) ? (used_swap / total_swap) * 100.0 : 0.0;
        
        const char* pressure_status = "NORMAL";
        if (pressure_level >= 4) {
            pressure_status = "CRITICAL";
        } else if (pressure_level >= 2) {
            pressure_status = "HIGH";
        } else if (pressure_level >= 1) {
            pressure_status = "LOW";
        }
        
        char event[512];
        snprintf(event, sizeof(event), 
                "--trigger '%s' "
                "pressure_level=%d "
                "pressure_status=%s "
                "swap_total=%.1f "
                "swap_used=%.1f "
                "swap_percentage=%.1f",
                argv[1], pressure_level, pressure_status, total_swap, used_swap, swap_percentage);
        
        sketchybar(event);
        
        usleep(update_freq * 1000000);
    }
    
    return 0;
}
