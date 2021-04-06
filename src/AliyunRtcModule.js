import React, { Component } from 'react';
import { PropTypes } from 'prop-types';
import { requireNativeComponent, View, UIManager, findNodeHandle } from 'react-native';



var RCT_VIDEO_REF = 'AliyunRtcView';

class AliyunRtcView extends Component {
    constructor(props) {
        super(props);
    }
    _onChange(event) {
        if (!this.props.onStatus) {
            return;
        }
        this.props.onStatus(event.nativeEvent.code, event.nativeEvent.msg);
    }

    
    startPreview() {
        UIManager.dispatchViewManagerCommand(
            findNodeHandle(this.refs[RCT_VIDEO_REF]),
            UIManager.getViewManagerConfig('AliyunRtc').Commands.startPreview,
            null
        );
    }

    stopPreview() {
        UIManager.dispatchViewManagerCommand(
            findNodeHandle(this.refs[RCT_VIDEO_REF]),
            UIManager.getViewManagerConfig('AliyunRtc').Commands.stopPreview,
            null
        );
    }

    switchCamera() {
        UIManager.dispatchViewManagerCommand(
            findNodeHandle(this.refs[RCT_VIDEO_REF]),
            UIManager.getViewManagerConfig('AliyunRtc').Commands.switchCamera,
            null
        );
    }

    joinBegin() {
        UIManager.dispatchViewManagerCommand(
            findNodeHandle(this.refs[RCT_VIDEO_REF]),
            UIManager.getViewManagerConfig('AliyunRtc').Commands.joinBegin,
            null
        );
    }

    leaveChannel() {
        UIManager.dispatchViewManagerCommand(
            findNodeHandle(this.refs[RCT_VIDEO_REF]),
            UIManager.getViewManagerConfig('AliyunRtc').Commands.leaveChannel,
            null
        );
    }


    render() {
        return <AliyunRtc
        {...this.props}
        ref={RCT_VIDEO_REF}
        onChange={this._onChange.bind(this)}
            />;
    };
}

AliyunRtcView.name = RCT_VIDEO_REF;
AliyunRtcView.propTypes = {
    settings: PropTypes.shape({
        AppID : PropTypes.string,
        userID: PropTypes.string,
        channelID: PropTypes.string,
        nonce : PropTypes.string,
        timestamp : PropTypes.number,
        token : PropTypes.string,
        GSLB : PropTypes.array,
        agent : PropTypes.array,
    }),
    onStatus: PropTypes.func,
    ...View.propTypes // 包含默认的View的属性
};

const AliyunRtc = requireNativeComponent('AliyunRtc', AliyunRtcView, {
    nativeOnly: { onChange: true }
});

module.exports = AliyunRtcView;
