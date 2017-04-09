//
//  monitor.h
//  TypeScouter
//
//  Created by André Neves on 04/04/17.
//  Copyright © 2017 André Neves. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface monitor : UIViewController

@property (nonatomic, strong) NSMutableArray *deltaListArray;
@property (nonatomic, strong) NSMutableArray *dateListArray;
@property (nonatomic, strong) NSMutableArray *sgvListArray;

@property (weak, nonatomic) IBOutlet UILabel *glicose_lida;
@property (weak, nonatomic) IBOutlet UILabel *diferenca_glicoses;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *alerta;
@property (weak, nonatomic) IBOutlet UILabel *alerta_sensor;
@property (weak, nonatomic) IBOutlet UIProgressView *barra;

@property (weak, nonatomic) IBOutlet UILabel *cubo_vazio;
@property (weak, nonatomic) IBOutlet UILabel *cubo_vazio_titulo;

@property (weak, nonatomic) IBOutlet UIButton *bt_alarme;
- (IBAction)suspender_alarme:(id)sender;

@end
