//
//  Track.m
//  WhereAmI
//
//  Created by Cyril Godefroy on 26/06/08.
//  Copyright 2008 eCOMPOSITE. All rights reserved.
//

#import "Track.h"
#include <math.h>


static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *delete_statement = nil;
static sqlite3_stmt *save_statement = nil;
static sqlite3_stmt *hydrate_statement = nil;
static sqlite3_stmt *dehydrate_statement = nil;

@implementation Track

@synthesize primaryKey;
@synthesize trackpoints;
@synthesize serie;
@synthesize date, endDate, title;
@synthesize distance, speed, calories, totalTime, maxSpeed;

+ (NSInteger)insertNewTrackIntoDatabase:(sqlite3 *)database{
	if (insert_statement == nil) {
		static char *sql = "INSERT INTO tracks(date) VALUES(?)";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	NSDate *today = [NSDate date];
	NSString *date = [today description];
	sqlite3_bind_text(insert_statement, 1, [date UTF8String], -1, SQLITE_TRANSIENT);
	
    int success = sqlite3_step(insert_statement);
    sqlite3_reset(insert_statement);
    if (success != SQLITE_ERROR) {
        return sqlite3_last_insert_rowid(database);
    }
    NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
    return -1;
}

+ (void)finalizeStatements{
	if (insert_statement) sqlite3_finalize(insert_statement);
    if (init_statement) sqlite3_finalize(init_statement);
    if (delete_statement) sqlite3_finalize(delete_statement);
    if (hydrate_statement) sqlite3_finalize(hydrate_statement);
	if (dehydrate_statement) sqlite3_finalize(dehydrate_statement);
}

+ (NSString*) timeAsString: (NSTimeInterval) duration{
	int hours = duration / 3600;
	int minutes = (int)(duration / 60) % 60;
	int seconds;
	if(duration>0){
		seconds = (int)duration % 60;
	} else {
		seconds = 0;
	}
	return [NSString stringWithFormat:@"%.2dh:%.2dm:%.2ds",hours, minutes, seconds ];
}



- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db{
	if (self = [super init]) {
		primaryKey = pk;
		database = db;
		if (init_statement == nil) {
			const char *sql = "SELECT date, endDate, title, distance, speed, calories, maxSpeed FROM tracks WHERE id=?";
			if (sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
				NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			}
		}
		sqlite3_bind_int(init_statement, 1, primaryKey);
		if (sqlite3_step(init_statement) == SQLITE_ROW) {
			self.date = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(init_statement, 0)];
			if(sqlite3_column_text(init_statement, 1) != NULL){
				self.endDate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 1)];
			} else {
				self.endDate = self.date;
			}
			
			if(sqlite3_column_text(init_statement, 2) != NULL){
				self.title = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(init_statement, 2)];
			} else {
				self.title = self.date;
			}
			self.distance = sqlite3_column_int(init_statement, 3);
			self.speed = sqlite3_column_double(init_statement, 4);
			self.calories = sqlite3_column_int(init_statement, 5);
			self.maxSpeed = sqlite3_column_double(init_statement, 6);
		} else {
			self.date = @"No Date";
		}
		// Reset the statement for future reuse.
		sqlite3_reset(init_statement);
	}
	
	NSMutableArray *pointsArray = [[NSMutableArray alloc] init];
	self.trackpoints = pointsArray;
	[pointsArray release];
	
	return self;
}

- (void) checkAndHydrate{
	if([trackpoints count] == 0)
		[self hydrate];
}

- (void)hydrate{
	if (hydrate_statement == nil) {
		const char *sql = "SELECT id FROM points where track_id=?";
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(database, sql, -1, &hydrate_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	sqlite3_bind_int(hydrate_statement, 1, primaryKey);
	
	while (sqlite3_step(hydrate_statement) == SQLITE_ROW) {
		// The second parameter indicates the column index into the result set.
		int tpPrimaryKey = sqlite3_column_int(hydrate_statement, 0);
		//NSLog(@"tpPrimaryKey = %i",tpPrimaryKey );
		TrackPoint *point = [[TrackPoint alloc] initWithPrimaryKey:tpPrimaryKey database:database];
		[self addTrackPoint:point];
		[point release];
	}	
	sqlite3_reset(hydrate_statement);
}

- (void)dealloc{
	//deallocs trackpoints
	//[date dealloc];
	//[title dealloc];
	[serie release];
	[trackpoints dealloc];
	[super dealloc];
}

- (void)deleteFromDatabase{
	[TrackPoint deleteTrackPointsIntoDatabase:database forTrackId:primaryKey];
	if (delete_statement == nil) {
		const char *sql = "DELETE FROM tracks WHERE id=?";
		if (sqlite3_prepare_v2(database, sql, -1, &delete_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	sqlite3_bind_int(delete_statement, 1, primaryKey);
	int success = sqlite3_step(delete_statement);
	sqlite3_reset(delete_statement);
	if (success != SQLITE_DONE) {
		NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
	}
}

- (NSInteger)save {
	if (save_statement == nil) {
		static char *sql = "UPDATE tracks SET date=?, endDate=?, title=?, distance=?, speed=?, calories=?, maxSpeed=? WHERE id=?";
		if (sqlite3_prepare_v2(database, sql, -1, &save_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	sqlite3_bind_text(save_statement, 1, [date UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(save_statement, 2, [endDate UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(save_statement, 3, [title UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_double(save_statement, 4, distance);
	sqlite3_bind_double(save_statement, 5, speed);
	sqlite3_bind_double(save_statement, 6, calories);
	sqlite3_bind_double(save_statement, 7, maxSpeed);
	sqlite3_bind_double(save_statement, 8, (primaryKey));
	
	int success = sqlite3_step(save_statement);
	sqlite3_reset(save_statement);
	if (success != SQLITE_ERROR) {
		return sqlite3_last_insert_rowid(database);
	}
	NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
	return -1;
}	

- (void)addTrackPoint: (TrackPoint *)point{
	if(trackpoints == nil){
		NSMutableArray *pointsArray = [[NSMutableArray alloc] init];
		self.trackpoints = pointsArray;
		[pointsArray release];
	}
	[trackpoints addObject:point];
}

- (NSString *)title {
	if (!title ||  [title isEqualToString:@""]) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init]  ;
		[formatter setDateFormat:@"yyyy-MM-dd' 'HH:mm:ss' 'ZZZ"];
		NSDate *aDate = [formatter dateFromString:date];
		[formatter setDateFormat:@"yyyy-MM-dd' 'HH:mm:ss"];
		[self setTitle:[formatter stringFromDate:aDate]];
		[formatter release];
	}
	return title;
}

- (NSString*)shortStartDate{
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease]  ;
	[formatter setDateFormat:@"yyyy-MM-dd' 'HH:mm:ss' 'ZZZ"];
	NSDate *aDate = [formatter dateFromString:date];
	[formatter setDateFormat:@""];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	return [formatter stringFromDate:aDate];
}

- (NSString*)veryShortStartDate{
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease]  ;
	[formatter setDateFormat:@"yyyy-MM-dd' 'HH:mm:ss' 'ZZZ"];
	NSDate *aDate = [formatter dateFromString:date];
	[formatter setDateFormat:@""];
	[formatter setDateStyle:NSDateFormatterMediumStyle];
	[formatter setTimeStyle:NSDateFormatterNoStyle];
	return [formatter stringFromDate:aDate];
}

- (void)setStartTime {
	
}

- (NSDate *)startTime{
	if(date == nil || [date isEqualToString:@""]) return [[NSDate alloc] init];
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init]  autorelease];
	[formatter setDateFormat:@"yyyy-MM-dd' 'HH:mm:ss"];
	
	return [formatter dateFromString:date];
}

- (void)setEndTime {
	NSDate *now = [[NSDate alloc]init];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init]  ;
	[formatter setDateFormat:@"yyyy-MM-dd' 'HH:mm:ss"];
	[self setEndDate:[formatter stringFromDate:now]];
	[now release];
	[formatter release];
}

- (NSDate *)endTime{
	if(endDate == nil || [endDate isEqualToString:@""]) return [[NSDate alloc] init];
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init]  autorelease];
	[formatter setDateFormat:@"yyyy-MM-dd' 'HH:mm:ss"];
	
	return [formatter dateFromString:endDate];
}

- (void)resetDistanceAndSpeed{
	distance=0.0f;
	speed=0.0f;
}

#pragma mark -
#pragma mark calculations

- (float)calculateDistance{
	if (distance>0) return distance;
	float newDistance = 1.0f;
	distance = newDistance;
	[self save];
	return newDistance ;
}

- (NSString *)calculateDistanceAsString{
	float ratio;
	NSString *distanceUnit;
	NSString *format;
	NSInteger units = [[NSUserDefaults standardUserDefaults] integerForKey:@"unitsKey"];
	if (units == 1){
		ratio = 1.f;
		distanceUnit = @"m";
		format = @"%0.0f %@";
	} else {
		ratio = 1609.0f;
		distanceUnit = @"miles";
		format = @"%1.3f %@";
	}
	float finalDistance = [self calculateDistance]/ratio;
	return [NSString stringWithFormat:format, finalDistance, distanceUnit];
}

- (float)calculateSpeed{

	return speed;
}

- (NSString *)calculateSpeedAsString{
	[self calculateSpeed];
	float ratio;
	NSString *speedUnit;
	NSInteger units = [[NSUserDefaults standardUserDefaults] integerForKey:@"unitsKey"];
	if (units == 1){
		ratio = 1.f;
		speedUnit = @"km/h";
	} else {
		ratio = 1.609f;
		speedUnit = @"mph";
	}
	float finalSpeed = speed/ratio * 3.6f;
	return [NSString stringWithFormat:@"%0.2f %@", finalSpeed, speedUnit];
}

- (NSString *)calculateRythmAsString{
	float rythm = 1000.f/(60.f*[self calculateSpeed]);
	NSInteger units = [[NSUserDefaults standardUserDefaults] integerForKey:@"unitsKey"];
	NSString *stringWithFormat;
	if(units == 1){
		stringWithFormat = [[NSString alloc] initWithFormat:@"%2.2f min/km", rythm];
	} else {
		stringWithFormat = [[NSString alloc] initWithFormat:@"%0.0f min/mile", rythm];
	}
	return stringWithFormat;
}


- (void)updateMaxSpeed {
	maxSpeed = 0.0f;
	NSMutableArray *average = [[NSMutableArray alloc] init];
	id point;
	NSEnumerator *enumerator = [[self trackpoints] objectEnumerator];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
	[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	
	NSString *currentPointString;
	NSDate *currentTime, *latestTime;
	NSTimeInterval timeElapsed, instantTimeElapsed;
	double aLatitude, aLongitude;
	CLLocation *lastLoc, *currentLoc;
	float currentDistance=0.0f;
	float currentSpeed = 0.0f;
	int i=0;
	BOOL isFirst= TRUE;
	int pas = 2;
	NSDate *firstTime = [self startTime];
	
	while ((point = [enumerator nextObject])) {
		TrackPoint *currentPoint = (TrackPoint *)point;
		currentPointString = currentPoint.time;
		currentTime = [formatter dateFromString:currentPointString];
		
		// Dead Store here: it means this variable is never used.
		// Why is it there? is it an error, code that changed? You have to do something about it.
		
		timeElapsed = [currentTime timeIntervalSinceDate:firstTime];
		aLatitude = [[currentPoint latitude] doubleValue];
		aLongitude = [[currentPoint longitude] doubleValue];
		
		currentLoc = [[CLLocation alloc] initWithLatitude:aLatitude longitude:aLongitude];
		if(i>0 && (i%pas)==0){
			currentDistance = [currentLoc getDistanceFrom:lastLoc];
			[lastLoc release];
			instantTimeElapsed = [currentTime timeIntervalSinceDate:latestTime];
			latestTime = currentTime;
			lastLoc = currentLoc;
			[lastLoc retain];
			currentSpeed = currentDistance / instantTimeElapsed;
			NSNumber *aSpeed = [NSNumber numberWithFloat:currentSpeed];
			int accuracy = [currentPoint.accuracy intValue];
			if(currentSpeed>0 && instantTimeElapsed>0 && accuracy<50){
				if(isFirst){
					[average addObject:[NSNumber numberWithDouble:0]];
					isFirst =!isFirst;
				} else {
					// Calcul vitesse moyenne sur 9 points +1
					NSEnumerator *enu2 = [average objectEnumerator];
					NSNumber *pastSpeed;
					float totalSpeed = 0.0f;
					while ((pastSpeed = [enu2 nextObject])) {
						totalSpeed += [pastSpeed floatValue];
					}
					float averageSpeed =([aSpeed floatValue]+totalSpeed)/([average count]+1);
					aSpeed = [NSNumber numberWithFloat:averageSpeed];
					
					if([average count]==9){
						[average removeObjectAtIndex:0];
					}
					[average addObject:aSpeed];
				}
				if([aSpeed floatValue] > maxSpeed) maxSpeed = [aSpeed floatValue];
				//NSLog (@"Max %@", maxSpeed);
			}
		}
		if(i==0){
			latestTime = currentTime;
			lastLoc = currentLoc;
			[lastLoc retain];
		}
		[currentLoc release];
		i++;
	}
	[self save];
	[average release];
	[formatter release];
}


/* CALORIES
 Calories burned by exercise = ((METs * 3.5 * weight in kg) / 200) * duration in minutes. 
 MET : http://prevention.sph.sc.edu/tools/docs/documents_compendium.pdf
 12030 8.0 12030 8.0 running running, 5 mph (12 min/mile) 
 12040 9.0 12040 9.0 running running, 5.2 mph (11.5 min/mile) 
 12050 10.0 12050 10.0 running running, 6 mph (10 min/mile) 
 12060 11.0 12060 11.0 running running, 6.7 mph (9 min/mile) 
 12070 11.5 12070 11.5 running running, 7 mph (8.5 min/mile) 
 12080 12.5 12080 12.5 running running, 7.5 mph (8 min/mile) 
 12090 13.5 12090 13.5 running running, 8 mph (7.5 min/mile) 
 12100 14.0 12100 14.0 running running, 8.6 mph (7 min/mile) 
 12110 15.0 12110 15.0 running running, 9 mph (6.5 min/mile) 
 12120 16.0 12120 16.0 running running, 10 mph (6 min/mile) 
 12130 18.0 12130 18.0 running running, 10.9 mph (5.5 min/mile) 
 
 17170 3.0 17170 3.0 walking walking, 2.5 mph, firm surface 
 17180 3.0 17180 2.8 walking walking, 2.5 mph, downhill 
 17190 3.5 17190 3.3 walking walking, 3.0 mph, level, moderate pace, firm surface 
 17200 4.0 17200 3.8 walking walking, 3.5 mph, level, brisk, firm surface, walking for exercise 
 17210 6.0 17210 6.0 walking walking, 3.5 mph, uphill 
 17220 4.0 17220 5.0 walking walking, 4.0 mph, level, firm surface, very brisk pace 
 17230 4.5 17230 6.3 walking walking, 4.5 mph, level, firm su
 
 01020 6.0 01020 6.0 bicycling bicycling, 10-11.9 mph, leisure, slow, light effort 
 01030 8.0 01030 8.0 bicycling bicycling, 12-13.9 mph, leisure, moderate effort  
 01040 10.0 01040 10.0 bicycling bicycling, 14-15.9 mph, racing or leisure, fast, vigorous effor 
 01050 12.0 01050 12.0 bicycling bicycling, 16-19 mph, racing/not drafting or >19 mph drafting, very fast, racing genera 
 01060 16.0 01060 16.0 bicycling bicycling, >20 mph, racing, not drafting 
 */

- (int)calculateCalories{
	int weight = [[NSUserDefaults standardUserDefaults] integerForKey:@"weightKey"];
	int mets = 7.0;
	[self checkAndHydrate];
	[self calculateSpeed];
	int speedKmh = speed * 3.6;
	if(speedKmh>8.045) mets=8;
	if(speedKmh>8.3668) mets=9;
	if(speedKmh>9.654) mets=10;
	if(speedKmh>10.7803) mets=11;
	if(speedKmh>11.263) mets=11.5;
	if(speedKmh>12.0675) mets=12.5;
	if(speedKmh>12.872) mets=13.5;
	if(speedKmh>13.8374) mets=14;
	if(speedKmh>14.481) mets=15;
	if(speedKmh>16.09) mets=16;
	if(speedKmh>17.5381) mets=18;
	return ((mets * 3.5 * weight) / 200) * ([self calculateTotalTime]/60);
}




- (NSTimeInterval) calculateTotalTime{
	NSTimeInterval duration = [[self endTime] timeIntervalSinceDate:[self startTime]];
	return duration;
}

- (NSString*) totalTimeAsString {
	NSTimeInterval duration = [self calculateTotalTime];
	int hours = duration / 3600;
	int minutes = (int)(duration / 60) % 60;
	int seconds;
	if(duration>0){
		seconds = (int)duration % 60;
	} else {
		seconds = 0;
	}
	return [NSString stringWithFormat:@"%.2dh:%.2dm:%.2ds",hours, minutes, seconds ];
}

#pragma mark -
#pragma mark Export methods




- (NSMutableArray *)generatePointSeries {
	if(serie != nil) return serie;
	serie = [[NSMutableArray alloc] init];
	NSMutableArray *average = [[NSMutableArray alloc] init];
	id point;
	maxSpeed = 0.0f;
	NSEnumerator *enumerator = [[self trackpoints] objectEnumerator];
	
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init]  autorelease];
	[formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
	[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	
	NSString *currentPointString;
	NSDate *currentTime;
	NSDate *latestTime;
	NSTimeInterval timeElapsed, instantTimeElapsed;
	double aLatitude, aLongitude;
	CLLocation *lastLoc, *currentLoc;
	float currentDistance=0.0f;
	float currentSpeed = 0.0f;
	int i=0;
	BOOL isFirst= TRUE;
	int pas = 2;
	NSDate *firstTime = [self startTime];
	
	while ((point = [enumerator nextObject])) {
		TrackPoint *currentPoint = (TrackPoint *)point;
		currentPointString = currentPoint.time;
		currentTime = [formatter dateFromString:currentPointString];
		timeElapsed = [currentTime timeIntervalSinceDate:firstTime];
		aLatitude = [[currentPoint latitude] doubleValue];
		aLongitude = [[currentPoint longitude] doubleValue];
		
		currentLoc = [[CLLocation alloc] initWithLatitude:aLatitude longitude:aLongitude];
		if(i>0 && (i%pas)==0){
			currentDistance = [currentLoc getDistanceFrom:lastLoc];
			[lastLoc release];
			instantTimeElapsed = [currentTime timeIntervalSinceDate:latestTime];
			latestTime = currentTime;
			lastLoc = currentLoc;
			[lastLoc retain];
			currentSpeed = currentDistance / instantTimeElapsed;
			NSNumber *aSpeed = [NSNumber numberWithFloat:currentSpeed];
			int accuracy = [currentPoint.accuracy intValue];
			if(currentSpeed>0 && instantTimeElapsed>0 && accuracy<50 && accuracy>0){
				NSArray *keys = [NSArray arrayWithObjects:@"speed", @"time", nil];
				NSArray *objects;
				if(isFirst){
					objects = [NSArray arrayWithObjects:[NSNumber numberWithDouble:0], [NSNumber numberWithDouble:0], nil];
					[average addObject:[NSNumber numberWithDouble:0]];
					isFirst =!isFirst;
				} else {
					// Calcul vitesse moyenne sur 9 points +1
					NSEnumerator *enu2 = [average objectEnumerator];
					NSNumber *pastSpeed;
					float totalSpeed = 0.0f;
					while ((pastSpeed = [enu2 nextObject])) {
						totalSpeed += [pastSpeed floatValue];
					}
					float averageSpeed =([aSpeed floatValue]+totalSpeed)/([average count]+1);
					aSpeed = [NSNumber numberWithFloat:averageSpeed];
					
					
					if([average count]==9){
						[average removeObjectAtIndex:0];
					}
					[average addObject:aSpeed];
					objects = [NSArray arrayWithObjects:aSpeed, [NSNumber numberWithDouble:timeElapsed], nil];
				}
				NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
				[serie addObject:dictionary];
				if([aSpeed floatValue] > maxSpeed) maxSpeed = [aSpeed floatValue];
				//NSLog (@"Max %@",maxSpeed);
			}
		}
		if(i==0){
			latestTime = currentTime;
			lastLoc = currentLoc;
			[lastLoc retain];
		}
		[currentLoc release];
		i++;
	}
	[self save];
	return serie;
}

@end

@implementation TrackPoint
@synthesize longitude, latitude, altitude, time, accuracy;
+ (void)deleteTrackPointsIntoDatabase:(sqlite3 *)database 
						   forTrackId:(NSInteger)trackId{}
@end

@implementation TrainerAppDelegate
- (Boolean)isLite{ return NO;}
@end

