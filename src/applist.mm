/*
 * Applist.mm - get list of installed applications
 */

#import "Foundation/Foundation.h"
#import "applist.h"

/*
 * Prototypes
 */

NSArray * get_application_list(BOOL sort, BOOL updates);
static NSComparisonResult alphabeticalSort(id one, id two, void *context);

/*
 * Implementations
 */


// get_application_list()
// return list of installed applications on device

NSArray * get_application_list(BOOL sort, BOOL updates)
{
    // Prepare array to return application list
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    // Get base path for installed applications
	NSString *basePath = @"/var/mobile/Applications/";

	// Get list of all applictions from file manager
	NSArray *apps = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:NULL];
	
	if ([apps count] == 0) {
		return NULL;
	}
	
    // See if application cache exists or not, if not, create it
	NSMutableDictionary *cache = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/cache/clutch.plist"];
	BOOL cflush = FALSE;
	if ((cache == nil) || (![cache count]))
    {
		cache = [NSMutableDictionary dictionary];
        
        // Write the cache to disk at the end
		cflush = TRUE;
	}
    
    // Get list of cracked app versions
    NSMutableDictionary *versions;
	if (updates)
    {
        if (![[NSFileManager defaultManager] fileExistsAtPath:@"/etc/clutch_cracked.plist"]) {
            versions = [[NSMutableDictionary alloc] init];
        }
        else {
            versions = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/cache/clutch_cracked.plist"];
        }
    }

    // Iterate over all applications
	NSEnumerator *e;
	e = [apps objectEnumerator];
    NSString *applicationDirectory;
    while (applicationDirectory = [e nextObject])
    {
		//if ([cache objectForKey:applicationDirectory] != nil) {
        //[returnArray addObject:[cache objectForKey:applicationDirectory]];
        //	} else {
        
        // Build full path to application sandbox
        NSArray *sandboxPath = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[basePath stringByAppendingFormat:@"%@/", applicationDirectory] error:NULL];
        
        // Iterate over sandbox subdirectories
        NSEnumerator *e2 = [sandboxPath objectEnumerator];
        NSString *applicationSubdirectory;
        while (applicationSubdirectory = [e2 nextObject])
        {
            // Find the '*.app' sandbox subdirectory
            if ([applicationSubdirectory rangeOfString:@".app"].location == NSNotFound)
            {
                continue;
            }
            
            // Parse the Info.plist for the bundle display name and bundle version
            NSString * bundleDisplayName = [[NSDictionary dictionaryWithContentsOfFile:[basePath stringByAppendingFormat:@"%@/%@/Info.plist", applicationDirectory, applicationSubdirectory]] objectForKey:@"CFBundleDisplayName"];

            NSString * bundleIdentifier = [[NSDictionary dictionaryWithContentsOfFile:[basePath stringByAppendingFormat:@"%@/%@/Info.plist", applicationDirectory, applicationSubdirectory]] objectForKey:@"CFBundleIdentifier"];

            NSString * bundleVersionString = [[[NSDictionary dictionaryWithContentsOfFile:[basePath stringByAppendingFormat:@"%@/%@/Info.plist", applicationDirectory, applicationSubdirectory]] objectForKey:@"CFBundleVersion"] stringByReplacingOccurrencesOfString:@"." withString:@""];
            
            NSString *applicationRealname = [[NSDictionary dictionaryWithContentsOfFile:[basePath stringByAppendingFormat:@"%@/%@/Info.plist", applicationDirectory, applicationSubdirectory]] objectForKey:@"CFBundleExecutable"];
            // [applicationSubdirectory stringByReplacingOccurrencesOfString:@".app" withString:@""];
            
            // Default bundle display name if it's not in the Info.plist
            if (bundleDisplayName == nil) {
                bundleDisplayName = applicationRealname;
            }
            
            // Create dictionary of useful keys from Info.plist
            // if and only if the SC_Info folder exists, which indicates
            // if an application is encrypted or not.
            NSDictionary *applicationDetailObject;
            if ([[NSFileManager defaultManager] fileExistsAtPath:[basePath stringByAppendingFormat:@"%@/%@/SC_Info/", applicationDirectory, applicationSubdirectory]])
            {
                applicationDetailObject = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [basePath stringByAppendingFormat:@"%@/", applicationDirectory], @"ApplicationBaseDirectory",
                                           [basePath stringByAppendingFormat:@"%@/%@/", applicationDirectory, applicationSubdirectory], @"ApplicationDirectory",
                                           bundleDisplayName, @"ApplicationDisplayName",
                                           applicationRealname, @"ApplicationName",
                                           applicationSubdirectory, @"ApplicationBasename",
                                           applicationDirectory, @"RealUniqueID",
                                           bundleVersionString, @"ApplicationVersion",
                                           bundleIdentifier, @"ApplicationIdentifier",
                                           nil];
                
                // If we are doing updates only, check to see if the versions cache is not the same as the
                // bundle version.
                if (!updates || [versions objectForKey:applicationRealname] != bundleVersionString)
                {
                    // Return this application
                    [returnArray addObject:applicationDetailObject];
                }
                
                // Add to the cache
                [cache setValue:bundleDisplayName forKey:applicationDirectory];
                
                // Write the cache to disk at the end
                cflush = TRUE;
            }
        }
    }
    
	// Write the cache to disk
	if (cflush)
    {
		[cache writeToFile:@"/var/cache/clutch.plist" atomically:TRUE];
	}
    
    // If we have nothing to return, return NULL rather than an empty array
	if ([returnArray count] == 0) {
        [returnArray release];
		return NULL;
    }
	
    // If we want sorting, do so with an alphabetical sort on the application name
	if (sort)
    {
		return (NSArray *)[returnArray sortedArrayUsingFunction:alphabeticalSort context:NULL];
    }
    
    // Return the array
	return (NSArray *) returnArray;
}

// alphabeticalSort()
// Comparison function for use with sorting option

static NSComparisonResult alphabeticalSort(id one, id two, void *context)
{
	return [[(NSDictionary *)one objectForKey:@"ApplicationName"] localizedCaseInsensitiveCompare:[(NSDictionary *)two objectForKey:@"ApplicationName"]];
}