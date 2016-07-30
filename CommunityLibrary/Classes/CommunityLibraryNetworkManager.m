//
//  CommunityLibraryNetworkManager.m
//  Zero Platform
//
//  Created by Team Zero on 18/7/16.
//  Copyright © 2016 Charter Partners. All rights reserved.
//

#import "CommunityLibraryNetworkManager.h"

#import "AFURLResponseSerialization.h"

@interface CommunityLibraryNetworkManager ()

@property (strong, nonatomic) NSString* communityServBaseUrl;

@end

@implementation CommunityLibraryNetworkManager

+ (instancetype)sharedInstance
{
    static CommunityLibraryNetworkManager* instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[CommunityLibraryNetworkManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    NSString* bundleIden = [[NSBundle mainBundle] bundleIdentifier];
    NSString* devUrl = @"http://samplechats.livegenic.com/pubnub_chats_api/";
    NSString* stagUrl = @"http://samplechats.livegenic.com/pubnub_chats_api/";
    self.communityServBaseUrl = ([bundleIden isEqualToString: @"com.zero.beta.ios"]) ? devUrl : stagUrl;
    
    
    NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self = [super initWithBaseURL: [NSURL URLWithString: self.communityServBaseUrl]
             sessionConfiguration: configuration];
    if(self)
    {
        AFJSONResponseSerializer* ser = [AFJSONResponseSerializer serializer];
        ser.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        ser.readingOptions = NSJSONReadingAllowFragments;
        self.responseSerializer = ser;
        
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        [self.requestSerializer setValue: @"application/json" forHTTPHeaderField: @"Accept"];
        [self.requestSerializer setValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
    }
    
    return self;
}

#pragma mark - Chat

- (void) createChatWithParticipants: (NSArray*) participants
                           chatName: (NSString*) chatName
                    completionBlock: (CommunityLibraryNetworkCompletionBlock) aBlock
{
    [self POSTWithMethodName: @"chats"
                  withParams: [@{ @"chat" : @{ @"name" : chatName, @"user_ids" : participants } } mutableCopy]
         withCompletionBlock: aBlock];
}

- (void) updateChatWithChatId: (NSString*) chatId
                 participants: (NSArray*) participants
                     chatName: (NSString*) chatName
              completionBlock: (CommunityLibraryNetworkCompletionBlock) aBlock
{
    [self PATCHWithMethodName: [NSString stringWithFormat: @"chats/%@", chatId]
                   withParams: [@{ @"chat" : @{ @"name" : chatName, @"user_ids" : participants }} mutableCopy]
          withCompletionBlock: aBlock];
}

- (void) getAllChatsWithCompletionBlock: (CommunityLibraryNetworkCompletionBlock) aBlock
{
    [self GETWithMethodName: @"chats"
                 withParams: nil
        withCompletionBlock: aBlock];
}

- (void) getChatWithChatId: (NSString*) chatId
           completionBlock: (CommunityLibraryNetworkCompletionBlock) aBlock
{
    [self GETWithMethodName: [NSString stringWithFormat: @"chats/%@", chatId]
                 withParams: nil
        withCompletionBlock: aBlock];
}

- (void) deleteChatWithChatId: (NSString*) chatId
              completionBlock: (CommunityLibraryNetworkCompletionBlock) aBlock
{
    [self DELETEWithMethodName: [NSString stringWithFormat: @"chats/%@", chatId]
                    withParams: nil
           withCompletionBlock: aBlock];
}

- (void) leaveFromChatWithChatId: (NSString*) chatId
                          userId: (NSNumber*) userId
                 completionBlock: (CommunityLibraryNetworkCompletionBlock) aBlock
{
    [self POSTWithMethodName: [NSString stringWithFormat: @"chats/%@/remove_user", chatId]
                  withParams: [@{ @"userId" : userId } mutableCopy]
         withCompletionBlock: aBlock];
}

#pragma mark - Request Methods

- (void)POSTWithMethodName: (NSString*) aName
                withParams: (NSMutableDictionary*) aDictionary
       withCompletionBlock: (CommunityLibraryNetworkCompletionBlock) aBlock
{
    aDictionary = aDictionary ? : [NSMutableDictionary dictionary];
    aName = aName ?: @"";
    
    [self POST: aName
    parameters: aDictionary
      progress: ^(NSProgress * _Nonnull uploadProgress) {
          
      } success: ^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          
          NSError* error;
          
          aBlock(error == nil, error, responseObject);
          
      } failure: ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          aBlock(NO, [CommunityLibraryNetworkManager parseError: error response: task.response], nil);
      }];
}

- (void)GETWithMethodName: (NSString*) aName
               withParams: (NSMutableDictionary*) aDictionary
      withCompletionBlock: (CommunityLibraryNetworkCompletionBlock) aBlock
{
    aDictionary = aDictionary ? : [NSMutableDictionary dictionary];
    aName = aName ?: @"";
    
    [self GET: aName
   parameters: aDictionary
     progress: ^(NSProgress * _Nonnull uploadProgress) {
         
     } success: ^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         
         NSError* error = nil;
         
         aBlock(error == nil, error, responseObject);
         
     } failure: ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         aBlock(NO, [CommunityLibraryNetworkManager parseError: error response: task.response], nil);
     }];
}

- (void)PATCHWithMethodName: (NSString*) aName
                 withParams: (NSMutableDictionary*) aDictionary
        withCompletionBlock: (CommunityLibraryNetworkCompletionBlock) aBlock
{
    aDictionary = aDictionary ? : [NSMutableDictionary dictionary];
    aName = aName ?: @"";
    
    [self PATCH: aName
     parameters: aDictionary
        success: ^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSError *error = nil;
            
            aBlock(error == nil, error, responseObject);
            
        } failure: ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            aBlock(NO, [CommunityLibraryNetworkManager parseError: error response: task.response], nil);
        }];
}

- (void)DELETEWithMethodName: (NSString*) aName
                  withParams: (NSMutableDictionary*) aDictionary
         withCompletionBlock: (CommunityLibraryNetworkCompletionBlock) aBlock
{
    aDictionary = aDictionary ? : [NSMutableDictionary dictionary];
    aName = aName ?: @"";
    
    [self DELETE: aName
      parameters: aDictionary
         success: ^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             
             NSError *error = nil;
             
             aBlock(error == nil, error, responseObject);
             
         } failure: ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             aBlock(NO, [CommunityLibraryNetworkManager parseError: error response: task.response], nil);
         }];
}

+ (NSError*) parseError: (NSError*) error response: (NSURLResponse*) response
{
    if (error.code == -1009)
    {
        error = [CommunityLibraryNetworkManager createErrorWithCode: -1009
                                  localizeString: NSLocalizedString(@"Internet connection unavailable.", nil)];
    }
    else
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        error = [CommunityLibraryNetworkManager createErrorWithCode: [httpResponse statusCode]
                                  localizeString: error.localizedDescription];
    }
    
    return error;
}

+ (NSError*) createErrorWithCode: (NSInteger) code localizeString: (NSString*) localizeString
{
    NSError* error = [NSError errorWithDomain: @"Zero"
                                         code: code
                                     userInfo: @{ NSLocalizedDescriptionKey : localizeString }];
    
    return error;
}

@end
