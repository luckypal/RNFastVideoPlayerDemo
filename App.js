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
} from 'react-native';

class App extends Component {
  render() {
    return (
      <SafeAreaView>
        <StatusBar translucent hidden/>
        <View>
          <Text style={{fontSize: 30}}>Home</Text>
        </View>
      </SafeAreaView>
    );
  }
}

export default App;
