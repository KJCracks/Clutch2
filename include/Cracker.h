//
//  Cracker.h
//  Clutch
//
//  Created by DilDog on 12/22/13.
//
//

#import <Foundation/Foundation.h>
#import "Application.h"

@interface Cracker : NSObject
{
    NSString *_appDescription;
    NSString *_finaldir;
    NSString *_baselinedir;
    NSString *_workingdir;
    
    NSString *workingDirectory;
    NSMutableArray *headersToStrip;
    NSString *sinfPath;
    NSString *suppPath;
    NSString *supfPath;
}

-(id)init;
-(BOOL)createFullCopyOfContents:(NSString *)outdir withAppBaseDir:(NSString *)appdir;
-(BOOL)createPartialCopy:(NSString *)outdir withApplicationDir:(NSString *)appdir withMainExecutable:(NSString *)mainexe;
-(BOOL)prepareFromInstalledApp:(NSDictionary *)appdict;
-(BOOL)prepareFromSpecificExecutable:(NSString *)exepath returnDescription:(NSMutableString *)description;
-(NSString *)getAppDescription;
-(NSString *)getOutputFolder;

// Objective-C method declarations
- (BOOL)crackApplication:(Application *)application; // Cracks the application
- (BOOL)preflightBinaryOfApplication:(Application *)application; // Does some preflight checks on the binary of given application
- (BOOL)crackBinary:(Application *)application; // Cracks the binary
- (BOOL)createWorkingDirectory; // Create the working directory for cracking & sets the path to (NSString *)workingDirectory

- (BOOL)createCopyOfDirectory:(NSString *)applicationDirectory; // Create copy of all application files to /tmp/{UUID}
- (BOOL)createCopyOfBinary:(NSString *)binaryPath; // Create copy of application binary to /tmp/{UUID}
- (BOOL)removeTempFiles;
- (NSDictionary *)analyseInfoPlistAtPath:(NSString *)infoPlistPath; // Builds a foundation data model of Info.plist

// C method declarations
void get_local_device_information();

// Properties
@property (nonatomic, strong) NSString *workingDirectory;

@end
