import 'package:flutter/material.dart';

class AppOfflineBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool isRetrying;

  const AppOfflineBanner({
    super.key,
    this.message = 'Menampilkan data offline / sinyal lemah',
    this.onRetry,
    this.isRetrying = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4D6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE9C76A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.signal_wifi_off, size: 16, color: Color(0xFF8A5A00)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: Color(0xFF8A5A00)),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 4),
            TextButton(
              onPressed: isRetrying ? null : onRetry,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF8A5A00),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: isRetrying
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Coba Lagi'),
            ),
          ],
        ],
      ),
    );
  }
}

class AppPageSkeleton extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double itemWidth;
  final double spacing;

  const AppPageSkeleton({
    super.key,
    this.itemCount = 3,
    this.itemHeight = 80,
    this.itemWidth = double.infinity,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == itemCount - 1 ? 0 : spacing,
          ),
          child: Container(
            width: itemWidth,
            height: itemHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
          ),
        );
      }),
    );
  }
}

class AppErrorState extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback? onRetry;

  const AppErrorState({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel = 'Coba Lagi',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC2C6D4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.signal_wifi_connected_no_internet_4,
            color: Color(0xFFB3261E),
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF141D23),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF424752)),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: 180,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003F87),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(actionLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
