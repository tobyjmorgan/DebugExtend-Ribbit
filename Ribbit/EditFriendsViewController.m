//
//  EditFriendsViewController.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "EditFriendsViewController.h"
#import "App.h"

#import "FriendsCell.h"

// TJM - Backendless integration
#import <Backendless/Backendless.h>
#import "TJMFriends.h"

@interface EditFriendsViewController ()

// TJM - Backendless integration
@property (nonatomic, strong) BackendlessUser *currentUser;
@property (nonatomic, strong) NSMutableArray *allUsers;
@property (nonatomic, strong) TJMFriends *myFriends;

@end

@implementation EditFriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    // TJM - Backendless integration

    self.allUsers = [[NSMutableArray alloc] init];
    self.currentUser = [backendless.userService currentUser];
  
    BackendlessDataQuery *allUsersQuery = [BackendlessDataQuery query];
    allUsersQuery.whereClause = [NSString stringWithFormat:@"objectId != \'%@\'", self.currentUser.objectId];

    BackendlessDataQuery *friendsQuery = [BackendlessDataQuery query];
    friendsQuery.whereClause = [NSString stringWithFormat:@"user.email = \'%@\'", self.currentUser.email];

    @try {
        BackendlessCollection *usersCollection = [[backendless.persistenceService of:[BackendlessUser class]] find:allUsersQuery];
        NSLog(@"users collection: %@", usersCollection);
        
        BackendlessCollection *friendsCollection = [[backendless.persistenceService of:[TJMFriends class]] find:friendsQuery];
        NSLog(@"friends collection: %@", friendsCollection);
        
        self.allUsers = [usersCollection.data mutableCopy];
        
        if (friendsCollection.data.count > 0) {
            
            self.myFriends = [friendsCollection.data firstObject];
            [self.myFriends loadFriends];

        } else {
        
            self.myFriends = [[TJMFriends alloc] init];
            self.myFriends.user = self.currentUser;
            
        }
        
        [self.tableView reloadData];
    }
    @catch (Fault *fault) {
        
        NSLog(@"FAULT (SYNC): %@", fault);
    }

//  self.currentUser = [User currentUser];
}

// TJM - Backendless integration
//- (NSArray *)allUsers {
//  return [[App currentApp] allUsers];
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.allUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendsCell";
    FriendsCell *cell = (FriendsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    BackendlessUser *user = [self.allUsers objectAtIndex:indexPath.row];
    cell.nameLabel.text = user.name;
    
    if ([self.myFriends hasFriend:user]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  
    BackendlessUser *user = [self.allUsers objectAtIndex:indexPath.row];
    
    if ([self.myFriends hasFriend:user]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.myFriends removeFromFriends:user];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.myFriends addToFriends:user];
    }
    
    [[backendless.persistenceService of:[TJMFriends class]] save:self.myFriends];
}

@end
