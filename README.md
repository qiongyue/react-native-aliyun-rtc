# react-native-aliyun-rtc

React Native接入阿里云音视频通信 RTC（Real-Time Communication）

## Installation

```sh
npm install react-native-aliyun-rtc
```

## Usage

```js
import React, { Component } from 'react';
import { View, Image, Text, Dimensions } from 'react-native';
import * as Permissions from 'expo-permissions';

import { AliyunRtcView } from 'react-native-aliyun-rtc';

// ...
const height = Dimensions.get('window').height;
const width = Dimensions.get('window').width;

class Rtc extends Component {
  constructor(props) {
    super(props)

    this.state = {
      publishBtnTitle: '开始',
      isPublish: false, // 是否直播中
      granted : false,

      status : false,
    }
  }

  async componentDidMount() {
    await this.requestCameraPermission() // 权限要求

    // this.onStart() // 自动开始！
  }

  componentWillUnmount() {
    // 退出处理
    // if (this.vp) {
    //   this.vp.stop()
    // }
  }

  async requestCameraPermission() {
    try {
      const { status } = await Permissions.askAsync(Permissions.CAMERA, Permissions.AUDIO_RECORDING)

      if (status === 'granted') {
        this.setState({
          granted: true,
        })

        console.log("permission granted");
      } else {
        // alert('提示', '需授权使用摄像头和麦克风才能使用直播功能')
      }
    } catch (err) {
      console.warn(err);
    }
  }

  // 摄向头转向控制
  onSwitchCamera = ()=> {
    if (this.vb) this.vb.switchCamera()
  }

  startPreview = () => {
    const { info } = this.props

    if (!info.params) return ;

    if (this.rtc) {
      this.rtc.startPreview();
      this.rtc.joinBegin();
    }

    this.setState({ status: true });
  }

  stopPreview = () => {
    if (this.rtc) {
      // rtc.stopPreview();
      this.rtc.leaveChannel();
    }

    this.setState({ status: false });
  }

  defaultView = () => {
    return (
      <View style={[commonStyle.flex_column_center_center, styles.bg_body_black]}>
        <Text style={[commonStyle.font_size_18, commonStyle.font_color_white]}>请开启摄像头权限</Text>
      </View>
    );
  }

  setRef = (vb) => {
    this.vb = vb;
    this.props.setRtcRef(vb)
  }

  render() {
    if (typeof(AliyunRtcView) === "undefined") return this.defaultView()

    if (this.state.granted !== true) return null; // 未开启权限

    // const { memberInfo={} } = this.props
    // 以下配置数据是后端App Server通过接口获取
    const memberInfo = {
        AppID : appid,
        userID : userid,
        channelID : channelId,
        nonce : nonce,
        timestamp : timestamp,
        token : token,
        GSLB : ['https://rgslb.rtc.aliyuncs.com'],
        agent : agent, //来源
        
        userName : 'xx', //用户名，平台自定义
    }

    return (
      <AliyunRtcView
        style={{ width, height }}
        settings={memberInfo ? memberInfo.params : {}}

        ref={(vb) => this.setRef(vb)}
      />
    );
  }
}

export default Rtc;


```


## License

Apache License

