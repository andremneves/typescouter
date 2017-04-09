//
//  config.h
//  TypeScouter
//
//  Created by André Neves on 04/04/17.
//  Copyright © 2017 André Neves. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface config : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *url_nightscout;
@property (weak, nonatomic) IBOutlet UITextField *min;
@property (weak, nonatomic) IBOutlet UITextField *max;

@property (weak, nonatomic) IBOutlet UIButton *bt_continue;

@end
