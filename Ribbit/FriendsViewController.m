//
//  FriendsViewController.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "FriendsViewController.h"
#import "EditFriendsViewController.h"
#import "App.h"

#import "FriendsCell.h"

// TJM - Backendless integration
#import <Backendless/Backendless.h>
#import "TJMFriends.h"

@interface FriendsViewController ()

// TJM - Backendless integration
@property (nonatomic, strong) BackendlessUser *currentUser;
@property (nonatomic, strong) TJMFriends *myFriends;

@end

@implementation FriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // TJM - Backendless integration

    self.currentUser = [backendless.userService currentUser];

    BackendlessDataQuery *friendsQuery = [BackendlessDataQuery query];
    friendsQuery.whereClause = [NSString stringWithFormat:@"user.email = \'%@\'", self.currentUser.email];
    
    @try {
        BackendlessCollection *friendsCollection = [[backendless.persistenceService of:[TJMFriends class]] find:friendsQuery];
        NSLog(@"friends collection: %@", friendsCollection);
        
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

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.myFriends.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendsCell";
    FriendsCell *cell = (FriendsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    BackendlessUser *user = [self.myFriends.friends objectAtIndex:indexPath.row];
    cell.nameLabel.text = user.name;
    
    return cell;
}

@end
