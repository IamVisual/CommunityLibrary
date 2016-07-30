//
//  CommunityLibraryNetworkManager.h
//  Zero Platform
//
//  Created by Team Zero on 18/7/16.
//  Copyright © 2016 Charter Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

#import "CommunityLibraryNetworkProtocol.h"

@interface CommunityLibraryNetworkManager : AFHTTPSessionManager <CommunityLibraryNetworkProtocol>

+ (instancetype)sharedInstance;

@end
