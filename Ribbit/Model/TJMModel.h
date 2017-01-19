//
//  TJMModel.h
//  Ribbit
//
//  Created by redBred LLC on 1/18/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TJMModel_Messages_Refreshed @"TJMModel_Messages_Refreshed"
#define TJMModel_Friends_Refreshed @"TJMModel_Friends_Refreshed"

@class BackendlessUser;
@class TJMMessage;

@interface TJMModel : NSObject

@property (nonatomic, strong) BackendlessUser *currentUser;
@property (nonatomic, strong) NSArray *allUsers;

// singleton model shared across app
+ sharedInstance;

- (NSArray *)currentUsersFriends;
- (BOOL)hasFriend:(BackendlessUser *)currentFriend;
- (void)addFriend:(BackendlessUser *)newFriend;
- (void)removeFriend:(BackendlessUser *)oldFriend;

- (NSArray *)currentUsersMessages;
- (void)sendMessagesForFileNamed:(NSString *)fileName withData:(NSData *)data fileType:(NSString *)fileType toRecipients:(NSArray *)recipients error:(void(^)(NSString *))errorBlock;
- (void)removeMessage:(TJMMessage *)message;

- (void)logInWithEmail:(NSString *)email andPassword:(NSString *)password completion:(void(^)(BackendlessUser *))completion error:(void(^)(NSString *))errorBlock;
- (void)signupNewUserWithName:(NSString *)name email:(NSString *)email andPassword:(NSString *)password completion:(void(^)(BackendlessUser *))completion error:(void(^)(NSString *))errorBlock;
- (void)logOut;
- (void)passwordResetForEmail:(NSString *)email completion:(void(^)(void))completion error:(void(^)(NSString *))errorBlock;

@end
