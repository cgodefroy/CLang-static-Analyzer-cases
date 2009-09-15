//
//  September.m
//  StaticAnalizerExamples
//
//  Originally ParisMacCommunity.m
//  CocoaHeadsParis
//
//  Created by Guillaume Cerquant, MacMation 
//  http://www.macmation.com/TimeBoxed
//
//  Copyright MacMation 2009. All rights reserved.
//

#import "September.h"
//#import <HumanKit/MacGeek.h>
//#import <CoreServices/DrinksAndFood.h>

#import "CocoaHeads.h"


@implementation September

- (id)init {
     CocoaHeads *session_5;
     
     if (self = [super init]) {
         session_5 = [[CocoaHeads alloc] init];
         
         [session_5 setDate:@"Jeudi, 17 septembre 2009"];
         [session_5 setStartTime:@"19:00"];
         [session_5 setEndTime:@"21:00"];
         
         [session_5 setLocationName:@"Spirit Cafe"]; 
         [session_5 setLocation:@"11, rue rameau - 75002 Paris"];
         
         // Get more info at
		 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.cocoaheads.org/fr/Paris/"]];
     }
     
     return self;
 }

@end
