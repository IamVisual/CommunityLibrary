//
//  CommunityLibraryPubNubManager.h
//  Zero Platform
//
//  Created by Team Zero on 18/7/16.
//  Copyright © 2016 Charter Partners. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <PubNub/PubNub.h>

@protocol CommunityLibraryPubNubManagerDelegate;

typedef void (^CommunityLibraryPubNubManagerCompletionBlock)(BOOL success, PNErrorData *error, id response);

@interface CommunityLibraryPubNubManager : NSObject

@property (weak, nonatomic) id <CommunityLibraryPubNubManagerDelegate> delegate;

@property (assign, nonatomic) BOOL isPushTokenRegistered;

- (instancetype) init;

- (void) registerPushToken: (NSData*) pushToken
               forChannels: (NSArray*) channels
           completionBlock: (CommunityLibraryPubNubManagerCompletionBlock) aBlock;

- (void)getHistoryForChatRoom: (NSString*) chatRoom
               startTimestamp: (NSNumber*) startTimestamp
              completionBlock: (void(^)(PNErrorData *error, PNHistoryData* response)) aBlock;

- (NSArray*) subscribeChannels;
- (void) subscribeToChannel: (NSString*) channelName;
- (void) subscribeToChannels: (NSArray*) channels;

- (void) unsubscribeFromAllChannels;
- (void) unsubscribeFromChannel: (NSString*) channelName;
- (void) unsubscribeFromChannels: (NSArray*) channels;

- (void) sendMessage: (id) message
           toChannel: (NSString*) channelName
     completionBlock: (CommunityLibraryPubNubManagerCompletionBlock) aBlock;

@end

@protocol CommunityLibraryPubNubManagerDelegate <NSObject>

- (void) parsePubNubMessage: (PNMessageData*) message;

@end
