//
//  game.m
//  TypeScouter
//
//  Created by André Neves on 19/04/17.
//  Copyright © 2017 André Neves. All rights reserved.
//

#import "game.h"

@interface game ()

@end

NSString * url_game = @"";
int unidade_game = 0;
int minimo_game = 100;
int maximo_game = 210;
int time_level_game = 10;
int level_game = 1;
int score_game = 0;
int stars = 0;
int recorde_game = 0;

float HBA1C_game = 0;
float Media_game;
float down_game = 0;
float target_game = 0;
float up_game = 0;
int Contador_game = 0;


@implementation game
@synthesize deltaListArray2, dateListArray2, sgvListArray2;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // montar os quados graficamente
    _average.layer.borderColor = [[UIColor colorWithRed:(192/255.0) green:(192/255.0) blue:(192/255.0) alpha:1] CGColor]; // cinza claro
    _average.layer.borderWidth = 1.0;
    _inthegoal.layer.borderColor = [[UIColor colorWithRed:(192/255.0) green:(192/255.0) blue:(192/255.0) alpha:1] CGColor]; // cinza claro
    _inthegoal.layer.borderWidth = 1.0;
    _belowthemin.layer.borderColor = [[UIColor colorWithRed:(192/255.0) green:(192/255.0) blue:(192/255.0) alpha:1] CGColor]; // cinza claro
    _belowthemin.layer.borderWidth = 1.0;
    _abovethemax.layer.borderColor = [[UIColor colorWithRed:(192/255.0) green:(192/255.0) blue:(192/255.0) alpha:1] CGColor]; // cinza claro
    _abovethemax.layer.borderWidth = 1.0;
    
    // desabilita o descanso de tela
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // atualiza o level para o level 1
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"1" forKey:@"level"];
    [defaults synchronize];
    level_game = 1;
    
    //inicia o placar em zero
    score_game = 0;

    //inicia o jogo
    [self Jogar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // desabilita o teclado ao tocar na tela
    [[self view] endEditing:TRUE];
}

-(void) Jogar {
    
    //omite o botão de next level e limpa as estrelas
    _bt_nextlevel.hidden = YES;
    _star1.image = [UIImage imageNamed:@"white star.png"];
    _star2.image = [UIImage imageNamed:@"white star.png"];
    _star3.image = [UIImage imageNamed:@"white star.png"];

    
    //inicia as estrelas
    stars = 0;
    
    // inicia as arrays para guardar os dados lidos
    deltaListArray2 = [[NSMutableArray alloc] initWithCapacity:0];
    dateListArray2 = [[NSMutableArray alloc] initWithCapacity:0];
    sgvListArray2 = [[NSMutableArray alloc] initWithCapacity:0];
    
    // ler os valores de min e max
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"minimo"]) {minimo_game = [[defaults objectForKey:@"minimo"] intValue];}
    if ([defaults objectForKey:@"maximo"]) {maximo_game = [[defaults objectForKey:@"maximo"] intValue];}
    if ([defaults objectForKey:@"url"]) {url_game = [defaults objectForKey:@"url"];}
    if ([defaults objectForKey:@"unidade"]) {unidade_game = [[defaults objectForKey:@"unidade"] intValue];}
    if ([defaults objectForKey:@"recorde"]) {recorde_game = [[defaults objectForKey:@"recorde"] intValue];}
    
    [defaults synchronize];
    
    // escreve o recorde
    _recorde.text = [NSString stringWithFormat:@"best: %d", recorde_game];
    
    //ler os dados
    [self LerDadosGame];
    
    if ([sgvListArray2 count] > 0){
    
        //define o número de medidas de acordo com o level do game
        time_level_game = level_game * 10;
        _level.text = [NSString stringWithFormat:@"LEVEL %d \n\n last %d glucoses", level_game, time_level_game];

        NSLog(@"level (game) - %d", level_game);
    
        //analisa os dados
        [self MontaHBA1C2];
    
        //monta a tela com o resultado
        if (unidade_game == 0){
            _average.text = [NSString stringWithFormat:@"%.0f", Media_game];
        } else if (unidade_game == 1){
            float media_mmol = (Media_game / 18);
            _average.text = [NSString stringWithFormat:@"%.1f", media_mmol];
        }
        _inthegoal.text = [NSString stringWithFormat:@"%.0f", target_game];
        _abovethemax.text = [NSString stringWithFormat:@"%.0f", up_game];
        _belowthemin.text = [NSString stringWithFormat:@"%.0f", down_game];

        // verifica as estrelas no nível
        if ((Media_game > minimo_game) && (Media_game < maximo_game)){
            stars++;
        }
        if ((Media_game > minimo_game) && (Media_game < maximo_game) && (up_game == 0)){
            stars++;
        }
        if ((Media_game > minimo_game) && (Media_game < maximo_game) && (down_game == 0)){
            stars++;
        }
    
        //ativa as estrelas
        if (stars == 1){
            _star1.image = [UIImage imageNamed:@"yellow star.png"];
            _bt_nextlevel.hidden = NO;
        }
        if (stars == 2){
            _star1.image = [UIImage imageNamed:@"yellow star.png"];
            _star2.image = [UIImage imageNamed:@"yellow star.png"];
            _bt_nextlevel.hidden = NO;
        }
        if (stars == 3){
            _star1.image = [UIImage imageNamed:@"yellow star.png"];
            _star2.image = [UIImage imageNamed:@"yellow star.png"];
            _star3.image = [UIImage imageNamed:@"yellow star.png"];
            _bt_nextlevel.hidden = NO;
        }
    
        // informa que perdeu
        if (stars == 0){
            _level.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(121/255.0) blue:(121/255.0) alpha:1]; // vermelho
            _level.text = [NSString stringWithFormat:@"LEVEL %d \n\n your average is above the max in the last %d glucoses \n\n GAME OVER", level_game, time_level_game];
        
            // atualiza o recorde
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if ([defaults objectForKey:@"recorde"]) {recorde_game = [[defaults objectForKey:@"recorde"] intValue];}
            if (recorde_game < score_game){
                [defaults setObject:[NSString stringWithFormat:@"%d", score_game] forKey:@"recorde"];
                _recorde.text = [NSString stringWithFormat:@"best: %d", score_game];
                _recorde.textColor = [UIColor colorWithRed:(255/255.0) green:(121/255.0) blue:(121/255.0) alpha:1]; // vermelho
            }
            [defaults synchronize];
        
            // apaga as estrelas
            _star1.hidden = YES;
            _star2.hidden = YES;
            _star3.hidden = YES;
        } else {
            // atualiza o score
            score_game = score_game + (time_level_game * stars) + 17;
            _score.text = [NSString stringWithFormat:@"score: %d", score_game];
        }
        
    } else {
        _score.text = @"score:000";
        _average.text = @"-";
        _inthegoal.text = @"-";
        _belowthemin.text = @"-";
        _abovethemax.text = @"-";
        _level.text = @"-";
    }

    
}



- (void) MontaHBA1C2{
    
    // define variáveis
    float Soma_game = 0;
    Contador_game = 0;
    Media_game = 0;
    down_game = 0;
    target_game = 0;
    up_game = 0;
    
    for (int i = 0; i < (int)(time_level_game); i++){
        
        float valorGlicose = [[sgvListArray2 objectAtIndex:i] floatValue];
        Soma_game = Soma_game + valorGlicose;
        Contador_game++;
        
        if (valorGlicose <= minimo_game){ down_game++; }
        if ((valorGlicose > minimo_game) && (valorGlicose < maximo_game)){ target_game++; }
        if (valorGlicose >= maximo_game){ up_game++; }
        
    }
    
    down_game = (down_game / Contador_game) * 100;
    up_game = (up_game / Contador_game) * 100;
    target_game = (target_game / Contador_game) * 100;
    
    Media_game = Soma_game / Contador_game;
    HBA1C_game = (Media_game + 46.7) / 28.7;
}


-(void) LerDadosGame
{
    NSString *thisUrl = [url_game stringByAppendingString:@"/api/v1/entries.json?count=1000"];
    NSURL *nightScoutUrl = [NSURL URLWithString:thisUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nightScoutUrl
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:60];
    [request setHTTPMethod:@"GET"];
    
    NSURLResponse * response = nil;
    NSError * error = nil;
    
    NSData *data = [self sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error == nil)
    {
        
        NSArray *sgvArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        for (int i = 0; i < (int)([sgvArray count]-1); i++)
        {
            NSDictionary *jsonDict = [sgvArray objectAtIndex:i];
            
            id temp = [jsonDict objectForKey:@"sgv"];
            NSString *sgv;
            if ([temp isKindOfClass:[NSString class]])
            {
                sgv = temp;
            }
            else
            {
                sgv = [temp stringValue];
            }
            
            if (sgv){
                [sgvListArray2 addObject:sgv];
                
                NSString *datetime = [jsonDict objectForKey:@"date"];
                
                float dateInt = [datetime floatValue];
                dateInt = dateInt/1000;
                
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:dateInt];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
                NSString *timeString = [dateFormatter stringFromDate:date];
                
                [dateListArray2 addObject:timeString];
            }
            
        }
        
    }
}

- (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error
{
    
    NSError __block *err = NULL;
    NSData __block *data;
    BOOL __block reqProcessed = false;
    NSURLResponse __block *resp;
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable _data, NSURLResponse * _Nullable _response, NSError * _Nullable _error) {
        resp = _response;
        err = _error;
        data = _data;
        reqProcessed = true;
    }] resume];
    
    while (!reqProcessed) {
        [NSThread sleepForTimeInterval:0];
    }
    
    *response = resp;
    *error = err;
    return data;
}

- (IBAction)next_level:(id)sender {
    
    // atualiza o level
    level_game++;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%d", level_game] forKey:@"level"];
    [defaults synchronize];
    
    // carrega o novo level
    [self Jogar];
    
}
@end
