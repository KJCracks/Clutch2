//
//  Application.m
//  Clutch
//
//  Created by Ninja on 03/01/2014.
//
//

#import "Application.h"

@implementation Application


- (NSString *)description
{
    return [NSString stringWithFormat: @"{ Application: BaseDirectory = %@\nDirectory = %@\nDisplayName = %@\nBinary = %@\nBaseName = %@\nUUID = %@\nVersion = %@\nIdentifier = %@\nInfoPlist = %@", baseDirectory, directory, displayName, binary, baseDirectory, UUID, version, identifier, infoPlist];
}

@end
