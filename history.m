//
//  history.m
//  TypeScouter
//
//  Created by André Neves on 04/04/17.
//  Copyright © 2017 André Neves. All rights reserved.
//

#import "history.h"

@interface history ()

@end

NSString * url_nscout1 = @"";
int minimo1 = 100;
int maximo1 = 210;

float HBA1C1 = 0;
float Media1;
float down = 0;
float target = 0;
float up = 0;
int Contador = 0;


@implementation history
@synthesize deltaListArray1, dateListArray1, sgvListArray1;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // pega url nightscout, min e max
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"minimo"]) {_min.text = [defaults objectForKey:@"minimo"];}
    if ([defaults objectForKey:@"maximo"]) {_max.text = [defaults objectForKey:@"maximo"];}
    
    // fecha o NSUserDefaults
    [defaults synchronize];

    
    // montar as bordas das caixas
    _glicose_media.layer.borderColor = [[UIColor colorWithRed:(192/255.0) green:(192/255.0) blue:(192/255.0) alpha:1] CGColor]; // cinza claro
    _glicose_media.layer.borderWidth = 1.0;
    _a1c_estimada.layer.borderColor = [[UIColor colorWithRed:(192/255.0) green:(192/255.0) blue:(192/255.0) alpha:1] CGColor]; // cinza claro
    _a1c_estimada.layer.borderWidth = 1.0;
    _in_the_goal.layer.borderColor = [[UIColor colorWithRed:(192/255.0) green:(192/255.0) blue:(192/255.0) alpha:1] CGColor]; // cinza claro
    _in_the_goal.layer.borderWidth = 1.0;
    _below.layer.borderColor = [[UIColor colorWithRed:(192/255.0) green:(192/255.0) blue:(192/255.0) alpha:1] CGColor]; // cinza claro
    _below.layer.borderWidth = 1.0;
    _above.layer.borderColor = [[UIColor colorWithRed:(192/255.0) green:(192/255.0) blue:(192/255.0) alpha:1] CGColor]; // cinza claro
    _above.layer.borderWidth = 1.0;
    _min.layer.borderColor=[[UIColor colorWithRed:(200/255.0) green:(200/255.0) blue:(200/255.0) alpha:1] CGColor];
    _min.layer.borderWidth= 1.0f;
    _max.layer.borderColor=[[UIColor colorWithRed:(200/255.0) green:(200/255.0) blue:(200/255.0) alpha:1] CGColor];
    _max.layer.borderWidth= 1.0f;

    
    // inicia dados
    [self Day1];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // desabilita o teclado ao tocar na tela
    [[self view] endEditing:TRUE];
    
}
- (void) Day1{
    
    // inicia as arrays para guardar os dados lidos
    deltaListArray1 = [[NSMutableArray alloc] initWithCapacity:0];
    dateListArray1 = [[NSMutableArray alloc] initWithCapacity:0];
    sgvListArray1 = [[NSMutableArray alloc] initWithCapacity:0];
    
    // lê os valores de min - max e url
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"minimo"]) {minimo1 = [[defaults objectForKey:@"minimo"] intValue];}
    if ([defaults objectForKey:@"maximo"]) {maximo1 = [[defaults objectForKey:@"maximo"] intValue];}
    if ([defaults objectForKey:@"url"]) {url_nscout1 = [defaults objectForKey:@"url"];}
    [defaults synchronize];
    
    //NSLog(@"minimo (monitor) - %d", minimo);
    //NSLog(@"maximo (monitor) - %d", maximo);
    
    // monta a url para ler um dia de dador
    url_nscout1 = [url_nscout1 stringByAppendingString:@"/api/v1/entries.json?count=102"];
    
    //ler os dados
    [self Setup];
    
    // monta a media e a1c
    [self MontaHBA1C1];
    
    // escreve as variáveis na tela
    _glicose_media.text = [NSString stringWithFormat:@"%.0f", Media1];
    _a1c_estimada.text = [NSString stringWithFormat:@"%.1f", HBA1C1];
    _in_the_goal.text = [NSString stringWithFormat:@"%.1f", target];
    _above.text = [NSString stringWithFormat:@"%.1f", up];
    _below.text = [NSString stringWithFormat:@"%.1f", down];
    
    if ((Media1 > minimo1) && (Media1 < maximo1)){
        _congrats.backgroundColor = [UIColor colorWithRed:(7/255.0) green:(197/255.0) blue:(172/255.0) alpha:1]; // verde claro
        _congrats.textColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1]; // branco
        //_congrats.text = @"CONGRATULATIONS\n\nyour glucose is under control in the last 100 measurements\n:-)";
        _congrats.text = [NSString stringWithFormat:@"CONGRATULATIONS\n\nyour glucose average is in the goal in the last %.0d measurements\n:-)", Contador];
    } else {
        _congrats.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(121/255.0) blue:(121/255.0) alpha:1]; // vermelho
        _congrats.textColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1]; // branco
        //_congrats.text = @"ATTENTION\n\nyour glucose is out of control in the last 100 measurements\n::(";
        _congrats.text = [NSString stringWithFormat:@"ATTENTION\n\nyour glucose average is out of your interval in the last %.0d measurements\n::(", Contador];
    }
    if (down > 20){
        _congrats.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(121/255.0) blue:(121/255.0) alpha:1]; // vermelho
        _congrats.textColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1]; // branco
        //_congrats.text = @"CONGRATULATIONS\n\nyour glucose is under control in the last 100 measurements\n:-)";
        _congrats.text = [NSString stringWithFormat:@"ATTENTION\n\nmore than 20%% of your glucoses are below the min in the last %.0d measurements\n:-)", Contador];
    }
    if (up > 30){
        _congrats.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(121/255.0) blue:(121/255.0) alpha:1]; // vermelho
        _congrats.textColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1]; // branco
        //_congrats.text = @"CONGRATULATIONS\n\nyour glucose is under control in the last 100 measurements\n:-)";
        _congrats.text = [NSString stringWithFormat:@"ATTENTION\n\nmore than 30%% of your glucoses are above the max in the last %.0d measurements\n:-)", Contador];
    }
}

- (void) Day3{
    
    // inicia as arrays para guardar os dados lidos
    deltaListArray1 = [[NSMutableArray alloc] initWithCapacity:0];
    dateListArray1 = [[NSMutableArray alloc] initWithCapacity:0];
    sgvListArray1 = [[NSMutableArray alloc] initWithCapacity:0];
    
    // lê os valores de min - max e url
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"minimo"]) {minimo1 = [[defaults objectForKey:@"minimo"] intValue];}
    if ([defaults objectForKey:@"maximo"]) {maximo1 = [[defaults objectForKey:@"maximo"] intValue];}
    if ([defaults objectForKey:@"url"]) {url_nscout1 = [defaults objectForKey:@"url"];}
    [defaults synchronize];
    
    //NSLog(@"minimo (monitor) - %d", minimo);
    //NSLog(@"maximo (monitor) - %d", maximo);
    
    // monta a url para ler um dia de dador
    url_nscout1 = [url_nscout1 stringByAppendingString:@"/api/v1/entries.json?count=1002"];
    
    //ler os dados
    [self Setup];
    
    // monta a media e a1c
    [self MontaHBA1C1];
    
    // escreve as variáveis na tela
    _glicose_media.text = [NSString stringWithFormat:@"%.0f", Media1];
    _a1c_estimada.text = [NSString stringWithFormat:@"%.1f", HBA1C1];
    _in_the_goal.text = [NSString stringWithFormat:@"%.1f", target];
    _above.text = [NSString stringWithFormat:@"%.1f", up];
    _below.text = [NSString stringWithFormat:@"%.1f", down];
    
    if ((Media1 > minimo1) && (Media1 < maximo1)){
        _congrats.backgroundColor = [UIColor colorWithRed:(7/255.0) green:(197/255.0) blue:(172/255.0) alpha:1]; // verde claro
        _congrats.textColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1]; // branco
        //_congrats.text = @"CONGRATULATIONS\n\nyour glucose is under control in the last 100 measurements\n:-)";
        _congrats.text = [NSString stringWithFormat:@"CONGRATULATIONS\n\nyour glucose average is in the goal in the last %.0d measurements\n:-)", Contador];
    } else {
        _congrats.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(121/255.0) blue:(121/255.0) alpha:1]; // vermelho
        _congrats.textColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1]; // branco
        //_congrats.text = @"ATTENTION\n\nyour glucose is out of control in the last 100 measurements\n::(";
        _congrats.text = [NSString stringWithFormat:@"ATTENTION\n\nyour glucose average is out of your interval in the last %.0d measurements\n::(", Contador];
    }
    if (down > 20){
        _congrats.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(121/255.0) blue:(121/255.0) alpha:1]; // vermelho
        _congrats.textColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1]; // branco
        //_congrats.text = @"CONGRATULATIONS\n\nyour glucose is under control in the last 100 measurements\n:-)";
        _congrats.text = [NSString stringWithFormat:@"ATTENTION\n\nmore than 20%% of your glucoses are below the min in the last %.0d measurements\n:-)", Contador];
    }
    if (up > 30){
        _congrats.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(121/255.0) blue:(121/255.0) alpha:1]; // vermelho
        _congrats.textColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1]; // branco
        //_congrats.text = @"CONGRATULATIONS\n\nyour glucose is under control in the last 100 measurements\n:-)";
        _congrats.text = [NSString stringWithFormat:@"ATTENTION\n\nmore than 30%% of your glucoses are above the max in the last %.0d measurements\n:-)", Contador];
    }
}

- (void) Day10{
    
    // inicia as arrays para guardar os dados lidos
    deltaListArray1 = [[NSMutableArray alloc] initWithCapacity:0];
    dateListArray1 = [[NSMutableArray alloc] initWithCapacity:0];
    sgvListArray1 = [[NSMutableArray alloc] initWithCapacity:0];
    
    // lê os valores de min - max e url
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"minimo"]) {minimo1 = [[defaults objectForKey:@"minimo"] intValue];}
    if ([defaults objectForKey:@"maximo"]) {maximo1 = [[defaults objectForKey:@"maximo"] intValue];}
    if ([defaults objectForKey:@"url"]) {url_nscout1 = [defaults objectForKey:@"url"];}
    [defaults synchronize];
    
    //NSLog(@"minimo (monitor) - %d", minimo);
    //NSLog(@"maximo (monitor) - %d", maximo);
    
    // monta a url para ler um dia de dador
    url_nscout1 = [url_nscout1 stringByAppendingString:@"/api/v1/entries.json?count=10002"];
    
    //ler os dados
    [self Setup];
    
    // monta a media e a1c
    [self MontaHBA1C1];
    
    // escreve as variáveis na tela
    _glicose_media.text = [NSString stringWithFormat:@"%.0f", Media1];
    _a1c_estimada.text = [NSString stringWithFormat:@"%.1f", HBA1C1];
    _in_the_goal.text = [NSString stringWithFormat:@"%.1f", target];
    _above.text = [NSString stringWithFormat:@"%.1f", up];
    _below.text = [NSString stringWithFormat:@"%.1f", down];
    
    if (((Media1 > minimo1) && (Media1 < maximo1)) && (target > 70)){
        _congrats.backgroundColor = [UIColor colorWithRed:(7/255.0) green:(197/255.0) blue:(172/255.0) alpha:1]; // verde claro
        _congrats.textColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1]; // branco
        //_congrats.text = @"CONGRATULATIONS\n\nyour glucose is under control in the last 10000 measurements\n:-)";
        _congrats.text = [NSString stringWithFormat:@"CONGRATULATIONS\n\nyour glucose is under control in the last %.0d measurements\n:-)", Contador];
    } else {
        _congrats.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(121/255.0) blue:(121/255.0) alpha:1]; // vermelho
        _congrats.textColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1]; // branco
        //_congrats.text = @"ATTENTION\n\nyour glucose is out of control in the last 10000 measurements\n::(";
        _congrats.text = [NSString stringWithFormat:@"ATTENTION\n\nyour glucose is out of control in the last %.0d measurements\n::(", Contador];
    }
}



-(void) Setup
{
    NSString *thisUrl = url_nscout1;
    NSURL *nightScoutUrl = [NSURL URLWithString:thisUrl];
    
    NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:nightScoutUrl
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:60];
    [request1 setHTTPMethod:@"GET"];
    
    NSURLResponse * response = nil;
    NSError * error = nil;
    
    //NSLog(@"url lida (monitor) - %@", thisUrl);
    
    NSData * data1 = [NSURLConnection sendSynchronousRequest:request1 returningResponse:&response error:&error];
    
    if (error == nil)
    {
        NSArray *sgvArray = [NSJSONSerialization JSONObjectWithData:data1 options:0 error:&error];
        
        for (int i = 0; i < (int)([sgvArray count]-1); i++)
        {
            NSDictionary *jsonDict1 = [sgvArray objectAtIndex:i];
            NSDictionary *nextDict1 = [sgvArray objectAtIndex:i+1];
            
            id temp = [jsonDict1 objectForKey:@"sgv"];
            NSString *sgv;
            if ([temp isKindOfClass:[NSString class]])
            {
                sgv = temp;
            }
            else
            {
                sgv = [temp stringValue];
            }
            
            NSString *nextSgv = [nextDict1 objectForKey:@"sgv"];
            
            int sgvInt = [sgv intValue];
            int nextSgvInt = [nextSgv intValue];
            
            int delta = sgvInt - nextSgvInt;
            
            [deltaListArray1 addObject:[NSString stringWithFormat:@"%d", delta]];
            [sgvListArray1 addObject:sgv];
            
            //NSLog(@"ultima glicose sgv (monitor) - %@", [sgvListArray objectAtIndex:0]);
            //NSLog(@"ultima glicose delta (monitor) - %@", [deltaListArray objectAtIndex:0]);
            
            NSString *datetime = [jsonDict1 objectForKey:@"date"];
            
            float dateInt = [datetime floatValue];
            dateInt = dateInt/1000;
            //NSLog(@"ultima universal lida (monitor) - %.0f", dateInt);
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:dateInt];
            NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
            [dateFormatter1 setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
            NSString *timeString = [dateFormatter1 stringFromDate:date];
            
            [dateListArray1 addObject:timeString];
            //NSLog(@"ultima data lida (monitor) - %@", [dateListArray objectAtIndex:0]);
            
        }
        
    }
}

- (void) MontaHBA1C1{
    
    // define variáveis
    float Soma = 0;
    Contador = 0;
    Media1 = 0;
    down = 0;
    target = 0;
    up = 0;
    
    for (int i = 0; i < (int)([sgvListArray1 count]-1); i++){
        
        float valorGlicose = [[sgvListArray1 objectAtIndex:i] floatValue];
        Soma = Soma + valorGlicose;
        Contador++;
        
        if (valorGlicose <= minimo1){ down++; }
        if ((valorGlicose > minimo1) && (valorGlicose < maximo1)){ target++; }
        if (valorGlicose >= maximo1){ up++; }
        
    }
    
    down = (down / Contador) * 100;
    up = (up / Contador) * 100;
    target = (target / Contador) * 100;
    
    Media1 = Soma / Contador;
    HBA1C1 = (Media1 + 46.7) / 28.7;
}

- (IBAction)day1:(id)sender {
    [self Day1];
    [_bt_day1 setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
}

- (IBAction)day3:(id)sender {
    [self Day3];
    [_bt_day3 setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
}

- (IBAction)day10:(id)sender {
    [self Day10];
    [_bt_day10 setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
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
