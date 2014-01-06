
//
//  out.mm
//  Clutch
//
//  Created by Ninja on 04/01/2014.
//
//

#import "out.h"
#import <sys/ioctl.h>
#import <sys/types.h>

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

int determine_screen_width()
{
    int fd;
    struct winsize wsz;
    
    fd = fileno(stderr);
    
    if (ioctl(fd, TIOCGWINSZ, &wsz) < 0)
    {
        return 0;
    }
    
    return wsz.ws_col;
}

int bar_mode = 0; // 0 = inactive, 1 = active
int bar_percent = -1; // negative is no bar
char bar_msg[200]; // msg buffer

void progress_percent(int percent) {
    if ((bar_percent < percent - 5) || (percent == 100) || (percent < 0)) {
        bar_percent = percent;
        print_bar();
    }
}

void print_bar()
{
    if (bar_mode == 1)
    {
        printf("\033[0G\033[J");
    }
    
    bar_mode = 1;
    
    int width = determine_screen_width();
    
    if (bar_percent < 0)
    {
        if (strlen(bar_msg) > (width - 5))
        {
            strncpy(bar_msg + width - 5, "...", 4);
        }
        
        printf("%s", bar_msg);
        fflush(stdout);
    }
    else
    {
        int pstart = floor(width / 2);
        int pwidth = width - pstart;
        int barwidth = ceil((pwidth - 7) * (((double)bar_percent) / 100));
        int spacewidth = (pwidth - 7) - barwidth;
        
        if (strlen(bar_msg) > (pstart - 5)) {
            strncpy(bar_msg + pstart - 5, "...", 4);
        }
        
        printf("%s [", bar_msg);
        
        for (int i = 0; i < barwidth; i++) {
            printf("=");
        }
        
        for (int i = 0; i < spacewidth; i++) {
            printf(" ");
        }
        
        printf("] %d%%", bar_percent);
        
        fflush(stdout);
    }
}

void pause_bar(void) {
    if (bar_mode == 1) {
        printf("\033[0G\033[J");
        fflush(stdout);
    }
    
    bar_mode = 0;
}

void stop_bar(void) {
    if (bar_mode == 1) {
        printf("\033[0G\033[J");
        fflush(stdout);
        bar_mode = 0;
        bar_percent = -1;
    }
}