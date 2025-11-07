import 'package:core/core.dart';

class ReviewImageModal extends StatelessWidget {
  final String imageUrl;

  const ReviewImageModal({super.key, required this.imageUrl});

  static Future<void> show({
    required BuildContext context,
    required String imageUrl,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.95),
      builder: (context) => Center(
        child: ReviewImageModal(imageUrl: imageUrl),
      ),
    );
  }

  // ✅ fallback image jika URL kosong
  String get safeUrl {
    if (imageUrl.isEmpty) {
      return 'https://esb-order.oss-ap-southeast-5.aliyuncs.com/images/app/menu/MNU_861_20251027104452_optim.webp';
    }
    return imageUrl;
  }

  Future<ImageInfo> _getImageInfo(String url) async {
    final completer = Completer<ImageInfo>();
    final img = NetworkImage(url);

    img.resolve(const ImageConfiguration()).addListener(
          ImageStreamListener(
            (info, _) => completer.complete(info),
            onError: (err, stack) => completer.completeError(err),
          ),
        );

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;

            // ✅ Jika image kosong → tampilkan placeholder tanpa FutureBuilder
            if (imageUrl.isEmpty) {
              return SizedBox(
                width: maxWidth,
                child: Image.network(
                  safeUrl,
                  fit: BoxFit.cover,
                ),
              );
            }

            return FutureBuilder<ImageInfo>(
              future: _getImageInfo(safeUrl),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  );
                }

                final info = snapshot.data!;
                final aspectRatio = info.image.width / info.image.height;

                return InteractiveViewer(
                  maxScale: 3,
                  minScale: 1,
                  child: SizedBox(
                    width: maxWidth,
                    child: AspectRatio(
                      aspectRatio: aspectRatio,
                      child: Image.network(
                        safeUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),

        // CLOSE BUTTON
        Positioned(
          top: 40,
          right: 20,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 22, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
