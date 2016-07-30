//
//  CommunityLibraryPubNubManager.m
//  Zero Platform
//
//  Created by Team Zero on 18/7/16.
//  Copyright © 2016 Charter Partners. All rights reserved.
//

#import "CommunityLibraryPubNubManager.h"

@interface CommunityLibraryPubNubManager ()
<
PNObjectEventListener
>

@property (nonatomic) PubNub *client;

@end

@implementation CommunityLibraryPubNubManager

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"pub-c-8697c53b-34eb-4cfb-84a3-58f69b6033cd"
                                                                         subscribeKey:@"sub-c-693a6c02-533f-11e6-82fe-0619f8945a4f"];
        self.client = [PubNub clientWithConfiguration:configuration];
        [self.client addListener:self];
    }
    
    return self;
}

- (void) registerPushToken: (NSData*) pushToken
               forChannels: (NSArray*) channels
           completionBlock: (CommunityLibraryPubNubManagerCompletionBlock) aBlock
{
    __weak CommunityLibraryPubNubManager* weakSelf = self;
    
    [self.client removeAllPushNotificationsFromDeviceWithPushToken: pushToken
                                                     andCompletion:^(PNAcknowledgmentStatus * _Nonnull status) {}];
    
    [self.client addPushNotificationsOnChannels: channels
                            withDevicePushToken: pushToken
                                  andCompletion:^(PNAcknowledgmentStatus *status) {
                                      
                                      if (status.isError)
                                      {
                                          weakSelf.isPushTokenRegistered = NO;
                                          aBlock(NO, status.errorData, nil);
                                      }
                                      else
                                      {
                                          weakSelf.isPushTokenRegistered = YES;
                                          aBlock(YES, nil, nil);
                                      }
                                      
                                  }];
}

- (void) sendMessage: (id) message
           toChannel: (NSString*) channelName
     completionBlock: (CommunityLibraryPubNubManagerCompletionBlock) aBlock
{
    NSString* dateStr = [[CommunityLibraryManager dateFormatter] stringFromDate: [NSDate date]];
    
    NSNumber* userId = [NSNumber numberWithInteger: [USER_DEFAULTS integerForKey: DEFAULT_USER_ID]];
    
    NSDictionary* messageDic = @{ @"message" : @{ @"createdAt"  : dateStr,
                                                  @"updatedAt"  : dateStr,
                                                  @"chatId" : channelName,
                                                  @"userId"     : userId,
                                                  @"type" : @"chatMessage",
                                                  @"text"       : message
//                                                  @"media" : @[],
//                                                  @"location" : @{}
                                                  } };
    
    NSString* name = @"Aleksandr V.:";
    NSString* msgStr = @"";
    
    if ([message isKindOfClass: [NSString class]])
    {
        NSString* nMessage = (NSString*)message;
        if (nMessage.length <= 15)
        {
            msgStr = [NSString stringWithFormat: @"%@ %@", name, nMessage];
        }
        else
        {
            msgStr = [NSString stringWithFormat: @"%@ %@...", name, [nMessage substringToIndex: 10]];
        }
    }
    else
    {
        msgStr = [NSString stringWithFormat: @"%@ some changes", name];
    }
    
    NSDictionary* pushDic = @{ @"alert"         : msgStr,
                               @"sound"         : @"default",
                               @"identifier"    : channelName,
                               @"object"        : @"chat",
                               @"userId"        : userId,
                               @"type"          : @"chatMessage"};
    
    NSDictionary* fullPush = @{ @"apns" : @{ @"aps": pushDic },
                                @"gcm" : @{ @"data": pushDic } };
    
    [self.client publish: messageDic
               toChannel: channelName
       mobilePushPayload: fullPush
          storeInHistory: YES
          withCompletion:^(PNPublishStatus * _Nonnull status) {
              aBlock(YES, nil, nil);
          }];
}

- (void)getHistoryForChatRoom: (NSString*) chatRoom
               startTimestamp: (NSNumber*) startTimestamp
              completionBlock: (void(^)(PNErrorData *error, PNHistoryData* response)) aBlock
{
    [self.client historyForChannel: chatRoom
                             start: startTimestamp
                               end: nil
                             limit: 100
                    withCompletion:^(PNHistoryResult * _Nullable result, PNErrorStatus * _Nullable status) {
                        
                        if (status.isError)
                        {
                            aBlock(status.errorData, nil);
                        }
                        else
                        {
                            aBlock(nil, result.data);
                        }
                        
                    }];
}

#pragma mark Subscribe

- (NSArray*) subscribeChannels
{
    return self.client.channels;
}

- (void) subscribeToChannel: (NSString*) channelName
{
    [self subscribeToChannels: @[ channelName ]];
}

- (void) subscribeToChannels: (NSArray*) channels
{
    [self.client subscribeToChannels: channels withPresence: NO];
}

#pragma mark Unsubscribe

- (void) unsubscribeFromAllChannels
{
    [self.client unsubscribeFromAll];
}

- (void) unsubscribeFromChannel: (NSString*) channelName
{
    [self unsubscribeFromChannels: @[ channelName ]];
}

- (void) unsubscribeFromChannels: (NSArray*) channels
{
    [self.client unsubscribeFromChannels: channels withPresence: NO];
}

#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message
{
    if ([self.delegate respondsToSelector: @selector(parsePubNubMessage:)])
    {
        [self.delegate parsePubNubMessage: message.data];
    }
}

- (void)client:(PubNub *)client didReceiveStatus:(PNSubscribeStatus *)status
{
    if (status.category == PNUnexpectedDisconnectCategory)
    {
        
    }
    else if (status.category == PNConnectedCategory)
    {
        [self.client publish: @"Hello from the PubNub Objective-C SDK"
                   toChannel: @"my_channel"
              withCompletion:^(PNPublishStatus *status)
         {
             if (!status.isError)
             {
                 
             }
             else
             {
                 
             }
         }];
    }
    else if (status.category == PNReconnectedCategory)
    {
        
    }
    else if (status.category == PNDecryptionErrorCategory)
    {
        
    }
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event
{
    
}

@end
