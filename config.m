//
//  config.m
//  TypeScouter
//
//  Created by André Neves on 04/04/17.
//  Copyright © 2017 André Neves. All rights reserved.
//

#import "config.h"

@interface config ()

@end

@implementation config

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // pega url nightscout, min e max
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"url"]) {_url_nightscout.text = [defaults objectForKey:@"url"];}
    if ([defaults objectForKey:@"minimo"]) {_min.text = [defaults objectForKey:@"minimo"];}
    if ([defaults objectForKey:@"maximo"]) {_max.text = [defaults objectForKey:@"maximo"];}
    
    // fecha o NSUserDefaults
    [defaults synchronize];
    
    // arruma graficamente as cxs de input
    
    _url_nightscout.layer.backgroundColor=[[UIColor colorWithRed:(100/255.0) green:(100/255.0) blue:(100/255.0) alpha:1] CGColor];
    _url_nightscout.layer.borderWidth= 1.0f;
    
    _min.layer.borderColor=[[UIColor colorWithRed:(200/255.0) green:(200/255.0) blue:(200/255.0) alpha:1] CGColor];
    _min.layer.borderWidth= 1.0f;
    
    _max.layer.borderColor=[[UIColor colorWithRed:(200/255.0) green:(200/255.0) blue:(200/255.0) alpha:1] CGColor];
    _max.layer.borderWidth= 1.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // desabilita o teclado ao tocar na tela
    [[self view] endEditing:TRUE];
    
}


- (IBAction)atualiza_url:(id)sender {
    // adiciona o s de security no http
    _url_nightscout.text = [_url_nightscout.text stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
    
    // abre o NSdefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // grava a nova url
    [defaults setObject:_url_nightscout.text forKey:@"url"];
    // fecha o NSUserDefaults
    [defaults synchronize];
}

- (IBAction)atualiza_min:(id)sender {
    // abre o NSdefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // grava o novo minimo
    [defaults setObject:_min.text forKey:@"minimo"];
    // fecha o NSUserDefaults
    [defaults synchronize];
}

- (IBAction)atualiza_max:(id)sender {
    // abre o NSdefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // grava o novo maximo
    [defaults setObject:_max.text forKey:@"maximo"];
    // fecha o NSUserDefaults
    [defaults synchronize];
}

@end
