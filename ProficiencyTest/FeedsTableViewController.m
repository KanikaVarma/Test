//
//  FeedsTableViewController.m
//  ProficiencyTest
//
//  Created by Kanika Varma on 18/05/2015.
//  Copyright (c) 2015 Kanika Varma. All rights reserved.
//

#import "FeedsTableViewController.h"
#import "FeedsTableViewCell.h"

static NSString *CellIdentifier = @"CellIdentifier";

#define nJSONFeedURL [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/746330/facts.json"]
#define nBackgroundQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#define kAppIconSize 80


///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

@interface FeedsTableViewController ()

@property (nonatomic,strong) NSMutableDictionary *offscreenCells;

@end

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

@implementation FeedsTableViewController

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
#pragma mark - Life Cycle

///////////////////////////////////////////////////////////////
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.jsonDict=[[NSDictionary alloc] init];
    queue =[[NSOperationQueue alloc] init];
    self.offscreenCells = [NSMutableDictionary dictionary];
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.tableView registerClass:[FeedsTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    //initializing refresh control
    UIRefreshControl* refreshControl=[[UIRefreshControl alloc] init] ;
    refreshControl.attributedTitle=[[NSAttributedString alloc] initWithString:@"Pull to refresh"];
    self.refreshControl=refreshControl;
    [refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
    
    //fetching data in background thread
    dispatch_async(nBackgroundQueue, ^{
        NSError *error = nil;
        NSString *jsonString = [NSString stringWithContentsOfURL:nJSONFeedURL
                                                        encoding:NSASCIIStringEncoding
                                                           error:&error];
        //NSLog(@"\nJSON: %@ \n Error: %@", jsonString, error);
        
        if(!error) {
            NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self fetchedData:data];
            });
        }
        
    });
}

///////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
#pragma mark - Table view data source
///////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

///////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[self.jsonDict valueForKey:@"rows"] count];
}

///////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FeedsTableViewCell* cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ([[[self.jsonDict valueForKey:@"rows"] valueForKey:@"title"] objectAtIndex:indexPath.row]==[NSNull null]) {
        
        cell.headLine.text=@"";
    }else{
        cell.headLine.text=[[[self.jsonDict valueForKey:@"rows"] valueForKey:@"title"] objectAtIndex:indexPath.row];
    }
    
    if ([[[self.jsonDict valueForKey:@"rows"] valueForKey:@"description"] objectAtIndex:indexPath.row]==[NSNull null]) {
        
        cell.slugLine.text=@"";
    }else{
        cell.slugLine.text=[[[self.jsonDict valueForKey:@"rows"] valueForKey:@"description"] objectAtIndex:indexPath.row];
    }
    
    [self updateImageWithIndex:indexPath.row andCell:cell];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

///////////////////////////////////////////////////////////////
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSString *reuseIdentifier = CellIdentifier;
    FeedsTableViewCell *cell = [self.offscreenCells objectForKey:reuseIdentifier];
    if (!cell) {
        cell = [[FeedsTableViewCell alloc] init];
        [self.offscreenCells setObject:cell forKey:reuseIdentifier];
    }
    
    if ([[[self.jsonDict valueForKey:@"rows"] valueForKey:@"title"] objectAtIndex:indexPath.row]==[NSNull null]) {
        
        cell.headLine.text=@"";
    }else{
        cell.headLine.text=[[[self.jsonDict valueForKey:@"rows"] valueForKey:@"title"] objectAtIndex:indexPath.row];
    }
    if ([[[self.jsonDict valueForKey:@"rows"] valueForKey:@"description"] objectAtIndex:indexPath.row]==[NSNull null]) {
        
        cell.slugLine.text=@"";
    }else{
        cell.slugLine.text=[[[self.jsonDict valueForKey:@"rows"] valueForKey:@"description"] objectAtIndex:indexPath.row];
    }
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height += 1;
    
    return height;
    
}

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
#pragma mark - Custom Methods

///////////////////////////////////////////////////////////////
- (void)fetchedData:(NSData *)responseData {
    NSError* error;
    self.jsonDict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    [self setTitle:[self.jsonDict valueForKey:@"title"]];
    
    [self.tableView reloadData];
}

///////////////////////////////////////////////////////////////
-(void)refreshData:(UIRefreshControl*)refreshControl

{
    NSDateFormatter* dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, h:mm a"];
    
    dispatch_async(nBackgroundQueue, ^{
        NSError *error = nil;
        NSString *jsonString = [NSString stringWithContentsOfURL:nJSONFeedURL
                                                        encoding:NSASCIIStringEncoding
                                                           error:&error];
        if(!error) {
            NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self fetchedData:data];
            });
        }
        
    });
    
    NSString* lastUpdated=[NSString stringWithFormat:@"Last Updated on:%@",[dateFormatter stringFromDate:[NSDate date]]];
    refreshControl.attributedTitle=[[NSAttributedString alloc] initWithString:lastUpdated];
    [refreshControl endRefreshing];
}


///////////////////////////////////////////////////////////////
-(void)updateImageWithIndex:(NSInteger)index andCell:(FeedsTableViewCell*)cell
{
    
    if ([[[self.jsonDict valueForKey:@"rows"] valueForKey:@"imageHref"] objectAtIndex:index]==[NSNull null]) {
        [cell.img setFrame:CGRectMake(0.0,0.0, 0, 0)];
    }else{
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[[[self.jsonDict valueForKey:@"rows"] valueForKey:@"imageHref"] objectAtIndex:index]]];
        if ( queue == nil )
        {
            queue = [[NSOperationQueue alloc] init];
        }
        
        //fetching images in the background
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse * resp, NSData *data, NSError *error)
         {
             dispatch_async(nBackgroundQueue,^
                            {
                                if ( error == nil && data )
                                {
                                    //UIImage *urlImage = [UIImage imageWithData:data];
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        //[cell.img setImage:urlImage];
                                        
                                        UIImage *image = [[UIImage alloc] initWithData:data];
                                        
                                        if (image.size.width != kAppIconSize || image.size.height != kAppIconSize)
                                        {
                                            CGSize itemSize = CGSizeMake(kAppIconSize, kAppIconSize);
                                            UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.0f);
                                            CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                                            [image drawInRect:imageRect];
                                            cell.img.image = UIGraphicsGetImageFromCurrentImageContext();
                                            UIGraphicsEndImageContext();
                                        }
                                        else
                                        {
                                            cell.img.image = image;
                                        }
                                    });
                                    
                                }
                            });
         }];
        
    }
}


@end
