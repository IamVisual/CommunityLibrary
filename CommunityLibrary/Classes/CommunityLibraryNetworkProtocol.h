//
//  CommunityLibraryNetworkProtocol.h
//  CommunityLibrary
//
//  Created by Aleksandr Vnukov on 23.07.16.
//  Copyright © 2016 Aleksandr Vnukov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CommunityLibraryNetworkCompletionBlock)(BOOL success, NSError *error, id response);

@protocol CommunityLibraryNetworkProtocol <NSObject>

#pragma mark - Chat

- (void) createChatWithParticipants: (NSArray*) participants
                           chatName: (NSString*) chatName
                    completionBlock: (CommunityLibraryNetworkCompletionBlock) aBlock;

- (void) updateChatWithChatId: (NSString*) chatId
                 participants: (NSArray*) participants
                     chatName: (NSString*) chatName
              completionBlock: (CommunityLibraryNetworkCompletionBlock) aBlock;

- (void) getAllChatsWithCompletionBlock: (CommunityLibraryNetworkCompletionBlock) aBlock;

- (void) getChatWithChatId: (NSString*) chatId
           completionBlock: (CommunityLibraryNetworkCompletionBlock) aBlock;

- (void) deleteChatWithChatId: (NSString*) chatId
              completionBlock: (CommunityLibraryNetworkCompletionBlock) aBlock;

- (void) leaveFromChatWithChatId: (NSString*) chatId
                          userId: (NSNumber*) userId
                 completionBlock: (CommunityLibraryNetworkCompletionBlock) aBlock;

@end
