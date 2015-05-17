//
//  FeedsTableViewController.h
//  ProficiencyTest
//
//  Created by Kanika Varma on 18/05/2015.
//  Copyright (c) 2015 Kanika Varma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedsTableViewController : UITableViewController <UITableViewDataSource,UITableViewDelegate>
{
    NSOperationQueue* queue;
}
@property(nonatomic, strong)NSDictionary* jsonDict;

@end
