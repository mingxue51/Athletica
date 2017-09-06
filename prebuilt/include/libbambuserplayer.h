/*
 * libbambuser - Bambuser iOS library
 * Copyright 2016 Bambuser AB
 */

#import <UIKit/UIKit.h>
#import "libbambuserplayer-constants.h"

/**
 * \anchor BambuserPlayerDelegate
 * The delegate of a BambuserPlayer must adopt the BambuserPlayerDelegate
 * protocol. Optional methods of the protocol allow the delegate to receive
 * signals about the state of playback.
 */
@protocol BambuserPlayerDelegate <NSObject>
@optional
/**
 * \anchor videoLoadFail
 * This method will be called when the BambuserPlayer
 * failed to load or prime after a BambuserPlayer.playVideo: call.
 */
- (void) videoLoadFail;
/**
 * \anchor playbackStarted
 * This method will be called when playback of a broadcast starts.
 */
- (void) playbackStarted;
/**
 * \anchor playbackPaused
 * This method will be called when playback of a broadcast is paused.
 */
- (void) playbackPaused;
/**
 * \anchor playbackStopped
 * This method will be called when playback of a broadcast is stopped.
 */
- (void) playbackStopped;
/**
 * \anchor playbackCompleted
 * This method will be called when a broadcast, archived or live, has reached the end.
 * This method is called regardless of whether the player enters the stopped or paused state at the end.
 */
- (void) playbackCompleted;
/**
 * \anchor durationKnown
 * This method will be called when the duration of an archived broadcast is known.
 */
- (void) durationKnown: (double) duration;
/**
 * \anchor playerCurrentViewerCountUpdated
 * Called when the number of current viewers is updated.
 *
 * @param viewers Number of current viewers of the broadcast. This is generally an interesting number during a live broadcast.
 */
-(void) currentViewerCountUpdated: (int) viewers;
/**
 * \anchor playerTotalViewerCountUpdated
 * Called when the total number of viewers is updated.
 *
 * @param viewers Total number of viewers of the broadcast. This accumulates over time and is generally a nice number to show for an old broadcast.
 * The counted viewers are not guaranteed to be unique, but there are measures in place to exclude obvious duplicates, eg. replays from a viewer.
 */
-(void) totalViewerCountUpdated: (int) viewers;
@end

/**
 * \anchor BambuserPlayer
 * This is the main class for using the player library.
 */
@interface BambuserPlayer : UIView {
}

/**
 * Set this to the object that conforms to the BambuserPlayerDelegate protocol, to receive updates about playback.
 */
@property (nonatomic, weak) id <BambuserPlayerDelegate> delegate;
/**
 * \anchor resourceUri
 * Contains the broadcastId for the currently loaded broadcast.
 */
@property (nonatomic) NSString *resourceUri;
/**
 * \anchor playerApplicationId
 * Contains the Iris Application ID necessary to make authorized requests.
 */
@property (nonatomic, retain, setter = setApplicationId:, getter = applicationId) NSString *applicationId;
/**
 * \anchor requiredBroadcastState
 * Setting this requires the broadcast to be in a specific state for playback.
 */
@property (nonatomic) enum BroadcastState requiredBroadcastState;
/**
 * \anchor status
 * This property reflects the current state of playback.
 */
@property (nonatomic, readonly) enum BambuserPlayerState status;
/**
 * \anchor playbackPosition
 * This property reflects the current playback position.
 */
@property (nonatomic, readonly, getter = playbackPosition) double playbackPosition;
/**
 * \anchor live
 * This boolean property indicates whether the broadcast loaded for playback is currently live or not.
 * Live broadcasts cannot be paused nor seeked in.
 */
@property (nonatomic, readonly) BOOL live;
/**
 * \anchor VODControlsEnabled
 * This boolean property indicates whether or not system controls should be displayed when doing playback of archived broadcasts.
 */
@property (nonatomic, setter = setVODControlsEnabled:) BOOL VODControlsEnabled;
/**
 * \anchor timeShiftModeEnabled
 * This boolean property is used to request that seeking is enabled during a live broadcast.
 * The value default is NO, as the timeshift mode has trade-offs: it adds additional latency, and
 * is mainly suited for broadcasts with reasonable duration. This should only be enabled if
 * seeking in live content is actually required.
 * Note: This property can only be changed before calling playVideo:
 */
@property (nonatomic, setter = setTimeShiftModeEnabled:) BOOL timeShiftModeEnabled NS_AVAILABLE_IOS(8_0);
/**
 * \anchor seekableStart
 * This property holds the earliest possible position to seek to in timeshift mode.
 * This property will return a negative value if not available.
 */
@property (nonatomic, readonly) double seekableStart NS_AVAILABLE_IOS(8_0);
/**
 * \anchor seekableEnd
 * This property holds the latest possible position to seek to in timeshift mode.
 * This property will return a negative value if not available.
 */
@property (nonatomic, readonly) double seekableEnd NS_AVAILABLE_IOS(8_0);
/**
 * This float adjusts the volume of playback. Set in the range 0.0 to 1.0.
 *
 * Note: This property only has an effect on iOS 8.0 and newer.
 */
@property (nonatomic, setter = setVolume:) float volume NS_AVAILABLE_IOS(8_0);

/**
 * Used to initialise the BambuserPlayer view.
 */
- (id) init;
/**
 * \anchor playVideoWithResourceUri
 * Request the BambuserPlayer to start playing a broadcast with the supplied resource uri,
 * which is a signed URI received from the Iris Metadata API.
 * @param resourceUri The resource uri associated with the broadcast to be loaded.
 */
- (void) playVideo: (NSString*) resourceUri;
/**
 * \anchor stopVideo
 * Stops playback of broadcast.
 */
- (void) stopVideo;
/**
 * \anchor pauseVideo
 * Pauses playback of broadcast.
 *
 * Note: For live broadcasts, this will behave in the same manner as stopVideo.
 */
- (void) pauseVideo;
/**
 * \anchor playVideo
 * Resume playback of a video that has been paused. This only works
 * for non-live videos; for live videos, playback must be requested
 * via the #playVideo: method.
 */
- (void) playVideo;
/**
 * \anchor seekTo
 * Seek archived broadcast to supplied time (in seconds).
 */
- (void) seekTo: (double) time;

// Deprecated accessors
/// @cond
- (NSString*) getApplicationId DEPRECATED_MSG_ATTRIBUTE("Replaced by applicationId");
- (double) getPlaybackPosition DEPRECATED_MSG_ATTRIBUTE("Replaced by playbackPosition");
/// @endcond
@end
