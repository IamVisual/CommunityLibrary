//
//  MessageEntity.h
//  Zero Platform
//
//  Created by Team Zero on 22/7/16.
//  Copyright © 2016 Charter Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChatEntity, FileEntity, UserEntity;

NS_ASSUME_NONNULL_BEGIN

@interface MessageEntity : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "MessageEntity+CoreDataProperties.h"
