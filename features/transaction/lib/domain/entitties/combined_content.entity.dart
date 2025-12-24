import 'package:transaction/domain/entitties/content_item.entity.dart';

/// Entity representing combined content for the POS UI: a muating flag
/// and the list of content items (packets + products).
class CombinedContent {
  final bool isLoadingCombined;
  final List<ContentItemEntity> items;

  const CombinedContent(
      {this.isLoadingCombined = false, this.items = const []});
}
