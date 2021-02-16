import PropTypes from 'prop-types';
import { requireNativeComponent, ViewPropTypes } from 'react-native';

var viewProps = {
  name: 'ExoPlayer',
  propTypes: {
    url: PropTypes.string,
    ...ViewPropTypes,
  }
}


export default requireNativeComponent('ExoPlayer', viewProps);