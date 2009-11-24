//
//  Track.h
//
//  Created by Cyril Godefroy on 26/06/08.
//  Copyright 2008 eCOMPOSITE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import <CoreLocation/CoreLocation.h>

@interface TrackPoint : NSObject {
	NSNumber *longitude, *latitude, *altitude, *accuracy;
    NSString *time;
}
@property (copy, nonatomic) NSString *time;
@property (copy, nonatomic) NSNumber *longitude, *latitude, *altitude, *accuracy;
+ (void)deleteTrackPointsIntoDatabase:(sqlite3 *)database 
						   forTrackId:(NSInteger)trackId;
@end

@interface TrainerAppDelegate : NSObject {
}
- (Boolean)isLite;
@end

@interface Track : NSObject {
    sqlite3 *database;
    NSInteger primaryKey;
    
	// Attributes.
    NSString *date, *title, *endDate;
	float distance;
	float maxSpeed;
	float speed;
	int totalTime;
	int calories;
	
	NSMutableArray *trackpoints;
	NSMutableArray *serie;
}

@property NSInteger primaryKey;
@property (retain, nonatomic) NSString *date;
@property (retain, nonatomic) NSString *endDate;
@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSMutableArray *serie;
@property float distance;
@property float speed;
@property int calories;
@property int totalTime;
@property float maxSpeed;
@property (retain, nonatomic) NSMutableArray *trackpoints;

+ (NSInteger)insertNewTrackIntoDatabase:(sqlite3 *)database;
+ (void)finalizeStatements;
+ (NSString*) timeAsString: (NSTimeInterval) duration;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;
- (void)hydrate;
- (void)deleteFromDatabase;
- (NSInteger)save;

- (NSString*) shortStartDate;
- (NSString*)veryShortStartDate;
- (void)setStartTime;
- (NSDate *)startTime;
- (void)setEndTime;
- (NSDate *)endTime;

- (void)addTrackPoint:(TrackPoint *)point;

- (float)calculateDistance;
- (NSString *)calculateDistanceAsString;
- (float)calculateSpeed;
- (NSString*)calculateSpeedAsString;
- (NSString *)calculateRythmAsString;
- (void)updateMaxSpeed;

- (int) calculateCalories;
- (NSTimeInterval)calculateTotalTimeOld;
- (NSTimeInterval)calculateTotalTime;
- (NSString*) totalTimeAsString;
- (void)resetDistanceAndSpeed;

- (NSString *)generateGPX;
- (NSString *)generateKML;
- (NSString *)pointsAsPath;
- (NSMutableArray *)generatePointSeries;

@end


	
