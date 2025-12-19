import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget editor teks stateless yang dapat digunakan ulang.
/// Semua properti dapat dikonfigurasi melalui parameter konstruktor
/// sehingga widget tetap stateless dan mudah digunakan kembali.
class FullScreenTextEditor extends StatelessWidget {
  final String title;
  final String actionLabel;
  final TextEditingController controller;
  final FutureOr<void> Function(String)? onSave;
  final String? hintText;
  final Color? backgroundColor;
  final Color? appBarColor;
  final Color? cursorColor;
  final TextStyle? titleTextStyle;
  final TextStyle? actionTextStyle;
  final List<Widget>? bottomActions;
  final double fontSize;
  final ValueNotifier<double>? fontSizeNotifier;
  final EdgeInsetsGeometry contentPadding;
  final FocusNode? focusNode;

  const FullScreenTextEditor({
    super.key,
    this.title = 'Catatan',
    this.actionLabel = 'SIMPAN',
    required this.controller,
    this.onSave,
    this.hintText,
    this.backgroundColor,
    this.appBarColor,
    this.cursorColor,
    this.titleTextStyle,
    this.actionTextStyle,
    this.bottomActions,
    this.fontSize = 16.0,
    this.fontSizeNotifier,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Colors.white;
    final appBarBg = appBarColor ?? bg;
    final cColor = cursorColor ?? Theme.of(context).primaryColor;

    const iconColor = Colors.black54;
    const List<IconData> defaultIconData = [
      Icons.keyboard,
      Icons.settings_outlined,
      Icons.more_horiz,
    ];

    final defaultActions = defaultIconData.map((iconData) {
      return _ToolbarAction(
        iconData: iconData,
        iconColor: iconColor,
        controller: controller,
        focusNode: focusNode,
        fontSizeNotifier: fontSizeNotifier,
        fontSize: fontSize,
      );
    }).toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        title: Text(
          title,
          style: titleTextStyle ??
              const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (onSave != null) {
                await onSave!(controller.text);
              } else {
                Navigator.maybePop(context, controller.text);
              }
            },
            child: Text(
              actionLabel,
              style: actionTextStyle ??
                  TextStyle(
                      color: Theme.of(context).primaryColor, fontSize: 14),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.zero,
              child: (fontSizeNotifier != null)
                  ? ValueListenableBuilder<double>(
                      valueListenable: fontSizeNotifier!,
                      builder: (ctx, fs, _) => TextField(
                        controller: controller,
                        cursorColor: cColor,
                        style: TextStyle(color: Colors.black87, fontSize: fs),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        expands: true,
                        decoration: InputDecoration(
                          hintText: hintText ?? '',
                          hintStyle: const TextStyle(color: Colors.black38),
                          border: InputBorder.none,
                          contentPadding: contentPadding,
                        ),
                      ),
                    )
                  : TextField(
                      controller: controller,
                      cursorColor: cColor,
                      style:
                          TextStyle(color: Colors.black87, fontSize: fontSize),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      expands: true,
                      decoration: InputDecoration(
                        hintText: hintText ?? '',
                        hintStyle: const TextStyle(color: Colors.black38),
                        border: InputBorder.none,
                        contentPadding: contentPadding,
                      ),
                    ),
            ),
          ),
          Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: bottomActions ?? defaultActions,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show this editor as a bottom-up modal sheet with rounded top corners
  /// and an iPhone-style grabber. The method handles popping the sheet
  /// after [onSave] completes.
  static Future<T?> showAsBottomSheet<T>(
    BuildContext context, {
    required TextEditingController controller,
    FutureOr<void> Function(String)? onSave,
    String title = 'Catatan',
    String? hintText,
    Color? backgroundColor,
    Color? appBarColor,
    Color? cursorColor,
    TextStyle? titleTextStyle,
    TextStyle? actionTextStyle,
    List<Widget>? bottomActions,
    double fontSize = 16.0,
    ValueNotifier<double>? fontSizeNotifier,
    EdgeInsetsGeometry contentPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
  }) {
    if (!context.mounted) return Future.value(null);

    final fsNotifier = fontSizeNotifier ?? ValueNotifier<double>(fontSize);
    final focus = FocusNode();

    // dispose the focus node after sheet closes
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.95,
        child: Material(
          color: backgroundColor ?? Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // grabber
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 6),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              // Small hint explaining how to open emoji via keyboard
              const _EditorHint(),

              Expanded(
                child: FullScreenTextEditor(
                  controller: controller,
                  onSave: (value) async {
                    if (onSave != null) await onSave(value);
                    if (ctx.mounted) Navigator.of(ctx).pop<T>(null);
                  },
                  title: title,
                  hintText: hintText,
                  backgroundColor: backgroundColor,
                  appBarColor: appBarColor,
                  cursorColor: cursorColor,
                  titleTextStyle: titleTextStyle,
                  actionTextStyle: actionTextStyle,
                  bottomActions: bottomActions,
                  contentPadding: contentPadding,
                  fontSize: fontSize,
                  fontSizeNotifier: fsNotifier,
                  focusNode: focus,
                ),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      try {
        focus.dispose();
      } catch (_) {}
    });
  }
}

/// Small informative hint shown under the sheet grabber.
/// Extracted to a private widget for easier testing and readability.
class _EditorHint extends StatelessWidget {
  const _EditorHint();

  @override
  Widget build(BuildContext context) {
    // const hint = 'Tekan ikon keyboard lalu pilih emoji dari keyboard HP';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 14,
            color:
                Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
          const SizedBox(width: 6),
          // Text(
          //   hint,
          //   style:
          //       Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
          // ),
        ],
      ),
    );
  }
}

/// Toolbar action encapsulated in a small widget to allow unit testing of
/// tooltip and onPressed behaviors separately from the editor layout.
class _ToolbarAction extends StatelessWidget {
  final IconData iconData;
  final Color iconColor;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueNotifier<double>? fontSizeNotifier;
  final double fontSize;

  const _ToolbarAction({
    required this.iconData,
    required this.iconColor,
    required this.controller,
    this.focusNode,
    this.fontSizeNotifier,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    // settings button needs live tooltip when notifier provided
    if (iconData == Icons.settings_outlined && fontSizeNotifier != null) {
      return ValueListenableBuilder<double>(
        valueListenable: fontSizeNotifier!,
        builder: (ctx, fs, _) => Tooltip(
          message: 'Ukuran font: ${fs.toInt()}',
          child: IconButton(
            onPressed: () async {
              if (!context.mounted) return;
              final sizes = [14, 16, 18, 20, 22, 24];
              final RenderBox box = context.findRenderObject() as RenderBox;
              final offset = box.localToGlobal(Offset.zero);
              final selected = await showMenu<int?>(
                context: context,
                position: RelativeRect.fromLTRB(
                  offset.dx,
                  offset.dy + box.size.height,
                  offset.dx + box.size.width,
                  offset.dy,
                ),
                items: sizes
                    .map((s) =>
                        PopupMenuItem<int>(value: s, child: Text('Ukuran $s')))
                    .toList(),
              );
              if (selected != null) {
                fontSizeNotifier!.value = selected.toDouble();
              }
              FocusManager.instance.primaryFocus?.unfocus();
            },
            icon: Icon(iconData),
            color: iconColor,
          ),
        ),
      );
    }

    final tooltipMsg = iconData == Icons.settings_outlined
        ? 'Ukuran font: ${fontSizeNotifier?.value ?? fontSize}'
        : iconData == Icons.keyboard
            ? 'Buka keyboard'
            : '';

    return Tooltip(
      message: tooltipMsg,
      child: IconButton(
        onPressed: () async {
          if (iconData == Icons.keyboard) {
            focusNode?.requestFocus();
            SystemChannels.textInput.invokeMethod('TextInput.show');
            return;
          }

          if (iconData == Icons.settings_outlined) {
            if (!context.mounted) {
              return;
            }
            final sizes = [14, 16, 18, 20, 22, 24];
            final RenderBox box = context.findRenderObject() as RenderBox;
            final offset = box.localToGlobal(Offset.zero);
            final selected = await showMenu<int?>(
              context: context,
              position: RelativeRect.fromLTRB(
                offset.dx,
                offset.dy + box.size.height,
                offset.dx + box.size.width,
                offset.dy,
              ),
              items: sizes
                  .map((s) =>
                      PopupMenuItem<int>(value: s, child: Text('Ukuran $s')))
                  .toList(),
            );
            if (selected != null) {
              if (fontSizeNotifier != null) {
                fontSizeNotifier!.value = selected.toDouble();
              }
            }
            FocusManager.instance.primaryFocus?.unfocus();
            return;
          }

          if (iconData == Icons.more_horiz) {
            if (!context.mounted) {
              return;
            }
            await showModalBottomSheet<void>(
              context: context,
              builder: (c) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.copy),
                      title: const Text('Copy semua'),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: controller.text));
                        Navigator.of(c).pop();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.select_all),
                      title: const Text('Pilih semua'),
                      onTap: () {
                        controller.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: controller.text.length);
                        Navigator.of(c).pop();
                      },
                    ),
                  ],
                ),
              ),
            );
            FocusManager.instance.primaryFocus?.unfocus();
            return;
          }
        },
        icon: Icon(iconData),
        color: iconColor,
      ),
    );
  }
}
