/*
 ReadMe.strings
 
 Created by chuliangliang on 15-1-14.
 Copyright (c) 2014年 aikaola. All rights reserved.
 */

/**
 * 这一版修正了在 arm64 下机型的使用问题  优化了录音方式 变声处理采用了多线程,并且实现了简单的音频文件的变声
 * 下一版 我会优化一下 对其他音频的处理 例如MP3 歌曲等
 * 本例使用了 SoundTouch 音频处理框架
 * QQ:949977202
 * Email : chuliangliang300@sina.com
 * 更多内容尽在 : http://blog.csdn.net/u011205774 (本博客 收录了一些cocos2dx 简单介绍 和使用实例)
 ***/
#import "ViewController.h"
#import "Recorder.h"
@interface ViewController () <AVAudioPlayerDelegate>
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    sayBeginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sayBeginBtn.backgroundColor = [UIColor redColor];
    [sayBeginBtn setTitle:@"开始录音" forState:UIControlStateNormal];
    sayBeginBtn.frame = CGRectMake(10, screenRect.size.height-90, 300, 30);
    [sayBeginBtn addTarget:self action:@selector(buttonSayBegin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sayBeginBtn];
    
    sayEndBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sayEndBtn.backgroundColor = [UIColor greenColor];
    [sayEndBtn setTitle:@"停止录音" forState:UIControlStateNormal];
    sayEndBtn.frame = CGRectMake(10, screenRect.size.height-90, 300, 30);
    [sayEndBtn addTarget:self action:@selector(buttonSayEnd:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sayEndBtn];
    sayEndBtn.hidden = YES;
    
    playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    playBtn.backgroundColor = [UIColor blueColor];
    [playBtn setTitle:@"播放效果" forState:UIControlStateNormal];
    playBtn.frame = CGRectMake(10, screenRect.size.height-90, 300, 30);
    [playBtn addTarget:self action:@selector(buttonPlay:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playBtn];
    playBtn.hidden = YES;
    
    
    reSayEndBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    reSayEndBtn.backgroundColor = [UIColor purpleColor];
    [reSayEndBtn setTitle:@"重新录音/停止播放" forState:UIControlStateNormal];
    reSayEndBtn.frame = CGRectMake(10, screenRect.size.height- 50, 300, 30);
    [reSayEndBtn addTarget:self action:@selector(buttonReSayBegin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:reSayEndBtn];

    
    audioBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    audioBtn.backgroundColor = [UIColor blueColor];
    [audioBtn setTitle:@"播放文件" forState:UIControlStateNormal];
    audioBtn.frame = CGRectMake(10, screenRect.size.height-140, 300, 30);
    [audioBtn addTarget:self action:@selector(buttonPlayFlie:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:audioBtn];
    
    soundTouchQueue = [[NSOperationQueue alloc] init];
    soundTouchQueue.maxConcurrentOperationCount = 1;
    
    
    CGRect tmpRect = self.countDownLabel.frame;
    tmpRect.origin.y = screenRect.size.height - 140 - tmpRect.size.height;
    self.countDownLabel.frame = tmpRect;
    
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(16,
                                                                  self.rateChangeSlide.frame.origin.y + self.rateChangeSlide.frame.size.height,
                                                                  screenRect.size.width - 32,
                                                                  self.countDownLabel.frame.origin.y - (self.rateChangeSlide.frame.origin.y + self.rateChangeSlide.frame.size.height))];
    msgLabel.textColor = [UIColor redColor];
    msgLabel.textAlignment = NSTextAlignmentCenter;
    msgLabel.numberOfLines = 0;
    msgLabel.text = @"变声过程时间长短取决于音频文件的采样率(采样率越大时间越长)请耐心等待\n注意: 这里使用的是多线程处理防止堵塞主线程,目前对录音文件(wav格式)的处理已达到基本完美的支持;对于除录音文件以外的其他音频文件处理不完美,本人正在积极研究中😊";
    msgLabel.font = [UIFont systemFontOfSize:12.0f];
    [self.view insertSubview:msgLabel atIndex:0];
    [msgLabel release];
    
    tempoChangeNum = 0;
    pitchSemiTonesNum= 0;
    rateChangeNum = 0;
    
    timeManager = [DotimeManage DefaultManage];
    [timeManager setDelegate:self];
    
    self.actView.hidesWhenStopped = YES;
    [self.actView stopAnimating];

}

//处理音频文件
- (void)buttonPlayFlie:(UIButton *)btn
{
    [self stopAudio];
    [[Recorder shareRecorder] stopRecord];
    
    [audioBtn setTitle:@"文件处理中..." forState:UIControlStateNormal];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"第一夫人-铃声" ofType:@"wav"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    [self.actView startAnimating];
    
    
    MySountTouchConfig config;
    config.sampleRate = 44100;
    config.tempoChange = tempoChangeNum;
    config.pitch = pitchSemiTonesNum;
    config.rate = rateChangeNum;
    
    SoundTouchOperation *sdop = [[SoundTouchOperation alloc] initWithTarget:self
                                                                     action:@selector(soundMusicFinish:)
                                                           SoundTouchConfig:config soundFile:data];
    [soundTouchQueue cancelAllOperations];
    [soundTouchQueue addOperation:sdop];
    
}


 //时间改变
- (void)TimerActionValueChange:(int)time
{
    
    if (time == 30) {
        
        [timeManager stopTimer];
        
        sayBeginBtn.hidden = YES;
        sayEndBtn.hidden = YES;
        playBtn.hidden = NO;
        reSayEndBtn.hidden = NO;
        
        [[Recorder shareRecorder] stopRecord];
    }
    if (time > 30) time = 30;
    
    self.countDownLabel.text = [NSString stringWithFormat:@"时间: %02d",time];

}

- (void)buttonReSayBegin
{
    
    sayBeginBtn.hidden = NO;
    sayEndBtn.hidden = YES;
    playBtn.hidden = YES;

    [soundTouchQueue cancelAllOperations];
    [self stopAudio];
}

- (void)buttonSayBegin:(id)sender
{
    //录音
    [soundTouchQueue cancelAllOperations];
    [self stopAudio];
    
    sayBeginBtn.hidden = YES;
    sayEndBtn.hidden = NO;
    playBtn.hidden = YES;
    reSayEndBtn.hidden = YES;
    
    [timeManager setTimeValue:30];
    [timeManager startTime];

    [[Recorder shareRecorder] startRecord];
}

- (void)buttonSayEnd:(id)sender
{
    [timeManager stopTimer];
    
    sayBeginBtn.hidden = YES;
    sayEndBtn.hidden = YES;
    playBtn.hidden = NO;
    reSayEndBtn.hidden = NO;
  
    [[Recorder shareRecorder] stopRecord];
}

- (void)buttonPlay:(UIButton *)sender
{
    NSLog(@"播放音效");
    [self stopAudio];
    [self.actView startAnimating];
    
    [playBtn setTitle:@"处理中..." forState:UIControlStateNormal];
    
    NSData *data = [NSData dataWithContentsOfFile:[Recorder shareRecorder].filePath];
    
    MySountTouchConfig config;
    config.sampleRate = 8000;
    config.tempoChange = tempoChangeNum;
    config.pitch = pitchSemiTonesNum;
    config.rate = rateChangeNum;
    
    SoundTouchOperation *sdop = [[SoundTouchOperation alloc] initWithTarget:self
                                                                     action:@selector(soundTouchFinish:)
                                                           SoundTouchConfig:config soundFile:data];
    [soundTouchQueue cancelAllOperations];
    [soundTouchQueue addOperation:sdop];

    
}



- (IBAction)tempoChangeValue:(UISlider *)sender {
    int value = (int)sender.value;
    self.tempoChangeLabel.text = [NSString stringWithFormat:@"setTempoChange: %d",value];
    tempoChangeNum = value;
}


- (IBAction)pitchSemitonesValue:(UISlider *)sender {
    int value = (int)sender.value;
    self.pitchSemitonesLabel.text = [NSString stringWithFormat:@"setPitchSemiTones: %d",value];
    pitchSemiTonesNum = value;

}
- (IBAction)rateChangeValue:(UISlider *)sender {
    
    int value = (int)sender.value;
    self.rateChangeLabel.text = [NSString stringWithFormat:@"setRateChange: %d",value];
    rateChangeNum = value;

}

#pragma mark - 处理音频文件结束
- (void)soundMusicFinish:(NSString *)path {
    [self stopAudio];
    [self.actView stopAnimating];
    [audioBtn setTitle:@"播放文件中..." forState:UIControlStateNormal];
    [self playAudio:path];
}
#pragma mark - 处理录音结束
- (void)soundTouchFinish:(NSString *)path {
    
    [self stopAudio];
    [self.actView stopAnimating];
    [playBtn setTitle:@"播放效果中..." forState:UIControlStateNormal];

    [self playAudio:path];
}
//播放
- (void)playAudio:(NSString *)path {
    NSURL *url = [NSURL URLWithString:path];
    NSError *err = nil;
    audioPalyer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    audioPalyer.delegate = self;
    [audioPalyer prepareToPlay];
    [audioPalyer play];
}
//停止播放
- (void)stopAudio {
    if (audioPalyer) {
        [audioPalyer stop];
        audioPalyer = nil;
    }
    [self.actView stopAnimating];
    [audioBtn setTitle:@"播放文件" forState:UIControlStateNormal];
    [playBtn setTitle:@"播放效果" forState:UIControlStateNormal];
}

#pragma mak - 播放回调代理
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    //    sayBeginBtn.hidden = NO;
    //    sayEndBtn.hidden = YES;
    //    playBtn.hidden = YES;
    NSLog(@"恢复音效按钮");
    
    [audioBtn setTitle:@"播放文件" forState:UIControlStateNormal];
    [playBtn setTitle:@"播放效果" forState:UIControlStateNormal];
}



- (void)dealloc
{
    [_tempoChangeLabel release];
    [_tempoChangeSlide release];
    [_pitchSemitonesLabel release];
    [_pitchSemitonesSlide release];
    [_rateChangeLabel release];
    [_rateChangeSlide release];
    [_countDownLabel release];
    [_actView release];
    [audioPalyer release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setTempoChangeLabel:nil];
    [self setTempoChangeSlide:nil];
    [self setPitchSemitonesLabel:nil];
    [self setPitchSemitonesSlide:nil];
    [self setRateChangeLabel:nil];
    [self setRateChangeSlide:nil];
    [self setCountDownLabel:nil];
    [self setActView:nil];
    [super viewDidUnload];
}
@end
