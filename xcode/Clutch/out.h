#define CLUTCH_DEBUG 1

#ifdef CLUTCH_DEBUG
#   define FILE_NAME (strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : __FILE__) // shortened path of __FILE__ is there is one
#   define DEV(M, ...) fprintf(stderr, "\033[0;32mDEBUG\033[0m | %s | " M "\n", FILE_NAME, ##__VA_ARGS__);
#   define NSLog(M, ...) fprintf(stderr, "\033[0;32mDEBUG\033[0m | %s:%d | %s\n", FILE_NAME, __LINE__, [[NSString stringWithFormat:M, ##__VA_ARGS__] UTF8String]);
#else
#   define DEBUG(M, ...)
#   define NSLog(...)
#endif
