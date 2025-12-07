import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ybs_pay/View/notification/widgets/notificationApp_bar.dart';
import 'package:ybs_pay/main.dart';
import '../../core/bloc/notificationBloc/notificationBloc.dart';
import '../../core/bloc/notificationBloc/notificationEvent.dart';
import '../../core/bloc/notificationBloc/notificationState.dart';
import '../../core/const/color_const.dart';
import '../../core/const/assets_const.dart';

class notificationScreen extends StatefulWidget {
  const notificationScreen({super.key});

  @override
  State<notificationScreen> createState() => _notificationScreenState();
}

class _notificationScreenState extends State<notificationScreen> {
  @override
  void initState() {
    super.initState();
    // Always fetch fresh data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        print('Opening notification screen, fetching data...');
        context.read<NotificationBloc>().add(const RefreshNotificationsEvent());
      }
    });
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            notification['title'] ?? 'Notification',
            style: TextStyle(
              fontSize: scrWidth*0.04,
              fontWeight: FontWeight.bold,
              color: colorConst.primaryColor1,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (notification['image'] != null)
                  Container(
                    width: double.infinity,
                    height: 200,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(
                          '${AssetsConst.apiBase}media/${notification['image']}',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Text(
                  notification['message'] ?? '',
                  style: TextStyle(fontSize: scrWidth*0.035),
                ),
                const SizedBox(height: 12),
                Text(
                  'From: ${notification['sentBy'] ?? 'System'}',
                  style: TextStyle(
                    fontSize: scrWidth*0.035,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Date: ${notification['createdAt'] ?? ''}',
                  style: TextStyle(fontSize: scrWidth*0.035, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          actions: [
            if (notification['redirectUrl'] != null)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Handle redirect URL if needed
                },
                child: Text(
                  'View Details',
                  style: TextStyle(color: colorConst.primaryColor1),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: Colors.grey[600])),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appbarInNotification(),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationsMarkedRead) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Marked ${state.updatedCount} notifications as read',
                ),
                backgroundColor: colorConst.primaryColor1,
              ),
            );
          } else if (state is NotificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          print('Notification screen state: ${state.runtimeType}');
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationsLoaded) {
            final notifications = state.notificationsResponse.notifications;

            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You\'ll see your notifications here',
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Mark all as read button
                if (state.notificationsResponse.unreadCount > 0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<NotificationBloc>().add(
                          const MarkAllNotificationsReadEvent(),
                        );
                      },
                      icon: const Icon(
                        Icons.mark_email_read,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Mark All as Read (${state.notificationsResponse.unreadCount})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorConst.primaryColor1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),

                // Notifications list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<NotificationBloc>().add(
                        const RefreshNotificationsEvent(),
                      );
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: notification.isRead
                                ? Colors.grey[50]
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: notification.isRead
                                  ? Colors.grey[300]!
                                  : colorConst.primaryColor1.withOpacity(0.3),
                              width: notification.isRead ? 1 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: notification.isRead
                                  ? Colors.grey[300]
                                  : colorConst.primaryColor1,
                              child: Icon(
                                Icons.notifications,
                                color: notification.isRead
                                    ? Colors.grey[600]
                                    : Colors.white,
                              ),
                            ),
                            title: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: scrWidth*0.035,
                                fontWeight: notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                color: notification.isRead
                                    ? Colors.grey[700]
                                    : Colors.black87,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  notification.message,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: scrWidth*0.03,
                                    color: notification.isRead
                                        ? Colors.grey[600]
                                        : Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    // Icon(
                                    //   Icons.person,
                                    //   size: 14,
                                    //   color: Colors.grey[500],
                                    // ),
                                    // const SizedBox(width: 4),
                                    // Text(
                                    //   notification.sentBy,
                                    //   style: TextStyle(
                                    //     fontSize: 12,
                                    //     color: Colors.grey[500],
                                    //   ),
                                    // ),
                                    // const SizedBox(width: 16),
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      notification.createdAt,
                                      style: TextStyle(
                                        fontSize: scrWidth*0.03,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: notification.image != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      '${AssetsConst.apiBase}media/${notification.image}',
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 60,
                                              height: 60,
                                              color: Colors.grey[200],
                                              child: Icon(
                                                Icons.image,
                                                color: Colors.grey[400],
                                              ),
                                            );
                                          },
                                    ),
                                  )
                                : null,
                            onTap: () {
                              _showNotificationDetails({
                                'title': notification.title,
                                'message': notification.message,
                                'image': notification.image,
                                'sentBy': notification.sentBy,
                                'createdAt': notification.createdAt,
                                'redirectUrl': notification.redirectUrl,
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          } else if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading notifications',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotificationBloc>().add(
                        const RefreshNotificationsEvent(),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // If we're in initial state or stuck, show retry option
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Unable to load notifications',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to retry',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<NotificationBloc>().add(
                      const RefreshNotificationsEvent(),
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
