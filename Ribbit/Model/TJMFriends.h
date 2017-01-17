#import <Foundation/Foundation.h>

@class BackendlessUser;

@interface TJMFriends : NSObject
@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSDate *updated;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSString *ownerId;
@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) BackendlessUser *user;

-(void)addToFriends:(BackendlessUser *)backendlessUser;
-(void)removeFromFriends:(BackendlessUser *)backendlessUser;
-(NSMutableArray *)loadFriends;
-(void)freeFriends;

- (BOOL)hasFriend:(BackendlessUser *)friendUser;
@end
