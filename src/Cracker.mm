//
//  Cracker.m
//  Clutch
//
//  Created by DilDog on 12/22/13.
//
//

#import "Cracker.h"

@implementation Cracker

- (id)init
{
    self = [super init];
    if (self)
    {
        _appDescription = NULL;
        _finaldir = NULL;
        _baselinedir = NULL;
        _workingdir = NULL;
    }
    return self;
}

-(void)dealloc
{
    if(_appDescription)
    {
        [_appDescription release];
    }
    if(_baselinedir)
    {
        [_baselinedir release];
    }
    if(_finaldir)
    {
        [_finaldir release];
    }
    if(_workingdir)
    {
        [_workingdir release];
    }
    
    [super dealloc];
}

static BOOL forceRemoveDirectory(NSString *dirpath)
{
    BOOL isDir;
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:dirpath isDirectory:&isDir])
    {
        if(![fileManager removeItemAtPath:dirpath error:NULL])
        {
            return NO;
        }
    }
    return YES;
}

static BOOL forceCreateDirectory(NSString *dirpath)
{
    BOOL isDir;
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:dirpath isDirectory:&isDir])
    {
        if(![fileManager removeItemAtPath:dirpath error:NULL])
        {
            return NO;
        }
    }
    if(![fileManager createDirectoryAtPath:dirpath withIntermediateDirectories:YES attributes:nil error:NULL])
    {
        return NO;
    }
    return YES;
}

static BOOL copyFile(NSString *infile, NSString *outfile)
{
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if(![fileManager createDirectoryAtPath:[outfile stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:NULL])
    {
        return NO;
    }

    if(![fileManager copyItemAtPath:infile toPath:outfile error:NULL])
    {
        return NO;
    }
    return YES;
}

- (BOOL) crackApp {
    
    return true;
}


// analyse
// loads the binary, prepare the headers, etc
-(void) analyse {
    char[4096]* buffer;
    binary = fopen([_binaryLocation UTF8String], "r+");
    
}

// createPartialCopy
// copies only the files required for cracking an application to a staging area

-(BOOL)createPartialCopy:(NSString *)outdir withApplicationDir:(NSString *)appdir withMainExecutable:(NSString *)mainexe
{
    // Create output directory
    if(!forceCreateDirectory(outdir))
    {
        return NO;
    }
    
    // XXX: This, only if necessary: Get sandbox folder
    //NSString *topleveldir=[appdir stringByDeletingLastPathComponent];
    //NSString *appdirprefix=[appdir lastPathComponent];

    // Get top level .app folder
    NSString *topleveldir=[appdir copy];

    // Files required for cracking
    NSMutableArray *files=[[NSMutableArray alloc] init];
    [files addObject:@"_CodeSignature/CodeResources"];
    [files addObject:[NSString stringWithFormat:@"SC_Info/%@.sinf", mainexe]];
    [files addObject:[NSString stringWithFormat:@"SC_Info/%@.supp", mainexe]];
    [files addObject:mainexe];
    //XXX:[files addObject:[NSString stringWithFormat:@"%@/_CodeSignature/CodeResources", appdirprefix]];
    //XXX:[files addObject:[NSString stringWithFormat:@"%@/SC_Info/%@.sinf", appdirprefix, mainexe]];
    //XXX:[files addObject:[NSString stringWithFormat:@"%@/SC_Info/%@.supp", appdirprefix, mainexe]];
    //XXX:[files addObject:[NSString stringWithFormat:@"%@/%@", appdirprefix, mainexe]];
    //XXX:[files addObject:[NSString stringWithFormat:@"%@/Info.plist", appdirprefix];
    //XXX:[files addObject:@"iTunesMetadata.plist"];
    //XXX:[files addObject:@"iTunesArtwork"];
    
    NSEnumerator *e = [files objectEnumerator];
    NSString *file;
    while(file = [e nextObject])
    {
        if(!copyFile([NSString stringWithFormat:@"%@/%@", topleveldir, file],
                     [NSString stringWithFormat:@"%@/%@", outdir, file]))
        {
            forceRemoveDirectory(outdir);
            return NO;
        }
    }

    [topleveldir release];
    [files release];
    
    return YES;
}

// prepareFromInstalledApp
// set up application cracking from an installed application

-(BOOL)prepareFromInstalledApp:(NSDictionary *)appdict
{
    // Create the app description
    _appDescription=[NSString stringWithFormat:@"%@: %@ (%@)",
                     [appdict objectForKey:@"ApplicationIdentifier"],
                     [appdict objectForKey:@"ApplicationDisplayName"],
                     [appdict objectForKey:@"ApplicationVersion"]];

    // Create full copy of application which we will modify to our needs
    // to form final IPA file
    NSUUID *finaluuid=[[NSUUID alloc] init];
    _finaldir=[NSString stringWithFormat:@"%@/%@/Payload",
                                            NSTemporaryDirectory(),
                                            [finaluuid UUIDString]];
    if(![self createFullCopyOfContents: _finaldir withAppBaseDir:[appdict objectForKey:@"ApplicationBaseDirectory"]])
    {
        [_finaldir release];
        _finaldir=NULL;
        [finaluuid release];
        return NO;
    }


    // Create executable baseline copy from which lipo copies are formed
    NSUUID *baselineuuid=[[NSUUID alloc] init];
    _baselinedir=[NSString stringWithFormat:@"%@/%@",
                                            NSTemporaryDirectory(),
                                            [baselineuuid UUIDString]];
    if(![self createPartialCopy: _baselinedir
             withApplicationDir:[appdict objectForKey:@"ApplicationDirectory"]
             withMainExecutable:[appdict objectForKey:@"ApplicationName"]])
    {
        [_baselinedir release];
        _baselinedir=NULL;
        [baselineuuid release];
        return NO;
    }

/*
    // Create working directory copy
    NSUUID *workinguuid=[[NSUUID alloc] init];
    _workingdir=[NSString stringWithFormat:@"%@/%@",
                           NSTemporaryDirectory(),
                           [workinguuid UUIDString]];
    if(![self createPartialCopy:_workingdir
         withApplicationDir:[appdict objectForKey:@"ApplicationDirectory"]
         withMainExecutable:[appdict objectForKey:@"ApplicationName"]])
    {
        [[NSFileManager defaultManager] removeItemAtPath:_baselinedir error:nil];
        
        [_baselinedir release];
        _baselinedir=NULL;
        [_workingdir release];
        _workingdir=NULL;
        [baselineuuid release];
        [workinguuid release];
        return NO;
    }

    [workinguuid release];
*/
    // Clean up
    [baselineuuid release];
    
    [self analyse];

    return YES;
}

-(BOOL)prepareFromSpecificExecutable:(NSString *)exepath returnDescription:(NSMutableString *)description
{
    // Create the app description
    _appDescription=[NSString stringWithFormat:@"%@",exepath];

    return YES;
}

-(NSString *)getAppDescription
{
    return _appDescription;
}

-(NSString *)getOutputFolder
{
    return _finaldir;
}


@end
