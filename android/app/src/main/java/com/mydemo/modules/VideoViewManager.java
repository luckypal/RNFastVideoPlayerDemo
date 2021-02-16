package com.mydemo.modules;

import android.media.MediaPlayer;
import android.net.Uri;
import android.util.Log;
import android.widget.VideoView;

import com.facebook.infer.annotation.Assertions;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;


@ReactModule(name = VideoViewManager.REACT_CLASS)
public class VideoViewManager extends SimpleViewManager<VideoView> {
    public static final String REACT_CLASS = "VideoView";
    List<Uri> urlList = new ArrayList<>();

    private static final int SET_VIDEOINDEX = 1;

    public VideoView mVideoView = null;
    public int index = 0;

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    protected VideoView createViewInstance(ThemedReactContext reactContext) {
        VideoView videoView = new VideoView(reactContext);
        mVideoView = videoView;
        return videoView;
    }

    @Override
    public void receiveCommand(@NonNull VideoView root, String commandId, @Nullable ReadableArray args) {
//        super.receiveCommand(root, commandId, args);
        Assertions.assertNotNull(mVideoView);
        switch (commandId) {
            case "nextVideo":
                this.index = (this.index + 1) % this.urlList.size();
                playVideo();
                return;
            case "prevVideo":
                this.index -= 1;
                if (this.index < 0) this.index = this.urlList.size() - 1;
                playVideo();
                return;
        }
    }

    @ReactProp(name="urls")
    public void setVideoPath(VideoView videoView, ReadableArray urls) {
        for (int i = 0; i < urls.size(); i ++)
            urlList.add(Uri.parse(urls.getString(i)));

        this.index = 0;
        playVideo();

        videoView.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(MediaPlayer mp) {
                onNextVideo();
            }
        });
    }

    @ReactProp(name="index")
    public void setVideoIndex(VideoView videoView, int index) {
        this.index = index;
        playVideo();
    }

    public void onNextVideo() {
        if (index < urlList.size()) index ++;

        playVideo();
    }

    public void playVideo() {
        if (urlList.size() == 0) return;

        mVideoView.setVideoURI(urlList.get(index));
        mVideoView.start();
    }
}