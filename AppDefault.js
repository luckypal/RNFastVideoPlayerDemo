/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow strict-local
 */

import React, { Component } from 'react';
import {
  SafeAreaView,
  View,
  Text,
  StatusBar,
  StyleSheet,
  Dimensions,
  TouchableOpacity,
  findNodeHandle
} from 'react-native';
import Video from 'react-native-video';
import convertToProxyURL, { convertAndStartDownloadAsync } from 'react-native-video-cache';
import { videoUrls } from './src/files';

const { width, height } = Dimensions.get("window");

var styles = StyleSheet.create({
  back: {
    width,
    height,
    backgroundColor: '#333'
  },
  backgroundVideo: {
    width,
    height,
    position: 'absolute',
    left: 0,
    top: 0,
    zIndex: 20
  },
  controls: {
    position: 'absolute',
    flexDirection: 'row',
    bottom: 150
  },
  btnTouch: {
    marginHorizontal: 30,
    backgroundColor: '#aaa',
    borderRadius: 4,
    padding: 3
  },
  btnText: {
    color: 'white',
    fontSize: 20
  }
});

class App extends Component {

  loadedList = {};

  state = {
    index: 0
  }

  componentDidMount() {
  }

  onEnd = () => {
    this.onNext();
  }

  onPrev = () => {
    this.onMove(-1);
  }

  onNext = () => {
    this.onMove(1);
  }

  getVideoViewHandle = () => findNodeHandle(this.videoView)

  onMove = (index) => {
    let newIndex = this.state.index + index + videoUrls.length;
    newIndex = newIndex % videoUrls.length;

    this.setState({
      index: newIndex
    });
  }

  onLoad = async () => {
    let newIndex = this.state.index + 1 + videoUrls.length;
    newIndex = newIndex % videoUrls.length;
    let videoUrl = videoUrls[newIndex];
    if (this.loadedList[videoUrl]) return;

    let cachedVideoUrl = convertToProxyURL(videoUrl);
    if (!cachedVideoUrl.startsWith('file')) {
      this.loadedList[videoUrl] = true;

      await convertAndStartDownloadAsync(videoUrl);
    }
  }

  onProgress = ({ currentTime, playableDuration }) => {
    if (currentTime >= playableDuration - 0.5) {
    }
  }

  render() {
    const urls = videoUrls.map(url => convertToProxyURL(url));
    const { index } = this.state;
    const posterUrl = 'https://d1peoxbuws2jej.cloudfront.net/character/5ba5447fb90e6a00192e15c6/a4bfbc20-ea25-4e02-9350-9d27ca5baa10-thumbnail.jpg';

    console.log('Render', index, urls[index]);

    return (
      <SafeAreaView>
        <StatusBar translucent hidden />
        <View style={styles.back}>
          <Video
            ref={ref => this.player = ref}
            source={{ uri: urls[index] }}
            style={styles.backgroundVideo}
            paused={false}
            onEnd={this.onEnd}
            resizeMode="cover"
            onLoad={this.onLoad}
            poster={posterUrl}
            posterResizeMode="cover"
            // onProgress={this.onProgress}
            // onBuffer={this.onBuffer}
            controls={false} />
        </View>
        <View style={styles.controls}>
          <TouchableOpacity style={styles.btnTouch} onPress={this.onPrev}>
            <Text style={styles.btnText}>Prev</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.btnTouch} onPress={this.onNext}>
            <Text style={styles.btnText}>Next</Text>
          </TouchableOpacity>
        </View>
      </SafeAreaView>
    );
  }
}

export default App;
