//
//  GarbageColl.m
//  SAExamplesCocoa
//
//  Created by Cyril Godefroy on 17/09/09.
//  Copyright 2009 eCOMPOSITE. All rights reserved.
//

#import "GarbageColl.h"


@implementation GarbageColl

- (id) readForeignPref
{
	CFPropertyListRef matchStyle = CFPreferencesCopyAppValue(CFSTR("PBXFindMatchStyle"), CFSTR("com.apple.Xcode"));
	return [(id)CFMakeCollectable(matchStyle)  autorelease];
	
}

@end
