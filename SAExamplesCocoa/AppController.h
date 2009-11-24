//
//  AppController.h
//  
//
//  Created by Guillaume Cerquant on 22/04/09.
//  Copyright 2009 MacMation. All rights reserved.
//

//#import <PreferencePanes/NSPreferencePane.h>
//#import <Cocoa/Cocoa.h>

//NS_RETURNS_RETAINED


@interface AppController: NSObject /*: NSPreferencePane*/ {

}


+ (id) controller ;
- (NSString*) returnsRetained NS_RETURNS_RETAINED;
- (NSString*) alsoReturnsRetained;

@end
