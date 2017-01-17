//
//  App.h
//  Ribbit
//
//  Created by Amit Bijlani on 9/6/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RibbitMessage;

@interface App : NSObject

+ (instancetype) currentApp;
- (void) addMessage:(RibbitMessage*)message;
- (void) deleteMessage:(RibbitMessage*)message;
- (NSArray *) messages;
- (NSArray *) allUsers;

@end
