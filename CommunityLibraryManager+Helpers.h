//
//  CommunityLibraryManager+Helpers.h
//  CommunityLibrary
//
//  Created by Aleksandr Vnukov on 23.07.16.
//  Copyright © 2016 Aleksandr Vnukov. All rights reserved.
//

#import "CommunityLibraryManager.h"

@interface CommunityLibraryManager (Helpers)

+ (NSDateFormatter*) dateFormatter;

+ (NSDate*) dateOneMonthAgo;

+ (NSNumber*) timestampOneMonthAgo;
+ (NSNumber*) timestampCurrentDate;

@end
