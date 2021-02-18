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
    
    //    self.backgroundColor = UIColor.gray
    //    self.isUserInteractionEnabled = true
    NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem)
  }
  
  @objc
  func playerDidFinishPlaying(note: NSNotification) {
    print("Video Finished")
    nextVideo();
  }
  
  private func setupView() {
    if (urls.count == 0) {
      return;
    }
    if (playingIndex >= urls.count) {
      playingIndex = 0;
    }
    
    for index in 0..<urls.count {
      let videoURL = URL(string: urls[index])
      if (videoURL == nil) {
        continue;
      }
      let playItem = AVPlayerItem(url: videoURL!)
      videoPlayer.insert(playItem, after: nil)
    }
    
    videoPlayer.play()
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
        self.setupView()
      }
    }
  }
  
  @objc var onEventSent: RCTBubblingEventBlock?
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let onEventSent = self.onEventSent else { return }
    
    let params: [String : Any] = ["value1":"react demo","value2":1]
    onEventSent(params)
  }
  
  func nextVideo() {
    playingIndex += 1
    if (playingIndex >= urls.count) {
      return;
//      playingIndex = 0;
    }
    videoPlayer.advanceToNextItem()
    
    guard let onEventSent = self.onEventSent else { return }
    let params: [String : Any] = ["value1":"Next Video event...","value2":1]
    onEventSent(params)
  }
  
  func prevVideo() {
//    let items = videoPlayer.items();
//    playingIndex -= 1
//    if (playingIndex < 0) {
//      playingIndex = urls.count - 1;
//    }
//    setupView()
    
//    guard let onEventSent = self.onEventSent else { return }
//    let params: [String : Any] = ["value1":"Prev Video event...","value2":1]
//    onEventSent(params)
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
        view.prevVideo();
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
        view.nextVideo();
      }
    }
  }
}
