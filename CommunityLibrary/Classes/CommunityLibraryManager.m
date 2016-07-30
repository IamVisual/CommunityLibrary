//
//  CommunityLibraryManger.m
//  Zero Platform
//
//  Created by Team Zero on 18/7/16.
//  Copyright © 2016 Charter Partners. All rights reserved.
//

#import "CommunityLibraryManager.h"

#import "CommunityLibraryPubNubManager.h"
#import "CommunityLibraryNetworkManager.h"

@interface CommunityLibraryManager ()
<
CommunityLibraryPubNubManagerDelegate
>

@property (strong, nonatomic) CommunityLibraryPubNubManager* pubNubManager;

@property (strong, nonatomic) NSString* userSystemChannel;

@property (assign, nonatomic) BOOL isPushTokenRegistering;

@end

@implementation CommunityLibraryManager

+ (instancetype)sharedInstance
{
    static CommunityLibraryManager* instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[CommunityLibraryManager alloc] init];
    });
    return instance;
}

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        [self startPushToken];
        
        self.userSystemChannel = [NSString stringWithFormat: @"user_notifier_%@", [USER_DEFAULTS objectForKey: DEFAULT_USER_ID]];
        
        self.pubNubManager = [[CommunityLibraryPubNubManager alloc] init];
        [self.pubNubManager setDelegate: self];
        
        [self updateUsers]; // remove this method
        
        [self updateAllChatsFromServerWithCompletionBlock:^(NSError *error) {}];
    }
    
    return self;
}

- (void) startPushToken
{
//    if ([UIDevice isSystemVersion8])
//    {
        [[UIApplication sharedApplication] registerUserNotificationSettings: [UIUserNotificationSettings settingsForTypes: (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
//    }
//    else
//    {
//        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: ( UIRemoteNotificationTypeBadge |
//                                                                                UIRemoteNotificationTypeSound |
//                                                                                UIRemoteNotificationTypeAlert ) ];
//    }
}

- (void) registerPushToken
{
    if (!self.isPushTokenRegistering && [[self.pubNubManager subscribeChannels] count] > 0)
    {
        __weak CommunityLibraryManager* weakSelf = self;
        
        NSLog(@"subscribeChannels\n%@", [self.pubNubManager subscribeChannels]);
        self.isPushTokenRegistering = YES;
        [self.pubNubManager registerPushToken: self.pushToken
                                  forChannels: [self.pubNubManager subscribeChannels]
                              completionBlock:^(BOOL success, PNErrorData *error, id response) {
                                  NSLog(@"PUSH ERROR - %@", error);
                                  weakSelf.isPushTokenRegistering = NO;
                              }];
    }
}

- (void) parsePushNotificationMessage: (id) message
{
    NSLog(@"push message\n%@",message);
}

#pragma mark - CommunityLibraryPubNubManagerDelegate

- (void) parsePubNubMessage: (PNMessageData*) message
{
    NSDictionary* messageDic = message.message[@"message"];
    
    NSLog(@"messageDic\n%@", messageDic);
    if ([message.subscribedChannel isEqualToString: self.userSystemChannel])
    {
        NSString* action = messageDic[@"action"];
        NSString* object = messageDic[@"object"];
        
        if ([object isEqualToString: @"chat"])
        {
            NSString* chatId = [NSString stringWithFormat:@"%@", messageDic[@"identifier"]];
            
            
            
            if ([action isEqualToString: @"create"])
            {
                [self getChatWithId: chatId competionBlock:^(NSError *error) {}];
            }
            else if ([action isEqualToString: @"update"])
            {
                [self getChatWithId: chatId competionBlock:^(NSError *error) {}];
            }
            else if ([action isEqualToString: @"leave"])
            {
                [self updateChatInDbWithChatId: chatId isMute: YES completionBlock:^(NSError *error) {}];
            }
            else if ([action isEqualToString: @"destroy"])
            {
                [self deleteChatFromDbWithChatId: chatId completionBlock:^(NSError *error) {}];
            }
        }
    }
    else
    {
        [[CommunityLibraryDataBaseManager sharedInstance] updateMessageWithDic: messageDic
                                                               completionBlock:^(NSError *error) {}];
    }
}

#pragma mark - Chat

- (void) updateAllChatsFromServerWithCompletionBlock: (void(^)(NSError* error)) completionBlock
{
    [[CommunityLibraryNetworkManager sharedInstance] getAllChatsWithCompletionBlock:^(BOOL success, NSError *error, id response) {
        
        if (error)
        {
            completionBlock(error);
        }
        else
        {
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                
                [[CommunityLibraryDataBaseManager sharedInstance] updateChats: [response objectForKey: @"chats"]
                                                              completionBlock:^(NSError *error, NSArray *subscribeChatsIds, NSArray *unsubscribeChatsIds) {
                                                                  
                      [self updateChatChannels: subscribeChatsIds];
                      
                      for (NSString* currentChatRoom in subscribeChatsIds)
                      {
                          dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                              [self updateChatHistoryForChatRoom: currentChatRoom
                                                  startTimestamp: nil
                                                 completionBlock:^(NSError *error) {}];
                          });
                      }
                      
                      dispatch_async(dispatch_get_main_queue(), ^{
                          completionBlock(nil);
                      });
                                                              }];
            });
        }
        
    }];
}

- (void) updateChatHistoryForChatRoom: (NSString*) chatRoom
                       startTimestamp: (NSNumber*) startTimestamp
                      completionBlock: (void(^)(NSError* error)) completionBlock
{
    [self.pubNubManager getHistoryForChatRoom: chatRoom
                               startTimestamp: startTimestamp
                              completionBlock:^(PNErrorData *error, PNHistoryData *response) {
                                  
                                  dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                      [[CommunityLibraryDataBaseManager sharedInstance] updateMessages: response.messages
                                                                             chatStartHistoryTimeStamp: (response.start.integerValue == 0) ? nil : response.start
                                                                                       completionBlock:^(NSError *error) {}];
                                  });
                                  
                                  completionBlock(error);
                                  
                              }];
}

- (NSArray*) getAllChats
{
    return [[CommunityLibraryDataBaseManager sharedInstance] getAllChatsInContext: [CommunityLibraryDataBaseManager mainContext]];
}

- (void) createChatWithParticipants: (NSArray*) participants
                           chatName: (NSString*) chatName
                     competionBlock: (void(^)(NSError* error)) completionBlock
{
    [[CommunityLibraryNetworkManager sharedInstance] createChatWithParticipants: [CommunityLibraryManager usersIds: participants]
                                                                       chatName: chatName
                                                                completionBlock:^(BOOL success, NSError *error, id response) {
                                                                  
                                                                    if (error)
                                                                    {
                                                                        completionBlock(error);
                                                                    }
                                                                    else
                                                                    {
                                                                        [self createChatInDbWithChatDic: [response objectForKey: @"chat"]
                                                                                         competionBlock: completionBlock];
                                                                    }
                                                                    
                                                                }];
}

- (void) updateChatWithChatId: (NSString*) chatId
                 participants: (NSArray*) participants
                     chatName: (NSString*) chatName
              completionBlock: (void(^)(NSError* error)) completionBlock
{
    [[CommunityLibraryNetworkManager sharedInstance] updateChatWithChatId: chatId
                                                             participants: [CommunityLibraryManager usersIds: participants]
                                                                 chatName: chatName
                                                          completionBlock:^(BOOL success, NSError *error, id response) {
                                                              
                                                              if (error)
                                                              {
                                                                  completionBlock(error);
                                                              }
                                                              else
                                                              {
                                                                  [self updateChatInDbWithChatDic: [response objectForKey: @"chat"]
                                                                                  completionBlock: completionBlock];
                                                              }
                                                              
                                                          }];
}

- (void) deleteChatWithChatId: (NSString*) chatId
              completionBlock: (void(^)(NSError* error)) completionBlock
{
    [[CommunityLibraryNetworkManager sharedInstance] leaveFromChatWithChatId: chatId
                                                                      userId: [USER_DEFAULTS objectForKey: DEFAULT_USER_ID]
                                                             completionBlock:^(BOOL success, NSError *error, id response) {
                                                                 
                                                                 if (error)
                                                                 {
                                                                     completionBlock(error);
                                                                 }
                                                                 else
                                                                 {
                                                                     [self deleteChatFromDbWithChatId: chatId
                                                                                      completionBlock: completionBlock];
                                                                     
                                                                     completionBlock(nil);
                                                                 }
                                                                 
                                                             }];
}

- (void) leaveFromChatWithChatId: (NSString*) chatId
                 completionBlock: (void(^)(NSError* error)) completionBlock
{
    [[CommunityLibraryNetworkManager sharedInstance] leaveFromChatWithChatId: chatId
                                                                      userId: [USER_DEFAULTS objectForKey: DEFAULT_USER_ID]
                                                             completionBlock:^(BOOL success, NSError *error, id response) {
                                                                 
                                                                 if (error)
                                                                 {
                                                                     completionBlock(error);
                                                                 }
                                                                 else
                                                                 {
                                                                     [self updateChatInDbWithChatId: chatId
                                                                                             isMute: YES
                                                                                    completionBlock:^(NSError *error) {}];
                                                                     
                                                                     completionBlock(nil);
                                                                 }
                                                                 
                                                             }];
}

- (void) getChatWithId: (NSString*) chatId
        competionBlock: (void(^)(NSError* error)) completionBlock
{
    [[CommunityLibraryNetworkManager sharedInstance] getChatWithChatId: chatId
                                                       completionBlock:^(BOOL success, NSError *error, id response) {
                                                       
                                                           if (error)
                                                           {
                                                               completionBlock(error);
                                                           }
                                                           else
                                                           {
                                                               [self updateChatInDbWithChatDic: [response objectForKey: @"chat"]
                                                                               completionBlock: completionBlock];
                                                           }
                                                           
                                                       }];
}

- (void) updateChatChannels: (NSArray*) channels
{
    NSMutableArray* channelsAll = [[NSMutableArray alloc] initWithArray: channels];
    [channelsAll addObject: self.userSystemChannel];
    
    [self.pubNubManager unsubscribeFromAllChannels];
    [self.pubNubManager subscribeToChannels: channelsAll];
    [self registerPushToken];
}

#pragma mark Chat DB

- (void) createChatInDbWithChatDic: (NSDictionary*) chatDic
                    competionBlock: (void(^)(NSError* error)) completionBlock
{
    [self updateChatInDbWithChatDic: chatDic completionBlock: completionBlock];
}

- (void) updateChatInDbWithChatDic: (NSDictionary*) chatDic
                   completionBlock: (void(^)(NSError* error)) completionBlock
{
    [[CommunityLibraryDataBaseManager sharedInstance] updateChatWithDic: chatDic
                                                        completionBlock:^(NSError *error, NSString *subscribeChats) {
                                                            
                                                            if (![[self.pubNubManager subscribeChannels] containsObject: subscribeChats])
                                                            {
                                                                [self.pubNubManager subscribeToChannel: subscribeChats];
                                                                [self registerPushToken];
                                                            }
                                                            
                                                            completionBlock(error);
                                                        }];
}

- (void) updateChatInDbWithChatId: (NSString*) chatId
                           isMute: (BOOL) isMute
                  completionBlock: (void(^)(NSError* error)) completionBlock
{
    [[CommunityLibraryDataBaseManager sharedInstance] updaChatWithChatId: chatId
                                                               muteState: isMute
                                                         completionBlock:^(NSError *error, NSString* chatRoom) {
                                                             
                                                             if (isMute && [[self.pubNubManager subscribeChannels] containsObject: chatRoom])
                                                             {
                                                                 [self.pubNubManager unsubscribeFromChannel: chatRoom];
                                                                 [self registerPushToken];
                                                             }
                                                             else if (!isMute && ![[self.pubNubManager subscribeChannels] containsObject: chatRoom])
                                                             {
                                                                 [self.pubNubManager subscribeToChannel: chatRoom];
                                                                 [self registerPushToken];
                                                             }
                                                             
                                                             completionBlock(error);
                                                             
                                                         }];
}

- (void) deleteChatFromDbWithChatId: (NSString*) chatId
                    completionBlock: (void(^)(NSError* error)) completionBlock
{
    [[CommunityLibraryDataBaseManager sharedInstance] deleteChatWithChatId: chatId
                                                           completionBlock:^(NSError *error, NSString *unsubscribeChats) {
                                                               
                                                               if ([[self.pubNubManager subscribeChannels] containsObject: unsubscribeChats])
                                                               {
                                                                   [self.pubNubManager unsubscribeFromChannel: unsubscribeChats];
                                                                   [self registerPushToken];
                                                               }
                                                               
                                                               completionBlock(error);
                                                           }];
}

#pragma mark - Message

- (void) sendMessage: (id) message
             forChat: (id) chat
     completionBlock: (void(^)(NSError* error)) completionBlock
{
    [self.pubNubManager sendMessage: message
                          toChannel: chat
                    completionBlock:^(BOOL success, PNErrorData *error, id response) {
                        completionBlock(error);
                        // if response success add message to chat.
                    }];
}

#pragma mark - User

+ (NSArray*) usersIds: (NSArray*) users
{
    NSMutableArray* ids = [[NSMutableArray alloc] initWithCapacity: users.count];
    
    for (UserEntity* curUser in users)
    {
        [ids addObject: curUser.serverId];
    }
    
    return ids;
}

- (void) updateUsers
{
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    
    for (int index = 1; index <= 30; index++)
    {
        NSDictionary* curUserDic = @{ @"id" : [NSNumber numberWithInt: index],
                                      @"first_name" : [NSString stringWithFormat: @"firstName%@", [NSNumber numberWithInt: index]],
                                      @"last_name" : [NSString stringWithFormat: @"lastName%@", [NSNumber numberWithInt: index]] };
        
        [arr addObject: curUserDic];
    }
    
    [[CommunityLibraryDataBaseManager sharedInstance] updateUsers: arr completionBlock:^(NSError *error) {}];
}

@end
