package com.mydemo.modules;

import android.media.MediaPlayer;
import android.net.Uri;
import android.util.Log;
import android.view.Surface;
import android.view.SurfaceView;
import android.widget.VideoView;

import com.facebook.infer.annotation.Assertions;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.google.android.exoplayer2.MediaItem;
import com.google.android.exoplayer2.Player;
import com.google.android.exoplayer2.SimpleExoPlayer;
import com.google.android.exoplayer2.ui.StyledPlayerControlView;
import com.google.android.exoplayer2.video.VideoListener;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;


@ReactModule(name = ExoPlayerManager.REACT_CLASS)
public class ExoPlayerManager extends SimpleViewManager<SurfaceView> {
    public static final String REACT_CLASS = "ExoPlayer";
    List<Uri> urlList = new ArrayList<>();

    private static final int SET_VIDEOINDEX = 1;

    public SimpleExoPlayer player = null;
    public SurfaceView mVideoView = null;
    public int index = 0;

    public ReactContext mContext;

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    protected SurfaceView createViewInstance(ThemedReactContext reactContext) {
        mContext = reactContext;
        SurfaceView videoView = new SurfaceView(reactContext);
        player = new SimpleExoPlayer.Builder(reactContext).build();
        player.setVideoSurfaceView(videoView);
        player.setRepeatMode(Player.REPEAT_MODE_ALL);
        mVideoView = videoView;

        player.addListener(new Player.EventListener() {
            @Override
            public void onEvents(Player player, Player.Events events) {
                if (events.contains(Player.EVENT_STATIC_METADATA_CHANGED)) sendEvent("Metadata", "Metadata is changed", null);
                else if (events.contains(Player.EVENT_MEDIA_ITEM_TRANSITION)) sendEvent("Media Item", "Item changed", null);
            }
        });
        return videoView;
    }

    @Override
    public void receiveCommand(@NonNull SurfaceView root, String commandId, @Nullable ReadableArray args) {
//        super.receiveCommand(root, commandId, args);
        Assertions.assertNotNull(mVideoView);
        switch (commandId) {
            case "nextVideo":
                player.next();
                return;
            case "prevVideo":
                player.previous();
                return;
        }
    }

    @Nullable
    @Override
    public Map<String, Object> getExportedCustomDirectEventTypeConstants() {
//        return super.getExportedCustomDirectEventTypeConstants();
        return MapBuilder.<String, Object>builder()
                .put("onEventSent", MapBuilder.of("registrationName", "onEventSent"))
                .build();
    }

    @ReactProp(name="urls")
    public void setVideoPath(SurfaceView videoView, ReadableArray urls) {
        for (int i = 0; i < urls.size(); i ++) {
            Uri uri = Uri.parse(urls.getString(i));
            MediaItem mediaItem = MediaItem.fromUri(uri);
            player.addMediaItem(mediaItem);
        }

        this.index = 0;
        playVideo();
    }

    @ReactProp(name="index")
    public void setVideoIndex(SurfaceView videoView, int index) {
        this.index = index;
        playVideo();
    }

    public void playVideo() {
        if (player.getMediaItemCount() == 0) return;

        player.prepare();
        player.play();
    }

    public void sendEvent(String key, String value, String value2) {
        WritableMap event = new WritableNativeMap();
        event.putString("type", key);
        event.putString("value", value);
        if (value2 != null) {
            event.putString("value2", value2);
        }
        ((ReactContext) mContext).getJSModule(RCTEventEmitter.class)
                .receiveEvent(mVideoView.getId(),
                        "onEventSent", event);
    }
}
