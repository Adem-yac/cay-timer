package com.example.caytimer

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import org.json.JSONArray

/**
 * Sends the user home when they open an app whose package is listed in
 * SharedPreferences key [flutter.blocked_package_names] (JSON string array),
 * written from Flutter via [shared_preferences].
 */
class AppBlockingAccessibilityService : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        val pkg = event.packageName?.toString() ?: return
        if (pkg == packageName) return
        if (!isBlocked(pkg)) return
        performGlobalAction(GLOBAL_ACTION_HOME)
    }

    private fun isBlocked(pkg: String): Boolean {
        val prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        val json = prefs.getString("flutter.blocked_package_names", null) ?: return false
        return try {
            val arr = JSONArray(json)
            for (i in 0 until arr.length()) {
                if (arr.optString(i) == pkg) return true
            }
            false
        } catch (_: Exception) {
            false
        }
    }

    override fun onInterrupt() {}
}
