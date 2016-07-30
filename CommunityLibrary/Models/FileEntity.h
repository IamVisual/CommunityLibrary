//
//  FileEntity.h
//  Zero Platform
//
//  Created by Team Zero on 22/7/16.
//  Copyright © 2016 Charter Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChatEntity, MessageEntity, UserEntity;

NS_ASSUME_NONNULL_BEGIN

@interface FileEntity : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "FileEntity+CoreDataProperties.h"
