//
//  EditFriendsViewController.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "EditFriendsViewController.h"

#import "BackendlessUser.h"
#import "TJMModel.h"
#import "FriendsCell.h"

@interface EditFriendsViewController ()

// TJM - Backendless integration
@property (nonatomic, weak) TJMModel *model;

@end

@implementation EditFriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    // TJM - Backendless integration
    self.model = [TJMModel sharedInstance];
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
    return [self.model.allUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendsCell";
    FriendsCell *cell = (FriendsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    BackendlessUser *user = [self.model.allUsers objectAtIndex:indexPath.row];
    cell.nameLabel.text = user.name;
    
    if ([self.model hasFriend:user]) {
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
  
    BackendlessUser *user = [self.model.allUsers objectAtIndex:indexPath.row];
    
    if ([self.model hasFriend:user]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.model removeFriend:user];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.model addFriend:user];
    }
}

@end
