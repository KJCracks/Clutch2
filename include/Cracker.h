//
//  Cracker.h
//  Clutch
//
//  Created by DilDog on 12/22/13.
//
//

#import <Foundation/Foundation.h>
#import <mach-o/fat.h>

#define CPUTYPE_32 0xc000000
#define CPUTYPE_64 0xc000001

@interface Cracker : NSObject
{
    NSString *_appDescription;
    NSString *_binaryLocation;
    NSString *_finaldir;
    NSString *_baselinedir;
    NSString *_workingdir;
    FILE* binary;
    struct fat_header* fat_header;
   
}

-(id)init;
//cracking stuff
-(BOOL)isFat;
-(BOOL)canCrack;
-(BOOL)needStrip;

-(void)onlyKeepArch:(uint32_t) arch;
-(void)stripArch:(uint32_t) arch;
-(void)analyse;


-(BOOL)createFullCopyOfContents:(NSString *)outdir withAppBaseDir:(NSString *)appdir;
-(BOOL)createPartialCopy:(NSString *)outdir withApplicationDir:(NSString *)appdir withMainExecutable:(NSString *)mainexe;
-(BOOL)prepareFromInstalledApp:(NSDictionary *)appdict;
-(BOOL)prepareFromSpecificExecutable:(NSString *)exepath returnDescription:(NSMutableString *)description;
-(NSString *)getAppDescription;
-(NSString *)getOutputFolder;


@end
