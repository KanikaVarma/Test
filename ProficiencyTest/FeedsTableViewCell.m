//
//  FeedsTableViewCell.m
//  ProficiencyTest
//
//  Created by Kanika Varma on 18/05/2015.
//  Copyright (c) 2015 Kanika Varma. All rights reserved.
//

#import "FeedsTableViewCell.h"

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

@interface FeedsTableViewCell ()

@property (nonatomic,assign) BOOL didSetupConstraints;

@end

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

@implementation FeedsTableViewCell

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
#pragma mark - Life Cycle

///////////////////////////////////////////////////////////////
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        
        self.headLine = [[UILabel alloc] init];
        [self.headLine setTextColor:[UIColor blueColor]];
        [self.headLine setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
        [self.headLine setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.headLine.lineBreakMode = NSLineBreakByWordWrapping;
        [self.headLine setNumberOfLines:0];
        
        self.slugLine = [[UILabel alloc] init];
        [self.slugLine setTextColor:[UIColor blackColor]];
        [self.slugLine setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0f]];
        [self.slugLine setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.slugLine.lineBreakMode = NSLineBreakByWordWrapping;
        [self.slugLine setNumberOfLines:0];
        
        self.img = [[UIImageView alloc] init];
        self.img.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:self.headLine];
        [self.contentView addSubview:self.slugLine];
        [self.contentView addSubview:self.img];

    }
    return self;
}

///////////////////////////////////////////////////////////////
-(void)updateConstraints{
    if (!self.didSetupConstraints) {
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[headLabel]-6-|" options:0 metrics:nil views:@{ @"headLabel": self.headLine }]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[bodyLabel]-[image]-6-|" options:0 metrics:nil views:@{ @"bodyLabel": self.slugLine,@"image": self.img }]];
        
        NSLayoutConstraint* constrnt;
        constrnt = [NSLayoutConstraint constraintWithItem:self.img
                                                attribute:NSLayoutAttributeWidth
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:nil
                                                attribute:NSLayoutAttributeNotAnAttribute
                                               multiplier:1.0f
                                                 constant:50.0f];
        [self.contentView addConstraint:constrnt];
        
        constrnt = [NSLayoutConstraint constraintWithItem:self.img
                                                attribute:NSLayoutAttributeHeight
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:nil
                                                attribute:NSLayoutAttributeNotAnAttribute
                                               multiplier:1.0f
                                                 constant:50.0f];
        [self.contentView addConstraint:constrnt];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[headLabel]-4-[bodyLabel]-6-|" options:0 metrics:nil views:@{@"headLabel": self.headLine, @"bodyLabel": self.slugLine }]];
        
        self.didSetupConstraints=YES;
    }
    [super updateConstraints];
}


///////////////////////////////////////////////////////////////
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    self.headLine.preferredMaxLayoutWidth = CGRectGetWidth(self.headLine.frame);
    self.slugLine.preferredMaxLayoutWidth = CGRectGetWidth(self.slugLine.frame);
}



@end
