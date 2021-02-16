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
  UIManager,
  findNodeHandle
} from 'react-native';
// import RNFS from 'react-native-fs';
import convertToProxyURL, { convertAndStartDownloadAsync } from 'react-native-video-cache';
import ExoPlayer from './src/ExoPlayer';
import { videoUrls } from './src/files';

const { width, height } = Dimensions.get("window");

var styles = StyleSheet.create({
  back: {
    width,
    height
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
    bottom: 100
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
  },
  text: {
    fontSize: 30,
    color: '#fff'
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
    UIManager.dispatchViewManagerCommand(
      this.getVideoViewHandle(),
      index > 0 ? 'nextVideo' : 'prevVideo',
      []
    );
    this.setState({
      index: this.state.index + 1
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

  onEventSent = (event) => {
    console.log('Event', event.nativeEvent);
  }

  render() {
    const urls = videoUrls.map(url => convertToProxyURL(url));
    const { index } = this.state;

    console.log('Render', index);

    return (
      <SafeAreaView>
        <StatusBar translucent hidden />
        <View style={styles.back}>
          <ExoPlayer
            style={{ flex: 1, width: '100%', height: '100%' }}
            urls={urls}
            index={index}
            ref={(ref) => { this.videoView = ref; }}
            onEventSent={this.onEventSent}
          />
        </View>
        <View style={styles.controls}>
          <Text style={styles.text}>{index}</Text>
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
