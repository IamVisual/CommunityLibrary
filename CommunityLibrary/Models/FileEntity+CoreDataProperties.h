//
//  FileEntity+CoreDataProperties.h
//  Zero Platform
//
//  Created by Team Zero on 22/7/16.
//  Copyright © 2016 Charter Partners. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FileEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface FileEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *fileId;
@property (nullable, nonatomic, retain) NSString *localUrl;
@property (nullable, nonatomic, retain) NSString *thumbUrl;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) ChatEntity *chatAvatar;
@property (nullable, nonatomic, retain) ChatEntity *chatFile;
@property (nullable, nonatomic, retain) MessageEntity *messageFile;
@property (nullable, nonatomic, retain) UserEntity *userAvatar;
@property (nullable, nonatomic, retain) UserEntity *userFile;

@end

NS_ASSUME_NONNULL_END
