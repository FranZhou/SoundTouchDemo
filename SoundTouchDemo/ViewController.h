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
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "DotimeManage.h"

#import "SoundTouchOperation.h"

@interface ViewController : UIViewController<DotimeManageDelegate>
{
    UIButton *sayBeginBtn;
    UIButton *sayEndBtn;
    UIButton *reSayEndBtn;
    UIButton *playBtn;
    UIButton *audioBtn;
    AVAudioPlayer *audioPalyer;

    
    /*
     * 初始值 均为0
     */
    int tempoChangeNum;
    int pitchSemiTonesNum;
    int rateChangeNum;
    DotimeManage *timeManager;
    
    
    NSOperationQueue *soundTouchQueue;
}

@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *actView;

@property (retain, nonatomic) IBOutlet UILabel *tempoChangeLabel;
@property (retain, nonatomic) IBOutlet UISlider *tempoChangeSlide;
- (IBAction)tempoChangeValue:(id)sender;


@property (retain, nonatomic) IBOutlet UILabel *pitchSemitonesLabel;
@property (retain, nonatomic) IBOutlet UISlider *pitchSemitonesSlide;
- (IBAction)pitchSemitonesValue:(id)sender;


@property (retain, nonatomic) IBOutlet UILabel *rateChangeLabel;
@property (retain, nonatomic) IBOutlet UISlider *rateChangeSlide;
- (IBAction)rateChangeValue:(id)sender;


@property (retain, nonatomic) IBOutlet UILabel *countDownLabel;
@end
