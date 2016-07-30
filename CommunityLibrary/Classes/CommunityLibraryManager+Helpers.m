//
//  CommunityLibraryManager+Helpers.m
//  CommunityLibrary
//
//  Created by Aleksandr Vnukov on 23.07.16.
//  Copyright © 2016 Aleksandr Vnukov. All rights reserved.
//

#import "CommunityLibraryManager+Helpers.h"

@implementation CommunityLibraryManager (Helpers)

+ (NSDateFormatter*) dateFormatter
{
    NSDateFormatter *fullDateFormatter = [[NSDateFormatter alloc] init];
    [fullDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"];
    
    return fullDateFormatter;
}

+ (NSDate*) dateOneMonthAgo
{
    NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setMonth: -1];
    
    NSDate *oneMonthAgo = [gregorian dateByAddingComponents: offsetComponents
                                                     toDate: [NSDate date]
                                                    options: 0];
    return oneMonthAgo;
}

+ (NSNumber*) timestampOneMonthAgo
{
    return [CommunityLibraryManager timeIntarvalSinceDate: [CommunityLibraryManager dateOneMonthAgo]];
}

+ (NSNumber*) timestampCurrentDate
{
    return [CommunityLibraryManager timeIntarvalSinceDate: [NSDate date]];
}

+ (NSNumber*) timeIntarvalSinceDate: (NSDate*) date
{
    double timeInterval = [date timeIntervalSince1970];
    double miliSeconds = timeInterval * 10000000.0f;
    return [NSNumber numberWithDouble: miliSeconds];
}

@end
