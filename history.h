//
//  history.h
//  TypeScouter
//
//  Created by André Neves on 04/04/17.
//  Copyright © 2017 André Neves. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface history : UIViewController

@property (nonatomic, strong) NSMutableArray *deltaListArray1;
@property (nonatomic, strong) NSMutableArray *dateListArray1;
@property (nonatomic, strong) NSMutableArray *sgvListArray1;

@property (weak, nonatomic) IBOutlet UILabel *glicose_media;
@property (weak, nonatomic) IBOutlet UILabel *a1c_estimada;

@property (weak, nonatomic) IBOutlet UILabel *in_the_goal;
@property (weak, nonatomic) IBOutlet UILabel *below;
@property (weak, nonatomic) IBOutlet UILabel *above;

@property (weak, nonatomic) IBOutlet UITextView *congrats;

- (IBAction)day1:(id)sender;
- (IBAction)day3:(id)sender;
- (IBAction)day10:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *bt_day1;
@property (weak, nonatomic) IBOutlet UIButton *bt_day3;
@property (weak, nonatomic) IBOutlet UIButton *bt_day10;

@property (weak, nonatomic) IBOutlet UITextField *min;
@property (weak, nonatomic) IBOutlet UITextField *max;


@end
