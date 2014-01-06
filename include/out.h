#import <Foundation/Foundation.h>

#define CLUTCH_DEBUG // flag to enable debug logging

#define FILE_NAME (strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : __FILE__) // shortened path of __FILE__ is there is one

#ifdef CLUTCH_DEBUG
#   define DEV(M, ...) fprintf(stderr, "\033[0;32mDEBUG\033[0m | %s\t|\t" M "\n", FILE_NAME, [[NSString stringWithFormat:M, ##__VA_ARGS__] UTF8String]);
#   define NSLog(M, ...) fprintf(stderr, "\033[0;32mDEBUG\033[0m | %s:%d\t|\t%s\n", FILE_NAME, __LINE__, [[NSString stringWithFormat:M, ##__VA_ARGS__] UTF8String]);
#else
#   define DEBUG(M, ...)
#   define NSLog(...)
#endif

#define ERROR(M, ...) fprintf(stderr, "\033[1;31mERROR\033[0m | %s:%d\t|\t%s\n", FILE_NAME, __LINE__, [[NSString stringWithFormat:M, ##__VA_ARGS__] UTF8String]); // prints error
#define VERBOSE(M, ...) fprintf(stderr, "%s\n", [[NSString stringWithFormat:M, ##__VA_ARGS__] UTF8String]); // prints verbose
#define PERCENT(x) progress_percent(x);

#if defined __cplusplus
extern "C" {
#endif
    
int determine_screen_width();
void progress_percent(int percent);
void print_bar();
void stop_bar();
void pause_bar();

#if defined __cplusplus
};
#endif


