//
//  CommunityLibraryManger.h
//  Zero Platform
//
//  Created by Team Zero on 18/7/16.
//  Copyright © 2016 Charter Partners. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CommunityLibraryDataBaseManager.h"

#define DEFAULT_USER_ID @"userDefaultsUserId"
#define DEFAULT_IS_NOT_FIRST_HISTORY_SYNC @"userDefaultsIsNotFirstHistorySync"

@interface CommunityLibraryManager : NSObject

@property (strong, nonatomic) NSData* pushToken;

+ (instancetype)sharedInstance;

- (void) parsePushNotificationMessage: (id) message;

#pragma mark - Chat

- (void) updateAllChatsFromServerWithCompletionBlock: (void(^)(NSError* error)) completionBlock;

- (NSArray*) getAllChats;

- (void) createChatWithParticipants: (NSArray*) participants
                           chatName: (NSString*) chatName
                     competionBlock: (void(^)(NSError* error)) completionBlock;

- (void) updateChatWithChatId: (NSString*) chatId
                 participants: (NSArray*) participants
                     chatName: (NSString*) chatName
              completionBlock: (void(^)(NSError* error)) completionBlock;

- (void) updateChatInDbWithChatId: (NSString*) chatId
                           isMute: (BOOL) isMute
                  completionBlock: (void(^)(NSError* error)) completionBlock;

- (void) deleteChatWithChatId: (NSString*) chatId
              completionBlock: (void(^)(NSError* error)) completionBlock;

- (void) leaveFromChatWithChatId: (NSString*) chatId
                 completionBlock: (void(^)(NSError* error)) completionBlock;

- (void) getChatWithId: (NSString*) chatId
        competionBlock: (void(^)(NSError* error)) completionBlock;

- (void) updateChatHistoryForChatRoom: (NSString*) chatRoom
                       startTimestamp: (NSNumber*) startTimestamp
                      completionBlock: (void(^)(NSError* error)) completionBlock;

#pragma mark - Message

- (void) sendMessage: (id) message
             forChat: (id) chat
     completionBlock: (void(^)(NSError* error)) completionBlock;

@end
