//
//  TJMModel.m
//  Ribbit
//
//  Created by redBred LLC on 1/18/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

#import "TJMModel.h"

// TJM - Backendless integration
#import <Backendless/Backendless.h>
#import "TJMMessage.h"
#import "TJMFriends.h"
#import "TJMFileToDelete.h"

@interface TJMModel ()

@property (nonatomic, strong) id<IDataStore> friendsDataStore;
@property (nonatomic, strong) TJMFriends *myFriends;

@property (nonatomic, strong) id<IDataStore> messagesDataStore;
@property (nonatomic, strong) BackendlessCollection *myMessages;

@end

@implementation TJMModel

////////////////////////////////////////////////
// singleton code
static TJMModel *singletonObject = nil;

+ (id) sharedInstance
{
    if (! singletonObject) {
        
        singletonObject = [[TJMModel alloc] init];
    }
    
    return singletonObject;
}

// stops init being called inadvertently - just returns the shared instance instead
- (id)init
{
    if (! singletonObject) {
        
        // TJM - set up Backendless
        [backendless initApp:@"F4DCDE2A-CF35-8B99-FFAF-E6B022C3C300" secret:@"F53ADE62-C1B3-6B0A-FF0B-79766AE4BC00" version:@"v1"];
        
        // If you plan to use Backendless Media Service, uncomment the following line (iOS ONLY!)
        // backendless.mediaService = [MediaService new];

        singletonObject = [super init];
        
        // create these ahead of time for reuse
        self.friendsDataStore = [backendless.persistenceService of:[TJMFriends class]];
        self.messagesDataStore = [backendless.persistenceService of:[TJMMessage class]];
        
        // TJM - validating current user with Backendless
        @try {
            NSNumber *result = [backendless.userService isValidUserToken];
            
            if ([result boolValue] == YES) {
                
                // user already logged in from previous app execution
                self.currentUser = [backendless.userService currentUser];
                NSLog(@"Current user: %@", self.currentUser.name);
                
            } else {
                
                // no user logged in so make sure current user is set to nil
                self.currentUser = nil;
            }
            
        }
        @catch (Fault *fault) {
            
            // TJM - if there was an error validating the current
            NSLog(@"FAULT (SYNC): %@", fault);

            // no user logged in so make sure current user is set to nil
            self.currentUser = nil;
        }
        
        [self deleteOldFiles];
    }
    
    return singletonObject;
}
////////////////////////////////////////////////

// overriding the currentUser setter so it can trigger refreshing all associated data
- (void)setCurrentUser:(BackendlessUser *)currentUser {
    _currentUser = currentUser;
    
    self.myFriends = nil;
    self.myMessages = nil;
    self.allUsers = nil;
    
    [self refreshModelForUserChange];
}

// refresh everything associated with the current user
- (void)refreshModelForUserChange {
    [self refresUsers];
    [self refreshFriends];
    [self refreshMessages];
}




#pragma mark Friend Management

// fetches friends for current user
- (void)refreshFriends {
    
    BackendlessDataQuery *friendsQuery = [BackendlessDataQuery query];
    friendsQuery.whereClause = [NSString stringWithFormat:@"user.email = \'%@\'", self.currentUser.email];
    
    [self.friendsDataStore find:friendsQuery response:^(BackendlessCollection *friendsCollection) {
        
        if (friendsCollection.data.count > 0) {
            
            NSLog(@"Found existing friends data for this user");
            self.myFriends = [friendsCollection.data firstObject];
            [[NSNotificationCenter defaultCenter] postNotificationName:TJMModel_Friends_Refreshed object:self];
            
        } else {
            
            NSLog(@"No friends data found for this user - creating a new record");
            self.myFriends = [[TJMFriends alloc] init];
            self.myFriends.user = self.currentUser;
            [[NSNotificationCenter defaultCenter] postNotificationName:TJMModel_Friends_Refreshed object:self];
        }
        
    } error:^(Fault *fault) {
        
        NSLog(@"FAULT (SYNC): %@", fault);
    }];
}

// shields the consumer from the implementation of firends and prevents accidental changes to mutable array
- (NSArray *)currentUsersFriends {
    
    return self.myFriends.friends;
}

- (BOOL)hasFriend:(BackendlessUser *)currentFriend {
    
    return [self.myFriends hasFriend:currentFriend];
}

- (void)addFriend:(BackendlessUser *)newFriend {
    
    if (![self.myFriends hasFriend:newFriend]) {
        [self.myFriends addToFriends:newFriend];
        [self saveFriends];
    }
}

- (void)removeFriend:(BackendlessUser *)oldFriend {
    
    if ([self.myFriends hasFriend:oldFriend]) {
        [self.myFriends removeFromFriends:oldFriend];
        [self saveFriends];
    }
}

- (void)saveFriends {
    
    // save friends record to Backendless server
    [self.friendsDataStore save:self.myFriends response:^(id response) {
        
        TJMFriends *friend = (TJMFriends*)response;
        
        // needed so Backendless knows this is the same object
        // otherwise it will create duplicate rows unecessarily
        self.myFriends.objectId = friend.objectId;
        
        NSLog(@"Friends list updated");
        
    } error:^(Fault *fault) {
        
        NSLog(@"FAULT (SYNC): %@", fault);
    }];
}




#pragma mark Message Management

// fetches messages for current user
- (void)refreshMessages {
    
    BackendlessDataQuery *messagesQuery = [BackendlessDataQuery query];
    messagesQuery.whereClause = [NSString stringWithFormat:@"recipient.email = \'%@\'", self.currentUser.email];
    
    [self.messagesDataStore find:messagesQuery response:^(BackendlessCollection *messagesCollection) {
        
        self.myMessages = messagesCollection;
        [[NSNotificationCenter defaultCenter] postNotificationName:TJMModel_Messages_Refreshed object:self];
        
    } error:^(Fault *fault) {
        
        NSLog(@"FAULT (SYNC): %@", fault);
    }];
}

// shields the consumer from the implementation of messages
- (NSArray *)currentUsersMessages {
    return self.myMessages.data;
}

// creates a message for each recipient that is associated with the file being "sent"
// in reality the file is uploaded to the server and referenced by each related message
- (void)sendMessagesForFileNamed:(NSString *)fileName withData:(NSData *)data fileType:(NSString *)fileType toRecipients:(NSArray *)recipients error:(void(^)(NSString *))errorBlock {
    
    [backendless.fileService upload:fileName content:data response:^(BackendlessFile * _Nullable file) {
        
        // TJM - file successfully saved to Backendless
        // TJM - now to save the messages themselves
        
        // iterate through the desired recipients
        for (BackendlessUser *recipient in recipients) {
            
            TJMMessage *newMessage = [[TJMMessage alloc] init];
            newMessage.sender = self.currentUser;
            newMessage.recipient = recipient;
            newMessage.fileType = fileType;
            newMessage.file = file.fileURL;
            
            [[backendless.persistenceService of:[TJMMessage class]] save:newMessage];
        }
        
    } error:^(Fault * _Nullable fault) {
        
        errorBlock(fault.message);
    }];
}

// delete the message from the server
- (void)removeMessage:(TJMMessage *)message {
    
    [self.messagesDataStore remove:message response:^(NSNumber *number) {
        
        NSLog(@"Message: file=%@", message.file);
        
        [self removeOldFileIfOrphaned:message.file];
        [self refreshMessages];
        
    } error:^(Fault *fault) {
        
        NSLog(@"FAULT (SYNC): %@", fault);
    }];
}

// checks to see if there are any messages left that reference this file
// if so marks the file for deletion at some point in the future
// if it is deleted right away then it may intefere with displaying the image/video file
- (void)removeOldFileIfOrphaned:(NSString *)urlString {
    
    BackendlessDataQuery *query = [BackendlessDataQuery query];
    query.whereClause = [NSString stringWithFormat:@"file = \'%@\'", urlString];
    BackendlessCollection *parents = [self.messagesDataStore find:query];
    
    if (parents.data.count == 0) {
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSString *fileName = (NSString *)url.lastPathComponent;
        
        [self markFileForDeletion:fileName];
    }
}

- (void)markFileForDeletion:(NSString *)fileName {
    
    TJMFileToDelete *fileToDelete = [[TJMFileToDelete alloc] init];
    fileToDelete.file = fileName;
    
    [[backendless.persistenceService of:[TJMFileToDelete class]] save:fileToDelete response:^(id response) {
        
        NSLog(@"File marked for deletion: %@", fileName);
        
    } error:^(Fault *fault) {
        
        NSLog(@"FAULT (SYNC): %@", fault);
    }];
}

// cycles through all "marked for delete" rows and attempts to delete the associated files
- (void)deleteOldFiles {

    [[backendless.persistenceService of:[TJMFileToDelete class]] find:^(BackendlessCollection *collection) {
        
        for (TJMFileToDelete *fileToDelete in collection.data) {
            
            NSLog(@"Attempting to remove file: %@...", fileToDelete.file);
            
            [backendless.fileService
             remove:fileToDelete.file
             response:^(id result) {
                 NSLog(@"File has been removed: result = %@", result);
                 
                 // now delete the marker record
                 [[backendless.persistenceService of:[TJMFileToDelete class]] remove:fileToDelete response:^(NSNumber *result) {
                     // marker deleted
                 } error:^(Fault *fault) {
                     NSLog(@"Server reported an error: %@", fault);
                 }];
             }
             error:^(Fault *fault) {
                 NSLog(@"Server reported an error: %@", fault);
             }];
        }
        
    } error:^(Fault *fault) {
        NSLog(@"Server reported an error: %@", fault);
    }];
}




#pragma mark User Management

// fetches all users that are not the current user
- (void)refresUsers {
    
    BackendlessDataQuery *allUsersQuery = [BackendlessDataQuery query];
    allUsersQuery.whereClause = [NSString stringWithFormat:@"objectId != \'%@\'", self.currentUser.objectId];
    
    [[backendless.persistenceService of:[BackendlessUser class]] find:allUsersQuery response:^(BackendlessCollection *usersCollection) {
        
        self.allUsers = [usersCollection.data mutableCopy];
        
    } error:^(Fault *fault) {
        
        NSLog(@"FAULT (SYNC): %@", fault);
    }];
}

- (void)logInWithEmail:(NSString *)email andPassword:(NSString *)password completion:(void(^)(BackendlessUser *))completion error:(void(^)(NSString *))errorBlock {
    
    [backendless.userService login:email password:password
                          response:^(BackendlessUser * _Nullable user) {

                              [backendless.userService setStayLoggedIn:YES];
                              self.currentUser = user;
                              
                              completion(user);
                              
                          } error:^(Fault * _Nullable fault) {
                              errorBlock(fault.message);
                          }];
}

- (void)signupNewUserWithName:(NSString *)name email:(NSString *)email andPassword:(NSString *)password completion:(void(^)(BackendlessUser *))completion error:(void(^)(NSString *))errorBlock {
    
    // TJM - attempt to create the new user in Backendless using email and password
    BackendlessUser *user = [BackendlessUser new];
    user.password = password;
    [user setProperty:@"name" object:name];
    [user setProperty:@"email" object:email];
    
    [backendless.userService registering:user
                                response:^(BackendlessUser * _Nullable user) {
                                    // TJM - all went well - now dismiss
                                    [backendless.userService setCurrentUser:user];
                                    [backendless.userService setStayLoggedIn:YES];
                                    self.currentUser = user;
                                    
                                    completion(user);

                                } error:^(Fault * _Nullable fault) {
                                    errorBlock(fault.message);
                                }];

}

- (void)logOut {
    
    // TJM - log out of Backendless
    [backendless.userService logout];
}

// sends a new password to the users email
// ideally would have a change password screen - but got to draw the line on this project somewhere!!!
- (void)passwordResetForEmail:(NSString *)email completion:(void(^)(void))completion error:(void(^)(NSString *))errorBlock {
    
    [backendless.userService restorePassword:email response:^(id willIgnore) {
        completion();
    } error:^(Fault *fault) {
        errorBlock(fault.message);
    }];
}


@end
