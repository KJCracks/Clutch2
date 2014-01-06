//
//  Cracker.m
//  Clutch
//
//  Created by on 12/22/13.
//
//

#import "applist.h"
#import "out.h"
#import "Application.h"

@implementation applist

+ (NSArray *)listApplications
{
    // Prepare array to return application list
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    // Get base path for installed applications
	NSString *basePath = @"/var/mobile/Applications/";
    
	// Get list of all applictions from file manager
	NSArray *apps = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:NULL];
	
	if ([apps count] == 0) {
        printf("No applications found\n");
        
        [returnArray release];
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
                NSString *subdirectory = [applicationDirectory stringByAppendingFormat:@"%@/", directory];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:[subdirectory stringByAppendingString:@"/SC_Info/"]]) {
                    NSDictionary *infoPlist = [[NSDictionary alloc] initWithContentsOfFile:[subdirectory stringByAppendingString:@"/Info.plist"]];
                    
                    NSString *bundleDisplayName = infoPlist[@"CFBundleDisplayName"];
                    
                    if (bundleDisplayName == nil)
                    {
                        NSLog(@"%@ CFBundleDisplayName not found", directory);
                        
                        // try CFBundleName
                        bundleDisplayName = infoPlist[@"CFBundleName"];
                        NSLog(@"Using CFBundleName: %@", bundleDisplayName);
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
                    NSString *binary = infoPlist[@"CFBundleExecutable"];
                    
                    // default to the executable name
                    if (bundleDisplayName == nil)
                    {
                        bundleDisplayName = binary;
                    }
                    
                    // Create dictionary of useful keys from Info.plis
                    // if and only if the SC_Info folder exsists, which indicates
                    // if an applicaiton is encrypted.
                    Application *app = [[Application alloc] init];
                    app.baseDirectory = applicationDirectory;
                    app.directory = subdirectory;
                    app.displayName = bundleDisplayName;
                    app.binary = binary;
                    app.baseName = directory;
                    app.UUID = [[applicationDirectory lastPathComponent] stringByDeletingPathExtension];
                    app.version = bundleVersionString;
                    app.identifier = bundleIdentifier;
                    app.infoPlist = infoPlist;
                    app.binaryPath = [applicationDirectory stringByAppendingFormat:@"/%@/%@", directory, binary];
                    
                    NSLog(@"REMOVE THIS binary path %@", app.binaryPath);
                    
                    
                    /*printf("\n");
                    NSLog(@"BaseDir %@", applicationDirectory);
                    NSLog(@"Directory %@", subdirectory);
                    NSLog(@"DispName: %@", bundleDisplayName);
                    NSLog(@"Binary %@", binary);
                    NSLog(@"BaseName %@", directory);
                    NSLog(@"UUID %@", [[applicationDirectory lastPathComponent] stringByDeletingPathExtension]);
                    NSLog(@"Version %@", bundleVersionString);
                    NSLog(@"Ident %@", bundleIdentifier);*/
                    
                    NSLog(@"Encrypted application found: %@", directory);
                    [returnArray addObject:app];
                    
                    [app release];
                    [infoPlist release];
                }
            }
        }
    }
    
    if ([returnArray count] == 0)
    {
        [returnArray release];
        
        return NULL;
    }
    
    NSArray *sortedReturnArray = [returnArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *first = [(Application*)obj1 displayName];
        NSString *second = [(Application *)obj2 displayName];
        
        return [first compare:second];
    }];
    
    // return the array
    return sortedReturnArray;
    
    //return (NSArray *)[returnArray sortedArrayUsingFunction:alphabeticalSort context:NULL];
}

@end
