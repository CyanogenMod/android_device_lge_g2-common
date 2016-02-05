/*
 * Copyright (C) 2016 The CyanogenMod Project
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
import android.os.Message;
import android.os.Parcel;

/**
 * Custom Qualcomm RIL for G2
 *
 * {@hide}
 */
public class LgeLteRIL extends RIL implements CommandsInterface {

    private static final int LGE_RIL_REQUEST_MAX = 161;
    private static final int LGE_RIL_REQUEST_ALLOW_DATA = 150;
    private static final int LGE_RIL_REQUEST_GET_HARDWARE_CONFIG = 151;
    private static final int LGE_RIL_REQUEST_SIM_AUTHENTICATION = 152;
    private static final int LGE_RIL_REQUEST_SHUTDOWN = 153;
    private static final int LGE_RIL_REQUEST_GET_RADIO_CAPABILITY = LGE_RIL_REQUEST_MAX + 1;

    public LgeLteRIL(Context context, int preferredNetworkType, int cdmaSubscription) {
        super(context, preferredNetworkType, cdmaSubscription, null);
    }

    public LgeLteRIL(Context context, int preferredNetworkType,
            int cdmaSubscription, Integer instanceId) {
        super(context, preferredNetworkType, cdmaSubscription, instanceId);
    }

    @Override
    protected Object
    responseFailCause(Parcel p) {
        int numInts;
        int response[];

        numInts = p.readInt();
        response = new int[numInts];
        for (int i = 0 ; i < numInts ; i++) {
            response[i] = p.readInt();
        }
        LastCallFailCause failCause = new LastCallFailCause();
        failCause.causeCode = response[0];
        if (p.dataAvail() > 0) {
          failCause.vendorCause = p.readString();
        }
        return failCause;
    }

    @Override
    public void
    setDataAllowed(boolean allowed, Message result) {
        RILRequest rr = RILRequest.obtain(LGE_RIL_REQUEST_ALLOW_DATA, result);
        if (RILJ_LOGD) {
            riljLog(rr.serialString() + "> " + requestToString(rr.mRequest) +
                    " allowed: " + allowed);
        }

        rr.mParcel.writeInt(1);
        rr.mParcel.writeInt(allowed ? 1 : 0);
        send(rr);
    }

    @Override
    public void
    getHardwareConfig(Message result) {
        RILRequest rr = RILRequest.obtain(LGE_RIL_REQUEST_GET_HARDWARE_CONFIG, result);

        if (RILJ_LOGD) riljLog(rr.serialString() + "> " + requestToString(rr.mRequest));

        send(rr);
    }

    @Override
    public void
    requestShutdown(Message result) {
        RILRequest rr = RILRequest.obtain(LGE_RIL_REQUEST_SHUTDOWN, result);

        if (RILJ_LOGD)
            riljLog(rr.serialString() + "> " + requestToString(rr.mRequest));

        send(rr);
    }

    @Override
    public void
    requestIccSimAuthentication(int authContext, String data, String aid,
            Message response) {
        RILRequest rr = RILRequest.obtain(LGE_RIL_REQUEST_SIM_AUTHENTICATION, response);

        rr.mParcel.writeInt(authContext);
        rr.mParcel.writeString(data);
        rr.mParcel.writeString(aid);

        if (RILJ_LOGD) riljLog(rr.serialString() + "> " + requestToString(rr.mRequest));

        send(rr);
    }

    @Override
    public void getRadioCapability(Message response) {
        riljLog("getRadioCapability: returning static radio capability");
        if (response != null) {
            Object ret = makeStaticRadioCapability();
            AsyncResult.forMessage(response, ret, null);
            response.sendToTarget();
        }
    }

    @Override
    protected RILRequest
    processSolicited(Parcel p) {
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
                    try {
                        switch (tr.mRequest) {
                            /* Get those we're interested in */
                            case LGE_RIL_REQUEST_ALLOW_DATA:
                            case LGE_RIL_REQUEST_GET_HARDWARE_CONFIG:
                            case LGE_RIL_REQUEST_SIM_AUTHENTICATION:
                            case LGE_RIL_REQUEST_SHUTDOWN:
                            case LGE_RIL_REQUEST_GET_RADIO_CAPABILITY:
                                rr = tr;
                                break;
                        }
                    } catch (Throwable thr) {
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
            /* Nothing we care about, return to original parcel position */
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
                case LGE_RIL_REQUEST_ALLOW_DATA: ret = responseVoid(p); break;
                case LGE_RIL_REQUEST_GET_HARDWARE_CONFIG: ret = responseHardwareConfig(p); break;
                case LGE_RIL_REQUEST_SIM_AUTHENTICATION: ret = responseICC_IOBase64(p); break;
                case LGE_RIL_REQUEST_SHUTDOWN: setRadioState(RadioState.RADIO_UNAVAILABLE); break;
                case LGE_RIL_REQUEST_GET_RADIO_CAPABILITY: ret = makeStaticRadioCapability(); error = 0; break;
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
}
