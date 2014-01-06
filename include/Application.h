//
//  Application.h
//  Clutch
//
//  Created by Ninja on 03/01/2014.
//
//

#import <Foundation/Foundation.h>

@interface Application : NSObject
{
    NSString *baseDirectory; // Full Path
    NSString *directory; // Name of application directory (after UUID bit)
    NSString *displayName; // Display name (found in Info.plist)
    NSString *binary; // The binary name (CFBundleExectuable)
    NSString *baseName; // Name of the application folder
    NSString *UUID; // The UUID Apple generated for application
    NSString *version; // Version of application (found in Info.plist)
    NSString *identifier; // The reverse-notion identifier
    NSDictionary *infoPlist; // Parsed Info.plist
    NSString *binaryPath; // Full path to binary
    
}

@property (nonatomic, retain) NSString *baseDirectory;
@property (nonatomic, retain) NSString *directory;
@property (nonatomic, retain) NSString *displayName;
@property (nonatomic, retain) NSString *binary;
@property (nonatomic, retain) NSString *baseName;
@property (nonatomic, retain) NSString *UUID;
@property (nonatomic, retain) NSString *version;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSDictionary *infoPlist;
@property (nonatomic, retain) NSString *binaryPath;

@end
