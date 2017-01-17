//
//  RibbitMessage.m
//  Ribbit
//
//  Created by Amit Bijlani on 8/25/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

#import "RibbitMessage.h"
#import "App.h"

@implementation RibbitMessage

- (void)saveInBackgroundWithBlock:(BooleanResultBlock)block {
  
    // TJM - save the message to Backendless
    
  [[App currentApp] addMessage:self];
  block(YES,nil);
}

@end
