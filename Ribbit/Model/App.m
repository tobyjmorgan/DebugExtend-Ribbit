//
//  App.m
//  Ribbit
//
//  Created by Amit Bijlani on 9/6/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

#import "App.h"
#import "RibbitMessage.h"

@interface App()

@property (strong, nonatomic) NSMutableArray *messagesMutable;
@property (strong, nonatomic) NSArray *internalAllUsers;

@end

@implementation App

+ (instancetype) currentApp {
  static App *sharedApp = nil;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedApp = [[self alloc] init];
    sharedApp.messagesMutable = [NSMutableArray array];
      
      // TJM 1/2/2017 Bug #3 & Bug #4 - create array once
      sharedApp.internalAllUsers = @[ [User userWithUsername:@"John"],
                                      [User userWithUsername:@"Andrew"],
                                      [User userWithUsername:@"Ben"],
                                      [User userWithUsername:@"Pasan"],
                                      [User userWithUsername:@"Amit"],
                                      [User userWithUsername:@"Craig"],
                                      [User userWithUsername:@"Alena"]];
  });
  
  return sharedApp;
}

- (void) addMessage:(RibbitMessage*)message {
  [self.messagesMutable addObject:message];
}

- (void) deleteMessage:(RibbitMessage*)message {
  [self.messagesMutable removeObject:message];
}

- (NSArray*)messages {
  return self.messagesMutable;
}

- (NSArray *)allUsers {
    // TJM 1/2/2017 Bug #3 & Bug #4 - create array once
    // Returning a different array with equivalent objects each time was confusing the existing code.
    // By creating the array only once and returning the same array in this method each time, the objects
    // are correctly identified as already being present in Friends lists etc
    return self.internalAllUsers;
//  return  @[ [User userWithUsername:@"John"],
//             [User userWithUsername:@"Andrew"],
//             [User userWithUsername:@"Ben"],
//             [User userWithUsername:@"Pasan"],
//             [User userWithUsername:@"Amit"],
//             [User userWithUsername:@"Craig"],
//             [User userWithUsername:@"Alena"]];
}


@end
