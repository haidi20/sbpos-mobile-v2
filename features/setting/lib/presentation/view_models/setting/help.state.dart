import 'package:core/core.dart';

@immutable
class FaqItemState {
  final String question;
  final String answer;
  final bool isExpanded;

  const FaqItemState({
    required this.question,
    required this.answer,
    required this.isExpanded,
  });

  FaqItemState copyWith({
    String? question,
    String? answer,
    bool? isExpanded,
  }) {
    return FaqItemState(
      question: question ?? this.question,
      answer: answer ?? this.answer,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

@immutable
class HelpState {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final List<FaqItemState> faqs;

  const HelpState({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.faqs,
  });

  const HelpState.initial()
      : title = 'Butuh Bantuan?',
        subtitle = 'Tim support kami siap membantu 24/7',
        buttonLabel = 'Chat WhatsApp',
        faqs = const [
          FaqItemState(
            question: 'Cara menghubungkan printer?',
            answer:
                'Pastikan perangkat printer sudah aktif dan terhubung, lalu buka halaman Printer & Struk untuk memilih printer yang tersedia.',
            isExpanded: false,
          ),
          FaqItemState(
            question: 'Bagaimana cara refund transaksi?',
            answer:
                'Saat ini alur refund belum tersedia di modul setting. Gunakan alur transaksi yang aktif di modul kasir.',
            isExpanded: false,
          ),
          FaqItemState(
            question: 'Lupa PIN akses?',
            answer:
                'Gunakan halaman Ubah PIN / Password dan ikuti prosedur internal outlet untuk penggantian akses.',
            isExpanded: false,
          ),
          FaqItemState(
            question: 'Cara export laporan ke Excel?',
            answer:
                'Fitur export laporan belum tersedia di modul setting saat ini dan akan memerlukan implementasi lanjutan.',
            isExpanded: false,
          ),
        ];

  HelpState copyWith({
    String? title,
    String? subtitle,
    String? buttonLabel,
    List<FaqItemState>? faqs,
  }) {
    return HelpState(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      buttonLabel: buttonLabel ?? this.buttonLabel,
      faqs: faqs ?? this.faqs,
    );
  }
}
