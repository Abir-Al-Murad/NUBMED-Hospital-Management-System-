import 'package:flutter/material.dart';
import 'package:nubmed/utils/Color_codes.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Sample notification data - replace with your actual data source
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Appointment Confirmed',
      'message': 'Your appointment with Dr. Smith has been confirmed for tomorrow at 2:00 PM',
      'time': DateTime.now().subtract(const Duration(minutes: 5)),
      'read': false,
      'type': 'appointment',
    },
    {
      'title': 'Lab Results Ready',
      'message': 'Your blood test results are now available in your dashboard',
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'read': true,
      'type': 'results',
    },
    {
      'title': 'Prescription Refill',
      'message': 'Your prescription for Amoxicillin is ready for refill',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'read': true,
      'type': 'prescription',
    },
    {
      'title': 'New Message',
      'message': 'You have a new message from the Cardiology Department',
      'time': DateTime.now().subtract(const Duration(days: 3)),
      'read': false,
      'type': 'message',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _buildNotificationCard(notification, index);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 60,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final isUnread = !notification['read'];
    final icon = _getNotificationIcon(notification['type']);
    final timeAgo = _formatTimeAgo(notification['time']);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _markAsRead(index),
      child: Container(
        decoration: BoxDecoration(
          color: isUnread ? Color_codes.light_plus.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isUnread ? Color_codes.deep_plus.withOpacity(0.3) : Colors.grey.shade200,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getNotificationColor(notification['type']).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: _getNotificationColor(notification['type']),
              ),
            ),
            const SizedBox(width: 16),

            // Notification Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notification['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isUnread ? Colors.black : Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['message'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Unread indicator
            if (isUnread)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Color_codes.deep_plus,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'appointment':
        return Icons.calendar_today;
      case 'results':
        return Icons.assignment;
      case 'prescription':
        return Icons.medical_services;
      case 'message':
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'appointment':
        return Colors.blue;
      case 'results':
        return Colors.green;
      case 'prescription':
        return Color_codes.deep_plus;
      case 'message':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  void _markAsRead(int index) {
    setState(() {
      _notifications[index]['read'] = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['read'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }
}