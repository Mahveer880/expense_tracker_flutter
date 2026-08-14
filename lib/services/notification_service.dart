import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'expense_tracker_channel';
  static const String channelName = 'Expense Tracker Notifications';
  static const String channelDescription = 'Expense Tracker Alerts';

  // ============================================================
  // INITIALIZE
  // ============================================================

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings);

    await notifications.initialize(settings);

    await requestPermission();
  }

  // ============================================================
  // REQUEST NOTIFICATION PERMISSION
  // ============================================================

  static Future<void> requestPermission() async {
    final androidImplementation = notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidImplementation?.requestNotificationsPermission();
  }

  // ============================================================
  // SHOW NOTIFICATION
  // ============================================================

  static Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await notifications.show(id, title, body, details);
  }

  // ============================================================
  // TEST NOTIFICATION
  // ============================================================

  static Future<void> showTestNotification() async {
    await showNotification(
      id: 1,
      title: 'Expense Tracker Pro',
      body: 'This is a test notification 🎉',
    );
  }

  // ============================================================
  // EXPENSE NOTIFICATION
  // ============================================================

  static Future<void> showExpenseNotification({
    required double amount,
    required String category,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Expense Added 💸',
      body: 'You spent Rs. ${amount.toStringAsFixed(0)} on $category.',
    );
  }

  // ============================================================
  // INCOME NOTIFICATION
  // ============================================================

  static Future<void> showIncomeNotification({
    required double amount,
    required String category,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Income Added 💰',
      body: 'You received Rs. ${amount.toStringAsFixed(0)} from $category.',
    );
  }

  // ============================================================
  // BUDGET WARNING
  // ============================================================

  static Future<void> showBudgetWarning({
    required double spent,
    required double budget,
  }) async {
    await showNotification(
      id: 100,
      title: 'Budget Warning ⚠️',
      body:
          'You have spent Rs. ${spent.toStringAsFixed(0)} '
          'of your Rs. ${budget.toStringAsFixed(0)} budget.',
    );
  }
}
