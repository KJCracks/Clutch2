/*
    ___ _       _       _
   / __\ |_   _| |_ ___| |__
  / /  | | | | | __/ __| '_ \
 / /___| | |_| | || (__| | | |
 \____/|_|\__,_|\__\___|_| |_|
 
 --------------------------------
 High-Speed iOS Decryption System
 --------------------------------
 
 Authors:
 
 dissident - The original creator of Clutch (pre 1.2.6)
 Nighthawk - Code contributor (pre 1.2.6)
 Rastignac - Inspiration and genius
 TheSexyPenguin - Inspiration
 dildog - Refactoring and code cleanup (2.0)
 
*/

/*
 * Includes
 */

#include<stdio.h>
#include<stdlib.h>
#include<unistd.h>

#import "Foundation/Foundation.h"
#import "applist.h"

#import "Cracker.h"
#import "Packager.h"

/*
 * Configuration
 */

#define CLUTCH_TITLE "Clutch"
#define CLUTCH_VERSION "v2.0.0"
#define CLUTCH_RELEASE "ALPHA 1"

/*
 * Prototypes
 */

void print_failures(NSArray *failures, NSArray *successes);
int iterate_crack(NSArray *apps, NSArray *successes, NSArray *failures);
int cmd_version(void);
int cmd_help(void);
int cmd_crack_all(void);
int cmd_crack_updated(void);
int cmd_flush_cache(void);
int cmd_crack_exe(NSString *path);

/*
 * Commands
 */


int cmd_version(void)
{
    printf("%s %s (%s)\n",CLUTCH_TITLE, CLUTCH_VERSION,CLUTCH_RELEASE);
    return 0;
}

int cmd_help(void)
{
    cmd_version();
    
    printf("-----------------------------\n");
    //printf("-c          Runs configuration utility\n");
    printf("-x <path>   Crack specific executable\n");
    printf("-a          Cracks all applications\n");
    printf("-u          Cracks updated applications\n");
    printf("-f          Flush/clear cache\n");
    printf("-v          Shows version\n");
    printf("-h,-?       Shows this help\n");
    printf("\n");

    return 0;
}

// print_failures()
// prints the list of things that succeeded and things that failed
void print_failures(NSArray *successes, NSArray *failures)
{
    if(successes && [successes count]>0)
    {
        printf("Success:\n");
        
        NSEnumerator *e = [successes objectEnumerator];
        while(NSString *app = [e nextObject])
        {
            printf("%s\n",[app UTF8String]);
        }
    }
    if(failures && [failures count]>0)
    {
        printf("Failure:\n");
        
        NSEnumerator *e = [failures objectEnumerator];
        while(NSString *app = [e nextObject])
        {
            printf("%s\n",[app UTF8String]);
        }
    }
}


// iterate_crack()
// iterates over all of the apps in the NSArray list,
// prepares the app, and cracks it.
// returns a list of successes and failures

int iterate_crack(NSArray *apps, NSMutableArray *successes, NSMutableArray *failures)
{
    // Iterate over all applications
	NSEnumerator *e = [apps objectEnumerator];
    while(NSDictionary *appdict = [e nextObject])
    {
        // Prepare this application from the installed app
        Cracker *cracker=[[Cracker alloc] init];
        
        NSMutableString *description=[[NSMutableString alloc] init];
        [cracker prepareFromInstalledApp:appdict returnDescription:description];
        
           
        if([cracker execute])
        {
            [successes addObject:description];
        }
        else
        {
            [failures addObject:description];
        }
        
        // Repackage IPA file
        Packager *packager=[[Packager alloc] init];
        [packager pack_from_source:[appdict objectForKey:@"ApplicationBaseDirectory"]
                  with_overlay:[cracker getOutputFolder]];
    }
    return 0;
}

int cmd_crack_all(void)
{
    // Get list of all applications
    NSArray *all_applications = get_application_list(FALSE, FALSE);
    
    // Create list for failures and successes
    NSMutableArray *failures=[[NSMutableArray alloc] init];
    NSMutableArray *successes=[[NSMutableArray alloc] init];
    
    // Iterate over all applications
    int ret=iterate_crack(all_applications, successes, failures);

    // Print failures and success status
    print_failures(successes,failures);
    
    [failures release];
    [successes release];
    
    return ret;
}

int cmd_crack_updated(void)
{
    // Get list of updated applications
    NSArray *update_applications = get_application_list(FALSE, TRUE);
    
    // Create list for failures and successes
    NSMutableArray *failures=[[NSMutableArray alloc] init];
    NSMutableArray *successes=[[NSMutableArray alloc] init];
    
    // Iterate over all applications
    int ret=iterate_crack(update_applications, successes, failures);
    
    // Print failures and success status
    print_failures(successes,failures);
    
    [failures release];
    [successes release];
    
    return ret;
}


int cmd_crack_exe(NSString *path)
{
    // Create list for failures and successes
    NSMutableArray *failures=[[NSMutableArray alloc] init];
    NSMutableArray *successes=[[NSMutableArray alloc] init];
    
    // Prepare this application from the installed app
    Cracker *cracker=[[Cracker alloc] init];
    
    NSMutableString *description=[[NSMutableString alloc] init];
    [cracker prepareFromSpecificExecutable:path returnDescription:description];
    
    int ret=0;
    if([cracker execute])
    {
        [successes addObject:description];
        ret=0;
    }
    else
    {
        [failures addObject:description];
        ret=1;
    }
    
    // Repackage IPA file
    Packager *packager=[[Packager alloc] init];
    [packager packFromSource:[path stringByDeletingLastPathComponent]
                  withOverlay:[cracker getOutputFolder]];
    
    // Print failures and success status
    print_failures(successes,failures);

    [failures release];
    [successes release];
    
    return ret;
}


int cmd_flush_cache(void)
{
    return 0;
}

int cmd_crack_exe(const char *path)
{
    return 0;
}

/*
 * Main Function
 */

int main(int argc, const char *argv[])
{
    // Prepare command line options
    int ret=0;
    
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    int idx,cnt=(int)[arguments count];
    for(idx=0;idx<cnt;idx++)
    {
        // Process each command line option
        
        NSString *arg = [arguments objectAtIndex:idx];
        
        if([arg isEqualToString:@"-a"])
        {
            // Crack all applications
            ret = cmd_crack_all();
        }
        else if([arg isEqualToString:@"-u"])
        {
            // Crack updated applications
            ret = cmd_crack_updated();
        }
        else if([arg isEqualToString:@"-f"])
        {
            // Flush caches
            ret = cmd_flush_cache();
        }
        else if([arg isEqualToString:@"-v"])
        {
            // Display version string
            ret = cmd_version();
        }
        else if([arg isEqualToString:@"-x"])
        {
            // Crack specific executable
            
            // Get path argument
            idx++;
            if(idx>=cnt)
            {
                printf("-x requires a 'path' argument");
                return 1;
            }
            NSString *path = [arguments objectAtIndex:idx];
            
            ret = cmd_crack_exe(path);
        }
        else if([arg isEqualToString:@"-h"] || [arg isEqualToString:@"-?"])
        {
            // Display help
            ret = cmd_help();
        }
        else
        {
            // Unknown command line option
            printf ("unknown option '%s'\n", [arg UTF8String]);
            return 1;
        }
    }
    
    return ret;
}

