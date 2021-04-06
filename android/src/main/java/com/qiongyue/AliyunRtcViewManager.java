package com.qiongyue;

import android.util.Log;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.SimpleViewManager;

import java.util.ArrayList;
import java.util.Map;

import javax.annotation.Nullable;

public class AliyunRtcViewManager extends ViewGroupManager<AliyunRtcView> {
    private static final int COMMAND_START_PREVIEW_ID = 0;
    private static final String COMMAND_START_PREVIEW_NAME = "startPreview";
    private static final int COMMAND_STOP_PREVIEW_ID = 1;
    private static final String COMMAND_STOP_PREVIEW_NAME = "stopPreview";
    private static final int COMMAND_JOIN_BEGIN_ID = 2;
    private static final String COMMAND_JOIN_BEGIN_NAME = "joinBegin";
    private static final int COMMAND_LEAVE_CHANNEL_ID = 3;
    private static final String COMMAND_LEAVE_CHANNEL_NAME = "leaveChannel";
    private static final int COMMAND_SWITCH_CAMERA_ID = 4;
    private static final String COMMAND_SWITCH_CAMERA_NAME = "switchCamera";

    @Override
    public String getName() {
        return "AliyunRtc";
    }

    @Override
    public Map getExportedCustomBubblingEventTypeConstants() {
        return MapBuilder.builder()
                .put("topChange", MapBuilder.of("phasedRegistrationNames", MapBuilder.of("bubbled", "onStatus")))
                .build();
    }

    @Override
    public boolean needsCustomLayoutForChildren() {
        return true;
    }

    @Override
    protected AliyunRtcView createViewInstance(ThemedReactContext reactContext) {
        AliyunRtcView view = new AliyunRtcView(reactContext);
        return view;
    }

    @ReactProp(name = "settings")
    public void setSettings(AliyunRtcView view, ReadableMap settings) {
        if (settings == null) return ;

        // convent param
        String[] gslb = new String[1];
        ReadableArray gslbParam = settings.getArray("GSLB");
        if (gslbParam != null) {
            for (int i = 0; i < gslbParam.size(); i++) {
                gslb[i] = gslbParam.getString(i);
                break;
            }
        }

        String[] agent = new String[1];
        ReadableArray agentParam = settings.getArray("agent");
        if (agentParam != null) {
            for (int i = 0; i < agentParam.size(); i++) {
                agent[i] = agentParam.getString(i);
                break;
            }
        }

        view.setUserInfo(
                settings.getString("AppID"),
                settings.getString("nonce"),
                gslb,
                settings.getInt("timestamp"),
                settings.getString("token"),
                settings.getString("userID"),
                settings.getString("channelID"),
                agent,
                settings.getString("userName")
        );
    }


    @Nullable
    @Override
    public Map<String, Integer> getCommandsMap() {
        return MapBuilder.of(COMMAND_START_PREVIEW_NAME, COMMAND_START_PREVIEW_ID, COMMAND_STOP_PREVIEW_NAME, COMMAND_STOP_PREVIEW_ID,
                COMMAND_JOIN_BEGIN_NAME, COMMAND_JOIN_BEGIN_ID, COMMAND_LEAVE_CHANNEL_NAME, COMMAND_LEAVE_CHANNEL_ID,
                COMMAND_SWITCH_CAMERA_NAME, COMMAND_SWITCH_CAMERA_ID);
    }

    @Override
    public void receiveCommand(AliyunRtcView root, int commandId, @Nullable ReadableArray args) {
        switch (commandId) {
            case COMMAND_START_PREVIEW_ID:
                root.startPreview();
                break;
            case COMMAND_STOP_PREVIEW_ID:
                root.stopPreview();
                break;
            case COMMAND_JOIN_BEGIN_ID:
                root.joinChannel();
                break;
            case COMMAND_LEAVE_CHANNEL_ID:
                root.leaveChannel();
                break;
            case COMMAND_SWITCH_CAMERA_ID:
                root.switchCamera();
                break;
        }
    }


}
