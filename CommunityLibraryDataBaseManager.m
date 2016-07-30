//
//  CommunityLibraryDataBaseManager.m
//  Zero Platform
//
//  Created by Team Zero on 18/7/16.
//  Copyright © 2016 Charter Partners. All rights reserved.
//

#import "CommunityLibraryDataBaseManager.h"

// Keys
NSString * const persistentStoreCoordinatorWait = @"persistentStoreCoordinatorWait";

@interface CommunityLibraryDataBaseManager () <UIAlertViewDelegate>

@end

@implementation CommunityLibraryDataBaseManager
{
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    NSManagedObjectContext *_mainManagedObjectContext;
    NSManagedObjectContext *_storeManagedObjectContext;
}

+ (instancetype)sharedInstance
{
    static CommunityLibraryDataBaseManager* instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[CommunityLibraryDataBaseManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setupPersistentStoreCoordinator];
        
        NSPersistentStoreCoordinator *persistentStoreCoordinator = [self persistentStoreCoordinator];
        
        _storeManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
        _storeManagedObjectContext.undoManager = nil;
        _storeManagedObjectContext.mergePolicy = NSOverwriteMergePolicy;
        [_storeManagedObjectContext setPersistentStoreCoordinator: persistentStoreCoordinator];
        
        _mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainManagedObjectContext.undoManager = nil;
        _mainManagedObjectContext.mergePolicy = NSOverwriteMergePolicy;
        _mainManagedObjectContext.parentContext = _storeManagedObjectContext;
    }
    return self;
}

#pragma mark - General

+ (void) clearDatabase
{
    [[CommunityLibraryDataBaseManager sharedInstance] releasePersistentStoreCoordinator];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? paths[0] : nil;
    NSURL *storeUrl = [NSURL fileURLWithPath:[basePath stringByAppendingPathComponent:@"CommunityDataBase.sqlite"]];
    
    void(^eraseDatabase)(void) = ^(void) {
        //NSLog(@"Will remove db file");
        
        __autoreleasing NSError *error;
        [[NSFileManager defaultManager] removeItemAtURL:storeUrl error:&error];
        if(error)
        {
            //NSLog(@"\n\n\n Fail to remove db store file %@ \n\n\n", [error localizedDescription]);
        }
        else
        {
            //NSLog(@"\n\n\n db store file removed!\n\n\n");
        }
    };
    
    eraseDatabase();
}

#pragma mark General NSPersistentStoreCoordinator

- (void)setupPersistentStoreCoordinator
{
    @synchronized(persistentStoreCoordinatorWait)
    {
        if(!_persistentStoreCoordinator)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            NSString *basePath = ([paths count] > 0) ? paths[0] : nil;
            NSString *storeFilePath = [basePath stringByAppendingPathComponent:@"CommunityDataBase.sqlite"];
            NSURL *storeUrl = [NSURL fileURLWithPath:storeFilePath];
            
            NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CommunityDataBase" withExtension:@"momd"];
            NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
            
            NSError *error;
            _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
            NSDictionary *options = @{
                                      NSMigratePersistentStoresAutomaticallyOption : @YES,
                                      NSInferMappingModelAutomaticallyOption : @YES
                                      };
            [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                          configuration:nil
                                                                    URL:storeUrl
                                                                options:options
                                                                  error:&error];
            
            if(!_persistentStoreCoordinator)
            {
                // NSAssert1(persistentStoreCoordinator, @"Can not create persistant store", error);
            }
        }
    }
}

- (void)releasePersistentStoreCoordinator
{
    @synchronized(persistentStoreCoordinatorWait)
    {
        _persistentStoreCoordinator = nil;
    }
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    @synchronized(persistentStoreCoordinatorWait)
    {
        if (!_persistentStoreCoordinator)
        {
            [self setupPersistentStoreCoordinator];
        }
        
        return _persistentStoreCoordinator;
    }
}

#pragma mark General Objects Methods

+ (id)newObjectForEntityName:(NSString *)entityName context:(NSManagedObjectContext *)context
{
    if (![entityName hasChars])
    {
        //NSLog(@"No entity name for context %@", context);
        
        return nil;
    }
    
    if (!context)
    {
        //NSLog(@"No context for entity name %@", entityName);
        
        return nil;
    }
    
    if (context == [self mainContext])
    {
        //NSLog(@"Attempt to insert entity into main context %@", entityName);
    }
    
    return (id)[NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
}

+ (void)deleteObject:(NSManagedObject *)object context:(NSManagedObjectContext *)context
{
    if(!object)
    {
        //NSLog(@"attemp to delete nil object from context %@ ", context);
        return;
    }
    
    if(!context)
    {
        //NSLog(@"attemp to delete object from nil context %@ ", object);
        return;
    }
    
    if([object managedObjectContext] != context)
    {
        NSLog(@"attemp to delete object from other context %@ ", object);
        return;
    }
    
    //NSLog(@"Will delete object from context %@", object);
    
    [context deleteObject:object];
}

+ (void)deleteObjectsInEntity: (NSString*) entity inContext: (NSManagedObjectContext*) context
{
    NSFetchRequest * allCars = [[NSFetchRequest alloc] init];
    [allCars setEntity:[NSEntityDescription entityForName: entity
                                   inManagedObjectContext: context]];
    [allCars setIncludesPropertyValues:NO];
    
    NSError * error = nil;
    NSArray * objects = [context executeFetchRequest:allCars error:&error];
    
    for (NSManagedObject * object in objects)
    {
        [CommunityLibraryDataBaseManager deleteObject: object context: context];
    }
    
    [self saveContext: context];
}

+ (NSManagedObject *)existingObjectWithObjectID:(NSManagedObjectID *)managedObjectID
                                        context:(NSManagedObjectContext *)context
{
    if (!managedObjectID)
    {
        NSAssert3(NO, @"%@ - %@ : %@", NSStringFromSelector(_cmd), NSStringFromClass([self class]), @"objectID can't be nil");
    }
    
    NSError *error;
    
    NSManagedObject *managedObject = [context existingObjectWithID:managedObjectID error:&error];
    
    if (error)
    {
        // NSAssert2(NO,
        // @"Error while getting existing object by objectID [%@] from data base. Error",
        // managedObjectID,
        // [error localizedDescription]);
        return nil;
    }
    
    return managedObject;
}

+ (NSManagedObject*) getEntityWithPredicate: (NSPredicate*) predicate
                                    context: (NSManagedObjectContext*) context
                                 entityName: (NSString*) entityName
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: entityName];
    [request setPredicate:predicate];
    
    __autoreleasing NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if (error)
    {
        //NSLog(@"error %@", error);
    }
    
    if(results.count >= 2)
    {
        //NSLog(@"result %@", results);
        // NSAssert1((results.count < 2), @"Database contains more then 1 rpn with ChatId", chatId);
    }
    
    NSManagedObject *object = [results lastObject];
    
    return object;
}

+ (NSArray*) getAllObjectFromEntityWithEntityName: (NSString*) entityName
                                          context: (NSManagedObjectContext*) context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: entityName];
    
    __autoreleasing NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if (error)
    {
        //NSLog(@"error %@", error);
    }
    
    if(results.count >= 2)
    {
        //NSLog(@"result %@", results);
        // NSAssert1((results.count < 2), @"Database contains more then 1 rpn with ChatId", chatId);
    }
    
    return results;
}

#pragma mark General Context Methods

+ (NSManagedObjectContext*) mainContext
{
    return [[CommunityLibraryDataBaseManager sharedInstance] mainManagedObjectContext];
}

- (NSManagedObjectContext*) mainManagedObjectContext
{
    return _mainManagedObjectContext;
}

+ (NSManagedObjectContext*) newNestedDatabaseContext
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.parentContext = [CommunityLibraryDataBaseManager mainContext];
    return context;
}

#pragma mark General Context Save Methods

+ (void) saveMainContext
{
    [self saveContext: [CommunityLibraryDataBaseManager mainContext]];
}

+ (void) saveContext: (NSManagedObjectContext*) context
{
    NSError *error;
    [self saveDatabaseForContext: context error: error];
}

+ (void) saveDatabaseForContext:(NSManagedObjectContext *)context error:(NSError *)error
{
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[CommunityLibraryDataBaseManager sharedInstance] persistentStoreCoordinator];
    
    if (!persistentStoreCoordinator)
    {
        return;
    }
    
    NSManagedObjectContext * __strong strongContext = context;
    
    [strongContext performBlock: ^{
        NSError *saveError;
        if ([strongContext save: &saveError])
        {
            NSManagedObjectContext *parentContext = strongContext.parentContext;
            if (parentContext)
            {
                [parentContext performBlock:^{
                    
                    NSError *parentSaveError;
                    [self saveDatabaseForContext:parentContext error:parentSaveError];
                    
                    if (parentSaveError)
                    {
                        //NSLog(@"parent save error %@", parentSaveError);
                    }
                    
                }];
            }
            
        }
    }];
}

#pragma mark - CommunityLibraryDataBaseProtocol
#pragma mark ChatEntity General

+ (ChatEntity*)newChatEntityWithContext: (NSManagedObjectContext*) context
{
    ChatEntity* chatEntity = (ChatEntity*)[CommunityLibraryDataBaseManager newObjectForEntityName: [ChatEntity className]
                                                                                          context: context];
    
    return chatEntity;
}

+ (ChatEntity*) chatEntityWithChatId: (NSString*) chatId
                             context: (NSManagedObjectContext*) context
{
    if(!chatId)
        return nil;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chatId == %@", [NSString stringWithFormat: @"%@", chatId]];
    
    return (ChatEntity*)[CommunityLibraryDataBaseManager getEntityWithPredicate: predicate
                                                                        context: context
                                                                     entityName: [ChatEntity className]];
}

- (ChatEntity*) updateChatEntityWithDic: (NSDictionary*) chatDic
                                context: (NSManagedObjectContext*) context
{
    ChatEntity* chatEntity = [CommunityLibraryDataBaseManager chatEntityWithChatId: chatDic[@"id"]
                                                                           context: context];
    
    if (!chatEntity)
    {
        chatEntity = [CommunityLibraryDataBaseManager newChatEntityWithContext: context];
        #warning change it
        chatEntity.lastUpdateTime = [NSDate date];
    }
    
    chatEntity.chatId = [NSString stringWithFormat: @"%@", chatDic[@"id"]];
    chatEntity.name = [NSString stringWithFormat: @"%@ %@", chatEntity.chatId, chatDic[@"name"]];
    chatEntity.startHostiryTimestamp = [CommunityLibraryManager timestampCurrentDate];
    chatEntity.isMute = [NSNumber numberWithBool: NO];
    
    
    NSMutableSet* users = [[NSMutableSet alloc] init];
    for (NSDictionary* curUser in chatDic[@"users"])
    {
        UserEntity* userEntity = [self updateUserEntityWithDic: curUser
                                                       context: context];
        [users addObject: userEntity];
    }
    
    chatEntity.participants = users;
    
    
    // delete old message, older than one month
    //
    NSArray* oldMessages = [self getAllMessagesForChatId: chatEntity.chatId
                                               predicate: [NSPredicate predicateWithFormat: @"time < %@", [CommunityLibraryManager dateOneMonthAgo]]
                                               inContext: context];
    for (MessageEntity* curMessage in oldMessages)
    {
        [CommunityLibraryDataBaseManager deleteObject: curMessage context: context];
    }
    
    return chatEntity;
}

#pragma mark ChatEntity

- (void) updateChats: (NSArray*) chats
     completionBlock: (void(^)(NSError* error, NSArray* subscribeChatsIds, NSArray* unsubscribeChatsIds)) completionBlock
{
    NSManagedObjectContext* context = [CommunityLibraryDataBaseManager newNestedDatabaseContext];
    
    NSArray* allChats = [[CommunityLibraryDataBaseManager sharedInstance] getAllChatsInContext: context];
    NSMutableSet* allChatsSet = [[NSMutableSet alloc] initWithArray: allChats];
    
    
    NSMutableArray* subscribeChatsIds = [[NSMutableArray alloc] init];
    NSMutableArray* unsubscribeChatsIds = [[NSMutableArray alloc] init];
    
    
    for (NSDictionary* curChatDic in chats)
    {
        ChatEntity* chatEntity = [self updateChatEntityWithDic: curChatDic context: context];
        
        if (chatEntity)
            [allChatsSet removeObject: chatEntity];

        [subscribeChatsIds addObject: [NSString stringWithFormat: @"%@", chatEntity.chatId]];
    }
    
    if (allChatsSet.count > 0)
    {
        for (NSManagedObject* chat in [allChatsSet allObjects])
        {
            ChatEntity* curChat = (ChatEntity*)chat;
            [unsubscribeChatsIds addObject: [NSString stringWithFormat: @"%@", curChat.chatId]];
            
            curChat.isMute = [NSNumber numberWithBool: YES];
        }
    }
    
    [CommunityLibraryDataBaseManager saveContext: context];
    
    completionBlock(nil, subscribeChatsIds, unsubscribeChatsIds);
}

- (void) updateChatWithDic: (NSDictionary*) chatDic
           completionBlock: (void(^)(NSError* error, NSString* subscribeChats)) completionBlock
{
    NSManagedObjectContext* context = [CommunityLibraryDataBaseManager newNestedDatabaseContext];
    [self updateChatEntityWithDic: chatDic context: context];
    [CommunityLibraryDataBaseManager saveContext: context];
    
    completionBlock(nil, [NSString stringWithFormat: @"%@", chatDic[@"id"]]);
}

- (void) updaChatWithChatId: (NSString*) chatId
                  muteState: (BOOL) muteState
            completionBlock: (void(^)(NSError* error, NSString* chatRoom)) completionBlock
{
    NSManagedObjectContext* context = [CommunityLibraryDataBaseManager newNestedDatabaseContext];
    
    ChatEntity* chatEntity = [CommunityLibraryDataBaseManager chatEntityWithChatId: chatId
                                                                           context: context];
    if (chatEntity)
    {
        chatEntity.isMute = [NSNumber numberWithBool: muteState];
    }
    
    [CommunityLibraryDataBaseManager saveContext: context];
    
    completionBlock(nil, chatId);
}

- (NSArray*) getAllChatsInContext: (NSManagedObjectContext*) context
{
    return [CommunityLibraryDataBaseManager getAllObjectFromEntityWithEntityName: [ChatEntity className]
                                                                         context: context];
}

- (void) deleteChatWithChatId: (NSString*) chatId
              completionBlock: (void(^)(NSError* error, NSString* unsubscribeChats)) completionBlock
{
    NSManagedObjectContext* context = [CommunityLibraryDataBaseManager newNestedDatabaseContext];
    
    ChatEntity* chatEntity = [CommunityLibraryDataBaseManager chatEntityWithChatId: chatId
                                                                           context: context];
    NSString* chatChannel = chatEntity.chatId;
    
    [CommunityLibraryDataBaseManager deleteObject: chatEntity context: context];
    [CommunityLibraryDataBaseManager saveContext: context];
    
    completionBlock(nil, chatChannel);
}

#pragma mark MessageEntity General

+ (MessageEntity *)newMessageEntityWithContext:(NSManagedObjectContext *)context
{
    MessageEntity *chatEntity = (MessageEntity*)[CommunityLibraryDataBaseManager newObjectForEntityName: [MessageEntity className]
                                                                                                context: context];
    
    return chatEntity;
}

+ (MessageEntity*) messageEntityWithMessageId: (NSString*) messageId
                                      context: (NSManagedObjectContext*) context
{
    if(!messageId)
        return nil;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageId == %@", messageId];
    
    return (MessageEntity*)[CommunityLibraryDataBaseManager getEntityWithPredicate: predicate
                                                                           context: context
                                                                        entityName: [MessageEntity className]];
}

- (MessageEntity*) updateMessageEntityWithDic: (NSDictionary*) messageDic
                    chatStartHistoryTimeStamp: (NSNumber*) chatStartHistoryTimeStamp
                                      context: (NSManagedObjectContext*) context
{
    NSString* msgId = messageDic[@"createdAt"];
    
    MessageEntity* messageEntity = [CommunityLibraryDataBaseManager messageEntityWithMessageId: msgId
                                                                                       context: context];
    
    if (!messageEntity)
    {
        messageEntity = [CommunityLibraryDataBaseManager newMessageEntityWithContext: context];
        messageEntity.isRead = [NSNumber numberWithBool: NO];
        messageEntity.messageId = msgId;
    }
    
    messageEntity.text = messageDic[@"text"];
    messageEntity.time = [[CommunityLibraryManager dateFormatter] dateFromString: messageDic[@"createdAt"]];
    messageEntity.type = @0;
    
    
    ChatEntity *chat = [CommunityLibraryDataBaseManager chatEntityWithChatId: messageDic[@"chatId"]
                                                                     context: context];
    
    if (chatStartHistoryTimeStamp)
        chat.startHostiryTimestamp = chatStartHistoryTimeStamp;
    
    if (!chat.lastMessage.time ||
        [messageEntity.time compare: chat.lastMessage.time] == NSOrderedDescending)
    {
        chat.lastMessage = messageEntity;
        chat.lastUpdateTime = chat.lastMessage.time;
    }
    
    messageEntity.chat = chat;
    
    
    id userId = messageDic[@"userId"];
    NSNumber* userIdNum = [NSNumber numberWithInteger: [userId integerValue]];
    UserEntity* userEntity = [self updateUserEntityWithDic: @{ @"id" : userIdNum }
                                                   context: context];
    messageEntity.user = userEntity;
    
    
    return messageEntity;
}

#pragma mark MessageEntity

- (void)    updateMessages: (NSArray*) messages
 chatStartHistoryTimeStamp: (NSNumber*) chatStartHistoryTimeStamp
           completionBlock: (void(^)(NSError* error)) completionBlock;
{
    NSManagedObjectContext* context = [CommunityLibraryDataBaseManager newNestedDatabaseContext];
    
    for (NSDictionary* curMessageDic in messages)
    {
        if (curMessageDic.allKeys.count > 0)
        {
            [self updateMessageEntityWithDic: [curMessageDic objectForKey: @"message"]
                   chatStartHistoryTimeStamp: chatStartHistoryTimeStamp
                                     context: context];
        }
    }
    
    [CommunityLibraryDataBaseManager saveContext: context];
    
    completionBlock(nil);
}

- (void) updateMessageWithDic: (NSDictionary*) messageDic
              completionBlock: (void(^)(NSError* error)) completionBlock
{
    NSManagedObjectContext* context = [CommunityLibraryDataBaseManager newNestedDatabaseContext];
    [self updateMessageEntityWithDic: messageDic chatStartHistoryTimeStamp: nil context: context];
    [CommunityLibraryDataBaseManager saveContext: context];
    
    completionBlock(nil);
}

- (NSArray*) getAllMessagesForChatId: (NSString*) chatId
                           predicate: (NSPredicate*) predicate
                           inContext: (NSManagedObjectContext*) context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: [MessageEntity className]];
    [request setPredicate: [NSCompoundPredicate andPredicateWithSubpredicates: @[ predicate,
                                                                                  [NSPredicate predicateWithFormat: @"chat.chatId == %@", chatId] ]]];
    
    __autoreleasing NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    return results;
}

+ (void) updateReadStateYesForMessageId: (NSString*) messageId
{
    NSManagedObjectContext* context = [CommunityLibraryDataBaseManager newNestedDatabaseContext];
    MessageEntity* messageEntity = [CommunityLibraryDataBaseManager messageEntityWithMessageId: messageId
                                                                                       context: context];
    messageEntity.isRead = [NSNumber numberWithBool: YES];
    [CommunityLibraryDataBaseManager saveContext: context];
}

+ (NSUInteger) unreadMessagesCountForChatWithId: (NSString*) chatId
                                        context: (NSManagedObjectContext*) context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: [MessageEntity className]];
    [request setPredicate: [NSCompoundPredicate andPredicateWithSubpredicates: @[ [NSPredicate predicateWithFormat: @"isRead == %@", [NSNumber numberWithBool: NO]],
                                                                                  [NSPredicate predicateWithFormat: @"chat.chatId == %@", chatId]]]];
    
    __autoreleasing NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if (error)
    {
        //NSLog(@"error %@", error);
    }
    
    return results.count;
}

#pragma mark UserEntity General

+ (UserEntity *)newUserEntityWithContext:(NSManagedObjectContext *)context
{
    UserEntity *userEntity = (UserEntity*)[CommunityLibraryDataBaseManager newObjectForEntityName: [UserEntity className]
                                                                                          context: context];
    
    return userEntity;
}

+ (UserEntity*) userEntityWithUserId: (NSNumber*) userId
                             context: (NSManagedObjectContext*) context
{
    if(!userId)
        return nil;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverId == %@", userId];
    
    return (UserEntity*)[CommunityLibraryDataBaseManager getEntityWithPredicate: predicate
                                                                        context: context
                                                                     entityName: [UserEntity className]];
}

- (UserEntity*) updateUserEntityWithDic: (NSDictionary*) userDic
                                context: (NSManagedObjectContext*) context
{
    UserEntity* userEntity = [CommunityLibraryDataBaseManager userEntityWithUserId: userDic[@"id"]
                                                                           context: context];
    
    if (!userEntity)
    {
        userEntity = [CommunityLibraryDataBaseManager newUserEntityWithContext: context];
        userEntity.serverId = userDic[@"id"];
    }
    
    userEntity.firstName = userDic[@"first_name"];
    userEntity.isOnline = [NSNumber numberWithBool: NO];
    userEntity.lastName = userDic[@"last_name"];
    userEntity.pubNubId = userDic[@"id"];
    
    
    return userEntity;
}

#pragma mark UserEntity

- (void) updateUsers: (NSArray*) users
     completionBlock: (void(^)(NSError* error)) completionBlock
{
    NSManagedObjectContext* context = [CommunityLibraryDataBaseManager newNestedDatabaseContext];
    
    for (NSDictionary* curUserDic in users)
    {
        [self updateUserEntityWithDic: curUserDic context: context];
    }
    
    [CommunityLibraryDataBaseManager saveContext: context];
    
    completionBlock(nil);
}

- (void) updateUserWithDic: (NSDictionary*) userDic
           completionBlock: (void(^)(NSError* error)) completionBlock
{
    NSManagedObjectContext* context = [CommunityLibraryDataBaseManager newNestedDatabaseContext];
    [self updateUserEntityWithDic: userDic context: context];
    [CommunityLibraryDataBaseManager saveContext: context];
    
    completionBlock(nil);
}

- (NSArray*) getAllUsersInContext: (NSManagedObjectContext*) context
{
    return [CommunityLibraryDataBaseManager getAllObjectFromEntityWithEntityName: [UserEntity className]
                                                                         context: context];
}

@end
