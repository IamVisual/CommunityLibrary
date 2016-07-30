//
//  ChatEntity.h
//  Zero Platform
//
//  Created by Team Zero on 22/7/16.
//  Copyright © 2016 Charter Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FileEntity, MessageEntity, UserEntity;

NS_ASSUME_NONNULL_BEGIN

@interface ChatEntity : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "ChatEntity+CoreDataProperties.h"
