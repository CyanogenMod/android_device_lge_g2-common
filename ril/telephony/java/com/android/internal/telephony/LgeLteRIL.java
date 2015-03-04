/*
 * Copyright (C) 2012 The CyanogenMod Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.android.internal.telephony;

import static com.android.internal.telephony.RILConstants.*;

import android.content.Context;
import android.os.AsyncResult;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.os.Message;
import android.os.Parcel;
import android.os.SystemProperties;
import android.telephony.Rlog;
import android.telephony.SmsMessage;
import android.telephony.SignalStrength;
import android.text.TextUtils;
import android.util.Log;

import com.android.internal.telephony.RILConstants;
import com.android.internal.telephony.gsm.SmsBroadcastConfigInfo;
import com.android.internal.telephony.cdma.CdmaInformationRecords;

import com.android.internal.telephony.dataconnection.DataCallResponse;
import com.android.internal.telephony.dataconnection.DcFailCause;

import com.android.internal.telephony.uicc.IccCardApplicationStatus;
import com.android.internal.telephony.uicc.IccCardStatus;

import java.util.ArrayList;

/**
 * Custom Qualcomm No SimReady RIL using the latest Uicc stack
 *
 * {@hide}
 */
public class LgeLteRIL extends RIL implements CommandsInterface {
    protected HandlerThread mIccThread;
    protected IccHandler mIccHandler;
    protected String mAid;
    protected boolean mUSIM = false;
    protected String[] mLastDataIface = new String[20];
    boolean RILJ_LOGV = true;
    boolean RILJ_LOGD = true;

    private final int RIL_INT_RADIO_OFF = 0;
    private final int RIL_INT_RADIO_UNAVALIABLE = 1;
    private final int RIL_INT_RADIO_ON = 2;
    private final int RIL_INT_RADIO_ON_NG = 10;
    private final int RIL_INT_RADIO_ON_HTC = 13;
    private int mSetPreferredNetworkType = -1;
    private Message mPendingNetworkResponse;

    private boolean isGSM = false;

    public LgeLteRIL(Context context, int preferredNetworkType,
            int cdmaSubscription, Integer instanceId) {
        this(context, preferredNetworkType, cdmaSubscription);
    }

    public LgeLteRIL(Context context, int networkMode, int cdmaSubscription) {
        super(context, networkMode, cdmaSubscription);
        mSetPreferredNetworkType = -1;
        mQANElements = 5;
    }

    @Override public void
    supplyIccPin2(String pin, Message result) {
        supplyIccPin2ForApp(pin, mAid, result);
    }

    @Override public void
    changeIccPin2(String oldPin2, String newPin2, Message result) {
        changeIccPin2ForApp(oldPin2, newPin2, mAid, result);
    }

    @Override public void
    supplyIccPuk(String puk, String newPin, Message result) {
        supplyIccPukForApp(puk, newPin, mAid, result);
    }

    @Override public void
    supplyIccPuk2(String puk2, String newPin2, Message result) {
        supplyIccPuk2ForApp(puk2, newPin2, mAid, result);
    }

    @Override
    public void
    queryFacilityLock(String facility, String password, int serviceClass,
                            Message response) {
        queryFacilityLockForApp(facility, password, serviceClass, mAid, response);
    }

    @Override
    public void
    setFacilityLock (String facility, boolean lockState, String password,
                        int serviceClass, Message response) {
        setFacilityLockForApp(facility, lockState, password, serviceClass, mAid, response);
    }

    @Override
    public void
    getIMSI(Message result) {
        RILRequest rr = RILRequest.obtain(RIL_REQUEST_GET_IMSI, result);

        rr.mParcel.writeInt(1);
        rr.mParcel.writeString(mAid);

        if (RILJ_LOGD) riljLog(rr.serialString() +
                              "> getIMSI:RIL_REQUEST_GET_IMSI " +
                              RIL_REQUEST_GET_IMSI +
                              " aid: " + mAid +
                              " " + requestToString(rr.mRequest));

        send(rr);
    }

    @Override
    public void
    iccIO (int command, int fileid, String path, int p1, int p2, int p3,
            String data, String pin2, Message result) {
        //Note: This RIL request has not been renamed to ICC,
        //       but this request is also valid for SIM and RUIM
        iccIOForApp(command, fileid, path, p1, p2, p3, data, pin2, mAid, result);
    }

    @Override
    protected Object
    responseIccCardStatus(Parcel p) {
        IccCardApplicationStatus ca;

        IccCardStatus status = new IccCardStatus();
        int cardState = p.readInt();
        /* Standard stack doesn't recognize REMOVED and SIM_DETECT_INSERTED,
         * so convert them to ABSENT and PRESENT to trigger the hot-swapping 
         * check */
        if (cardState > 2) {
            cardState -= 3;
        }
        status.setCardState(cardState);
        status.setUniversalPinState(p.readInt());
        status.mGsmUmtsSubscriptionAppIndex = p.readInt();
        status.mCdmaSubscriptionAppIndex = p.readInt();
        status.mImsSubscriptionAppIndex = p.readInt();

        int numApplications = p.readInt();

        // limit to maximum allowed applications
        if (numApplications > IccCardStatus.CARD_MAX_APPS) {
            numApplications = IccCardStatus.CARD_MAX_APPS;
        }
        status.mApplications = new IccCardApplicationStatus[numApplications];

        ca = new IccCardApplicationStatus();
        for (int i = 0; i < numApplications; i++) {
            if (i != 0) {
                ca = new IccCardApplicationStatus();
            }
            ca.app_type = ca.AppTypeFromRILInt(p.readInt());
            ca.app_state = ca.AppStateFromRILInt(p.readInt());
            ca.perso_substate = ca.PersoSubstateFromRILInt(p.readInt());
            ca.aid = p.readString();
            ca.app_label = p.readString();
            ca.pin1_replaced = p.readInt();
            ca.pin1 = ca.PinStateFromRILInt(p.readInt());
            ca.pin2 = ca.PinStateFromRILInt(p.readInt());
            if (!needsOldRilFeature("skippinpukcount")) {
                p.readInt(); //remaining_count_pin1
                p.readInt(); //remaining_count_puk1
                p.readInt(); //remaining_count_pin2
                p.readInt(); //remaining_count_puk2
            }
            status.mApplications[i] = ca;
        }
        // for sprint gsm(lte) only sim
        if (numApplications==1 && !isGSM && ca.app_type == ca.AppTypeFromRILInt(2)) {
            status.mApplications = new IccCardApplicationStatus[numApplications+2];
            status.mGsmUmtsSubscriptionAppIndex = 0;
            status.mApplications[status.mGsmUmtsSubscriptionAppIndex]=ca;
            status.mCdmaSubscriptionAppIndex = 1;
            status.mImsSubscriptionAppIndex = 2;
            IccCardApplicationStatus ca2 = new IccCardApplicationStatus();
            ca2.app_type       = ca2.AppTypeFromRILInt(4); // csim state
            ca2.app_state      = ca.app_state;
            ca2.perso_substate = ca.perso_substate;
            ca2.aid            = ca.aid;
            ca2.app_label      = ca.app_label;
            ca2.pin1_replaced  = ca.pin1_replaced;
            ca2.pin1           = ca.pin1;
            ca2.pin2           = ca.pin2;
            status.mApplications[status.mCdmaSubscriptionAppIndex] = ca2;
            IccCardApplicationStatus ca3 = new IccCardApplicationStatus();
            ca3.app_type       = ca3.AppTypeFromRILInt(5); // ims state
            ca3.app_state      = ca.app_state;
            ca3.perso_substate = ca.perso_substate;
            ca3.aid            = ca.aid;
            ca3.app_label      = ca.app_label;
            ca3.pin1_replaced  = ca.pin1_replaced;
            ca3.pin1           = ca.pin1;
            ca3.pin2           = ca.pin2;
            status.mApplications[status.mImsSubscriptionAppIndex] = ca3;
        }

        int appIndex = -1;
        if (mPhoneType == RILConstants.CDMA_PHONE &&
             status.mCdmaSubscriptionAppIndex >= 0) {
            appIndex = status.mCdmaSubscriptionAppIndex;
            Rlog.d(RILJ_LOG_TAG, "This is a CDMA PHONE " + appIndex);
        } else {
            appIndex = status.mGsmUmtsSubscriptionAppIndex;
            Rlog.d(RILJ_LOG_TAG, "This is a GSM PHONE " + appIndex);
        }

        if (cardState == 0) { // CardState.CARDSTATE_ABSENT
            return status;
        }

        if (numApplications > 0) {
            IccCardApplicationStatus application = status.mApplications[appIndex];
            mAid = application.aid;
            mUSIM = application.app_type
                      == IccCardApplicationStatus.AppType.APPTYPE_USIM;
            mSetPreferredNetworkType = mPreferredNetworkType;

            if (TextUtils.isEmpty(mAid))
               mAid = "";
            Rlog.d(RILJ_LOG_TAG, "mAid " + mAid);
        }

        return status;
    }

    @Override
    public void setPhoneType(int phoneType){
        super.setPhoneType(phoneType);
        isGSM = (phoneType != RILConstants.CDMA_PHONE);
    }

    /*
    @Override
    protected DataCallResponse getDataCallResponse(Parcel p, int version) {
        DataCallResponse dataCall = new DataCallResponse();

        boolean oldRil = needsOldRilFeature("datacall");

        if (!oldRil && version < 5) {
            return super.getDataCallResponse(p, version);
        } else if (!oldRil) {
            dataCall.version = version;
            dataCall.status = p.readInt();
            dataCall.suggestedRetryTime = p.readInt();
            dataCall.cid = p.readInt();
            dataCall.active = p.readInt();
            dataCall.type = p.readString();
            dataCall.ifname = p.readString();
            if ((dataCall.status == DcFailCause.NONE.getErrorCode()) &&
                    TextUtils.isEmpty(dataCall.ifname) && dataCall.active != 0) {
              throw new RuntimeException("getDataCallResponse, no ifname");
            }
            String addresses = p.readString();
            if (!TextUtils.isEmpty(addresses)) {
                dataCall.addresses = addresses.split(" ");
            }
            String dnses = p.readString();
            if (!TextUtils.isEmpty(dnses)) {
                dataCall.dnses = dnses.split(" ");
            }
            String gateways = p.readString();
            if (!TextUtils.isEmpty(gateways)) {
                dataCall.gateways = gateways.split(" ");
            }
        } else {
            dataCall.version = 4; // was dataCall.version = version;
            dataCall.cid = p.readInt();
            dataCall.active = p.readInt();
            dataCall.type = p.readString();
            dataCall.ifname = mLastDataIface[dataCall.cid];
            p.readString(); // skip APN

            if (TextUtils.isEmpty(dataCall.ifname)) {
                dataCall.ifname = mLastDataIface[0];
            }

            String addresses = p.readString();
            if (!TextUtils.isEmpty(addresses)) {
                dataCall.addresses = addresses.split(" ");
            }
            p.readInt(); // RadioTechnology
            p.readInt(); // inactiveReason

            dataCall.dnses = new String[2];
            dataCall.dnses[0] = SystemProperties.get("net."+dataCall.ifname+".dns1");
            dataCall.dnses[1] = SystemProperties.get("net."+dataCall.ifname+".dns2");
        }

        return dataCall;
    }*/

    @Override
    public void getNeighboringCids(Message response) {
        if (!getRadioState().isOn())
            return;

        RILRequest rr = RILRequest.obtain(
                RILConstants.RIL_REQUEST_GET_NEIGHBORING_CELL_IDS, response);

        if (RILJ_LOGD) riljLog(rr.serialString() + "> " + requestToString(rr.mRequest));

        send(rr);
    }

    @Override
    public void setPreferredNetworkType(int networkType , Message response) {
        /**
          * If not using a USIM, ignore LTE mode and go to 3G
          */
        if (!mUSIM && networkType == RILConstants.NETWORK_MODE_LTE_GSM_WCDMA &&
                 mSetPreferredNetworkType >= RILConstants.NETWORK_MODE_WCDMA_PREF) {
            networkType = RILConstants.NETWORK_MODE_WCDMA_PREF;
        }
        mSetPreferredNetworkType = networkType;

        super.setPreferredNetworkType(networkType, response);
    }

    @Override
    protected Object
    responseSignalStrength(Parcel p) {
        int numInts = 12;
        int response[];

        boolean oldRil = needsOldRilFeature("signalstrength");
        boolean noLte = false;

        /* TODO: Add SignalStrength class to match RIL_SignalStrength */
        response = new int[numInts];
        for (int i = 0 ; i < numInts ; i++) {
            if ((oldRil || noLte) && i > 6 && i < 12) {
                response[i] = -1;
            } else {
                response[i] = p.readInt();
            }
            if (i == 7 && response[i] == 99) {
                response[i] = -1;
                noLte = true;
            }
        }
        return new SignalStrength(response[0], response[1], response[2], response[3], response[4], response[5], response[6], response[7],response[8], response[9], response[10], response[11], true);
    }

    @Override
    protected void
    processUnsolicited (Parcel p) {
        Object ret;
        int dataPosition = p.dataPosition(); // save off position within the Parcel
        int response = p.readInt();

        /* Assume devices needing the "datacall" GB-compatibility flag are
         * running GB RILs, so skip 1031-1034 for those */
        if (needsOldRilFeature("datacall")) {
            switch(response) {
                 case 1031:
                 case 1032:
                 case 1033:
                 case 1034:
                     ret = responseVoid(p);
                     return;
            }
        }

        switch(response) {
            //case RIL_UNSOL_RESPONSE_RADIO_STATE_CHANGED: ret =  responseVoid(p); break;
            case RIL_UNSOL_RIL_CONNECTED: ret = responseInts(p); break;
            case 1035: ret = responseVoid(p); break; // RIL_UNSOL_VOICE_RADIO_TECH_CHANGED
            case 1036: ret = responseVoid(p); break; // RIL_UNSOL_RESPONSE_IMS_NETWORK_STATE_CHANGED
            case 1037: ret = responseVoid(p); break; // RIL_UNSOL_EXIT_EMERGENCY_CALLBACK_MODE
            case 1038: ret = responseVoid(p); break; // RIL_UNSOL_DATA_NETWORK_STATE_CHANGED

            default:
                // Rewind the Parcel
                p.setDataPosition(dataPosition);

                // Forward responses that we are not overriding to the super class
                super.processUnsolicited(p);
                return;
        }

        switch(response) {
            case RIL_UNSOL_RESPONSE_RADIO_STATE_CHANGED:
                int state = p.readInt();
                setRadioStateFromRILInt(state);
                break;
            case RIL_UNSOL_RIL_CONNECTED:
                if (RILJ_LOGD) unsljLogRet(response, ret);

                notifyRegistrantsRilConnectionChanged(((int[])ret)[0]);
                break;
            case 1035:
            case 1036:
                break;
            case 1037: // RIL_UNSOL_EXIT_EMERGENCY_CALLBACK_MODE
                if (RILJ_LOGD) unsljLogRet(response, ret);

                if (mExitEmergencyCallbackModeRegistrants != null) {
                    mExitEmergencyCallbackModeRegistrants.notifyRegistrants(
                                        new AsyncResult (null, null, null));
                }
                break;
            case 1038:
                break;
        }
    }

    private void setRadioStateFromRILInt (int stateCode) {
        CommandsInterface.RadioState radioState;
        HandlerThread handlerThread;
        Looper looper;
        IccHandler iccHandler;

        switch (stateCode) {
            case RIL_INT_RADIO_OFF:
                radioState = CommandsInterface.RadioState.RADIO_OFF;
                if (mIccHandler != null) {
                    mIccThread = null;
                    mIccHandler = null;
                }
                break;
            case RIL_INT_RADIO_UNAVALIABLE:
                radioState = CommandsInterface.RadioState.RADIO_UNAVAILABLE;
                break;
            case RIL_INT_RADIO_ON:
            case RIL_INT_RADIO_ON_NG:
            case RIL_INT_RADIO_ON_HTC:
                if (mIccHandler == null) {
                    handlerThread = new HandlerThread("IccHandler");
                    mIccThread = handlerThread;

                    mIccThread.start();

                    looper = mIccThread.getLooper();
                    mIccHandler = new IccHandler(this,looper);
                    mIccHandler.run();
                }
                radioState = CommandsInterface.RadioState.RADIO_ON;
                break;
            default:
                throw new RuntimeException("Unrecognized RIL_RadioState: " + stateCode);
        }

        setRadioState (radioState);
    }

    class IccHandler extends Handler implements Runnable {
        private static final int EVENT_RADIO_ON = 1;
        private static final int EVENT_ICC_STATUS_CHANGED = 2;
        private static final int EVENT_GET_ICC_STATUS_DONE = 3;
        private static final int EVENT_RADIO_OFF_OR_UNAVAILABLE = 4;

        private RIL mRil;
        private boolean mRadioOn = false;

        public IccHandler (RIL ril, Looper looper) {
            super (looper);
            mRil = ril;
        }

        public void handleMessage (Message paramMessage) {
            switch (paramMessage.what) {
                case EVENT_RADIO_ON:
                    mRadioOn = true;
                    Rlog.d(RILJ_LOG_TAG, "Radio on -> Forcing sim status update");
                    sendMessage(obtainMessage(EVENT_ICC_STATUS_CHANGED));
                    break;
                case EVENT_GET_ICC_STATUS_DONE:
                    AsyncResult asyncResult = (AsyncResult) paramMessage.obj;
                    if (asyncResult.exception != null) {
                        Rlog.e (RILJ_LOG_TAG, "IccCardStatusDone shouldn't return exceptions!", asyncResult.exception);
                        break;
                    }
                    IccCardStatus status = (IccCardStatus) asyncResult.result;
                    if (status.mApplications == null || status.mApplications.length == 0) {
                        if (!mRil.getRadioState().isOn()) {
                            break;
                        }

                        mRil.setRadioState(CommandsInterface.RadioState.RADIO_ON);
                    } else {
                        int appIndex = -1;
                        if (mPhoneType == RILConstants.CDMA_PHONE &&
                               status.mCdmaSubscriptionAppIndex >= 0) {
                            appIndex = status.mCdmaSubscriptionAppIndex;
                            Rlog.d(RILJ_LOG_TAG, "This is a CDMA PHONE " + appIndex);
                        } else {
                            appIndex = status.mGsmUmtsSubscriptionAppIndex;
                            Rlog.d(RILJ_LOG_TAG, "This is a GSM PHONE " + appIndex);
                        }

                        IccCardApplicationStatus application = status.mApplications[appIndex];
                        IccCardApplicationStatus.AppState app_state = application.app_state;
                        IccCardApplicationStatus.AppType app_type = application.app_type;

                        switch (app_state) {
                            case APPSTATE_PIN:
                            case APPSTATE_PUK:
                                switch (app_type) {
                                    case APPTYPE_SIM:
                                    case APPTYPE_USIM:
                                    case APPTYPE_RUIM:
                                        mRil.setRadioState(CommandsInterface.RadioState.RADIO_ON);
                                        break;
                                    default:
                                        Rlog.e(RILJ_LOG_TAG, "Currently we don't handle SIMs of type: " + app_type);
                                        return;
                                }
                                break;
                            case APPSTATE_READY:
                                switch (app_type) {
                                    case APPTYPE_SIM:
                                    case APPTYPE_USIM:
                                    case APPTYPE_RUIM:
                                        mRil.setRadioState(CommandsInterface.RadioState.RADIO_ON);
                                        break;
                                    default:
                                        Rlog.e(RILJ_LOG_TAG, "Currently we don't handle SIMs of type: " + app_type);
                                        return;
                                }
                                break;
                            default:
                                return;
                        }
                    }
                    break;
                case EVENT_ICC_STATUS_CHANGED:
                    if (mRadioOn) {
                        Rlog.d(RILJ_LOG_TAG, "Received EVENT_ICC_STATUS_CHANGED, calling getIccCardStatus");
                         mRil.getIccCardStatus(obtainMessage(EVENT_GET_ICC_STATUS_DONE, paramMessage.obj));
                    } else {
                         Rlog.d(RILJ_LOG_TAG, "Received EVENT_ICC_STATUS_CHANGED while radio is not ON. Ignoring");
                    }
                    break;
                case EVENT_RADIO_OFF_OR_UNAVAILABLE:
                    mRadioOn = false;
                    // disposeCards(); // to be verified;
                default:
                    Rlog.e(RILJ_LOG_TAG, " Unknown Event " + paramMessage.what);
                    break;
            }
        }

        public void run () {
            mRil.registerForIccStatusChanged(this, EVENT_ICC_STATUS_CHANGED, null);
            Message msg = obtainMessage(EVENT_RADIO_ON);
            mRil.getIccCardStatus(msg);
        }
    }

    @Override
    public void
    setNetworkSelectionModeManual(String operatorNumeric, Message response) {
        RILRequest rr
                = RILRequest.obtain(RIL_REQUEST_SET_NETWORK_SELECTION_MANUAL,
                                    response);

        if (RILJ_LOGD) riljLog(rr.serialString() + "> " + requestToString(rr.mRequest)
                    + " " + operatorNumeric);

        rr.mParcel.writeInt(2);
        rr.mParcel.writeString(operatorNumeric);
        rr.mParcel.writeString("NOCHANGE");

        send(rr);
    }

    @Override
    protected RILRequest
    processSolicited (Parcel p) {
        int serial, error;
        boolean found = false;
        int dataPosition = p.dataPosition(); // save off position within the Parcel
        serial = p.readInt();
        error = p.readInt();

        RILRequest rr = null;

        /* Pre-process the reply before popping it */
        synchronized (mRequestList) {
            RILRequest tr = mRequestList.get(serial);
            if (tr != null && tr.mSerial == serial) {
                if (error == 0 || p.dataAvail() > 0) {
                    try {switch (tr.mRequest) {
                        /* Get those we're interested in */
                        case RIL_REQUEST_DATA_REGISTRATION_STATE:
                            rr = tr;
                            break;
                    }} catch (Throwable thr) {
                        // Exceptions here usually mean invalid RIL responses
                        if (tr.mResult != null) {
                            AsyncResult.forMessage(tr.mResult, null, thr);
                            tr.mResult.sendToTarget();
                        }
                        return tr;
                    }
                }
            }
        }

        if (rr == null) {
            /* Nothing we care about, go up */
            p.setDataPosition(dataPosition);

            // Forward responses that we are not overriding to the super class
            return super.processSolicited(p);
        }


        rr = findAndRemoveRequestFromList(serial);

        if (rr == null) {
            return rr;
        }

        Object ret = null;

        if (error == 0 || p.dataAvail() > 0) {
            switch (rr.mRequest) {
                case RIL_REQUEST_DATA_REGISTRATION_STATE: ret =  dataRegState(p); break;
                default:
                    throw new RuntimeException("Unrecognized solicited response: " + rr.mRequest);
            }
            //break;
        }

        if (RILJ_LOGD) riljLog(rr.serialString() + "< " + requestToString(rr.mRequest)
            + " " + retToString(rr.mRequest, ret));

        if (rr.mResult != null) {
            AsyncResult.forMessage(rr.mResult, ret, null);
            rr.mResult.sendToTarget();
        }

        return rr;
    }

    private Object
    dataRegState(Parcel p) {
        int num;
        String response[];

        response = p.readStringArray();

        /* DANGER WILL ROBINSON
         * In the vzw variant, we're getting a "roaming" data indication
         * in the LTE response... with EHRPD as the RAT, and all the other
         * fields nulled out. Let's assume that's some weird kind of
         * stating we're out of LTE and declare it as regular service */
        if (response.length > 10 &&
            response[0].equals("5") &&
            response[2] == null &&
            response[3].equals("13") &&
            response[6] == null &&
            response[7] == null &&
            response[8] == null) {

            response[0] = "1";
        }

        return response;
    }

    /*
    @Override
    public void
    setupDataCall(String radioTechnology, String profile, String apn,
            String user, String password, String authType, String protocol,
            Message result) {

        riljLog("> getIMSI:UPDATING VSS PROFILE ");
        RILRequest rrSPT = RILRequest.obtain(
                0x88, null); // RIL_REQUEST_VSS_UPDATE_PROFILE
        rrSPT.mParcel.writeInt(1); // pdnId
        rrSPT.mParcel.writeInt(apn.length()); // apnLength
        rrSPT.mParcel.writeString(apn); // apn
        rrSPT.mParcel.writeInt(0); // ipType
        rrSPT.mParcel.writeInt(0); // inactivityTime
        rrSPT.mParcel.writeInt(1); // enable
        rrSPT.mParcel.writeInt(0); // authType
        rrSPT.mParcel.writeInt(0); // esmInfo
        rrSPT.mParcel.writeString(""); // username
        rrSPT.mParcel.writeString(""); // password
        send(rrSPT);


        super.setupDataCall(radioTechnology, profile, apn, user, password, 
                            authType, protocol, result);
    }*/

    @Override
    public void getImsRegistrationState(Message result) {
        if(mRilVersion >= 8)
            super.getImsRegistrationState(result);
        else {
            if (result != null) {
                CommandException ex = new CommandException(
                    CommandException.Error.REQUEST_NOT_SUPPORTED);
                AsyncResult.forMessage(result, null, ex);
                result.sendToTarget();
            }
        }
    }

}
