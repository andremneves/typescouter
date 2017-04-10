//
//  monitor.m
//  TypeScouter
//
//  Created by André Neves on 04/04/17.
//  Copyright © 2017 André Neves. All rights reserved.
//

#import "monitor.h"
#import <AVFoundation/AVFoundation.h>

@interface monitor ()

@end

NSString * url_nscout = @"";
NSTimer *intervalo_ciclo;
int minimo = 100;
int maximo = 210;

AVAudioPlayer *_hipoPlayer;
AVAudioPlayer *_hiperPlayer;
AVAudioPlayer *_beepPlayer;

BOOL alarme_glicemias = YES;
BOOL alarme_sensor = YES;

@implementation monitor
@synthesize deltaListArray, dateListArray, sgvListArray;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // montar os quados graficamente
    // montar as bordas das caixas
    _glicose_lida.layer.borderColor = [[UIColor colorWithRed:(192/255.0) green:(192/255.0) blue:(192/255.0) alpha:1] CGColor]; // cinza claro
    _glicose_lida.layer.borderWidth = 1.0;
    _time.layer.borderColor = [[UIColor colorWithRed:(192/255.0) green:(192/255.0) blue:(192/255.0) alpha:1] CGColor]; // cinza claro
    _time.layer.borderWidth = 1.0;
    _diferenca_glicoses.layer.borderColor = [[UIColor colorWithRed:(192/255.0) green:(192/255.0) blue:(192/255.0) alpha:1] CGColor]; // cinza claro
    _diferenca_glicoses.layer.borderWidth = 1.0;
    _cubo_vazio.layer.borderColor = [[UIColor colorWithRed:(192/255.0) green:(192/255.0) blue:(192/255.0) alpha:1] CGColor]; // cinza claro
    _cubo_vazio.layer.borderWidth = 1.0;

    
    //arruma as barras graficamente
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 6.0f);
    _barra.transform = transform;
    
    //prepara os sons do alerta
    NSString *hipopath = [NSString stringWithFormat:@"%@/hipo.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *hiposoundUrl = [NSURL fileURLWithPath:hipopath];
    _hipoPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:hiposoundUrl error:nil];
    
    // desabilita o descanso de tela
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // inicia dados
    [self Ciclo];
    
    // atualiza os dados em intervalos de x segundos
    intervalo_ciclo = [NSTimer scheduledTimerWithTimeInterval:10  target:self selector:@selector(Ciclo) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // desabilita o teclado ao tocar na tela
    [[self view] endEditing:TRUE];
    
}

- (void) Ciclo{
    
    // inicia as arrays para guardar os dados lidos
    deltaListArray = [[NSMutableArray alloc] initWithCapacity:0];
    dateListArray = [[NSMutableArray alloc] initWithCapacity:0];
    sgvListArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    // lê os valores de min e max
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"minimo"]) {minimo = [[defaults objectForKey:@"minimo"] intValue];}
    if ([defaults objectForKey:@"maximo"]) {maximo = [[defaults objectForKey:@"maximo"] intValue];}
    if ([defaults objectForKey:@"url"]) {url_nscout = [defaults objectForKey:@"url"];}
    [defaults synchronize];
    
    //NSLog(@"minimo (monitor) - %d", minimo);
    //NSLog(@"maximo (monitor) - %d", maximo);
    
    //indica a url do nightscout
    //url_nscout = @"https://vinitypeone.herokuapp.com";
    
    //ler os dados
    [self LerDados];
    
    // monta a tela
    [self MontaTela];
    
}

-(void) LerDados
{
    NSString *thisUrl = [url_nscout stringByAppendingString:@"/api/v1/entries.json?count=10"];
    NSURL *nightScoutUrl = [NSURL URLWithString:thisUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nightScoutUrl
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:60];
    [request setHTTPMethod:@"GET"];
    
    NSURLResponse * response = nil;
    NSError * error = nil;
    
    //NSLog(@"url lida (monitor) - %@", thisUrl);
    
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error == nil)
    {
        NSArray *sgvArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        for (int i = 0; i < (int)([sgvArray count]-1); i++)
        {
            NSDictionary *jsonDict = [sgvArray objectAtIndex:i];
            NSDictionary *nextDict = [sgvArray objectAtIndex:i+1];
            
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
            
            NSString *nextSgv = [nextDict objectForKey:@"sgv"];
            
            int sgvInt = [sgv intValue];
            int nextSgvInt = [nextSgv intValue];
            
            int delta = sgvInt - nextSgvInt;
            
            [deltaListArray addObject:[NSString stringWithFormat:@"%d", delta]];
            [sgvListArray addObject:sgv];
            
            //NSLog(@"ultima glicose sgv (monitor) - %@", [sgvListArray objectAtIndex:0]);
            //NSLog(@"ultima glicose delta (monitor) - %@", [deltaListArray objectAtIndex:0]);
            
            NSString *datetime = [jsonDict objectForKey:@"date"];
            
            float dateInt = [datetime floatValue];
            dateInt = dateInt/1000;
            //NSLog(@"ultima universal lida (monitor) - %.0f", dateInt);
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:dateInt];
            NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
            [dateFormatter1 setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
            NSString *timeString = [dateFormatter1 stringFromDate:date];
            
            [dateListArray addObject:timeString];
            //NSLog(@"ultima data lida (monitor) - %@", [dateListArray objectAtIndex:0]);
            
        }
        
    }
}

- (void) MontaTela {
    
    // escreve a ultima glicose lida
    _glicose_lida.text = [sgvListArray objectAtIndex:0];
    
    // escreve a glicose anterior
    _cubo_vazio.text = [sgvListArray objectAtIndex:1];

    // calcula a diferenca em relação a anterior
    int diferenca = ([[sgvListArray objectAtIndex:0] intValue] - [[sgvListArray objectAtIndex:1] intValue]);
    
    // escreve a diferença
    if (diferenca > 0){
        _diferenca_glicoses.text = [NSString stringWithFormat:@"+%.0d", diferenca];
    } else {
        _diferenca_glicoses.text = [NSString stringWithFormat:@"%.0d", diferenca];
    }
    
    // escreve o tempo desde a ultima leitura
    NSDate *ultima_data = [NSDate date];
    NSDate *data_sistema = [NSDate date];
    
    NSDateFormatter *datecompleteFormat = [[NSDateFormatter alloc] init];
    [datecompleteFormat setTimeZone:[NSTimeZone systemTimeZone]];
    [datecompleteFormat setLocale:[NSLocale currentLocale]];
    [datecompleteFormat setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    [datecompleteFormat setFormatterBehavior:NSDateFormatterBehaviorDefault];
    
    ultima_data = [datecompleteFormat dateFromString:[dateListArray objectAtIndex:0]];
    //NSLog(@"ultima data (monitor) - %@", ultima_data);
    
    NSDate *data_atual = [NSDate date];
    NSString *data_atual_str = [datecompleteFormat stringFromDate:data_atual];
    data_sistema = [datecompleteFormat dateFromString:data_atual_str];
    //NSLog(@"data_sistema (monitor) - %@", data_sistema);
    
    NSTimeInterval distancia_leituras = [data_sistema timeIntervalSinceDate:ultima_data];
    
    float minutos = 0;
    minutos = distancia_leituras/60;
    _time.text = [NSString stringWithFormat:@"%.0f", minutos];
    
    // verifica se está normal
    if (([[sgvListArray objectAtIndex:0] intValue] > minimo) && ([[sgvListArray objectAtIndex:0] intValue] < maximo)){
        _alerta.hidden = NO;
        _alerta.backgroundColor = [UIColor colorWithRed:(7/255.0) green:(197/255.0) blue:(172/255.0) alpha:1]; // verde claro
        _alerta.textColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1]; // branco
        _alerta.text = @"glucose is in the goal";
        alarme_glicemias = YES;
    }
    
    // verifica se está alto
    if ([[sgvListArray objectAtIndex:0] intValue] >= maximo){
        _alerta.hidden = NO;
        _alerta.backgroundColor = [UIColor colorWithRed:(216/255.0) green:(174/255.0) blue:(71/255.0) alpha:1]; // amarelo
        _alerta.textColor = [UIColor colorWithRed:(0/255.0) green:(0/255.0) blue:(0/255.0) alpha:1]; // preto
        _alerta.text = @"glucose is above the MAX";
        alarme_glicemias = YES;
    }
    
    // verifica se está baixo
    if ([[sgvListArray objectAtIndex:0] intValue] <= minimo){
        _alerta.hidden = NO;
        _alerta.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(121/255.0) blue:(121/255.0) alpha:1]; // vermelho
        _alerta.textColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1]; // branco
        _alerta.text = @"glucose is below the MIN";
        if (alarme_glicemias){
            [_hipoPlayer play];
            _bt_alarme.hidden = NO;
            _cubo_vazio.hidden = YES;
            _cubo_vazio_titulo.hidden = YES;
        }
    }
    
    // verifica se está mais de 25 minutos sem ler o sensor
    if (minutos >= 25){
        _alerta_sensor.hidden = NO;
        _alerta_sensor.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0) blue:(200/255.0) alpha:1]; // cinza claro
        _alerta_sensor.textColor = [UIColor colorWithRed:(0/255.0) green:(0/255.0) blue:(0/255.0) alpha:1]; // preto
        _alerta_sensor.text = @"sensor is not reading";
        if (alarme_sensor){
            [_hipoPlayer play];
            _bt_alarme.hidden = NO;
            _cubo_vazio.hidden = YES;
            _cubo_vazio_titulo.hidden = YES;
        }
    }
    
    // verifica se está dentro do tempo limite de 25 minutos
    if (minutos < 25){
        alarme_sensor = YES;
        _alerta_sensor.hidden = YES;
    }
    
    //monta a barra
    float barra = minutos/25;
    NSString *barra_round = [NSString stringWithFormat:@"%.2f", barra];
    barra = [barra_round floatValue];
    _barra.progress = barra;
    
}

- (IBAction)suspender_alarme:(id)sender {
    
    //para o som do alarme
    [_hipoPlayer stop];
    
    // omite o botão de stop e exibe de volta a glicose anterior
    _bt_alarme.hidden = YES;
    _cubo_vazio.hidden = NO;
    _cubo_vazio_titulo.hidden = NO;
    
    // desativa o alarme de hipoglicemias
    if (alarme_glicemias){
        alarme_glicemias = NO;
    }
    
    //desativa o alarme do sensor
    if (alarme_sensor){
        alarme_sensor = NO;
    }
}

@end
