//
//  ExoPlayerView.swift
//  MyDemo
//
//  Created by Lucky on 2/16/21.
//

import UIKit
import AVFoundation

@objc (ExoPlayerView)
class ExoPlayerView: UIView {
  var _frame: CGRect? = nil;
  
  var videoItems: [AVPlayerItem] = [];
  var videoPlayer: AVQueuePlayer;
  var videoPlayerLayer: AVPlayerLayer;
  
  var playingIndex = 0;
  
  override init(frame: CGRect) {
    videoPlayer = AVQueuePlayer()
    videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
    
    super.init(frame: frame)
    initView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    videoPlayer = AVQueuePlayer()
    videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
    
    super.init(coder: aDecoder)
    initView()
  }
  
  private func initView() {
    if #available(iOS 10.0, tvOS 10.0, OSX 10.12, *) {
        videoPlayer.automaticallyWaitsToMinimizeStalling = false
    }
    
    videoPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    self.layer.addSublayer(videoPlayerLayer)
    
    NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem)
  }
  
  @objc
  func playerDidFinishPlaying(note: NSNotification) {
    playNextVideo();
  }
  
  private func initPlayerItems() {
    if (urls.count == 0) {
      return;
    }
    
    for index in 0..<urls.count {
      let videoURL = URL(string: urls[index])
      if (videoURL == nil) {
        continue;
      }
      let playerItem = AVPlayerItem(url: videoURL!)
      videoItems.append(playerItem)
    }
    
    playingIndex = 0;
    videoPlayer.insert(videoItems[0], after: nil)
    videoPlayer.play()
    
    updateVideoPlayerQueue()
  }
  
  override func reactSetFrame(_ frame: CGRect) {
    super.reactSetFrame(frame)
    _frame = frame
    videoPlayerLayer.frame = frame
    print(frame)
  }
  
  @objc var urls: [String] = [] {
    didSet {
      if (urls.count > 0) {
        self.initPlayerItems()
      }
    }
  }
  
  @objc var onEventSent: RCTBubblingEventBlock?
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let onEventSent = self.onEventSent else { return }
    
    let params: [String : Any] = ["value1":"react demo","value2":1]
    onEventSent(params)
  }
  
  func getPlayerItemFromIndex(_ index: Int) -> AVPlayerItem {
    return videoItems[(index + videoItems.count) % videoItems.count];
  }
  
  func updateVideoPlayerQueue() {
    let items = videoPlayer.items()
    if (items.count > 1) {
      for index in 1..<items.count {
        videoPlayer.remove(items[index])
      }
    }
    
    let prevItem = getPlayerItemFromIndex(playingIndex - 1)
    let nextItem = getPlayerItemFromIndex(playingIndex + 1)
    videoPlayer.insert(nextItem, after: nil)
    videoPlayer.insert(prevItem, after: nil)
  }
  
  func playNextVideo() {
    playingIndex += 1
    if (playingIndex >= urls.count) {
      playingIndex = 0;
    }
    
    videoPlayer.advanceToNextItem()
    updateVideoPlayerQueue()
    
    guard let onEventSent = self.onEventSent else { return }
    let params: [String : Any] = ["desc":"Next Video event...","index": playingIndex]
    onEventSent(params)
  }
  
  func playPrevVideo() {
    playingIndex -= 1
    if (playingIndex < 0) {
      playingIndex = urls.count - 1;
    }
    
    let items = videoPlayer.items()
    videoPlayer.remove(items[1])
    videoPlayer.advanceToNextItem()
    updateVideoPlayerQueue()
    
    guard let onEventSent = self.onEventSent else { return }
    let params: [String : Any] = ["desc":"Prev Video event...","index": playingIndex]
    onEventSent(params)
  }
}



@objc (RCTExoPlayerViewManager)
class RCTExoPlayerViewManager: RCTViewManager {
  
  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
  
  override func view() -> UIView! {
    return ExoPlayerView()
  }
  
  @objc
  func prevVideo(_ reactTag: NSNumber) {
    self.bridge.uiManager.addUIBlock { (uiManager, viewRegistry) in
      let view:ExoPlayerView = viewRegistry![reactTag] as! ExoPlayerView;
      if (!view.isKind(of: ExoPlayerView.self)) {
        print("Invalid view returned from registry, expecting RCTWebView, got: %@", view);
      } else {
        view.playPrevVideo();
      }
    }
  }
  
  @objc
  func nextVideo(_ reactTag: NSNumber) {
    self.bridge.uiManager.addUIBlock { (uiManager, viewRegistry) in
      let view:ExoPlayerView = viewRegistry![reactTag] as! ExoPlayerView;
      if (!view.isKind(of: ExoPlayerView.self)) {
        print("Invalid view returned from registry, expecting RCTWebView, got: %@", view);
      } else {
        view.playNextVideo();
      }
    }
  }
}
