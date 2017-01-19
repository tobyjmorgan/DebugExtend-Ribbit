#import "Backendless.h"
#import "TJMFriends.h"

@implementation TJMFriends

-(void)addToFriends:(BackendlessUser *)backendlessUser {

    if (!self.friends)
        self.friends = [NSMutableArray array];

    [self.friends addObject:backendlessUser];
}

-(void)removeFromFriends:(BackendlessUser *)backendlessUser {

    NSInteger index = [self indexOfMatchingFriend:backendlessUser];
    
    if (index >= 0) {
        
        [self.friends removeObjectAtIndex:index];
    }

    if (!self.friends.count) {
        self.friends = nil;
    }
}

-(NSMutableArray *)loadFriends {

    if (!self.friends)
        [backendless.persistenceService load:self relations:@[@"friends"]];

    return self.friends;
}

-(void)freeFriends {

    if (!self.friends)
        return;

    [self.friends removeAllObjects];
    self.friends = nil;
}

- (NSInteger)indexOfMatchingFriend:(BackendlessUser *)friendUser {
    
    for (NSInteger index = 0; index < self.friends.count; index++) {
        
        BackendlessUser *user = self.friends[index];
        
        if ([user.email isEqualToString:friendUser.email]) {
            
            return index;
        }
    }
    
    return -1;
}

- (BOOL)hasFriend:(BackendlessUser *)friendUser {
    
    for (BackendlessUser *user in self.friends) {
        
        if ([user.email isEqualToString:friendUser.email]) {
            
            return YES;
        }
    }
    
    return NO;
}

@end
