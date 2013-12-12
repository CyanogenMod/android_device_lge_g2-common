package com.cyanogenmod.settings.device;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.Preference;
import android.preference.Preference.OnPreferenceChangeListener;
import android.preference.PreferenceManager;
import android.util.Log;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

public class KnockOn implements OnPreferenceChangeListener {

    public static final String SET_KNOCKON_FILE = "/sys/devices/virtual/input/lge_touch/touch_gesture";

    @Override
    public boolean onPreferenceChange(Preference preference, Object newValue) {
        String value = ((Boolean) newValue) ? "1" : "0";
        writeValue(SET_KNOCKON_FILE, value);
        return true;
    }

    public static void restore(Context context) {
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(context);
        String value = sp.getBoolean(TouchscreenGestureSettings.KEY_KNOCKON, true) ? "1" : "0";
        writeValue(SET_KNOCKON_FILE, value);
    }

    /**
     * Write a string value to the specified file.
     * @param filename      The filename
     * @param value         The value
     */
    public static void writeValue(String filename, String value) {
        try {
            FileOutputStream fos = new FileOutputStream(new File(filename));
            fos.write(value.getBytes());
            fos.flush();
            fos.close();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
