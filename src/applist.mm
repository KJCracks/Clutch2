//
//  Cracker.m
//  Clutch
//
//  Created by on 12/22/13.
//
//

#import "applist.h"
#import "out.h"

@implementation applist

- (NSArray *)listApplications
{
    // Prepare array to return application list
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    // Get base path for installed applications
	NSString *basePath = @"/var/mobile/Applications/";
    
	// Get list of all applictions from file manager
	NSArray *apps = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:NULL];
	
	if ([apps count] == 0) {
        printf("No applications found\n");
		return NULL;
	}
	
    // Iterate over all applications
    for (NSString *value in apps)
    {
        NSString *applicationDirectory = [basePath stringByAppendingFormat:@"%@/", value];
        NSArray *sandboxPath = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:applicationDirectory error:NULL];
        
        
        for (NSString *directory in sandboxPath)
        {
            if ([directory rangeOfString:@".app"].location == NSNotFound) // if the directory doesn't contain ".app" iterate loop
            {
                continue;
            } else
            {
                // We're in an application folder
                
                // Check if SC_Info exsists, these are only present on encrypted applications
                // Apple stock applications don't seem to have them (when did they start appearing
                // symlink'd to /mobile/Applications?
                NSString *subdirectory = [applicationDirectory stringByAppendingString:directory];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:[subdirectory stringByAppendingString:@"/SC_Info/"]]) {
                    NSDictionary *infoPlist = [[NSDictionary alloc] initWithContentsOfFile:[subdirectory stringByAppendingString:@"/Info.plist"]];
                    
                    NSString *bundleDisplayName = infoPlist[@"CFBundleDisplayName"];
                    
                    if (bundleDisplayName == nil)
                    {
                        NSLog(@"%@ CFBundleDisplayName not found", directory);
                        
                        // try CFBundleName
                        bundleDisplayName = infoPlist[@"CFBundleName"];
                    }
                    
                    // no aleternative for CFBundleIdentifier
                    NSString *bundleIdentifier = infoPlist[@"CFBundleIdentifier"];
                    
                    NSString *bundleVersionString = infoPlist[@"CFBundleVersion"];
                    
                    if (bundleVersionString == nil)
                    {
                        NSLog(@"%@ CFBundleVersion not found", directory);
                        
                        // try CFBundleShortVersionString
                        bundleVersionString = infoPlist[@"CFBundleShortVersionString"];
                    }
                    
                    // this should always be in Info.plist
                    NSString *applicationRealName = infoPlist[@"CFBundleExecutable"];
                    
                    // default to the executable name
                    if (bundleDisplayName == nil)
                    {
                        bundleDisplayName = applicationRealName;
                    }
                    
                    // Create dictionary of useful keys from Info.plis
                    // if and only if the SC_Info folder exsists, which indicates
                    // if an applicaiton is encrypted.
                    NSDictionary *applicationDetailObject = @{@"ApplicationBaseDirectory": applicationDirectory,
                                                              @"ApplicationDirectory": subdirectory,
                                                              @"ApplicationDisplayName": bundleDisplayName,
                                                              @"ApplicationName": applicationRealName,
                                                              @"ApplicationBaseName": directory,
                                                              @"UUID": applicationDirectory,
                                                              @"ApplicationVersion": bundleVersionString,
                                                              @"ApplicationIdentifer": bundleIdentifier
                                                              };
                    
                    if (applicationDetailObject)
                    {
                        NSLog(@"Encrypted application found: %@", directory);
                        [returnArray addObject:applicationDetailObject];
                    }
                        
                    //[returnArray addObject:applicationDetailObject];
                } else {
                    //NSLog(@"Not an encrypted application: %@", directory);
                }
            }
        }
    }
    
    if ([returnArray count] == 0)
    {
        [returnArray release];
        
        return NULL;
    }
    
    // return the array
    return (NSArray *)[returnArray sortedArrayUsingFunction:alphabeticalSort context:NULL];

}

static NSComparisonResult alphabeticalSort(id one, id two, void *context)
{
	return [[(NSDictionary *)one objectForKey:@"ApplicationName"] localizedCaseInsensitiveCompare:[(NSDictionary *)two objectForKey:@"ApplicationName"]];
}

@end
