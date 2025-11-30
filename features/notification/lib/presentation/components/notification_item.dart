import 'package:core/core.dart';

class NotificationItem extends StatelessWidget {
  // Asumsi tipe data model Anda. Sesuaikan jika perlu.
  final dynamic notification;
  final VoidCallback onTap;

  const NotificationItem({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  // Helper untuk Warna Background Icon
  Color _getBgColor(String type) {
    switch (type) {
      case 'alert':
        return Colors.red;
      case 'transaction':
        return AppColors.sbGreen;
      case 'promo':
        return AppColors.sbOrange;
      default:
        return AppColors.sbBlue;
    }
  }

  // Helper untuk Icon
  IconData _getIcon(String type) {
    switch (type) {
      case 'alert':
        return Icons.warning_amber_rounded;
      case 'transaction':
        return Icons.shopping_bag_outlined;
      case 'promo':
        return Icons.notifications_none_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isRead = notification is Map
        ? (notification['read'] as bool? ?? false)
        : (notification.read ?? false);

    // Normalize fields for Map or model object
    final String type = notification is Map
        ? (notification['type'] as String? ?? '')
        : (notification.type as String? ?? '');
    final String title = notification is Map
        ? (notification['title'] as String? ?? '')
        : (notification.title as String? ?? '');
    final String time = notification is Map
        ? (notification['time'] as String? ?? '')
        : (notification.time as String? ?? '');
    final String message = notification is Map
        ? (notification['message'] as String? ?? '')
        : (notification.message as String? ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : Colors.blue.shade50.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead ? Colors.grey.shade200 : Colors.blue.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Box
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getBgColor(type),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _getBgColor(type).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Icon(
                        _getIcon(type),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isRead
                                      ? Colors.grey[700]
                                      : Colors.grey[900],
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.access_time,
                                      size: 10, color: Colors.grey[400]),
                                  const SizedBox(width: 4),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              fontWeight:
                                  isRead ? FontWeight.normal : FontWeight.w500,
                              color:
                                  isRead ? Colors.grey[500] : Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Red Dot Indicator
                if (!isRead)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
