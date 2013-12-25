//
//  Cracker.h
//  Clutch
//
//  Created by DilDog on 12/22/13.
//
//

#import <Foundation/Foundation.h>

@interface Cracker : NSObject
{
    NSString *_appDescription;
    NSString *_finaldir;
    NSString *_baselinedir;
    NSString *_workingdir;
}

-(id)init;
-(BOOL)createFullCopyOfContents:(NSString *)outdir withAppBaseDir:(NSString *)appdir;
-(BOOL)createPartialCopy:(NSString *)outdir withApplicationDir:(NSString *)appdir withMainExecutable:(NSString *)mainexe;
-(BOOL)prepareFromInstalledApp:(NSDictionary *)appdict;
-(BOOL)prepareFromSpecificExecutable:(NSString *)exepath returnDescription:(NSMutableString *)description;
-(NSString *)getAppDescription;
-(NSString *)getOutputFolder;


@end
