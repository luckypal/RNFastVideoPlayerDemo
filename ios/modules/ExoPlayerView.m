//
//  ExoPlayerView.m
//  MyDemo
//
//  Created by Lucky on 2/16/21.
//

#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <React/RCTBridgeModule.h>
 
@interface RCT_EXTERN_MODULE(RCTExoPlayerViewManager, RCTViewManager)
 RCT_EXPORT_VIEW_PROPERTY(index, NSNumber)
 RCT_EXPORT_VIEW_PROPERTY(urls, NSArray<NSString *>)
 RCT_EXPORT_VIEW_PROPERTY(onEventSent, RCTBubblingEventBlock)

 RCT_EXTERN_METHOD(prevVideo:(nonnull NSNumber *)reactTag)
 RCT_EXTERN_METHOD(nextVideo:(nonnull NSNumber *)reactTag)
@end

