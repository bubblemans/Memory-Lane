//
//  HoundifyPhraseSpottingManager.h
//  HoundifyPhraseSpotter
//
//  Created by Jeff Weitzel on 1/18/19.
//  Copyright © 2019 SoundHound, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString* HoundVoiceSearchHotPhraseNotification;
extern NSString* HoundVoiceSearchSecondaryHotPhraseRecognized;

@interface HoundifyPhraseSpottingManager : NSObject

- (instancetype)initWithFrameLength:(NSUInteger)frameLength endFrameDelay:(NSUInteger)endFrameDelay
                    inputSampleRate:(double)inputSampleRate;

#pragma mark - "OK Hound" Threshold

/**
 This property adjusts the sensitivity for detecting the phrase 
 "OK Hound"
 
 Valid values are in the range 0.0-1.0. With lower values the phrase
 spotter will trigger more frequently, capturing the wakeup phrase
 more often, but with increased chance for false positives.
 
 Conversely, with higher values the phrase spotter will trigger less
 frequently, possibly missing the wakeup phrase more often, but with
 a lower false positive rate.
 */
@property (nonatomic, assign) float okHoundThreshold;

/**
 An informational value which shows highest confidence score reached
 by the phrase spotter for any single frame of audio since the last
 reset.
 
 Confidence scores are in the range 0.0-1.0
 
 This value is independent of whether a phrase is spotted. That is,
 the max confidence score will increase with each new high water mark
 regardless of whether the confidence score has exceeded the
 threshold.  This is useful information for tuning the phrase spotter
 sensitivity, and has no effect on phrase spotter functionality.

 @note The max confidence must be reset to 0.0 explicitly by calling
 -resetOkHoundMaxConfidenceScore. It will NOT reset if a phrase is
 spotted.  This allows the max confidence value to be tracked across
 any duration of audio, regardless of how many times it contains the
 target phrase.
 */
@property (nonatomic, readonly) float okHoundMaxConfidenceScore;


/**
 Resets okHoundMaxConfidenceScore to 0.0. This method is the only way
 to reset the value, even if the target phrase has been detected.
 */
- (void)resetOkHoundMaxConfidenceScore;

@end

NS_ASSUME_NONNULL_END
