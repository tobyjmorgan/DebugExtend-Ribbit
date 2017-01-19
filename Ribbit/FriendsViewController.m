//
//  FriendsViewController.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "FriendsViewController.h"
#import "EditFriendsViewController.h"

#import "FriendsCell.h"

#import "TJMModel.h"
#import "BackendlessUser.h"

@interface FriendsViewController ()

// TJM - Backendless integration
@property (nonatomic, weak) TJMModel *model;

@end

@implementation FriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // TJM - Backendless integration
    self.model = [TJMModel sharedInstance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:TJMModel_Friends_Refreshed object:self.model];

    [self.tableView reloadData];
}

- (void)refresh {
    
    [self.tableView reloadData];
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
    return [self.model currentUsersFriends].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendsCell";
    FriendsCell *cell = (FriendsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    BackendlessUser *user = [[self.model currentUsersFriends] objectAtIndex:indexPath.row];
    cell.nameLabel.text = user.name;
    
    return cell;
}

@end
