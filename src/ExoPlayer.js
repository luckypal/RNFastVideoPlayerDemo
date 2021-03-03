import PropTypes from 'prop-types';
import { Platform, requireNativeComponent, ViewPropTypes } from 'react-native';

const componentName = Platform.select({
  android: 'ExoPlayer',
  ios: 'RCTExoPlayerView'
});

var viewProps = {
  name: componentName,
  propTypes: {
    urls: PropTypes.array,
    index: PropTypes.number,
    onEventSent: PropTypes.func,
    ...ViewPropTypes,
  }
}


export default requireNativeComponent(componentName, viewProps);