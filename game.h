//
//  game.h
//  TypeScouter
//
//  Created by André Neves on 19/04/17.
//  Copyright © 2017 André Neves. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface game : UIViewController

@property (nonatomic, strong) NSMutableArray *deltaListArray2;
@property (nonatomic, strong) NSMutableArray *dateListArray2;
@property (nonatomic, strong) NSMutableArray *sgvListArray2;

@property (weak, nonatomic) IBOutlet UILabel *average;
@property (weak, nonatomic) IBOutlet UILabel *inthegoal;
@property (weak, nonatomic) IBOutlet UILabel *belowthemin;
@property (weak, nonatomic) IBOutlet UILabel *abovethemax;

@property (weak, nonatomic) IBOutlet UITextView *level;
@property (weak, nonatomic) IBOutlet UIButton *bt_nextlevel;

@property (weak, nonatomic) IBOutlet UIImageView *star1;
@property (weak, nonatomic) IBOutlet UIImageView *star2;
@property (weak, nonatomic) IBOutlet UIImageView *star3;

@property (weak, nonatomic) IBOutlet UILabel *score;
@property (weak, nonatomic) IBOutlet UILabel *recorde;

- (IBAction)next_level:(id)sender;

@end
