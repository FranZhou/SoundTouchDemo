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
#import <Foundation/Foundation.h>
typedef struct  sountTouchConfig {
    int sampleRate;     //采样率 <这里使用8000 原因: 录音是采样率:8000>
    int tempoChange;    //速度 <变速不变调>
    int pitch;          // 音调
    int rate;           //声音速率
} MySountTouchConfig;


@interface SoundTouchOperation : NSOperation
{
    id target;
    SEL action;
    MySountTouchConfig MysoundConfig;
}
- (id)initWithTarget:(id)tar action:(SEL)ac SoundTouchConfig:(MySountTouchConfig)soundConfig soundFile:(NSData *)file;
@end
