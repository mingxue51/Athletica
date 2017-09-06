/*
 * libbambuser - Bambuser iOS library
 * Copyright 2013 Bambuser AB
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "BambuserViewDelegate.h"

/**
 * @mainpage Bambuser library for iOS 6.0+
 *
 * @section libbambuser Bambuser broadcasting library, libbambuser
 * The Bambuser library has the following dependencies:
 *
 * libz.tbd
 *
 * AudioToolbox, AVFoundation, CoreGraphics, CoreLocation, CoreMedia,
 * CoreVideo, Foundation, QuartzCore, SystemConfiguration, UIKit, VideoToolbox
 *
 * The VideoToolbox framework is only required from iOS 8, thus it should be
 * linked as an optional library.
 *
 * The Bambuser library also requires the C++ runtime library. If your
 * application already uses C++ directly, a C++ runtime library will
 * already be linked in, and you don't need to do anything extra. If
 * your application doesn't use C++, you need to add it manually. Add
 * libc++.tbd to the list of linked frameworks and libraries. If your
 * application needs to run on iOS versions below 7.0, add libstdc++.tbd
 * instead.
 *
 * @section libbambuserplayer Bambuser player library, libbambuserplayer
 *
 * The Bambuser player library has the following dependencies:
 *
 * MediaPlayer, AudioToolbox, AVFoundation, CoreMedia, Foundation, UIKit, AVKit
 *
 * The AVKit framework is only required from iOS 8, thus it should be
 * linked as an optional library.
 */

/**
 * \anchor BambuserView
 * This is the main class for using the broadcasting library.
 */
@interface BambuserView : UIViewController {
}

/**
 * Property for setting delegate to receive BambuserViewDelegate callbacks
 */
@property (weak) id delegate;
/**
 * \anchor applicationId
 * This property should hold your application ID. Depending on serverside setup this ID can redirect you to a suitable
 * ingest server, and automatically set your broadcasting credentials.
 *
 * This property should be set before calling #startBroadcasting.
 */
@property (nonatomic, retain, setter = setApplicationId:, getter = applicationId) NSString* applicationId;
/**
 * \anchor chatView
 * This property presents a scrollable view for displaying chat messages.
 * See documentation for UIView for styling the view with background
 * color, alpha and frame.
 */
@property (nonatomic, retain) UIView *chatView;
/**
 * \anchor settingsView
 * This property contains a view with an user interface for configuring
 * settings. The settings shown in the view can be enabled with the
 * #enableOption:enabled: method. By default, no options are enabled.
 */
@property (nonatomic, retain) UIViewController *settingsView;
/**
 * \anchor canStart
 * This property is YES if the startBroadcasting method can be called.
 * If the library is connecting or already is connected this method will
 * return NO.
 */
@property (nonatomic, readonly, getter = canStart) BOOL canStart;
/**
 * \anchor audioQualityPreset
 * This property sets the audio quality preset for the upcoming bambuser broadcast.
 * This property should not be changed during an ongoing broadcast.
 * Constants are defined in BambuserConstants.h for the possible values of this property.
 */
@property (nonatomic, setter = setAudioQualityPreset:, getter = audioQualityPreset) enum AudioQuality audioQualityPreset;
/**
 * \anchor saveOnServer
 * This property reflects the 'save on server'-option in the settings view, and can also be set and read independently of the settings view.
 * When this property is YES, the next broadcast will signal the Bambuser video server that the broadcast
 * should be available on demand when the live broadcast is over.
 * This property should not be altered during an ongoing broadcast.
 */
@property (nonatomic, setter = setSaveOnServer:, getter = saveOnServer) BOOL saveOnServer;
/**
 * \anchor saveLocally
 * This property reflects the 'save locally'-option in the settings view, and can also be set and read independently of the settings view.
 * When this property is YES, the next broadcast will also be saved to a local file. If a path is set in #localFilename, the file gets written in that path,
 * otherwise the file gets a unique filename assigned and is stored within the sandbox's NSTemporaryDirectory().
 * This property should not be altered during an ongoing broadcast.
 *
 * @see #localFilename
 * @see #BambuserViewDelegate::recordingComplete:
 */
@property (nonatomic, setter = setSaveLocally:, getter = saveLocally) BOOL saveLocally;
/**
 * \anchor setTalkback
 * This property reflects the 'talkback'-option in the settings view, and can also be set and read independently of the settings view.
 * When this property is YES, the next broadcast will signal the Bambuser video server that the client is willing to accept requests for talkback.
 * This property should not be altered during an ongoing broadcast.
 */
@property (nonatomic, setter = setTalkback:, getter = talkback) BOOL talkback;
/**
 * \anchor setLocalFilename
 * This property can be set if you want to set a specific file path when saving a local copy of your broadcast.
 * If this value is nil the local copy will be saved with a unique filename in the sandbox's NSTemporaryDirectory().
 * This property should not be altered during an ongoing broadcast.
 *
 * @see #saveLocally
 * @see #BambuserViewDelegate::recordingComplete:
 */
@property (nonatomic, retain, setter = setLocalFilename:, getter = localFilename) NSString *localFilename;
/**
 * \anchor sendPosition
 * This property reflects the 'send position'-option in the settings view, and can also be set and read independently of the settings view.
 * When this property is YES, the location of the device will be sent continuously during the next broadcast.
 * This property should not be altered during an ongoing broadcast.
 */
@property (nonatomic, setter = setSendPosition:, getter = sendPosition) BOOL sendPosition;
/**
 * \anchor privateMode
 * This property reflects the 'private mode'-option in the settings view, and can also be set and read independently of the settings view.
 * When this property is YES, the next broadcast will signal the Bambuser video server that the broadcast should be listed as private.
 * This property should not be altered during an ongoing broadcast.
 */
@property (nonatomic, setter = setPrivateMode:, getter = privateMode) BOOL privateMode;
/**
 * \anchor author
 * Contains the author field which will be associated with the broadcast.
 *
 * This can be any arbitrary string that should be associated with the
 * broadcast.
 * This property should be set before calling #startBroadcasting.
 */
@property (nonatomic, retain, setter = setAuthor:, getter = author) NSString *author;
/**
 * \anchor broadcastTitle
 * Sets the title for an upcoming broadcast, or updates the title for
 * an ongoing broadcast. This property can be altered at any time.
 */
@property (nonatomic, retain, setter = setBroadcastTitle:, getter = broadcastTitle) NSString *broadcastTitle;
/**
 * \anchor customData
 * Can be set to an arbitrary string that will be associated with the broadcast.
 *
 * This property can be set before broadcasting and updated during the broadcast.
 *
 * Note: This field is currently limited to 10000 bytes serverside.
 */
@property (nonatomic, retain, setter = setCustomData:, getter = customData) NSString *customData;
/**
 * \anchor orientation
 * This property determines the orientation the video will be recorded in.
 *
 * This property can be set to the UIInterfaceOrientation* constants from UIKit/UIApplication.h.
 * The default value is UIInterfaceOrientationLandscapeRight.
 *
 * During a broadcast, it can only be set to flipped versions of the same orientation (i.e. switching from
 * UIInterfaceOrientationLandscapeRight to UIInterfaceOrientationLandscapeLeft).
 */
@property (nonatomic, setter = setOrientation:, getter = orientation) UIInterfaceOrientation orientation;
/**
 * \anchor previewOrientation
 * This property determines the orientation of the application UI, making sure that the camera picture on the screen is rotated correctly.
 *
 * This property is read-only - setting the orientation property sets this to the same value.
 * See #setOrientation:previewOrientation: in order to change it.
 */
@property (nonatomic, readonly, getter = previewOrientation) UIInterfaceOrientation previewOrientation;
/**
 * \anchor torch
 * This property turns the LED torch on and off, if the device has one. This property can be altered at any time.
 */
@property (nonatomic, setter = setTorch:, getter = torch) BOOL torch;
/**
 * \anchor hasLedTorch
 * This readonly property will be YES if the device has an LED torch.
 */
@property (nonatomic, readonly, getter = hasLedTorch) BOOL hasLedTorch;
/**
 * \anchor hasFrontCamera
 * This readonly property will be YES if the device has a front-facing camera.
 */
@property (nonatomic, readonly, getter = hasFrontCamera) BOOL hasFrontCamera;
/**
 * \anchor health
 * This readonly property returns a value between 0 and 100, indicating the current stream health.
 *
 * A value of 0 indicates that the connection is unable to keep up with transferring all data currently being generated.
 * A value of 100 indicates that the connection is able to send all the data currently being generated.
 *
 * This method will return 0 when not broadcasting.
 */
@property (nonatomic, readonly, getter = health) int health;
/**
 * \anchor talkbackState
 * This readonly property contains the current state of talkback.
 *
 * See BambuserConstants.h for possible values.
 */
@property (nonatomic, readonly, getter = talkbackState) enum TalkbackState talkbackState;
/**
 * \anchor zoom
 * This property controls the current zoom level. Accepted values are in the range [1.0, #maxZoom].
 */
@property (nonatomic, setter = setZoom:, getter = zoom) float zoom;
/**
 * \anchor maxZoom
 * This readonly property returns the highest value accepted for the zoom property.
 *
 * A negative value indicates that the device does not support zooming.
 */
@property (nonatomic, readonly, getter = maxZoom) float maxZoom;
/**
 * \anchor framerate
 * This property allows setting the maximum capture framerate, within a range from 24 to 30 fps.
 */
@property (nonatomic, setter = setFramerate:, getter = framerate) float framerate;
/**
 * \anchor minFramerate
 * This property indicates the minimum framerate.
 *
 * This property is read-only, it can be set via #setFramerate:minFramerate:.
 */
@property (nonatomic, readonly, getter = minFramerate) float minFramerate;
/**
 * \anchor uplinkSpeed
 * This property returns the current speed in bytes per second of an ongoing or previously
 * performed uplink test.
 *
 * If an uplink test has not yet been started, 0 will be returned.
 */
@property (nonatomic, readonly, getter = uplinkSpeed) float uplinkSpeed;
/**
 * \anchor uplinkRecommendation
 * This property returns the current recommendation whether to broadcast or not, during an
 * ongoing or previously performed uplink test.
 *
 * If an uplink test has not yet been started, NO will be returned.
 */
@property (nonatomic, readonly, getter = uplinkRecommendation) BOOL uplinkRecommendation;
/**
 * \anchor maxBroadcastDimension
 * Sets the max size for any dimension when using the auto quality preset.
 *
 * This property should not be altered during a broadcast.
 * For instance, if maxBroadcastDimension is set to 640, the broadcast is limited to 640x360
 * in landscape mode, and to 360x640 in portrait mode at the default aspect ratio.
 * Set to 0 for no limiting of maximum broadcast resolution.
 */
@property (nonatomic, setter=setMaxBroadcastDimension:, getter=maxBroadcastDimension) int maxBroadcastDimension;
/**
 * \anchor previewFrame
 * Property to set a custom rectangle with the desired location and dimensions for the preview view.
 */
@property (nonatomic, setter=setPreviewFrame:, getter=previewFrame) CGRect previewFrame;
/**
 * \anchor initWithPreset
 * Used to initialise the bambuserView.
 * This method should be called with one of the kSessionPreset* video preset constants declared in BambuserConstants.h.
 *
 * @param preset Preferred kSessionPreset-value from BambuserConstants.h
 * @return Returns the BambuserView object
 */
- (id) initWithPreset: (NSString *) preset;
/**
 * \anchor startBroadcasting
 * Connects to the Bambuser video server and starts a new broadcast.
 * This method should not be called if the library is trying to connect or is already connected.
 * It is advisable to check the canStart property before calling this method.
 */
- (void) startBroadcasting;
/**
 * \anchor stopBroadcasting
 * Stops the broadcast and disconnects from the Bambuser video server.
 * This method can be called at any time.
 */
- (void) stopBroadcasting;
/**
 * \anchor displayMessage
 * Display the supplied string message in chatView.
 * @param message A string containing the message to be displayed in chatView.
 */
- (void) displayMessage: (NSString*) message;
/**
 * \anchor enableOption
 * This method enables or disables the visibility of options in the settings view. This method can be called at any time.
 * @param optionName The name of the property being enabled/disabled. The name of all properties are defined in BambuserConstants.h.
 * @param enabled Boolean to set whether or not to display the option
 */
- (void) enableOption: (NSString*) optionName enabled: (BOOL) enabled;
/**
 * \anchor setTitle
 * Sets the title for an upcoming broadcast, or updates the title for
 * an ongoing broadcast. This method can be called at any time.
 * @deprecated Set the #broadcastTitle property instead.
 * @param title The title associated with the upcoming or ongoing broadcast
 */
- (void) setTitle: (NSString*) title DEPRECATED_MSG_ATTRIBUTE("Replaced by the broadcastTitle property");
/**
 * \anchor setVideoQualityPreset
 * Sets a video quality preset for the upcoming Bambuser session. This
 * method should not be called during a broadcast.
 *
 * The only valid values for this parameter is kSessionPresetAuto.
 *
 * The preset kSessionPresetAuto will allow the video quality to dynamically be adjusted depending on the connection quality.
 *
 * The default value is kSessionPresetAuto.
 *
 * Deprecation: Some constants from AVCaptureSession.h were previously used. These are still valid for backwards compatibility.
 * @param preset A video input preset as declared in BambuserConstants.h.
 * @return YES if the session could apply the preset, otherwise NO.
 */
- (BOOL) setVideoQualityPreset: (NSString*) preset;
/**
 * \anchor setOrientation
 * Sets the preview orientation independently from the capture orientation.
 *
 * The previewOrientation parameter should be the orientation mode used for the application UI where the preview is shown.
 * This allows e.g. keeping the UI locked in one orientation while capturing in an orientation depending on how the device is held.
 */
- (void) setOrientation: (UIInterfaceOrientation) orientation previewOrientation: (UIInterfaceOrientation) previewOrientation;
/**
 * \anchor setOrientationWithAspect
 * Sets the preview orientation independently from the capture orientation.
 *
 * The previewOrientation parameter should be the orientation mode used for the application UI where the preview is shown.
 * This allows e.g. keeping the UI locked in one orientation while capturing in an orientation depending on how the device is held.
 * This method additionally takes integers for width and height, to set aspect ratio for the captured video. Note that the captured
 * video is cropped to fit this ratio, so edges of your preview might not be in the broadcast video. Vice versa, parts not visible
 * in the preview might appear in the broadcast video. To avoid this, make sure to set the preview frame to the same aspect ratio using
 * the #previewFrame property.
 */
- (void) setOrientation: (UIInterfaceOrientation) orientation previewOrientation: (UIInterfaceOrientation) previewOrientation withAspect: (int) w by: (int) h;
/**
 * \anchor setFramerate
 * This method allows setting the minimum framerate of the capture, in addition to the maximum framerate.
 *
 * The minimum framerate only affects the capture from the camera itself; the actual streamed framerate may be lower.
 * This restricts the camera, not allowing it to lower the framerate even if it would be needed to get better exposure (e.g. in low light conditions).
 */
- (void) setFramerate:(float)framerate minFramerate:(float)minFramerate;
/**
 * \anchor swapCamera
 * For devices with more than one camera this method can be used to toggle
 * between these cameras. This method can be called at any time.
 */
- (void) swapCamera;
/**
 * \anchor takeSnapshot
 * Request a snapshot be returned from the camera.
 * The resulting UIImage will be returned through the #BambuserViewDelegate::snapshotTaken: method.
 */
- (void) takeSnapshot;
/**
 * \anchor acceptTalkbackRequest
 * This method is used to accept a pending talkback request.
 * The talkbackID should previously have been supplied by the delegate protocol method #BambuserViewDelegate::talkbackRequest:caller:talkbackID:.
 * @param talkbackID The talkbackID supplied in a previous talkback request during ongoing broadcast
 */
- (void) acceptTalkbackRequest: (int) talkbackID;
/**
 * \anchor declineTalkbackRequest
 * This method is used to reject a pending talkback request.
 * The talkbackID should previously have been supplied by the delegate protocol method #BambuserViewDelegate::talkbackRequest:caller:talkbackID:.
 * @param talkbackID The talkbackID supplied in a previous talkback request during ongoing broadcast
 */
- (void) declineTalkbackRequest: (int) talkbackID;
/**
 * \anchor endTalkback
 * This method is used to end an ongoing talkback session.
 */
- (void) endTalkback;
/**
 * \anchor startLinktest
 * This method is used to manually start a linktest.
 * The result will be returned through the #BambuserViewDelegate::uplinkTestComplete:recommendation: method.
 * A valid applicationId must be set before linktests can be performed.
 */
- (void) startLinktest;

// Deprecated accessors
/// @cond
- (NSString*) getApplicationId DEPRECATED_MSG_ATTRIBUTE("Replaced by applicationId");
- (BOOL) getCanStart DEPRECATED_MSG_ATTRIBUTE("Replaced by canStart");
- (enum AudioQuality) getAudioQualityPreset DEPRECATED_MSG_ATTRIBUTE("Replaced by audioQualityPreset");
- (BOOL) getSaveOnServer DEPRECATED_MSG_ATTRIBUTE("Replaced by saveOnServer");
- (BOOL) getSaveLocally DEPRECATED_MSG_ATTRIBUTE("Replaced by saveLocally");
- (BOOL) getTalkback DEPRECATED_MSG_ATTRIBUTE("Replaced by talkback");
- (NSString*) getLocalFilename DEPRECATED_MSG_ATTRIBUTE("Replaced by localFilename");
- (BOOL) getSendPosition DEPRECATED_MSG_ATTRIBUTE("Replaced by sendPosition");
- (BOOL) getPrivateMode DEPRECATED_MSG_ATTRIBUTE("Replaced by privateMode");
- (NSString*) getAuthor DEPRECATED_MSG_ATTRIBUTE("Replaced by author");
- (NSString*) getCustomData DEPRECATED_MSG_ATTRIBUTE("Replaced by customData");
- (UIInterfaceOrientation) getOrientation DEPRECATED_MSG_ATTRIBUTE("Replaced by orientation");
- (UIInterfaceOrientation) getPreviewOrientation DEPRECATED_MSG_ATTRIBUTE("Replaced by previewOrientation");
- (BOOL) getTorch DEPRECATED_MSG_ATTRIBUTE("Replaced by torch");
- (BOOL) pollLedTorch DEPRECATED_MSG_ATTRIBUTE("Replaced by hasLedTorch");
- (BOOL) pollFrontCamera DEPRECATED_MSG_ATTRIBUTE("Replaced by hasFrontCamera");
- (int) getHealth DEPRECATED_MSG_ATTRIBUTE("Replaced by health");
- (enum TalkbackState) getTalkbackState DEPRECATED_MSG_ATTRIBUTE("Replaced by talkbackState");
- (float) getZoom DEPRECATED_MSG_ATTRIBUTE("Replaced by zoom");
- (float) getMaxZoom DEPRECATED_MSG_ATTRIBUTE("Replaced by maxZoom");
- (float) getFramerate DEPRECATED_MSG_ATTRIBUTE("Replaced by framerate");
- (float) getMinFramerate DEPRECATED_MSG_ATTRIBUTE("Replaced by minFramerate");
- (float) getUplinkSpeed DEPRECATED_MSG_ATTRIBUTE("Replaced by uplinkSpeed");
- (BOOL) getUplinkRecommendation DEPRECATED_MSG_ATTRIBUTE("Replaced by uplinkRecommendation");
/// @endcond
@end
