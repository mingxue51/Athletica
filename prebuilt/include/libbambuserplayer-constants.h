/*
 * libbambuser - Bambuser iOS library
 * Copyright 2016 Bambuser AB
 */

/** @file */

/**
 * \anchor BambuserPlayerState
 * Possible values of #BambuserPlayer.status.
 */
enum BambuserPlayerState {
	/// Playback is stopped
	kBambuserPlayerStateStopped = 0,
	/// Playback of the stream has been requested but not yet started
	kBambuserPlayerStateLoading = 1,
	/// Playback is in progress
	kBambuserPlayerStatePlaying = 2,
	/// Playback is paused
	kBambuserPlayerStatePaused = 3
};

/**
 * \anchor BroadcastState
 * Possible values for #BambuserPlayer.requiredBroadcastState
 */
enum BroadcastState {
	/// Any broadcast state
	kBambuserBroadcastStateAny = 0,
	/// Only live broadcasts
	kBambuserBroadcastStateLive = 1,
	/// Only archived broadcasts
	kBambuserBroadcastStateArchived = 2
};
