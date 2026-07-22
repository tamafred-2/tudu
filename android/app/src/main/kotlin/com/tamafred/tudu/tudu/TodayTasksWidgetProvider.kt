package com.tamafred.tudu.tudu

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class TodayTasksWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.widget_today_tasks)

            try {
                val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val pendingCount = prefs.getInt("flutter.widget_pending_count", 0)
                val topTasksStr = prefs.getString("flutter.widget_top_tasks", "") ?: ""

                views.setTextViewText(R.id.widget_pending_badge, "$pendingCount Pending")

                if (topTasksStr.isNotEmpty()) {
                    views.setTextViewText(R.id.widget_tasks_preview, topTasksStr)
                } else {
                    views.setTextViewText(R.id.widget_tasks_preview, "No pending tasks for today! ✨")
                }
            } catch (e: Exception) {
                views.setTextViewText(R.id.widget_pending_badge, "0 Pending")
                views.setTextViewText(R.id.widget_tasks_preview, "Tudu — Focus on today!")
            }

            // Launch MainActivity when tapping widget
            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_tasks_preview, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
